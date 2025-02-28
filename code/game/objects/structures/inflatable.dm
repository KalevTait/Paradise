/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/inflatable/detailed_examine()
	return "Inflate by using it in your hand. The inflatable barrier will inflate on your tile. To deflate it, use the 'deflate' verb."

/obj/item/inflatable/attack_self(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	var/obj/structure/inflatable/R = new /obj/structure/inflatable(user.loc)
	src.transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	max_integrity = 50
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"
	var/torn = /obj/item/inflatable/torn
	var/intact = /obj/item/inflatable

/obj/structure/inflatable/detailed_examine()
	return "To remove these safely, use the 'deflate' verb. Hitting these with any objects will probably puncture and break it forever."

/obj/structure/inflatable/Initialize(location)
	..()
	air_update_turf(TRUE)

/obj/structure/inflatable/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/inflatable/CanPass(atom/movable/mover, turf/target, height=0)
	return 0

/obj/structure/inflatable/CanAtmosPass(turf/T)
	return !density

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)

/obj/structure/inflatable/attackby(obj/item/I, mob/living/user, params)
	if(I.sharp || is_type_in_typecache(I, GLOB.pointed_types))
		user.do_attack_animation(src, used_item = I)
		deconstruct(FALSE)
		return FALSE
	return ..()

/obj/structure/inflatable/AltClick()
	if(usr.stat || usr.restrained())
		return
	if(!Adjacent(usr))
		return
	deconstruct(TRUE)

/obj/structure/inflatable/deconstruct(disassembled = TRUE)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(!disassembled)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		visible_message("[src] slowly deflates.")
		addtimer(CALLBACK(src, .proc/deflate), 5 SECONDS)

/obj/structure/inflatable/proc/deflate()
	var/obj/item/inflatable/R = new intact(loc)
	transfer_fingerprints_to(R)
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || usr.restrained())
		return

	deconstruct(TRUE)

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door"

/obj/item/inflatable/door/attack_self(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	var/obj/structure/inflatable/door/R = new /obj/structure/inflatable/door(user.loc)
	src.transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_closed"
	torn = /obj/item/inflatable/door/torn
	intact = /obj/item/inflatable/door

	var/state_open = FALSE
	var/isSwitchingStates = FALSE

/obj/structure/inflatable/door/detailed_examine()
	return "Click the door to open or close it. It only stops air while closed.<br>\
			To remove these safely, use the 'deflate' verb. Hitting these with any objects will probably puncture and break it forever."

/obj/structure/inflatable/door/attack_ai(mob/user as mob) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/CanAtmosPass(turf/T)
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(ismob(user))
		var/mob/M = user
		if(world.time - user.last_bumped <= 60)
			return //NOTE do we really need that?
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state_open)
		Close()
	else
		Open()
	air_update_turf(1)

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = TRUE
	//playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	flick("door_opening",src)
	sleep(10)
	density = FALSE
	opacity = FALSE
	state_open = TRUE
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = TRUE
	//playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	flick("door_closing",src)
	sleep(10)
	density = TRUE
	opacity = FALSE
	state_open = FALSE
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/inflatable/door/update_icon()
	if(state_open)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='warning'>The inflatable wall is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door_torn"

/obj/item/inflatable/door/torn/attack_self(mob/user)
	to_chat(user, "<span class='warning'>The inflatable door is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/inflatable)

/obj/item/storage/briefcase/inflatable/populate_contents()
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
