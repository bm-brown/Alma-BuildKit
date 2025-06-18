#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = f40b716a
#   function = ensure_strong_password_hashing_algorithm_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_strong_password_hashing_algorithm_configured.sh
#
# Name					Date			Description
# ------------------------------------------------------------------------------------------------
# J Brown				02/28/24		Recommendation "Ensure strong password hashing algorithm is configured"
# # David Neilson       05/30/24        Appends ENCRYPT_METHOD to end of file if "Password aging controls" section doesn't exist.  Also, sets ENCRYPT_METHOD to "YESCRYPT" if that algorithm is available.

ensure_strong_password_hashing_algorithm_configured()
{
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

	ensure_strong_password_hashing_algorithm_configured_chk()
	{
		echo -e "- Start check - Ensure strong password hashing algorithm is configured" | tee -a "$LOG" 2>> "$ELOG"
		l_output="" l_output2=""

		# Check if ENCRYPT_METHOD is configured in /etc/login.defs
		if ! grep -Pq -- '^\h*ENCRYPT_METHOD' /etc/login.defs; then
			l_output2="$l_output2\n- /etc/login.defs does NOT contain ENCRYPT_METHOD"
		elif grep -Piq -- '^\h*ENCRYPT_METHOD\h+(SHA512|yescrypt)\b' /etc/login.defs; then
			l_output="$l_output\n- /etc/login.defs ENCRYPT_METHOD set to: $(grep -Pi -- '^\h*ENCRYPT_METHOD' /etc/login.defs | awk '{print $2}')"
		else
			l_output2="$l_output2\n- /etc/login.defs ENCRYPT_METHOD set to: $(grep -Ps -- '^\h*ENCRYPT_METHOD' /etc/login.defs | awk '{print $2}')"
		fi

		if [ -z "$l_output2" ]; then
			echo -e "- PASS:\n- /etc/login.defs password encryption method set correctly\n- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure strong password hashing algorithm is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- /etc/login.defs password encryption method set incorrectly\n- Failing Values:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
			if [ -n "$l_output" ]; then
				echo -e "- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			fi
			echo -e "- End check - Ensure strong password hashing algorithm is configured" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	ensure_strong_password_hashing_algorithm_configured_fix()
	{
		echo -e "- Start remediation - Ensure strong password hashing algorithm is configured" | tee -a "$LOG" 2>> "$ELOG"

		# Set ENCRYPT_METHOD to YESCRYPT if that hashing algorithm is available.
		if openssl list -digest-algorithms | grep -qi yescrypt; then
        	l_hash_algo="YESCRYPT"
		else
        	l_hash_algo="SHA512"
		fi

		# Set ENCRYPT_METHOD in /etc/login.defs"
		if ! grep -Pq -- '^\h*ENCRYPT_METHOD\h+(SHA512|yescrypt)\b' /etc/login.defs; then
			if grep -Pq -- '^\h*ENCRYPT_METHOD\h*' /etc/login.defs; then
				echo -e "- Updating ENCRYPT_METHOD entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri "s/^\s*(ENCRYPT_METHOD\s*)(.*)$/\1 $l_hash_algo/" /etc/login.defs
			else
				echo -e "- Inserting ENCRYPT_METHOD entry in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
                if grep -Pq -- 'Password\h+aging\h+controls' /etc/login.defs; then
					sed -ri "/^\s*#\s* Password\s+aging\s+controls/a ENCRYPT_METHOD $l_hash_algo" /etc/login.defs
				else
					echo "ENCRYPT_METHOD $l_hash_algo" >> /etc/login.defs
				fi
			fi
		fi

		echo -e "- Remediation only effects local users and passwords created after updating the file to use SHA512 or YESCRYPT.  Those users who did not use one of these password algorithms should change their passwords immediately." | tee -a "$LOG" 2>> "$ELOG"
		echo -e "- End remediation - Ensure strong password hashing algorithm is configured" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_strong_password_hashing_algorithm_configured_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		if [ "$l_test" != "NA" ]; then
			ensure_strong_password_hashing_algorithm_configured_fix
			if [ "$l_test" != "manual" ]; then
				ensure_strong_password_hashing_algorithm_configured_chk
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