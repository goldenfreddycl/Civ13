/obj/structure/transport_lever // same icon as the train lever for now
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/vehicles/train_lever.dmi'
	icon_state = "lever_none"
	var/none_state = "lever_none" // Icon for when the transport object is not being used
	var/pushed_state = "lever_pulled" // Icon for when the transport object is used
	var/depart_sound = 'sound/landing_craft.ogg' // Sound for when the transport leaves

	name = "Landing Craft control"
	var/position = "docked" // Where the transport is
	var/next_activation = -1;

/obj/structure/transport_lever/attack_hand(var/mob/user as mob)
//f (user && istype(user, /mob/living/human))
//function(user)
	if (world.time < next_activation)
		next_activation = world.time + 50
		visible_message("This Landing Craft isn't ready to depart yet.</span>")
	else
		next_activation = world.time + 400 //to give it time to reach the destination
		for (var/mob/M in range(10, src))
			M.playsound_local(get_turf(M), depart_sound, 100 - get_dist(M, src))
		if (position == "docked")
			visible_message("The Landing Craft is departing!</span>")
			if (icon_state == none_state)
				icon_state = pushed_state
			for (var/turf/floor/plating/concrete/T in range(10, src))
				T.opacity = TRUE
				T.density = TRUE
			spawn (3)
				icon_state = none_state
			spawn (200)
				for (var/mob/M in range(5, src))
					if (M.z == 1)
						M.z = 2
					else if (M.z == 2)
						M.z = 1
				for (var/obj/O in range(5, src))
					if (O.z == 1)
						O.z = 2
					else if (O.z == 2)
						O.z = 1
				visible_message("The Landing Craft has arrived.</span>")
				spawn(5)
					for (var/turf/floor/plating/concrete/T in range(10, src))
						T.opacity = FALSE
						T.density = FALSE
				spawn (400)
					if (z == 1)
						visible_message("The Landing Craft is returning!</span>")
						for (var/mob/M in range(10, src))
							M.playsound_local(get_turf(M), 'sound/landing_craft.ogg', 100 - get_dist(M, src))
						for (var/mob/M in range(5, src))
							if (M.z == 1)
								M.z = 2
							else if (M.z == 1)
								M.z = 2
						for (var/obj/O in range(5, src))
							if ((O.anchored == FALSE) || istype(O, /obj/structure/transport_lever))
								if (O.z == 1)
									O.z = 2
								else if (O.z == 1)
									O.z = 2
						z = 2
					spawn(5)
						for (var/turf/floor/plating/concrete/T in range(10, src))
							T.opacity = FALSE
							T.density = FALSE
			position = "launched"
		else if (position == "launched")
			visible_message("The Landing Craft is departing!</span>")
			if (icon_state == none_state)
				icon_state = pushed_state
			for (var/turf/floor/plating/concrete/T in range(10, src))
				T.opacity = TRUE
				T.density = TRUE
			position = "docked"
			spawn (3)
				icon_state = none_state
			spawn (200)
				for (var/mob/M in range(5, src))
					if (M.z == 1)
						M.z = 2
					else if (M.z == 2)
						M.z = 1
				for (var/obj/O in range(5, src))
					if ((O.anchored == FALSE) || istype(O, /obj/structure/transport_lever))
						if (O.z == 1)
							O.z = 2
						else if (O.z == 2)
							O.z = 1
				visible_message("The Landing Craft has arrived.</span>")
				spawn(5)
					for (var/turf/floor/plating/concrete/T in range(10, src))
						T.opacity = FALSE
						T.density = FALSE
				spawn (400)
					if (z == 1)
						visible_message("The Landing Craft is returning!</span>")
						for (var/mob/M in range(10, src))
							M.playsound_local(get_turf(M), 'sound/landing_craft.ogg', 100 - get_dist(M, src))
						for (var/mob/M in range(5, src))
							if (M.z == 1)
								M.z = 2
							else if (M.z == 1)
								M.z = 2
						for (var/obj/O in range(5, src))
							if ((O.anchored == FALSE) || istype(O, /obj/structure/transport_lever))
								if (O.z == 1)
									O.z = 2
								else if (O.z == 1)
									O.z = 2
						z = 2
					spawn(5)
						for (var/turf/floor/plating/concrete/T in range(10, src))
							T.opacity = FALSE
							T.density = FALSE

