#define DEFAULT_WHO_CELLS_PER_ROW 4

/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()
	var/columns_per_row = DEFAULT_WHO_CELLS_PER_ROW

	if(holder)
		if (check_rights(R_ADMIN,0) && isobserver(src.mob))//If they have +ADMIN and are a ghost they can see players IC names and statuses.
			columns_per_row = 1
			var/mob/dead/observer/G = src.mob
			if(!G.started_as_observer)//If you aghost to do this, KorPhaeron will deadmin you in your sleep.
				log_admin("[key_name(usr)] checked advanced who in-round")
			for(var/client/C in GLOB.clients)
				var/entry = "\t[C.key]"
				if(C.holder && C.holder.fakekey)
					entry += " <i>(as [C.holder.fakekey])</i>"
				if (isnewplayer(C.mob))
					entry += " - <font color='darkgray'><b>In Lobby</b></font>"
				else
					entry += " - Playing as [C.mob.real_name]"
					switch(C.mob.stat)
						if(UNCONSCIOUS, HARD_CRIT)
							entry += " - <font color='darkgray'><b>Unconscious</b></font>"
						if(DEAD)
							if(isobserver(C.mob))
								var/mob/dead/observer/O = C.mob
								if(O.started_as_observer)
									entry += " - <font color='gray'>Observing</font>"
								else
									entry += " - <font color='black'><b>DEAD</b></font>"
							else
								entry += " - <font color='black'><b>DEAD</b></font>"
					if(is_special_character(C.mob))
						entry += " - <b><font color='red'>Antagonist</font></b>"
				entry += " [ADMIN_QUE(C.mob)]"
				entry += " ([round(C.avgping, 1)]ms)"
				Lines += entry
		else//If they don't have +ADMIN, only show hidden admins
			for(var/client/C in GLOB.clients)
				var/entry = "[C.key]"
				if(C.holder && C.holder.fakekey)
					entry += " <i>(as [C.holder.fakekey])</i>"
				entry += " ([round(C.avgping, 1)]ms)"
				Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(C.holder && C.holder.fakekey)
				Lines += "[C.holder.fakekey] ([round(C.avgping, 1)]ms)"
			else
				Lines += "[C.key] ([round(C.avgping, 1)]ms)"

	var/num_lines = 0
	msg += "<table style='width: 100%; table-layout: fixed'><tr>"
	for(var/line in sort_list(Lines))
		msg += "<td>[line]</td>"

		num_lines += 1
		if (num_lines == columns_per_row)
			num_lines = 0
			msg += "</tr><tr>"
	msg += "</tr></table>"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, "<span class='infoplain'>[msg]</span>")

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"
	staff_who("Staffwho")

/client/verb/mentorwho()  // redundant with staffwho, but people wont check the admin tab for if there are mentors on
	set category = "Mentor"
	set name = "Mentorwho"
	staff_who("Mentorwho")

/client/proc/staff_who(via)
	var/msg
	if(holder)
		msg = "<b>Current Admins:</b>\n"
		for(var/client/C in GLOB.admins)
			msg += "\t[C] is a [C.holder.rank]"

			if(C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"

		msg += "<b>Current Mentors:</b>\n"
		for(var/client/C in GLOB.mentors)
			msg += "\t[C] is a Mentor"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"

	// for standard players
	else
		var/list/admin_list = list()
		var/list/non_admin_list = list()
		for(var/client/C in GLOB.admins)
			if(C.is_afk())
				continue //Don't show afk admins to adminwho
			if(!C.holder.fakekey)
				if(check_rights_for(C, R_ADMIN)) // ahelp needs R_ADMIN. If they have R_ADMIN, they'll be listed in admin list.
					var/rank = "\improper [C.holder.rank]"
					admin_list += "\t[C] is \a [rank]\n"
				else // admins without R_ADMIN perm should be sorted in different area, so that people won't believe coders will handle ahelp
					var/rank = "\improper [C.holder.rank]"
					non_admin_list += "\t[C] is \a [rank]\n"

		msg = "<b>Current Admins:</b>\n"
		for(var/each in admin_list)
			msg += each
		if(length(non_admin_list)) // notifying the absence of non-admins has no point
			msg += "<b>Current Maintainers:</b>\n"
			msg += "\t[span_info("Non-admin staff are unable to handle adminhelp tickets.")]\n"
			for(var/each in non_admin_list)
				msg += each
		msg += "<b>Current Mentors:</b>\n"
		for(var/client/C in GLOB.mentors)
			if(C.is_afk())
				continue //Don't show afk admins to adminwho
			msg += "\t[C] is a Mentor\n"

		msg += span_info("Adminhelps are also sent through TGS to services like IRC and Discord. If no admins are available in game adminhelp anyways and an admin will see it and respond.")
		if(TIMER_COOLDOWN_CHECK(src, staff_check_rate))
			message_admins("[ADMIN_LOOKUPFLW(src.mob)] has checked online staff[via ? " (via [via])" : ""].")
			log_admin("[key_name(src)] has checked online staff[via ? " (via [via])" : ""].")
			TIMER_COOLDOWN_START(src, staff_check_rate, 1 MINUTES)
	to_chat(src, msg)

#undef DEFAULT_WHO_CELLS_PER_ROW
