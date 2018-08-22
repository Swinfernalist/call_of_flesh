//#define TURNTABLE_CHANNEL 4488
var/global/turntable_channel = 4488
/*
/mob/var/datum/hear_music/hear_music
#define NONE_MUSIC 0
#define UPLOADING 1
#define PLAYING 2

/datum/hear_music
	var/mob/target = null
	//var/sound/sound
	var/status = NONE_MUSIC
	var/stop = 0

	proc/play(sound/S)
		status = NONE_MUSIC
		if(!target)
			return
		if(!S)
			return
		status = UPLOADING
		target << browse_rsc(S)
		//sound = S
		if(target.hear_music != src)
			qdel(src)
		if(!stop)
			target << S
			status = PLAYING
		else
			qdel(src)

	proc/stop()
		if(!target)
			return
		if(status == PLAYING)
			var/sound/S = sound(null)
			S.channel = 10
			S.wait = 1
			target << S
			qdel(src)
		else if(status == UPLOADING)
			stop = 1
		target.hear_music = null

*/
/mob/var/sound/music
/client/var/jukeboxplaying = 0

/datum/data/turntable_soundtrack
	var/f_name
	var/path
	var/length

/datum/data/turntable_soundtrack/New(f_name, name, path, length)
	src.f_name = f_name
	src.name = name
	src.path = path
	src.length = length

