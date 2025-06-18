#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 8d87a0dc
#   function = fed_ensure_latest_version_pam_installed
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_latest_version_pam_installed.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Randie Bejar       10/16/23    Recommendation "Ensure latest version of pam installed"
#

fed_ensure_latest_version_pam_installed()
{
    # Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

    nix_package_manager_set()
	{
		echo "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"
		if command -v rpm 2>/dev/null; then
			echo "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="rpm -q"
			command -v yum 2>/dev/null && G_PM="yum" && echo "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
			command -v dnf 2>/dev/null && G_PM="dnf" && echo "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
			command -v zypper 2>/dev/null && G_PM="zypper" && echo "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PR="$G_PM remove -y"
			export G_PQ G_PM G_PR
			echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		elif command -v dpkg 2>/dev/null; then
			echo -e "- system is apt based\n- system uses apt package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="dpkg -s"
			G_PM="apt"
			G_PR="$G_PM -y purge"
			export G_PQ G_PM G_PR
			echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n- Unable to determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			G_PQ="unknown"
			G_PM="unknown"
			export G_PQ G_PM G_PR
			echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

    fed_ensure_latest_version_pam_installed_chk()
    {
        echo -e "- Start check - Ensure latest version of pam installed" | tee -a "$LOG" 2>> "$ELOG"
        l_output=""

        # Set package manager information
		if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
			nix_package_manager_set
			[ "$?" != "101" ] && l_output="- Unable to determine system's package manager"
		fi

		# Check to see if latest version of pam is installed.  If not, we fail.
		if [ -z "$l_output" ]; then
			case "$G_PQ" in
				*rpm*)
					if $G_PQ pam|grep -Pi '^pam-(1.5.[1-9][0-9]*-|1.[6-9]+|[2-9]+)'; then
						echo -e "- PASSED:\n- latest version of pam is installed" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure latest version of pam is installed" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-101}"
					else
						echo -e "- FAILED:\n- latest version of pam is NOT installed" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure latest version of pam is installed" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-102}"
					fi
				;;
				*dpkg*)
					if $G_PQ libpam-runtime; then
						echo -e "- PASSED:\n- pam package installed on the system" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure latest version of pam is installed" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-101}"
					else
						echo -e "- FAILED:\n- pam is not installed" | tee -a "$LOG" 2>> "$ELOG"
						echo -e "- End check - Ensure latest version of pam is installed" | tee -a "$LOG" 2>> "$ELOG"
						return "${XCCDF_RESULT_PASS:-102}"
					fi
				;;
			esac
		else
			# If we can't determine the pkg manager, need manual remediation
			l_pkgmgr="$l_output"
			echo -e "- FAILED:\n- $l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure latest version of pam is installed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-106}"
		fi
    }

    fed_ensure_latest_version_pam_installed_fix()
    {
        echo -e "- Start remediation - Ensure latest version pam installed" | tee -a "$LOG" 2>> "$ELOG"

        if ! $G_PQ pam | grep -Eq 'pam-\S+' || ! $G_PQ pam|grep -Pi '^pam-(1.5.1-|1.[6-9]+|[2-9]+)'; then
			$G_PM install -y pam
		fi

		case "$G_PQ" in
			*rpm*)
				echo -e "- Installing package" | tee -a "$LOG" 2>> "$ELOG"
				$G_PM install -y pam
			;;
			*dpkg*)
				echo -e "- Installing package" | tee -a "$LOG" 2>> "$ELOG"
				$G_PM install -y libpam-runtime
			;;
		esac

		echo -e "- End remediation - Ensure pam is installed." | tee -a "$LOG" 2>> "$ELOG"
    }

    fed_ensure_latest_version_pam_installed_chk
	if [ $? -eq 101 ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		fed_ensure_latest_version_pam_installed_fix
		if [ "$l_test" != "manual" ]; then
			fed_ensure_latest_version_pam_installed_chk
			if [ $? -eq 101 ]; then
				[ "$l_test" != "failed" ] && l_test="remediated"
			else
				l_test="failed"
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
