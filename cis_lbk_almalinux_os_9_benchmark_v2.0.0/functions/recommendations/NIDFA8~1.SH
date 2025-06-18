#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 6176c69b
#   function = ensure_password_expiration_warning_days_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_password_expiration_warning_days_configured.sh
#
# Name					Date			Description
# ------------------------------------------------------------------------------------------------
# J Brown				02/28/24		Recommendation "Ensure password expiration warning days is configured"
# David Neilson         05/29/24        Corrected typos and incorrect cut and paste data, and modified to append PASS_WARN_AGE to end of file if "Password aging controls" section doesn't exist. 

ensure_password_expiration_warning_days_configured()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

	ensure_password_expiration_warning_days_configured_chk()
	{
		echo -e "- Start check - Ensure password expiration warning days is configured" | tee -a "$LOG" 2>> "$ELOG"
		l_output="" l_output2=""

		# Check if PASS_WARN_AGE is configured in /etc/login.defs
		if ! grep -Pq -- '^\h*PASS_WARN_AGE' /etc/login.defs; then
			l_output2="$l_output2\n- /etc/login.defs does NOT contain PASS_WARN_AGE"
		elif grep -Piq -- '^\h*PASS_WARN_AGE\h+([7-9]|[1-9][0-9]{1,})\b' /etc/login.defs; then
			l_output="$l_output\n- /etc/login.defs PASS_WARN_AGE set to: $(grep -Pi -- '^\h*PASS_WARN_AGE\h+\d+\b' /etc/login.defs | awk '{print $2}')"
		else
			l_output2="$l_output2\n- /etc/login.defs PASS_WARN_AGE set to: $(grep -Ps -- '^\h*PASS_WARN_AGE' /etc/login.defs | awk '{print $2}')"
		fi

		# Check users for their expiration
		l_users="$(awk -F: '($2~/^\$.+\$/) {if($6 < 7)print $1 " " $6}' /etc/shadow)"

		if [ -n "$l_users" ]; then
			while read l_user l_value; do
				if [ -n "$l_user" ] && [ "$l_value" -ge 7 ]; then
					l_output="$l_output\n- PASS_WARN_AGE value for '$l_user': $l_value"
				else
					l_output2="$l_output2\n- PASS_WARN_AGE value for '$l_user': $l_value"
				fi
			done <<< "$l_users"
		fi

		if [ -z "$l_output2" ]; then
			echo -e "- PASS:\n- /etc/login.defs and all users have password warning days set correctly\n- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure password expiration warning days is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- /etc/login.defs or users have password warning days set incorrectly\n- Failing Values:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
			if [ -n "$l_output" ]; then
				echo -e "- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			fi
			echo -e "- End check - Ensure password expiration warning days is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	ensure_password_expiration_warning_days_configured_fix()
	{
		echo -e "- Start remediation - Ensure password expiration warning days is configured" | tee -a "$LOG" 2>> "$ELOG"

		# Set PASS_MAX_DAYS in /etc/login.defs"
		if ! grep -Pq -- '^\h*PASS_WARN_AGE\h+([7-9]|[1-9][0-9]{1,})\b' /etc/login.defs; then
			if grep -Pq -- '^\h*PASS_WARN_AGE\h*' /etc/login.defs; then
				echo -e "- Updating PASS_WARN_AGE entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri 's/^\s*(PASS_WARN_AGE\s*)(.*)$/\1 7/' /etc/login.defs
			else
				echo -e "- Inserting PASS_WARN_AGE entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
                if grep -Pq -- 'Password\h+aging\h+controls' /etc/login.defs; then
					sed -ri '/^\s*#\s* Password\s+aging\s+controls/a PASS_WARN_AGE 7' /etc/login.defs
				else
					echo "PASS_WARN_AGE 7" >> /etc/login.defs
				fi
				
			fi
		fi

		# Update PASS_WARN_AGE for users 
		l_users="$(awk -F: '($2~/^\$.+\$/) {if($6 < 7)print $1 " " $6}' /etc/shadow)"

		if [ -z "$l_test" ] && [ -n "$l_users" ]; then
			while read l_user l_value; do
				echo "- User: '$l_user' has PASS_WARN_AGE of: '$l_value', remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
				chage --warndays 7 "$l_user"
			done <<< "$l_users"
		fi

		echo -e "- End remediation - Ensure password expiration warning days is configured" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_password_expiration_warning_days_configured_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		if [ "$l_test" != "NA" ]; then
			ensure_password_expiration_warning_days_configured_fix
			if [ "$l_test" != "manual" ]; then
			ensure_password_expiration_warning_days_configured_chk
			if [ "$?" = "101" ]; then
				[ "$l_test" != "failed" ] && l_test="remediated"
			else
				l_test="failed"
			fi
			fi
		fi
	fi

	# Set return code, end recommendation entry in verbose log, and return
	case "$l_test" in
		passed)
			echo -e "- Result - No remediation required\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
			;;
		remediated)
			echo -e "- Result - successfully remediated\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-103}"
			;;
		manual)
			echo -e "- Result - requires manual remediation\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-106}"
			;;
		NA)
			echo -e "- Result - Recommendation is non applicable\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo -e "- Result - remediation failed\n- End Recommendation \"$RN - $RNA\"\n**************************************************\n" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}