/obj/machinery/party/turntable
	name = "Jukebox"
	desc = "A jukebox is a partially automated music-playing device, usually a coin-operated machine, that will play a patron's selection from self-contained media."
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "Jukebox7"
	var/timer_id = 0
	var/play_song_cost = 1000
	var/skip_song_cost = 500
	var/start_time = 0
	var/collected_money = 0
	var/music_channel = 0
	var/obj/item/weapon/disk/music/disk
	var/playing = 1
	var/datum/data/turntable_soundtrack/track = null
	var/volume = 50
	var/list/mob/melomans = list()
	var/list/turntable_soundtracks = list(

		new /datum/data/turntable_soundtrack ("5nizza",				"Ya Soldat",						'sound/turntable/5nizza_ya_soldat.ogg',						2110),
		new /datum/data/turntable_soundtrack ("Addaraya",			"Gurza Dreaming",					'sound/turntable/gurza_dreaming.ogg',						2420),
		new /datum/data/turntable_soundtrack ("Bandits",			"Cheeki Breeki",					'sound/turntable/bandit_radio.ogg',							1110),
		new /datum/data/turntable_soundtrack ("Firelake",			"Fighting Unknown",					'sound/turntable/agroprom.ogg',								710),
		new /datum/data/turntable_soundtrack ("Firelake",			"Dirge For The Planet",				'sound/turntable/dirge_for_the_planet.ogg',					2850),
		new /datum/data/turntable_soundtrack ("Firelake",			"Live To Forget",					'sound/turntable/live_to_forget.ogg',						2960),
		new /datum/data/turntable_soundtrack ("Freedom",			"Smoke Weed",						'sound/turntable/freedom_radio.ogg',						1140),
		new /datum/data/turntable_soundtrack ("Krug M.",			"Kolschik",							'sound/turntable/kolshik.ogg',								2850),
		new /datum/data/turntable_soundtrack ("Butirka",			"Butirskaya Turma",					'sound/turntable/butirka.ogg',								1920),
		new /datum/data/turntable_soundtrack ("Gazmanov M.",		"Putana",							'sound/turntable/putana.ogg',								2460),
		new /datum/data/turntable_soundtrack ("Leps G.",			"Rumka Vodki Na Stole",				'sound/turntable/rumka.ogg',								2360),
		new /datum/data/turntable_soundtrack ("Aksenov V.",			"Murka",							'sound/turntable/murka.ogg',								3220),
		new /datum/data/turntable_soundtrack ("Rozenbaum A",		"Dagomis",							'sound/turntable/gopstop.ogg',								2450),
		new /datum/data/turntable_soundtrack ("Dispetchera",		"2000 Baksov",						'sound/turntable/2000_baksov.ogg',							2430),
		new /datum/data/turntable_soundtrack ("Agata Kristi",		"Kak Na Voine",						'sound/turntable/agata_kristi_na_voine.ogg',				2470),
		new /datum/data/turntable_soundtrack ("Alai Oli",			"Krilya",							'sound/turntable/alai_oli_krilya.ogg',						2150),
		new /datum/data/turntable_soundtrack ("Ariya",				"Bespechniy Angel",					'sound/turntable/ariya_bespechniy_angel.ogg',				2380),
		new /datum/data/turntable_soundtrack ("Ariya",				"Potyeraniy Ray",					'sound/turntable/ariya_poteryaniy_ray.ogg',					3530),
		new /datum/data/turntable_soundtrack ("Ariya",				"Ya Svoboden",						'sound/turntable/ariya_ya_svoboden.ogg',					3540),
		new /datum/data/turntable_soundtrack ("Bi2",				"Polkovnik",						'sound/turntable/bi2_polkovnik.ogg',						2640),
		new /datum/data/turntable_soundtrack ("Bi2",				"Serebro",							'sound/turntable/bi2_serebro.ogg',							2770),
		new /datum/data/turntable_soundtrack ("Bi2",				"Varvara",							'sound/turntable/bi2_varvara.ogg',							2990),
		new /datum/data/turntable_soundtrack ("4 pozicii bruno",	"Ya Ehala Domoy",					'sound/turntable/chetire_pozigii_bruno_ya_ehala_domoy.ogg',	2740),
		new /datum/data/turntable_soundtrack ("DDT",				"Osen",								'sound/turntable/ddt_osen.ogg',								2350),
		new /datum/data/turntable_soundtrack ("Delfin",				"Nadezhda",							'sound/turntable/delfin_nadezhda.ogg',						2690),
		new /datum/data/turntable_soundtrack ("Delfin",				"Sneg",								'sound/turntable/delfin_sneg.ogg',							1820),
		new /datum/data/turntable_soundtrack ("Delfin",				"Vesna",							'sound/turntable/delfin_vesna.ogg',							2910),
		new /datum/data/turntable_soundtrack ("Delfin",				"Ya Lublu Ludey",					'sound/turntable/delfin_ya_lublu_ludey.ogg',				2120),
		new /datum/data/turntable_soundtrack ("Electroforez",		"Eshafot",							'sound/turntable/elektroforez_eshafot.ogg',					2090),
		new /datum/data/turntable_soundtrack ("Elizium",			"Stoit Zhit",						'sound/turntable/elizium_stoit_zhit.ogg',					1800),
		new /datum/data/turntable_soundtrack ("Fleetwood Mac",		"Little Lies",						'sound/turntable/fleetwood_mac_little_lies.ogg',			2210),
		new /datum/data/turntable_soundtrack ("Kino",				"Gruppa Krovy",						'sound/turntable/kino_gruppa_krovi.ogg',					2030),
		new /datum/data/turntable_soundtrack ("Kino",				"Zvezda Po Imeni Soltnse",			'sound/turntable/kino_zvezda_po_imeni_solntse.ogg',			2245),
		new /datum/data/turntable_soundtrack ("Korol I Shut",		"Kukla kolduna",					'sound/turntable/korol_i_shut_kukila_kolduna.ogg',			2040),
		new /datum/data/turntable_soundtrack ("Korol I Shut",		"Lesnik",							'sound/turntable/korol_i_shut_lesnik.ogg',					1910),
		new /datum/data/turntable_soundtrack ("Krovostok",			"Kurtec",							'sound/turntable/krovostok_kurtec.ogg',						2400),
		new /datum/data/turntable_soundtrack ("Leprikonsy",			"Hali-Gali, Paratruper",			'sound/turntable/leprikonsy_paratruper.ogg',				2060),
		new /datum/data/turntable_soundtrack ("Lumen",				"Sid i Nensi",						'sound/turntable/lumen_sid_i_nensi.ogg',					2340),
		new /datum/data/turntable_soundtrack ("Monokini",			"Adrenalin",						'sound/turntable/monokini_adrenalin.ogg',					1970),
		new /datum/data/turntable_soundtrack ("Monokini",			"Dotyanusya Do Solntsa",			'sound/turntable/monokini_dotyanutsya_do_solntsa.ogg',		1600),
		new /datum/data/turntable_soundtrack ("Mucuraev",			"O Allah",							'sound/turntable/mucuraev_o_allah.ogg',						3970),
		new /datum/data/turntable_soundtrack ("Mumiy Troll",		"Delfiny",							'sound/turntable/mumiy_troll_delfiny.ogg',					2780),
		new /datum/data/turntable_soundtrack ("Mumiy Troll",		"Utekay",							'sound/turntable/mumiy_troll_utekay.ogg',					1410),
		new /datum/data/turntable_soundtrack ("Mumiy Troll",		"Vladivostok 2000",					'sound/turntable/mumiy_troll_vladivostok2000.ogg',			1610),
		new /datum/data/turntable_soundtrack ("Nautilus Pomilius",	"Apostol Andrey",					'sound/turntable/nautilus_pompilius_apostol_andrey.ogg',	2170),
		new /datum/data/turntable_soundtrack ("Nautilus Pomilius",	"Krylya",							'sound/turntable/nautilus_pompilius_krylya.ogg',			2080),
		new /datum/data/turntable_soundtrack ("Nautilus Pomilius",	"Skovanie",							'sound/turntable/nautilus_pompilius_skovanye.ogg',			2530),
		new /datum/data/turntable_soundtrack ("Nautilus Pomilius",	"Ya hochu byt s toboy",				'sound/turntable/nautilus_pompilius_ya_hochu_byt_s_toboy.ogg',2710),
		new /datum/data/turntable_soundtrack ("Okean Elxi",			"Obime",							'sound/turntable/okean_elzi_obime.ogg',						2260),
		new /datum/data/turntable_soundtrack ("Oken Elzi",			"Vidpusti",							'sound/turntable/okean_elzi_vidpusti.ogg',					2300),
		new /datum/data/turntable_soundtrack ("Phil Collins",		"In The Air Tonight",				'sound/turntable/phil_collins_in_the_air_tonight.ogg',		3300),
		new /datum/data/turntable_soundtrack ("Propaganda",			"Belim Melom",						'sound/turntable/propaganda_belim_melom.ogg',				1740),
		new /datum/data/turntable_soundtrack ("Gazmanov O.",		"Putana",							'sound/turntable/putana.ogg',								2460),
		new /datum/data/turntable_soundtrack ("Ranetki",			"O tebe",							'sound/turntable/ranetki_o_tebe.ogg',						1650),
		new /datum/data/turntable_soundtrack ("Ranetki",			"Ona odna",							'sound/turntable/ranetki_ona_odna.ogg',						1640),
		new /datum/data/turntable_soundtrack ("7B",					"Molodie Vetra",					'sound/turntable/semb_molodie_vetra.ogg',					2610),
		new /datum/data/turntable_soundtrack ("Shnurov",			"Mobilnik",							'sound/turntable/shnurov_mobilnik.ogg',						1680),
		new /datum/data/turntable_soundtrack ("Shnurov",			"Privet Morrikone",					'sound/turntable/shnurov_morikone.ogg',						2230),
		new /datum/data/turntable_soundtrack ("Splin",				"Mi sideli i kurili",				'sound/turntable/splin_mi_sideli_i_kurili.ogg',				1980),
		new /datum/data/turntable_soundtrack ("Splin",				"Moe Serdce",						'sound/turntable/splin_moe_serdce.ogg',						2440),
		new /datum/data/turntable_soundtrack ("Splin",				"Romans",							'sound/turntable/splin_romans.ogg',							2070),
		new /datum/data/turntable_soundtrack ("Splin",				"Vihoda net",						'sound/turntable/splin_vihoda_net.ogg',						2230),
		new /datum/data/turntable_soundtrack ("Steklovata",			"Noviy God",						'sound/turntable/steklovata_noviy_god.ogg',					2380),
		new /datum/data/turntable_soundtrack ("Narodnaya Russkaya",	"Kaztosky Kick",					'sound/turntable/tf2_kazotsky_kic.ogg',						670),
		new /datum/data/turntable_soundtrack ("Total",				"Byet Po Glazam Adrenalin",			'sound/turntable/total_byet_po_glazam_adrenalin.ogg',		2530),
		new /datum/data/turntable_soundtrack ("Trubetskoy",			"Kapital",							'sound/turntable/trubetskoy_kapital.ogg',					2000),
		new /datum/data/turntable_soundtrack ("XS-project",			"Kolotushki",						'sound/turntable/xsproject_kolotushki.ogg',					1610),
		new /datum/data/turntable_soundtrack ("Zemfira",			"Hochesh?",							'sound/turntable/zemfira_hochesh.ogg',						1920),
		new /datum/data/turntable_soundtrack ("Zhuki",				"Batareyka",						'sound/turntable/zhuki_batareyka.ogg',						2240)
	)
	anchored = 1
	density = 1

