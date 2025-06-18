#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 5a681030
#   function = ensure_minimum_password_age_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_minimum_password_age_configured.sh
#
# Name					Date			Description
# ------------------------------------------------------------------------------------------------
# J Brown				02/28/24		Recommendation "Ensure minimum password age is configured"
#

ensure_minimum_password_age_configured()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

	ensure_minimum_password_age_configured_chk()
	{
		echo -e "- Start check - Ensure minimum password age is configured" | tee -a "$LOG" 2>> "$ELOG"
		l_output="" l_output2=""

		# Check if PASS_MIN_DAYS is configured in /etc/login.defs
		if ! grep -Pq -- '^\h*PASS_MIN_DAYS' /etc/login.defs; then
			l_output2="$l_output2\n- /etc/login.defs does NOT contain PASS_MIN_DAYS"
		elif grep -Piq -- '^\h*PASS_MIN_DAYS\h+([1-9]|[1-9][0-9]{1,})\b' /etc/login.defs; then
			l_output="$l_output\n- /etc/login.defs PASS_MIN_DAYS set to: $(grep -Pi -- '^\h*PASS_MIN_DAYS\h+\d+\b' /etc/login.defs | awk '{print $2}')"
		else
			l_output2="$l_output2\n- /etc/login.defs PASS_MIN_DAYS set to: $(grep -Ps -- '^\h*PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}')"
		fi

		# Check users for their expiration
		l_users="$(awk -F: '($2~/^\$.+\$/) {if($4 < 1)print $1 " " $4}' /etc/shadow)"

		if [ -n "$l_users" ]; then
			while read l_user l_value; do
				if [ -n "$l_user" ] && [ "$l_value" -ge 1 ]; then
					l_output="$l_output\n- PASS_MIN_DAYS value for '$l_user': $l_value"
				else
					l_output2="$l_output2\n- PASS_MIN_DAYS value for '$l_user': $l_value"
				fi
			done <<< "$l_users"
		fi

		if [ -z "$l_output2" ]; then
			echo -e "- PASS:\n- /etc/login.defs and all users have minimum password age set correctly\n- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure minimum password age is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- /etc/login.defs or users have minimum password age set incorrectly\n- Failing Values:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
			if [ -n "$l_output" ]; then
				echo -e "- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			fi
			echo -e "- End check - Ensure minimum password age is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	ensure_minimum_password_age_configured_fix()
	{
		echo -e "- Start remediation - Ensure minimum password age is configured" | tee -a "$LOG" 2>> "$ELOG"

		# Set PASS_MIN_DAYS in /etc/login.defs"
		if ! grep -Pq -- '^\h*PASS_MIN_DAYS\h+([1-9]|[1-9][0-9]{1,})\b' /etc/login.defs; then
			if grep -Pq -- '^\h*PASS_MIN_DAYS\h+' /etc/login.defs; then
				echo -e "- Updating PASS_MIN_DAYS entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri 's/^\s*(PASS_MIN_DAYS\s+)([0-9]+)(.*)$/\11 \3 # Updated by CIS Build Kit/' /etc/login.defs
			else
				echo -e "- Inserting PASS_MIN_DAYS entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri '/^\s*#\s* Password\s+aging\s+controls/a PASS_MIN_DAYS 1 # Added by CIS Build Kit' /etc/login.defs
			fi
		fi

		# Update PASS_MIN_DAYS for users
		l_users="$(awk -F: '($2~/^\$.+\$/) {if($4 < 1)print $1 " " $4}' /etc/shadow)"

		if [ -z "$l_test" ] && [ -n "$l_users" ]; then
			while read l_user l_value; do
				echo "- User: '$l_user' has PASS_MIN_DAYS of: '$l_value', remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
				chage --mindays 1 "$l_user"
			done <<< "$l_users"
		fi

		echo -e "- End remediation - Ensure minimum password age is configured" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_minimum_password_age_configured_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		if [ "$l_test" != "NA" ]; then
			ensure_minimum_password_age_configured_fix
			if [ "$l_test" != "manual" ]; then
			ensure_minimum_password_age_configured_chk
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