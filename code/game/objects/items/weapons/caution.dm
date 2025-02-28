/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/caution/proximity_sign
	var/timing = FALSE
	var/armed = FALSE
	var/timepassed = 0

/obj/item/caution/proximity_sign/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/proximity_monitor)

/obj/item/caution/proximity_sign/attack_self(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.assigned_role != "Janitor")
			return
		if(armed)
			armed = FALSE
			to_chat(user, "<span class='notice'>You disarm \the [src].</span>")
			return
		timing = !timing
		if(timing)
			START_PROCESSING(SSobj, src)
		else
			armed = FALSE
			timepassed = 0
		to_chat(H, "<span class='notice'>You [timing ? "activate \the [src]'s timer, you have 15 seconds." : "de-activate \the [src]'s timer."]</span>")

/obj/item/caution/proximity_sign/process()
	if(!timing)
		STOP_PROCESSING(SSobj, src)
	timepassed++
	if(timepassed >= 15 && !armed)
		armed = TRUE
		timing = FALSE

/obj/item/caution/proximity_sign/HasProximity(atom/movable/AM)
	if(armed)
		if(istype(AM, /mob/living/carbon) && !istype(AM, /mob/living/carbon/brain))
			var/mob/living/carbon/C = AM
			if(C.m_intent != MOVE_INTENT_WALK)
				src.visible_message("[src] beeps, \"Running on wet floors is hazardous to your health.\"")
				explosion(src.loc,-1,0,2)
				if(ishuman(C))
					dead_legs(C)
				if(src)
					qdel(src)

/obj/item/caution/proximity_sign/proc/dead_legs(mob/living/carbon/human/H as mob)
	var/obj/item/organ/external/l = H.get_organ("l_leg")
	var/obj/item/organ/external/r = H.get_organ("r_leg")
	if(l)
		l.droplimb(0, DROPLIMB_SHARP)
	if(r)
		r.droplimb(0, DROPLIMB_SHARP)
