/mob/living/human/proc/update_eyes()
	var/obj/item/organ/eyes/eyes = internal_organs_by_name["eyes"]
	if (eyes)
		eyes.update_colour()
		regenerate_icons()

/mob/living/human/var/list/internal_organs = list()
/mob/living/human/var/list/organs = list()
/mob/living/human/var/list/organs_by_name = list() // map organ names to organs
/mob/living/human/var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/human/proc/handle_organs()

	var/force_process = FALSE
	var/damage_this_tick = getBruteLoss() + getBurnLoss() + getToxLoss()
	if (damage_this_tick > last_dam)
		force_process = TRUE
	last_dam = damage_this_tick
	if (force_process)
		bad_external_organs.Cut()
		for (var/obj/item/organ/external/Ex in organs)
			bad_external_organs |= Ex

	//processing internal organs is pretty cheap, do that first.
	for (var/obj/item/organ/I in internal_organs)
		I.process()

	handle_stance()
	handle_grasp()

	if (!force_process && !bad_external_organs.len)
		return

	for (var/obj/item/organ/external/E in bad_external_organs)
		if (!E)
			continue
		if (!E.need_process())
			bad_external_organs -= E
			continue
		else
			E.process()

			if (!lying && !buckled && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if (E.is_broken() && E.internal_organs && E.internal_organs.len && prob(15))
					var/obj/item/organ/I = pick(E.internal_organs)
					custom_pain("You feel broken bones moving in your [E.name]!", 55)
					I.take_damage(rand(3,5))

	var/limbs_count = 4
	var/obj/item/organ/external/E = organs_by_name["l_foot"]
	if (E)
		if (E.status & ORGAN_DESTROYED)
			limbs_count--

		E = organs_by_name["r_foot"]
		if (!E || (E.status & ORGAN_DESTROYED))
			limbs_count--

		E = organs_by_name["r_hand"]
		if (!E || (E.status & ORGAN_DESTROYED))
			limbs_count--

		E = organs_by_name["l_hand"]
		if (!E || (E.status & ORGAN_DESTROYED))
			limbs_count--

		if (limbs_count == FALSE)
			has_limbs = FALSE

/mob/living/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if (!stance_damage && (lying || resting || prone) && (life_tick % 4) == FALSE)
		return

	stance_damage = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	if (istype(buckled, /obj/structure/bed))
		return

	var/limb_pain
	for (var/limb_tag in list("l_leg","r_leg","l_foot","r_foot"))
		var/obj/item/organ/external/E = organs_by_name[limb_tag]
		if (!E || (E.status & (ORGAN_MUTATED|ORGAN_DEAD)) || E.is_stump()) //should just be !E.is_usable() here but dislocation screws that up.
			stance_damage += 2 // let it fail even if just foot&leg
		else if (E.is_broken() || !E.is_usable())
			stance_damage += 1
		else if (E.is_dislocated())
			stance_damage += 0.5
		
		if(E) limb_pain = E.can_feel_pain()

	// Canes and crutches help you stand (if the latter is ever added)
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs, canes aren't gonna help you.
	if (l_hand && istype(l_hand, ((/obj/item/weapon/cane)||(/obj/item/weapon/material/fancycane))))
		stance_damage -= 2
	if (r_hand && istype(r_hand, ((/obj/item/weapon/cane)||(/obj/item/weapon/material/fancycane))))
		stance_damage -= 2
	var/obj/item/organ/external/LL = get_organ("l_leg")
	if (LL && LL.prosthesis)
		if (LL.prosthesis_type == "pegleg")
			stance_damage -= 3
		if (LL.prosthesis_type == "woodleg")
			stance_damage -= 4
	var/obj/item/organ/external/RL = get_organ("r_leg")
	if (RL && RL.prosthesis)
		if (RL.prosthesis_type == "pegleg")
			stance_damage -= 3
		if (RL.prosthesis_type == "woodleg")
			stance_damage -= 4
	var/obj/item/organ/external/LF = get_organ("l_foot")
	if (LF && LF.prosthesis)
		if (LF.prosthesis_type == "woodfoot")
			stance_damage -= 3

	var/obj/item/organ/external/RF = get_organ("r_foot")
	if (RF && RF.prosthesis)
		if (RF.prosthesis_type == "woodfoot")
			stance_damage -= 3

	// standing is poor
	if (stance_damage >= 4 || (stance_damage >= 2 && prob(5)))
		if (!(lying || resting || prone))
			if (limb_pain)
				emote("painscream")
			custom_emote(1, "collapses!")
		Weaken(5) //can't emote while weakened, apparently.

/mob/living/human/proc/handle_grasp()
	if (!l_hand && !r_hand)
		return

	// You should not be able to pick anything up, but stranger things have happened.
	if (l_hand)
		for (var/limb_tag in list("l_hand","l_arm"))
			var/obj/item/organ/external/E = get_organ(limb_tag)
			if (!E)
				visible_message("<span class='danger'>Lacking a functioning left hand, \the [src] drops \the [l_hand].</span>")
				drop_from_inventory(l_hand)
				break

	if (r_hand)
		for (var/limb_tag in list("r_hand","r_arm"))
			var/obj/item/organ/external/E = get_organ(limb_tag)
			if (!E)
				visible_message("<span class='danger'>Lacking a functioning right hand, \the [src] drops \the [r_hand].</span>")
				drop_from_inventory(r_hand)
				break

	// Check again...
	if (!l_hand && !r_hand)
		return

	for (var/obj/item/organ/external/E in organs)
		if (!E || !E.can_grasp || (E.status & ORGAN_SPLINTED))
			continue

		if (E.is_broken() || E.is_dislocated())
			switch(E.body_part)
				if (HAND_LEFT, ARM_LEFT)
					if (!l_hand)
						continue
					drop_from_inventory(l_hand)
				if (HAND_RIGHT, ARM_RIGHT)
					if (!r_hand)
						continue
					drop_from_inventory(r_hand)

			var/emote_scream = pick("screams in pain and ", "lets out a sharp cry and ", "cries out and ")
			emote("me", TRUE, "[(species.flags & NO_PAIN) ? "" : emote_scream ]drops what they were holding in their [E.name]!")

//Handles chem traces
/mob/living/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for (var/datum/reagent/A in reagents.reagent_list)
		var/obj/item/organ/O = pick(organs)
		O.trace_chemicals[A.name] = 100

/mob/living/human/proc/sync_organ_dna()
	var/list/all_bits = internal_organs|organs
	for (var/obj/item/organ/O in all_bits)
		O.set_dna(dna)

/mob/living/proc/is_asystole()
	return FALSE

/mob/living/human/is_asystole()
	var/obj/item/organ/heart/heart = internal_organs_by_name["heart"]
	if(!istype(heart) || !heart.is_working())
		return TRUE
	return FALSE