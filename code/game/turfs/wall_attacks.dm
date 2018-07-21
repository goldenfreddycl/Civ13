//Interactions
/turf/wall/proc/toggle_open(var/mob/user)

	if (can_open == WALL_OPENING)
		return

	if (density)
		can_open = WALL_OPENING
		//flick("[material.icon_base]fwall_opening", src)
		sleep(15)
		density = FALSE
		opacity = FALSE
		update_icon()
		set_light(0)
	else
		can_open = WALL_OPENING
		//flick("[material.icon_base]fwall_closing", src)
		density = TRUE
		opacity = TRUE
		update_icon()
		sleep(15)
		set_light(1)

	can_open = WALL_CAN_OPEN
	update_icon()

/turf/wall/proc/fail_smash(var/mob/user)
	user << "<span class='danger'>You smash against the wall!</span>"
	take_damage(rand(25,75))

/turf/wall/proc/success_smash(var/mob/user)
	user << "<span class='danger'>You smash through the wall!</span>"
	user.do_attack_animation(src)
	spawn(1)
		dismantle_wall(1)

/turf/wall/proc/try_touch(var/mob/user, var/rotting)

	if (rotting)
		if (reinf_material)
			user << "<span class='danger'>\The [reinf_material.display_name] feels porous and crumbly.</span>"
		else
			user << "<span class='danger'>\The [material.display_name] crumbles under your touch!</span>"
			dismantle_wall()
			return TRUE

	if (..()) return TRUE

	if (!can_open)
		user << "<span class='notice'>You push the wall, but nothing happens.</span>"
		playsound(src, hitsound, 25, TRUE)
	else
		toggle_open(user)
	return FALSE