/obj/machinery/party/turntable/New()
	..()
	turntable_channel++
	music_channel = turntable_channel
/*
	turntable_soundtracks = list()
	for(var/i in subtypesof(/datum/turntable_soundtrack/)
		var/datum/turntable_soundtrack/D = new i()
		if(D.path)
			turntable_soundtracks += D
*/

/obj/machinery/party/turntable/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/disk/music) && !disk)
		user.drop_item()
		O.loc = src
		disk = O
		attack_hand(user)


/obj/machinery/party/turntable/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/party/turntable/attack_hand(mob/living/user as mob)
	if (..())
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	interact(H)

/obj/machinery/party/turntable/interact(var/mob/living/carbon/human/H)

	if(!istype(H.wear_id, /obj/item/device/stalker_pda))
		say("Put on your KPK.")
		return

	var/obj/item/device/stalker_pda/KPK = H.wear_id

	if(!KPK.profile || !KPK.owner)
		say("Activate your KPK profile.")
		return

	if(KPK.owner != H)
		say("No access.")
		return

	//balance = KPK.profile.fields["money"]

	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "Now playing: <b>[track.f_name] - [track.name]</b>"
	//dat += "Balance: [balance] �.<br>"
	dat += "<br>"
	if(KPK.profile.fields["faction_s"] == "Traders")
		dat += "<br><A href='?src=\ref[src];collect_money=\ref[src]'>Collect Money</A>"
		dat += "<br><A href='?src=\ref[src];change_volume=\ref[src]'>Change Volume</A>"
		if(playing)
			dat += "<br><A href='?src\ref[src];turn_off=\ref[src]'>Turn Off</A>"
		else
			dat += "<br><A href='?src\ref[src];turn_on=\ref[src]'>Turn On</A>"
	dat += "<br><A href='?src=\ref[src];skip=\ref[src]'>Skip</A> - <b>[skip_song_cost] RU</b>"
	dat += "<br>Play your song - <b>[play_song_cost] RU</b>"
	dat += "<br>Volume: <b>[volume]%</b>"
	dat += "</div>"
	dat += "<div class='lenta_scroll'>"
	dat += "<br><BR><table border='0' width='400'>"
	for(var/datum/data/turntable_soundtrack/TS in sortList(turntable_soundtracks))
		dat += "<tr><td>[TS.f_name]</td><td>[TS.name]</td><td><A href='?src=\ref[src];order=\ref[TS]'>PLAY</A></td></tr>"
	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup
	if(KPK.profile.fields["faction_s"] != "Traders")
		popup = new(H, "jukebox", "Jukebox", 450, 700)
	else
		popup = new(H, "jukebox", "Jukebox", 460, 760)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/party/turntable/power_change()
	return
	//turn_off()

