#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = ec5571ba
#   function = ensure_group_root_only_gid_0_group
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
# ~/CIS-LBK/functions/nix_ensure_group_root_only_gid_0_group.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Gokhan Lus          03/18/24    Recommendation "Ensure group root is the only GID 0 group"
#

ensure_group_root_only_gid_0_group()
{
   echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
   l_test=""	
	
	ensure_group_root_only_gid_0_group_chk()
	{
      echo -e "- Start check - Ensure group root is the only GID 0 group" | tee -a "$LOG" 2>> "$ELOG"
      l_output=""
      l_group=""

		for l_group in $(awk -F: '$3=="0"{print $1":"$3}' /etc/group); do
			if [ "$l_group" != "root:0" ]; then
				l_output="$l_output $l_group has a GID of 0\n"
			fi
		done
		
		if [ -z "$l_output" ]; then
			echo -e "- PASS: - Root is the only GID 0 account"  | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL: - \n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi	
	}
	
	ensure_group_root_only_gid_0_group_fix()
	{
		echo -e "- Start remediation - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
		echo -e "- Making modifications to /etc/passwd could have significant unintended consequences or result in outages and unhappy users. Therefore, it is recommended that the current user list be reviewed and determine the action to be taken in accordance with site policy. -" | tee -a "$LOG" 2>> "$ELOG"
		echo -e "- End remediation - Ensure root is the only GID 0 account" | tee -a "$LOG" 2>> "$ELOG"
		l_test="manual"
	}
	
	ensure_group_root_only_gid_0_group_chk
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