/turf/wall/attack_hand(var/mob/user)

	radiate()
	add_fingerprint(user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if (HULK in user.mutations)
		if (rotting || !prob(material.hardness))
			success_smash(user)
		else
			fail_smash(user)
			return TRUE

	try_touch(user, rotting)

/turf/wall/attack_generic(var/mob/user, var/damage, var/attack_message, var/wallbreaker)

	radiate()
	if (!istype(user))
		return

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if (!damage || !wallbreaker)
		try_touch(user, rotting)
		return

	if (rotting)
		return success_smash(user)

	if (reinf_material)
		if ((wallbreaker == 2) || (damage >= max(material.hardness,reinf_material.hardness)))
			return success_smash(user)
	else if (damage >= material.hardness)
		return success_smash(user)
	return fail_smash(user)

/turf/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if (istype(src, /turf/wall/indestructable))
		return
	else return ..()

	// this code is no longer used - you need c4 to get through walls now - Kachnov

	/* not sure what this shitcode is so its disabled - Kachnov
	if (!user.)
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return*/

	//get the user's location
	if (!istype(user.loc, /turf))	return	//can't do this stuff whilst inside objects and such

	if (W)
		radiate()
		if (is_hot(W))
			burn(is_hot(W))


	//THERMITE related stuff. Calls thermitemelt() which handles melting walls and the relevant effects
/*	if (thermite)
		if ( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if ( WT.remove_fuel(0,user) )
				thermitemelt(user)
				return


		else */

	var/turf/T = user.loc	//get user's location for delay checks


	// Basic dismantling.
	if (isnull(construction_stage) || !reinf_material)

		var/cut_delay = 60 - material.cut_delay
		var/dismantle_verb
		var/dismantle_sound

		if (istype(W,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if (!WT.isOn())
				return
			if (!WT.remove_fuel(0,user))
				user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return
			dismantle_verb = "cutting"
			dismantle_sound = 'sound/items/Welder.ogg'
			cut_delay *= 0.7

		if (dismantle_verb)

			user << "<span class='notice'>You begin [dismantle_verb] through the outer plating.</span>"
			if (dismantle_sound)
				playsound(src, dismantle_sound, 100, TRUE)

			if (cut_delay<0)
				cut_delay = FALSE

			if (!do_after(user,cut_delay,src))
				return

			user << "<span class='notice'>You remove the outer plating.</span>"
			dismantle_wall()
			user.visible_message("<span class='warning'>The wall was torn open by [user]!</span>")
			return

	//Reinforced dismantling.
	else
		switch(construction_stage)
			if (6)
				if (istype(W, /obj/item/weapon/wirecutters))
					playsound(src, 'sound/items/Wirecutter.ogg', 100, TRUE)
					construction_stage = 5
					new /obj/item/stack/rods( src )
					user << "<span class='notice'>You cut the outer grille.</span>"
					update_icon()
					return
			if (5)
				if (istype(W, /obj/item/weapon/screwdriver))
					user << "<span class='notice'>You begin removing the support lines.</span>"
					playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
					if (!do_after(user,40,src) || !istype(src, /turf/wall) || construction_stage != 5)
						return
					construction_stage = 4
					update_icon()
					user << "<span class='notice'>You remove the support lines.</span>"
					return
				else if ( istype(W, /obj/item/stack/rods) )
					var/obj/item/stack/O = W
					if (O.get_amount()>0)
						O.use(1)
						construction_stage = 6
						update_icon()
						user << "<span class='notice'>You replace the outer grille.</span>"
						return
			if (4)
				var/cut_cover
				if (istype(W,/obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = W
					if (!WT.isOn())
						return
					if (WT.remove_fuel(0,user))
						cut_cover=1
					else
						user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
						return
				if (cut_cover)
					user << "<span class='notice'>You begin slicing through the metal cover.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, TRUE)
					if (!do_after(user, 60, src) || !istype(src, /turf/wall) || construction_stage != 4)
						return
					construction_stage = 3
					update_icon()
					user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
					return
			if (3)
				if (istype(W, /obj/item/weapon/crowbar))
					user << "<span class='notice'>You struggle to pry off the cover.</span>"
					playsound(src, 'sound/items/Crowbar.ogg', 100, TRUE)
					if (!do_after(user,100,src) || !istype(src, /turf/wall) || construction_stage != 3)
						return
					construction_stage = 2
					update_icon()
					user << "<span class='notice'>You pry off the cover.</span>"
					return
			if (2)
				if (istype(W, /obj/item/weapon/wrench))
					user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>"
					playsound(src, 'sound/items/Ratchet.ogg', 100, TRUE)
					if (!do_after(user,40,src) || !istype(src, /turf/wall) || construction_stage != 2)
						return
					construction_stage = TRUE
					update_icon()
					user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
					return
			if (1)
				var/cut_cover
				if (istype(W, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = W
					if ( WT.remove_fuel(0,user) )
						cut_cover=1
					else
						user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
						return
				if (cut_cover)
					user << "<span class='notice'>You begin slicing through the support rods.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, TRUE)
					if (!do_after(user,70,src) || !istype(src, /turf/wall) || construction_stage != TRUE)
						return
					construction_stage = FALSE
					update_icon()
					new /obj/item/stack/rods(src)
					user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
					return
			if (0)
				if (istype(W, /obj/item/weapon/crowbar))
					user << "<span class='notice'>You struggle to pry off the outer sheath.</span>"
					playsound(src, 'sound/items/Crowbar.ogg', 100, TRUE)
					sleep(100)
					if (!istype(src, /turf/wall) || !user || !W || !T )	return
					if (user.loc == T && user.get_active_hand() == W )
						user << "<span class='notice'>You pry off the outer sheath.</span>"
						dismantle_wall()
					return
/*
	if (istype(W,/obj/item/frame))
		var/obj/item/frame/F = W
		F.try_build(src)
		return*/

	if (!istype(W, /obj/item/weapon/reagent_containers))
		if (!W.force)
			return attack_hand(user)
		var/dam_threshhold = material.integrity
		if (reinf_material)
			dam_threshhold = ceil(max(dam_threshhold,reinf_material.integrity)/2)
		var/dam_prob = min(100,material.hardness*1.5)
		if (dam_prob < 100 && W.force > (dam_threshhold/10))
			playsound(src, hitsound, 80, TRUE)
			if (!prob(dam_prob))
				visible_message("<span class='danger'>\The [user] attacks \the [src] with \the [W] and it [material.destruction_desc]!</span>")
				dismantle_wall(1)
			else
				visible_message("<span class='danger'>\The [user] attacks \the [src] with \the [W]!</span>")
		else
			visible_message("<span class='danger'>\The [user] attacks \the [src] with \the [W], but it bounces off!</span>")
		return