/obj/machinery/party/turntable/Topic(href, href_list)
	if(..())
		return

	var/mob/living/carbon/human/H = usr
	var/obj/item/device/stalker_pda/KPK = H.wear_id

	if(href_list["collect_money"])
		switch(alert("Do you want to transfer [collected_money]RU to your account?", "Turntable", "Yes", "No"))
			if("Yes")
				KPK.profile.fields["money"] += collected_money
				collected_money = 0
			if("No")
				return

	if(href_list["change_volume"])
		set_volume(input("Choose new volume.", "Turntable", src.volume) as num)
		return

	if(href_list["order"])
		var/datum/data/turntable_soundtrack/TS = locate(href_list["order"])

		if(!playing)
			say("Jukebox is turned off.")
			return

		if (!TS)
			updateUsrDialog()
			return

		if(alert("Play [TS.name] for [play_song_cost] RU?", "Turntable", "Yes", "No") == "No")
			return

		if(play_song_cost > KPK.profile.fields["money"])
			say("You don't have enough money to order a song.")
			updateUsrDialog()
			return

		deltimer(timer_id)
		skip_song(TS)

		KPK.profile.fields["money"] -= play_song_cost
		collected_money += play_song_cost
		return

	if(href_list["skip"])

		if(!playing)
			say("Jukebox is turned off.")
			return

		if(alert("Skip [track.name] for [skip_song_cost] RU?", "Turntable", "Yes", "No") == "No")
			return

		if(skip_song_cost > KPK.profile.fields["money"])
			say("You don't have enough money to skip a song.")
			updateUsrDialog()
			return

		deltimer(timer_id)
		skip_song()

		KPK.profile.fields["money"] -= skip_song_cost
		collected_money += skip_song_cost
		return

	if(href_list["set_volume"])
		set_volume(text2num(href_list["set_volume"]))
		return

	if(href_list["turn_off"])
		turn_off()
		return

	if(href_list["turn_on"])
		turn_on()
		return
