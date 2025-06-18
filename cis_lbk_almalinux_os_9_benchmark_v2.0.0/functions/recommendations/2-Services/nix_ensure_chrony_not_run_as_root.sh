#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = c9fcaca0
#   function = ensure_chrony_not_run_as_root
#   applicable =
# # END METADATA
#
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_chrony_not_run_as_root.sh
#
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# J Brown               08/28/23    Recommendation "Ensure chrony is not run as the root user"
#

ensure_chrony_not_run_as_root()
{
	echo
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

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

	ensure_chrony_not_run_as_root_chk()
	{
		echo "- Start check - Ensure chrony is not run as the root user" | tee -a "$LOG" 2>> "$ELOG"
		l_output="" l_output2=""
		l_pkgmgr=""

		# Set package manager information
		if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
			nix_package_manager_set
			[ "$?" != "101" ] && l_output2="$l_output2\n- Unable to determine system's package manager"
		fi

		# Check to see if the chrony package is installed.  If not, we mark N/A.
		if [ -z "$l_output2" ]; then
			case "$G_PQ" in
				*rpm*)
					if $G_PQ chrony | grep "not installed" ; then
						l_output="$l_output\n- Chrony package is NOT installed"
						l_test="NA"
						return "${XCCDF_RESULT_PASS:-106}"
					fi
				;;
				*dpkg*)
					if ! $G_PQ chrony; then
						l_output="$l_output\n- Chrony package is NOT installed"
						l_test="NA"
						return "${XCCDF_RESULT_PASS:-106}"
					fi
				;;
			esac
		else
			# If we can't determine the pkg manager, need manual remediation
			l_pkgmgr="$l_output2"
			echo -e "- FAILED:\n- $l_output2" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure chrony is not run as the root user" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-102}"
		fi

		# Determine if OPTIONS is set correctly
		if grep -Pqi -- '^\h*OPTIONS=\"?\h*-u\h+root\b' /etc/sysconfig/chronyd; then
			l_output2="$l_output2\n- Chrony IS configured to run as root\n $(grep -Pi -- '^\h*OPTIONS=\"?\h*-u\h+root\b' /etc/sysconfig/chronyd)"
		else
			l_output="$l_output\n- Chrony package is NOT configured to run as root"
		fi

		if [ -z "$l_output2" ]; then
			echo -e "- PASS:\n- chrony is configured correctly"  | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure chrony is not run as the root user" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAILED:\n$l_output2"  | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure chrony is not run as the root user" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	ensure_chrony_not_run_as_root_fix()
	{
		echo "- Start remediation - Ensure chrony is not run as the root user" | tee -a "$LOG" 2>> "$ELOG"

		echo "- Remediating chrony configuration" | tee -a "$LOG" 2>> "$ELOG"
		sed -ri 's/(^\s*OPTIONS=\"?\s*)(-\s*u)(\s+root)(.+$)/\1\2 chrony\4/' /etc/sysconfig/chronyd

		echo "- Start remediation - Ensure chrony is not run as the root user" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_chrony_not_run_as_root_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		if [ "$l_test" != "NA" ]; then
			ensure_chrony_not_run_as_root_fix
			ensure_chrony_not_run_as_root_chk
			if [ "$?" = "101" ]; then
				l_test="remediated"
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