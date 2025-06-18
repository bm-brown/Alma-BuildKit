#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 81ed5939
#   function = ensure_password_expiration_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_password_expiration_configured.sh
#
# Name					Date			Description
# ------------------------------------------------------------------------------------------------
# J Brown				02/28/24		Recommendation "Ensure password expiration is configured"
# David Neilson			05/23/24		Appends PASS_MAX_DAYS to end of file if "Password aging controls" section doesn't exist, fixes non-root users if root's PASS_MAX_DAYS is wrong.  

ensure_password_expiration_configured()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""
	if grep -Pi -- 'pretty_name' /etc/os-release | grep -Piq -- 'suse'; then
        l_os_name="suse"
    fi

	ensure_password_expiration_configured_chk()
	{
		echo -e "- Start check - Ensure password expiration is configured" | tee -a "$LOG" 2>> "$ELOG"
		l_output="" l_output2=""

		# Check if PASS_MAX_DAYS is configured in /etc/login.defs
		if ! grep -Pq -- '^\h*PASS_MAX_DAYS' /etc/login.defs; then
			l_output2="$l_output2\n- /etc/login.defs does NOT contain PASS_MAX_DAYS"
		elif grep -Piq -- '^\h*PASS_MAX_DAYS\h+([1-9]|[1-9][0-9]|[1-2][0-9]{2}|3[0-5][0-9]|36[0-5])\b' /etc/login.defs; then
			l_output="$l_output\n- /etc/login.defs PASS_MAX_DAYS set to: $(grep -Pi -- '^\h*PASS_MAX_DAYS\h+\d+\b' /etc/login.defs | awk '{print $2}')"
		else
			l_output2="$l_output2\n- /etc/login.defs PASS_MAX_DAYS set to: $(grep -Ps -- '^\h*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')"
		fi

		# Check users for their expiration
		l_users="$(awk -F: '($2~/^\$.+\$/) {if($5 > 365 || $5 < 1)print $1 " " $5}' /etc/shadow)"

		if [ -n "$l_users" ]; then
			while read l_user l_value; do
				if [ -n "$l_user" ] && [ "$l_value" -le 365 ] && [ "$l_value" -gt 0 ]; then
					l_output="$l_output\n- PASS_MAX_DAYS value for '$l_user': $l_value"
				else
					l_output2="$l_output2\n- PASS_MAX_DAYS value for '$l_user': $l_value"
				fi
			done <<< "$l_users"
		fi

		if [ -z "$l_output2" ]; then
			echo -e "- PASS:\n- /etc/login.defs and all users have password expiration set correctly\n- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure password expiration is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- /etc/login.defs or users have password expiration set incorrectly\n- Failing Values:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
			if [ -n "$l_output" ]; then
				echo -e "- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			fi
			echo -e "- End check - Ensure password expiration is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	ensure_password_expiration_configured_fix()
	{
		echo -e "- Start remediation - Ensure password expiration is configured" | tee -a "$LOG" 2>> "$ELOG"

		# Set PASS_MAX_DAYS in /etc/login.defs"
		if ! grep -Pq -- '^\h*PASS_MAX_DAYS\h+([1-9]|[1-9][0-9]|[1-2][0-9]{2}|3[0-5][0-9]|36[0-5])\b' /etc/login.defs; then
			if grep -Pq -- '^\h*PASS_MAX_DAYS\h*' /etc/login.defs; then
				echo -e "- Updating PASS_MAX_DAYS entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri 's/^\s*(PASS_MAX_DAYS\s*)(.*)$/\1 365/' /etc/login.defs
			else
				echo -e "- Inserting PASS_MAX_DAYS entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
				if grep -Pq -- 'Password\h+aging\h+controls' /etc/login.defs; then
					sed -ri '/^\s*#\s* Password\s+aging\s+controls/a PASS_MAX_DAYS 365' /etc/login.defs
				else
					echo "PASS_MAX_DAYS 365" >> /etc/login.defs
				fi
			fi
		fi

		# Check if test should be set to manual instead
		if grep -Piq 'root' <<< "$( awk -F: '($2~/^\$.+\$/) {if($5 > 365 || $5 < 1)print $1 " " $5}' /etc/shadow)"; then
			echo -e "- The password for 'root' needs to be updated before setting password expiration\n- Please update root's password and set an expiration for root" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- The Build Kit will not update root's password expiration to avoid unintentional system inaccessibility" | tee -a "$LOG" 2>> "$ELOG"
			l_test=manual
		fi 

		# Update PASS_MAX_DAYS for users (but not for root)
		if [ -z "$l_test" ]; then
			l_users="$(awk -F: '($2~/^\$.+\$/) {if($5 > 365 || $5 < 1)print $1 " " $5}' /etc/shadow)"
		else
			l_users="$(awk -F: '($2~/^\$.+\$/) {if($5 > 365 || $5 < 1)print $1 " " $5}' /etc/shadow | grep -Pv -- 'root')"
		fi

		if [ -n "$l_users" ]; then
			while read l_user l_value; do
				# On Suse systems, if a non-root user has an empty PASS_MAX_DAYS value, or if that value is not within 1-365, do manual remediation. 
				case $l_os_name in 
					suse)
						if ( [ -z "$l_value" ] || [ $l_value -gt 365 -o $l_value -lt 1 ] ) && [ "$(grep -Pi -- '^root:' /etc/shadow | awk -F: '($2~/^\$.+\$/) { print $5}')" = "0" ]; then
							echo "- User: '$l_user' has invalid PASS_MAX_DAYS, manual remediation required for user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
							[ -z "$l_test" ] && l_test=manual
						else
							echo "- User: '$l_user' has PASS_MAX_DAYS of: '$l_value', remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
							chage --maxdays 365 "$l_user"
						fi
						;;
					*)
						echo "- User: '$l_user' has PASS_MAX_DAYS of: '$l_value', remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
						chage --maxdays 365 "$l_user"
						;;
				esac
			done <<< "$l_users"
		fi

		echo -e "- End remediation - Ensure password expiration is configured" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_password_expiration_configured_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		if [ "$l_test" != "NA" ]; then
			ensure_password_expiration_configured_fix
			if [ "$l_test" != "manual" ]; then
			ensure_password_expiration_configured_chk
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