/*
	if(href_list["eject"])
		if(disk)
			disk.loc = src.loc
			if(disk.data && track == disk.data)
				turn_off()
				track = null
			disk = null
		return
*/
/obj/machinery/party/turntable/process()
	if(playing)
		update_sound()

/obj/machinery/party/turntable/proc/skip_song(var/datum/data/turntable_soundtrack/TS = pick(turntable_soundtracks))
	start_time = world.time
	track = TS
	say("Now playing: [track.f_name] - [track.name]")
	timer_id = addtimer(src, "skip_song", track.length)
	update_sound()
/*
/obj/machinery/party/turntable/proc/MusicSwitch()

	sleep(track.length)
		MusicSwitch()
*/
/obj/machinery/party/turntable/proc/turn_on(var/datum/data/turntable_soundtrack/selected)
	if(playing)
		turn_off()

	playing = 1

	if(selected)
		skip_song(selected)
	else
		skip_song()

	//MusicSwitch()
	var/area/A = get_area(src)
	for(var/area/RA in A.related)
		for(var/obj/machinery/party/lasermachine/L in RA)
			L.turnon(L.dir)

/obj/machinery/party/turntable/proc/turn_off()
	if(!playing)
		return

	deltimer(timer_id)
	timer_id = 0

	for(var/client/C in melomans)
		C.jukeboxplaying = 0
		C.mob << sound(null, channel = music_channel, wait = 0)
		melomans.Remove(C)

	playing = 0

	var/area/A = get_area(src)
	for(var/area/RA in A.related)
		for(var/obj/machinery/party/lasermachine/L in RA)
			L.turnoff()

