#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = f2393f16
#   function = ensure_xinetd_services_not_in_use
#   applicable =
# # END METADATA
#
#
#
#
# CIS-LBK _Main Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_xinetd_services_not_in_use.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# J Brown             10/14/23    Recommendation "Ensure xinetd services are not in use"
#

ensure_xinetd_services_not_in_use()
{
    nix_package_manager_set()
    {
        echo -e "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"

        if command -v rpm 2>/dev/null; then
            echo -e "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
            G_PQ="rpm -q"
            command -v yum 2>/dev/null && G_PM="yum" && echo "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
            command -v dnf 2>/dev/null && G_PM="dnf" && echo "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
            command -v zypper 2>/dev/null && G_PM="zypper" && echo "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
            G_PR="$G_PM remove -y"
            export G_PQ G_PM G_PR
            echo -e "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        elif command -v dpkg 2>/dev/null; then
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

    echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
    l_test=""

    ensure_xinetd_services_not_in_use_chk()
    {
        echo -e "- Start check - Ensure xinetd services are not in use" | tee -a "$LOG" 2>> "$ELOG"

        if $G_PQ xinetd &>/dev/null; then
            if systemctl is-enabled xinetd.service 2>/dev/null | grep 'enabled' || systemctl is-active xinetd.service 2>/dev/null | grep '^active'; then
                echo -e "- FAILED:\n- xinetd.service is enabled or running"  | tee -a "$LOG" 2>> "$ELOG"
                echo -e "- End check - Ensure xinetd services are not in use" | tee -a "$LOG" 2>> "$ELOG"
                return "${XCCDF_RESULT_FAIL:-102}"
            else
                echo -e "- PASS:\n- xinetd.service is NOT enabled or running"  | tee -a "$LOG" 2>> "$ELOG"
                echo -e "- End check - Ensure xinetd services are not in use" | tee -a "$LOG" 2>> "$ELOG"
                return "${XCCDF_RESULT_PASS:-101}"
            fi
        else
            echo -e "- PASS:\n- xinetd package is NOT installed"  | tee -a "$LOG" 2>> "$ELOG"
            echo -e "- End check - Ensure xinetd services are not in use" | tee -a "$LOG" 2>> "$ELOG"
            return "${XCCDF_RESULT_PASS:-101}"
        fi
    }

    ensure_xinetd_services_not_in_use_fix()
    {
        echo -e "- Start remediation - Ensure xinetd services are not in use" | tee -a "$LOG" 2>> "$ELOG"

            echo -e "- Stopping service" | tee -a "$LOG" 2>> "$ELOG"
            systemctl stop xinetd.service
            echo -e "- Masking service" | tee -a "$LOG" 2>> "$ELOG"
            systemctl mask xinetd.service

        echo -e "- End remediation - Ensure xinetd services are not in use" | tee -a "$LOG" 2>> "$ELOG"
    }

    # Set package manager information
    if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
        nix_package_manager_set
        [ $? -ne 101 ] && l_pkg="false"
    fi

    if [ "$l_pkg" != "false" ]; then
        ensure_xinetd_services_not_in_use_chk
        if [ $? -eq 101 ]; then
            [ -z "$l_test" ] && l_test="passed"
        else
            if [ "$l_test" != "NA" ]; then
                ensure_xinetd_services_not_in_use_fix
                if [ "$l_test" != "manual" ]; then
                    ensure_xinetd_services_not_in_use_chk
                    if [ $? -eq 101 ]; then
                        [ "$l_test" != "failed" ] && l_test="remediated"
                    else
                        l_test="failed"
                    fi
                fi
            fi
        fi
    else
        echo -e "- MANUAL:\n- Unable to determine system's package manager"  | tee -a "$LOG" 2>> "$ELOG"
        return "${XCCDF_RESULT_PASS:-106}"
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