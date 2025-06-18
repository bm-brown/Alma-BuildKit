#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = f0daf5d8
#   function = ensure_cron_daemon_enabled_active
#   applicable =
# # END METADATA
#
#
# CIS-LBK _MAIN Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_cron_daemon_enabled_active.sh
#
# Name              Date            Description
# ------------------------------------------------------------------------------------------------
# J Brown           11/12/22        Recommendation "Ensure cron daemon is enabled and active"
# David Neilson     06/22/24        Set l_test variable instead of running the "return" command if package manager is unknown or cron not installed.

ensure_cron_daemon_enabled_active()
{
    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test="" l_pkg=""

    nix_package_manager_set()
    {
        echo -e "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"
        if command -v rpm &>/dev/null; then
            echo -e "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
            G_PQ="rpm -q"
            command -v yum &> /dev/null && G_PM="yum" && echo -e "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
            command -v dnf &> /dev/null && G_PM="dnf" && echo -e "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
            command -v zypper &> /dev/null && G_PM="zypper" && echo -e "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
            G_PR="$G_PM remove -y"
            export G_PQ G_PM G_PR
            echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        elif command -v dpkg &> /dev/null; then
            echo -e "- system is apt based\n- system uses apt package manager" | tee -a "$LOG" 2>> "$ELOG"
            G_PQ="dpkg -s"
            G_PM="apt"
            G_PR="$G_PM -y purge"
            export G_PQ G_PM G_PR
            echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            echo -e "- FAIL:\n- Unable to determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
            G_PQ="unknown"
            G_PM="unknown"
            export G_PQ G_PM G_PR
            echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    ensure_cron_daemon_enabled_active_chk()
    {
        echo -e "- Start check - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"
        l_output="" l_output2=""

        # Collect cron status.
        l_enabled=$(systemctl list-unit-files | awk '$1~/^crond?\.service/{print $2}')
        l_running=$(systemctl list-units | awk '$1~/^crond?\.service/{print $3}')

        # Determine if cron is enabled.
        if [ "$l_enabled" = "enabled" ]; then
            l_output="$l_output\n- cron daemon enabled status is: $l_enabled"
        else
            l_output2="$l_output2\n- cron daemon enabled status is: $l_enabled"
        fi

        # Determine if cron is active.
        if [ "$l_running" = "active" ]; then
            l_output="$l_output\n- cron daemon running status is: $l_running"
        else
            [ -n "$l_running" ] && l_output2="$l_output2\n- cron daemon running status is: $l_running"
            [ -z "$l_running" ] && l_output2="$l_output2\n- cron daemon running status is: unknown"
        fi

        if [ -z "$l_output2" ]; then
            # print the reason why we are passing
            echo -e "- PASS: cron daemon is enabled and running"
            echo -e "- Passing Value:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        else
            # print the reason why we are failing
            echo -e "- FAILED: cron daemon is NOT enabled and/or running"
            echo -e "- Failing Value:\n$l_output2" | tee -a "$LOG" 2>> "$ELOG"
            if [ -n "$l_output" ]; then
                echo -e "- Passing Value:\n$l_output"
            fi
            echo -e "- End check - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_FAIL:-102}"
        fi
    }

    ensure_cron_daemon_enabled_active_fix()
    {
        echo -e "- Start remediation - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"

        if systemctl is-enabled "$(systemctl list-unit-files | awk '$1~/^crond?\.service/{print $1}')" | grep -Pq -- 'masked'; then
            echo -e "- Unmasking cron service" | tee -a "$LOG" 2>> "$ELOG"
            systemctl unmask "$(systemctl list-unit-files | awk '$1~/^crond?\.service/{print $1}')"
        fi

        echo -e "- Enabling and starting cron service." | tee -a "$LOG" 2>> "$ELOG"
        systemctl --now enable "$(systemctl list-unit-files | awk '$1~/^crond?\.service/{print $1}')"

        echo -e "- End remediation - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"
    }

    # Set package manager information
    if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
        nix_package_manager_set
        [ $? -ne 101 ] && l_pkg="false"
    fi

    # Determine if cron or cronie is installed.  If it is, run the chk and fix subfunctions.
    echo -e "- Determining if cron is installed on the system" | tee -a "$LOG" 2>> "$ELOG"
    if [ "$l_pkg" != "false" ] && ( $G_PQ cron &> /dev/null || $G_PQ cronie &> /dev/null ); then
        ensure_cron_daemon_enabled_active_chk
        if [ $? -eq 101 ]; then
            [ -z "$l_test" ] && l_test="passed"
        else
            ensure_cron_daemon_enabled_active_fix
            if [ "$l_test" != "manual" ]; then
                ensure_cron_daemon_enabled_active_chk
                if [ $? -eq 101 ]; then
                    [ "$l_test" != "failed" ] && l_test="remediated"
                else
                    l_test="failed"
                fi
            fi
        fi
    else
        if [ "$l_pkg" = "false" ]; then
            l_test="manual"
            echo -e "- MANUAL:\n- Unable to determine system's package manager"  | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"
        else
            [ -z "$l_test" ] && l_test="NA"
            echo -e "- PASS:\n- cron is not installed"  | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure cron daemon is enabled and active" | tee -a "$LOG" 2>> "$ELOG"
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