/obj/machinery/party/turntable/proc/set_volume(var/new_volume)
	volume = max(0, min(100, new_volume))
	//if(playing)
	//	update_sound()

/obj/machinery/party/turntable/proc/update_sound()
	var/area/A = get_area(src)

	if(!track)// || start_time + track.length < world.time + 5)
		skip_song()

	for(var/client/C in clients)

		if(!C || !C.mob)
			continue

		if(!(get_area(C.mob) in A.related))
			continue

		if(!C.mob.client.jukeboxplaying)
			C.jukeboxplaying = 1
			melomans.Add(C)
			create_sound(C.mob)
			C.mob.music.volume = volume
			C.mob << C.mob.music

	for (var/client/C in melomans)
		//var/inRange = (get_area(C.mob) in A.related)

		if(!C || !(C.mob))
			melomans -= C
			continue

		if(!playing || !(get_area(C.mob) in A.related))
			C.jukeboxplaying = 0
			if(C.mob.music)
				C.mob.music.status = SOUND_UPDATE
				C.mob.music.volume = 0
				C.mob << C.mob.music
			melomans.Remove(C)
			continue

		if(!C.mob.music)
			create_sound(C.mob)
			continue

		if(!C.mob.music.transition && C.mob.music.file != track.path)
			C.mob.music.file = track.path
			C.mob.music.status = SOUND_STREAM
		else
			C.mob.music.status = SOUND_UPDATE

		C.mob.music.volume = volume
		C.mob << C.mob.music

/obj/machinery/party/turntable/proc/create_sound(mob/M)
	if(!M.music || M.music.file != track.path)
		var/sound/S = sound(track.path)
		S.repeat = 1
		S.channel = music_channel
		S.falloff = 2
		S.wait = 0
		S.volume = 0
		S.status = 0 //SOUND_STREAM
		S.environment = get_area(src).environment

		M.music = S
		M << S
	else
		M.music.status = SOUND_UPDATE
		M.music.volume = volume
		M << M.music

/obj/machinery/party/mixer
	name = "mixer"
	desc = "A mixing board for mixing music"
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "mixer"
	density = 0
	anchored = 1

/obj/machinery/party/lasermachine
	name = "laser machine"
	desc = "A laser machine that shoots lasers."
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "lasermachine"
	dir = 4
	anchored = 1
	var/mirrored = 0

/obj/effect/laser2
	name = "laser"
	desc = "A laser..."
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "laserred1"
	anchored = 1
	layer = 4

/obj/machinery/party/lasermachine/proc/turnon(laser_dir)
	var/wall = 0
	var/cycle = 1
	var/area/A = get_area(src)
	var/X = 1
	var/Y = 0
	if(mirrored == 0)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effect/laser2/F = new/obj/effect/laser2(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.dir = laser_dir
				F.icon_state = "laserred1"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 2)
				var/obj/effect/laser2/F = new/obj/effect/laser2(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.dir = laser_dir
				F.icon_state = "laserred2"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 3)
				var/obj/effect/laser2/F = new/obj/effect/laser2(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.dir = laser_dir
				F.icon_state = "laserred3"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
	if(mirrored == 1)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effect/laser2/F = new/obj/effect/laser2(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred1m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 2)
				var/obj/effect/laser2/F = new/obj/effect/laser2(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred2m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 3)
				var/obj/effect/laser2/F = new/obj/effect/laser2(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred3m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++



/obj/machinery/party/lasermachine/proc/turnoff()
	var/area/A = src.loc.loc
	for(var/area/RA in A.related)
		for(var/obj/effect/laser2/F in RA)
			qdel(F)

/obj/machinery/party/lasermachine/Move()
	..()
	turnon(src.dir)
