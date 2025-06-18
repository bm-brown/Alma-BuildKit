#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = c9abbbc1
#   function = ensure_root_only_gid_0_account
#   applicable =
# # END METADATA
#
#
#
#
#
#
#
#
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/nix_ensure_root_only_gid_0_account.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Gokhan Lus          03/18/24    Recommendation "Ensure root is the only GID 0 account"
#

ensure_root_only_gid_0_account()
{
   echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
   l_test=""	
	
	ensure_root_only_gid_0_account_chk()
	{
      echo -e "- Start check - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
      l_output=""
      l_output2=""
        # Check users with GID 0
		for l_user in $(awk -F: '($1 !~ /^(sync|shutdown|halt|operator)/ && $4=="0") {print $1}' /etc/passwd); do
			if [ "$l_user" != "root" ]; then
				l_output2="$l_output2\n$l_user has a GID of 0"
			fi
		done

        # Verify root has GID 0
        l_group="$(awk -F: '($1=="root" && ! $4=="0") {print $1 " GID of " $4}' /etc/passwd)"
		if [ -n "$l_group" ]; then
			l_output2="$l_output2\n$l_group\n"
        else
            l_output="$l_output\n root has a GID of 0" 
		fi
		
		if [ -z "$l_output2" ]; then
			echo -e "- PASS:\n$l_output"  | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAILED:"  | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- Failing values:\n$l_output2\n"  | tee -a "$LOG" 2>> "$ELOG"
              if [ -n "$l_output" ]; then
                echo -e "- Passing values:\n$l_output\n"  | tee -a "$LOG" 2>> "$ELOG"
              fi
			echo -e "- End check - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi	
	}
	
	ensure_root_only_gid_0_account_fix()
	{
		echo -e "- Start remediation - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
		echo -e "- Making modifications to /etc/passwd could have significant unintended consequences or result in outages and unhappy users. Therefore, it is recommended that the current user list be reviewed and determine the action to be taken in accordance with site policy. -" | tee -a "$LOG" 2>> "$ELOG"
		echo -e "- End remediation - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
		l_test="manual"
	}
	
	ensure_root_only_gid_0_account_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		ensure_root_only_gid_0_account_fix
        if [ "$l_test" != "manual" ]; then
		    ensure_root_only_gid_0_account_chk
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