/obj/structure/aircraft_lever // same icon as the train lever for now
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/vehicles/train_lever.dmi'
	icon_state = "lever_none"
	var/none_state = "lever_none" // Icon for when the transport object is not being used
	var/pushed_state = "lever_pulled" // Icon for when the transport object is used
	var/depart_sound = 'sound/landing_craft.ogg' // Sound for when the transport leaves

	name = "Aircraft control"
	var/position = "landed" // Where the transport is
	var/next_activation = -1;

/obj/structure/aircraft_lever/attack_hand(var/mob/user as mob)
//f (user && istype(user, /mob/living/human))
//function(user)
	if (world.time < next_activation)
		next_activation = world.time + 50
		visible_message("The aircraft isn't ready to take off yet.</span>")
	else
		next_activation = world.time + 400 //to give it time to reach the destination
		for (var/mob/M in range(10, src))
			M.playsound_local(get_turf(M), depart_sound, 100 - get_dist(M, src))
		if (position == "landed")
			visible_message("The aircraft is taking off!</span>")
			if (icon_state == none_state) // Push lever
				icon_state = pushed_state
			for (var/turf/floor/plating/concrete/T in range(10, src))
				T.opacity = TRUE
				T.density = TRUE
			spawn (3)
				icon_state = none_state // Reset lever
			spawn (200)
				for (var/mob/M in range(5, src))
					if (M.z == 1)
						M.z = 2
					else if (M.z == 2)
						M.z = 1
				for (var/obj/O in range(5, src))
					if (O.z == 1)
						O.z = 2
					else if (O.z == 2)
						O.z = 1
				visible_message("The aircraft has arrived.</span>")
				spawn(5)
					for (var/turf/floor/plating/concrete/T in range(10, src))
						T.opacity = FALSE
						T.density = FALSE
				spawn (400)
					if (z == 1)
						visible_message("The aircraft is returning!</span>")
						for (var/mob/M in range(10, src))
							M.playsound_local(get_turf(M), 'sound/landing_craft.ogg', 100 - get_dist(M, src))
						for (var/mob/M in range(5, src))
							if (M.z == 1)
								M.z = 2
							else if (M.z == 1)
								M.z = 2
						for (var/obj/O in range(5, src))
							if ((O.anchored == FALSE) || istype(O, /obj/structure/transport_lever))
								if (O.z == 1)
									O.z = 2
								else if (O.z == 1)
									O.z = 2
						z = 2
					spawn(5)
						for (var/turf/floor/plating/concrete/T in range(10, src))
							T.opacity = FALSE
							T.density = FALSE
			position = "launched"
		else if (position == "launched")
			visible_message("The Landing Craft is departing!</span>")
			if (icon_state == none_state) // Push lever
				icon_state = pushed_state
			for (var/turf/floor/plating/concrete/T in range(10, src))
				T.opacity = TRUE
				T.density = TRUE
			position = "landed"
			spawn (3)
				icon_state = none_state // Reset lever
			spawn (200)
				for (var/mob/M in range(5, src))
					if (M.z == 1)
						M.z = 2
					else if (M.z == 2)
						M.z = 1
				for (var/obj/O in range(5, src))
					if ((O.anchored == FALSE) || istype(O, /obj/structure/transport_lever))
						if (O.z == 1)
							O.z = 2
						else if (O.z == 2)
							O.z = 1
				visible_message("The aircraft has arrived.</span>")
				spawn(5)
					for (var/turf/floor/plating/concrete/T in range(10, src))
						T.opacity = FALSE
						T.density = FALSE
				spawn (400)
					if (z == 1)
						visible_message("The aircraft is returning!</span>")
						for (var/mob/M in range(10, src))
							M.playsound_local(get_turf(M), 'sound/landing_craft.ogg', 100 - get_dist(M, src))
						for (var/mob/M in range(5, src))
							if (M.z == 1)
								M.z = 2
							else if (M.z == 1)
								M.z = 2
						for (var/obj/O in range(5, src))
							if ((O.anchored == FALSE) || istype(O, /obj/structure/transport_lever))
								if (O.z == 1)
									O.z = 2
								else if (O.z == 1)
									O.z = 2
						z = 2
					spawn(5)
						for (var/turf/floor/plating/concrete/T in range(10, src))
							T.opacity = FALSE
							T.density = FALSE