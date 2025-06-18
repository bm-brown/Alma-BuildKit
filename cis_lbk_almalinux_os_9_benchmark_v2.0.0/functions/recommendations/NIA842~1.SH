#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = ee779940
#   function = ensure_inactive_password_lock_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_inactive_password_lock_configured.sh
#
# Name                  Date            Description
# ------------------------------------------------------------------------------------------------
# J Brown               02/28/24        Recommendation "Ensure inactive password lock is configured"
# David Neilson         05/31/24        Updated "echo" statements which were referencing a different benchmark, minor syntax change to "grep" statement, fixes non-root users if root's INACTIVE value is wrong, doesn't remediate users on Ubuntu systems if INACTIVE = -1, and doesn't change users if they can sudo AND if they haven't logged in within the past 45 days.

ensure_inactive_password_lock_configured()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""
    if grep -Pi -- 'pretty_name' /etc/os-release | grep -Piq -- 'ubuntu'; then
        l_os_name="ubuntu"
    fi

    ensure_inactive_password_lock_configured_chk()
    {
        echo -e "- Start check - Ensure inactive password lock is configured" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        # Check if INACTIVE is configured in useradd
        l_useradd_default="$(useradd -D | grep -Pi -- 'INACTIVE' | awk -F"=" '{print $2}')"

        if [ -n "$l_useradd_default" ]; then
            if [ "$l_useradd_default" -le 45 ] && [ "$l_useradd_default" -ge 1 ]; then
                l_output="$l_output\n- useradd INACTIVE default set to: $l_useradd_default"
            else
                l_output2="$l_output2\n- useradd INACTIVE default set to: $l_useradd_default"
            fi
        else
            l_output2="$l_output2\n- useradd INACTIVE default NOT set"
        fi

        # Check users for their INACTIVE value
        l_users="$(awk -F: '($2~/^\$.+\$/) {if($7 > 45 || $7 < 0)print $1 " " $7}' /etc/shadow)"

        if [ -n "$l_users" ]; then
            while read l_user l_value; do
                if [ -n "$l_value" ] && [ "$l_value" -le 45 ] && [ "$l_value" -ge 1 ]; then
                    l_output="$l_output\n- INACTIVE value for '$l_user': $l_value"
                else
                    if [ -n "$l_value" ]; then
                        l_output2="$l_output2\n- INACTIVE value for '$l_user': $l_value"
                    else
                        l_output2="$l_output2\n- INACTIVE value NOT set for '$l_user'"
                    fi
                fi
            done <<< "$l_users"
        fi

        if [ -z "$l_output2" ]; then
            echo -e "- PASS:\n- Inactive password lock is set correctly\n- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure inactive password lock is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n- Inactive password lock is set incorrectly\n- Failing Values:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            if [ -n "$l_output" ]; then
                echo -e "- Passing Values:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            fi
            echo -e "- End check - Ensure inactive password lock is configured" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    ensure_inactive_password_lock_configured_fix()
    {
        echo -e "- Start remediation - Ensure inactive password lock is configured" | tee -a "$LOG" 2>> "$ELOG"

        # Set INACTIVE in useradd
        if ! useradd -D | grep -Piq -- 'INACTIVE\s*=\s*([1-9]|[1-3][0-9]|4[0-5])\b'; then
            echo -e "- Updating INACTIVE default in useradd" | tee -a "$LOG" 2>> "$ELOG"
            useradd -D -f 45
        fi

        # Check if test should be set to manual instead
        if grep -Piq -- 'root' <<< "$(awk -F: '($2~/^\$.+\$/) {if($7 > 45 || $7 < 0)print $1 " " $7}' /etc/shadow)"; then
            echo -e "- The password inactivity value for 'root' is out of compliance \n- Please update root's password inactivity value" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- The Build Kit will not update root's password expiration to avoid unintentional system inaccessibility" | tee -a "$LOG" 2>> "$ELOG"
            l_test=manual
        fi

        # Update INACTIVE for users
        if [ -z "$l_test" ]; then
                l_users="$(awk -F: '($2~/^\$.+\$/) {if($7 > 45 || $7 < 0)print $1 " " $7}' /etc/shadow)"
        else
                l_users="$(awk -F: '($2~/^\$.+\$/) {if($7 > 45 || $7 < 0)print $1 " " $7}' /etc/shadow | grep -Pv -- 'root')"
        fi

        if [ -n "$l_users" ]; then
            while read l_user l_value; do
                # If the user can sudo to root AND if they haven't logged in within the past 45 days, do not change their INACTIVITY.  It could lock them out.  
                if ! ( sudo -l -U $l_user | grep -Piq -- 'not allowed' ) && ! (last --since -45days $l_user | grep -Pq -- "^$l_user") ; then
                    echo "- User: '$l_user' can sudo to root and has been inactive for at least 45 days.  Manual remediation required." | tee -a "$LOG" 2>> "$ELOG"
                    [ -z "$l_test" ] && l_test=manual
                else
                    if [ -n "$l_value" ]; then
                        case $l_os_name in
                            # On Ubuntu systems, if the INACTIVITY value is "-1", the chage command produces unexpected results
                            ubuntu)
                                if [ "$l_value" = "-1" ]; then
                                    echo "- User: '$l_user' has incorrect INACTIVITY value, manual remediation required for user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
                                    [ -z "$l_test" ] && l_test=manual
                                else 
                                    echo "- User: '$l_user' has INACTIVITY of: '$l_value', remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
                                    chage --inactive 45 "$l_user"
                                fi
                                ;;
                            *)
                                echo "- User: '$l_user' has INACTIVITY of: '$l_value', remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
                                chage --inactive 45 "$l_user"
                                ;;
                        esac
                    else
                        echo "- User: '$l_user' has does NOT have INACTIVITY set, remediating user: '$l_user'" | tee -a "$LOG" 2>> "$ELOG"
                        chage --inactive 45 "$l_user"
                    fi
                fi
            done <<< "$l_users"
        fi

        echo -e "- End remediation - Ensure inactive password lock is configured" | tee -a "$LOG" 2>> "$ELOG"
    }

    ensure_inactive_password_lock_configured_chk
    if [ "$?" = "101" ]; then
        [ -z "$l_test" ] && l_test="passed"
    else
        if [ "$l_test" != "NA" ]; then
            ensure_inactive_password_lock_configured_fix
            if [ "$l_test" != "manual" ]; then
                ensure_inactive_password_lock_configured_chk
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