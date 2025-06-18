#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 5a813fb3
#   function = fed_ensure_pam_unix_does_not_include_nullok
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_pam_unix_does_not_include_nullok.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar        10/19/26   Recommendation "Ensure pam_unix does not include nullok"
#

fed_ensure_pam_unix_does_not_include_nullok()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation - Ensure pam_unix does not include nullok \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    fed_ensure_pam_unix_does_not_include_nullok_chk()
    {
        echo -e "- Start check - Ensure pam_unix does not include nullok" | tee -a "$LOG" 2>> "$ELOG"
        
       # Check if pam_unix is used and does not include nullok
        if grep -P -- '^\h*(auth|account|password|session)\h+(required|requisite|sufficient)\h+pam_unix\.so\b' /etc/pam.d/{password,system}-auth | grep -P '\bnullok\b'; then
            echo -e "- FAIL: pam_unix includes nullok" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- The following lines include nullok:" | tee -a "$LOG" 2>> "$ELOG"
            grep -P -- '^\h*(auth|account|password|session)\h+(required|requisite|sufficient)\h+pam_unix\.so\b' /etc/pam.d/{password,system}-auth | grep -P '\bnullok\b' | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix does not include nullok" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        else
            echo -e "- PASS: pam_unix does not include nullok" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure pam_unix does not include nullok" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        fi  
    }

    fed_ensure_pam_unix_does_not_include_nullok_fix()
    {
        echo -e "- Start remediation - Ensure pam_unix includes nullock" | tee -a "$LOG" 2>> "$ELOG"

        # Verify the active authselect profile's system-auth and password-auth files for nullok
        l_module_name="unix"
        l_profile_name="$(head -1 /etc/authselect/authselect.conf)"
        
        if [[ ! -f /etc/authselect/authselect.conf ]]; then
            echo " - Recommendation requires manual remedation refer to Recommendation 4.4.2.1 Ensure active authselect profile includes pam modules and then return to this Recommendation"
            l_test="manual"
        else
            if [[ ! "$l_profile_name" =~ ^custom\/ ]]; then
                echo " - Recommendation requires manual remedation refer to Recommendation 4.4.2.1 Ensure active authselect profile includes pam modules and then return to this Recommendation"
                l_test="manual"
            else
                # Check for nullok in the active authselect profile's system-auth and password-auth files
                if grep -P -- "\bpam_$l_module_name\.so\b" /etc/authselect/"$l_profile_name"/{password,system}-auth | grep -qP -- '\bnullok\b'; then
                    sed -ri 's/(^\h*(auth|account|password|session)\h+(required|requisite|sufficient)\h+pam_unix\.so\b.*)\bnullok\b(.*)$/\1\3/g' /etc/authselect/"$l_profile_name"/{password,system}-auth
                    # Enable the authselect without-nullok feature and update PAM files
                    authselect enable-feature without-nullok
                    authselect apply-changes
                fi
            fi
        fi

        echo -e "- End remediation - Ensure pam_unix includes nullock" | tee -a "$LOG" 2>> "$ELOG"

    }

    fed_ensure_pam_unix_does_not_include_nullok_chk
    if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
        fed_ensure_pam_unix_does_not_include_nullok_fix
        if [ "$l_test" != "manual" ]; then
            fed_ensure_pam_unix_does_not_include_nullok_chk
            if [ "$?" = "101" ]; then
                [ "$l_test" != "failed" ] && l_test="remediated"
                
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
