#!/usr/bin/env bash
#
# # START METADATA
#   recommendation = 9296929d
#   function = ssh7_ensure_strong_key_exchange_algorithms_used
#   applicable =
# # END METADATA
#
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ssh7_ensure_strong_key_exchange_algorithms_used.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/04/20    Recommendation "Ensure only strong Key Exchange algorithms are used"
# Justin Brown       05/14/22    Updated to modern format
# David Neilson		 11/16/23	 Changed "$G_PM -y remove" to "$G_PM remove -y", and "grep -E" to "grep -P --""

ssh7_ensure_strong_key_exchange_algorithms_used()
{
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
   
   ssh7_ensure_strong_key_exchange_algorithms_used_chk()
	{
      	echo -e "- Start check - Ensure only strong Key Exchange algorithms are used" | tee -a "$LOG" 2>> "$ELOG"
      	l_output="" l_sshd_cmd="" l_sshd_config=""
      
      	if [ -z "$G_PQ" ] || [ -z "$G_PM" ] || [ -z "$G_PR" ]; then
         	nix_package_manager_set
      	fi
      
      	# Check is openssh-server is installed
      	if ! $G_PQ openssh-server >/dev/null ; then
    		l_test=NA
      	else
			if sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -Pq -- '^\h*kexalgorithms\h+([^#]+,)?(diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group-exchange-sha1)\b'; then
				l_output="- Weak algorithm found: $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -P -- '^\h*kexalgorithms\h+([^#]+,)?(diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group-exchange-sha1)\b')" && l_sshd_cmd="failed"
			else
				l_output="- No weak algorithm found in sshd -T -C output" && l_sshd_cmd="passed"
			fi
			
			if grep -Piq -- '^\h*kexalgorithms\h+([^#]+,)?(diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group-exchange-sha1)\b' /etc/ssh/sshd_config; then
				l_output="$l_output\n- Weak algorithm found: $(grep -Pi -- '^\h*kexalgorithms\h+([^#]+,)?(diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group-exchange-sha1)\b' /etc/ssh/sshd_config)" && l_sshd_config="failed"
			else
				l_output="$l_output\n- No weak algorithm found in sshd_config" && l_sshd_config="passed"
			fi
      	fi
      
		if [ "$l_sshd_cmd" = "passed" ] && [ "$l_sshd_config" = "passed" ]; then
			echo -e "- PASS:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure only strong Key Exchange algorithms are used" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo -e "- FAIL:\n$l_output" | tee -a "$LOG" 2>> "$ELOG"
			echo -e "- End check - Ensure only strong Key Exchange algorithms are used" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
   }
   
   ssh7_ensure_strong_key_exchange_algorithms_used_fix()
	{
		echo -e "- Start remediation - Ensure only strong Key Exchange algorithms are used" | tee -a "$LOG" 2>> "$ELOG"
		
		echo -e "- Weak ciphers that are used for authentication to the cryptographic module cannot be relied upon to provide confidentiality or integrity, and system data may be compromised. Therefore, it is recommended that the sshd configuration be reviewed and determine the action to be taken in accordance with site policy." | tee -a "$LOG" 2>> "$ELOG"
		
		l_test="manual"
		
		echo -e "- Start remediation - Ensure only strong Key Exchange algorithms are used" | tee -a "$LOG" 2>> "$ELOG"
   }
   
   ssh7_ensure_strong_key_exchange_algorithms_used_chk
	if [ "$?" = "101" ]; then
		[ -z "$l_test" ] && l_test="passed"
	else
		if [ "$l_test" != "NA" ]; then
			ssh7_ensure_strong_key_exchange_algorithms_used_fix
			if [ "$l_test" != "manual" ]; then
				ssh7_ensure_strong_key_exchange_algorithms_used_chk
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