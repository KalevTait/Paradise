/obj/item/gun/throw/piecannon
	name = "pie cannon"
	desc = "A projectile weapon that fires pies."
	icon_state = "piecannon"
	w_class = WEIGHT_CLASS_HUGE
	throw_speed = 2
	throw_range = 3
	force = 5

	clumsy_check = FALSE
	valid_projectile_type = /obj/item/reagent_containers/food/snacks/pie
	max_capacity = 5
	projectile_speed = 2
	projectile_range = 30


/obj/item/gun/throw/piecannon/New()
	..()
	for(var/i in 1 to max_capacity)
		var/obj/item/reagent_containers/food/snacks/pie/P = new /obj/item/reagent_containers/food/snacks/pie(src)
		loaded_projectiles += P
	process_chamber()

/obj/item/gun/throw/piecannon/notify_ammo_count()
	return "<span class='notice'>[src] has [get_ammocount()] of [max_capacity] pies left.</span>"

/obj/item/gun/throw/piecannon/update_icon()
	if(to_launch)
		icon_state = "piecannon1"
	else
		icon_state = "piecannon0"
	item_state = icon_state

/obj/item/gun/throw/piecannon/process_chamber()
	..()
	update_icon()
