#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = a35c7f49
#   function = ensure_gpg_keys_configured
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_gpg_keys_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure GPG keys are configured"
# Justin Brown       04/18/22    Updated to modern format
#

ensure_gpg_keys_configured()
{
	# Start recommendation entry for verbose log and output to screen
	echo -e "\n**************************************************\n- $(date +%d-%b-%Y' '%T)\n- Start Recommendation \"$RN - $RNA\"" | tee -a "$LOG" 2>> "$ELOG"
	l_test=""

	ensure_gpg_keys_configured_chk()
	{
		echo -e "- Start check - Ensure GPG keys are configured" | tee -a "$LOG" 2>> "$ELOG"

		l_repo_gpg_keys="$(grep -r gpgkey /etc/yum.repos.d/* /etc/dnf/dnf.conf)"
		l_local_gpg_keys="$(for PACKAGE in $(find /etc/pki/rpm-gpg/ -type f -exec rpm -qf {} \; | sort -u); do rpm -q --queryformat "%{NAME}-%{VERSION} %{PACKAGER} %{SUMMARY}\\n" "${PACKAGE}"; done)"

		echo -e "- Repo Keys:\n$l_repo_gpg_keys\n- Local GPG Keys:\n$l_local_gpg_keys"  | tee -a "$LOG" 2>> "$ELOG"
		echo -e "- End check - Ensure GPG keys are configured" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-106}"
	}

	ensure_gpg_keys_configured_fix()
	{
		echo -e "- Start Remediation - Ensure GPG keys are configured" | tee -a "$LOG" 2>> "$ELOG"

		echo -e "- Update your package manager GPG keys in accordance with site policy."  | tee -a "$LOG" 2>> "$ELOG"
		l_test="manual"

		echo -e "- End Remediation - Ensure GPG keys are configured" | tee -a "$LOG" 2>> "$ELOG"
	}

	ensure_gpg_keys_configured_chk
	if [ "$?" = "101" ] ; then
		[ -z "$l_test" ] && l_test="passed"
	else
		ensure_gpg_keys_configured_fix
		if [ "$l_test" != "manual" ] ; then
			ensure_gpg_keys_configured_chk
			if [ "$?" = "101" ] ; then
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
