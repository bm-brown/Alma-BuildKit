#!/usr/bin/env bash

#
# CIS AlmaLinux OS 9 Benchmark v2.0.0 Build Kit script
#
# Name              Date		Description
# ------------------------------------------------------------------------------------------------
# GLus	2024-07-29	    Build Kit: "CIS AlmaLinux OS 9 Benchmark v2.0.0"
#

# Ensure script is executed in bash
if [ ! "$BASH_VERSION" ] ; then
	exec /bin/bash "$0" "$@"
fi

echo -e "
\n\t########################################################\n\n
\t\t\tCIS Benchmark\n\n
\t\tCIS AlmaLinux OS 9 Benchmark v2.0.0\n\n
\t\t\tLinux Build Kit\n\n
\t\tCIS AlmaLinux OS 9 Benchmark v2.0.0.1\n\n
\t########################################################\n"

# Set global variables
SILENT="false"
PROFILE=""
PDFURL="https://workbench.cisecurity.org/benchmarks/18208"
BDIR="$(dirname "$(readlink -f "$0")")"
FDIR=$BDIR/functions
RECDIR="$FDIR"/recommendations
GDIR="$FDIR"/general
LDIR=$BDIR/logs
# RDIR=$BDIR/backup
DTG=$(date +%m_%d_%Y_%H%M)
mkdir $LDIR/$DTG
# mkdir $RDIR/$DTG
LOGDIR=$LDIR/$DTG
# BKDIR=$RDIR/$DTG
LOG=$LOGDIR/CIS-LBK_verbose.log
SLOG=$LOGDIR/CIS-LBK.log
ELOG=$LOGDIR/CIS-LBK_error.log
FRLOG=$LOGDIR/CIS-LBK_failed.log
MANLOG=$LOGDIR/CIS-LBK_manual.log
SKIPLOG=$LOGDIR/CIS-LBK_skipped.log
passed_recommendations="0"
failed_recommendations="0"
remediated_recommendations="0"
not_applicable_recommendations="0"
excluded_recommendations="0"
manual_recommendations="0"
skipped_recommendations="0"
total_recommendations="0"

# Populate header of log files
# Standard Log
echo -e "*****************************************************************
*****************************************************************
 - The entries below countain the result of each benchmark item.
 - To investigate any issues further, open the corresponding CIS Benchmark PDF and navigate to the same recommendation number and name in the document.
 - A copy of the benchmark PDF document can be obtained at the following URL:\n\n   $PDFURL\n
*****************************************************************" >> "$SLOG"

# Error Log
echo -e "*****************************************************************
*****************************************************************
 - Each entry below countains any errors encountered in the remediation process.
 - To investigate any issues further, open the corresponding CIS Benchmark PDF and navigate to the same recommendation number and name in the document.
 - Sections describing the recommendation, the impact, and how to audit and remediate can be found for each item. Follow those instructions given in order to investigate the error and/or bring the system into compliance with the benchmark.
 - A copy of the benchmark PDF document can be obtained at the following URL:\n\n   $PDFURL\n
*****************************************************************" >> "$ELOG"

# Fail Log
echo -e "*****************************************************************
*****************************************************************
 - Each entry below countains a specific recommendation title that failed remediation and should be addressed.
 - To investigate any failing recommendations further, open the corresponding CIS Benchmark PDF and navigate to the same recommendation number and name in the document.
 - Sections describing the recommendation, the impact, and how to audit and remediate can be found for each item. Follow those instructions given in order to investigate the error and/or bring the system into compliance with the benchmark.
 - A copy of the benchmark PDF document can be obtained at the following URL:\n\n   $PDFURL\n
*****************************************************************" >> "$FRLOG"

# Manual Log
echo -e "*****************************************************************
*****************************************************************
 - Each entry below countains a specific recommendation title that requires manual remediation and should be addressed.
 - To properly remediate each manual recommendation, open the corresponding CIS Benchmark PDF and navigate to the same recommendation number and name in the document.
 - Steps to audit and remediate that recommendation can be found for each item. Follow those instructions given in order to bring the system into compliance with the benchmark.
 - It is sometimes helpful after following the steps in the Remediation section to follow up by performing the steps in the Audit section to verify that the remediation was performed successfully.
 - A copy of the benchmark PDF document can be obtained at the following URL:\n\n   $PDFURL\n
*****************************************************************" >> "$MANLOG"

# Skipped Log
echo -e "*****************************************************************
*****************************************************************
 - Each entry below countains a specific recommendation title that was included on the exclusion list or was found to be Not Applicable to the target system.
 - Each entry below should be verified against either the exclude list or it's non-applicability validated.
 - A copy of the benchmark PDF document can be obtained at the following URL:\n\n   $PDFURL\n
*****************************************************************" >> "$SKIPLOG"

# Load functions (Order matters)
for func in "$GDIR"/*.sh; do
	[ -e "$func" ] || break
	. "$func"
done
for func in "$RECDIR"/**/*.sh; do
	[ -e "$func" ] || break
	. "$func"
done

# Collect CLI Parameters
while getopts hsp:? flag
do
    case "${flag}" in
		h)
			CLI_HELP
			exit;;
        s) SILENT="true";;
        p) PROFILE=${OPTARG};;
		?)
			CLI_HELP
			exit;;
    esac
done

#Clear the screen for output
clear

if [ "$SILENT" != "true" ]; then
	# Display the build kit banner
	BANR
fi

# Ensure script is being run as root
ROOTUSRCK

if [ "$SILENT" != "true" ]; then
	# Display the terms of use
	TERMS_OF_USE

	# Display CIS Linux Build Kit warning banner
	WARBNR
fi

#run_profile=L2S # Uncomment this line to provide profile to be run manually
# Profile Options:
# L1S - For Level 1 Server
# L1W - For Level 1 Workstation
# L2S - For Level 2 Server
# L2W - For Level 2 Workstation
# Have user select profile to run
select_profile
# Recommediations This is where a BM specific script begins.

# 1 - Initial Setup

# 1.1 - Filesystem

# 1.1.1 - Configure Filesystem Kernel Modules

RN="1.1.1.1"
RNA="Ensure cramfs kernel module is not available"
profile="L1S L1W"
REC="ensure_cramfs_kernel_module_not_available"
FSN="nix_ensure_cramfs_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.2"
RNA="Ensure freevxfs kernel module is not available"
profile="L1S L1W"
REC="ensure_freevxfs_kernel_module_not_available"
FSN="nix_ensure_freevxfs_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.3"
RNA="Ensure hfs kernel module is not available"
profile="L1S L1W"
REC="ensure_hfs_kernel_module_not_available"
FSN="nix_ensure_hfs_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.4"
RNA="Ensure hfsplus kernel module is not available"
profile="L1S L1W"
REC="ensure_hfsplus_kernel_module_not_available"
FSN="nix_ensure_hfsplus_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.5"
RNA="Ensure jffs2 kernel module is not available"
profile="L1S L1W"
REC="ensure_jffs2_kernel_module_not_available"
FSN="nix_ensure_jffs2_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.6"
RNA="Ensure squashfs kernel module is not available"
profile="L2S L2W"
REC="ensure_squashfs_kernel_module_not_available"
FSN="nix_ensure_squashfs_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.7"
RNA="Ensure udf kernel module is not available"
profile="L2S L2W"
REC="ensure_udf_kernel_module_not_available"
FSN="nix_ensure_udf_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.8"
RNA="Ensure usb-storage kernel module is not available"
profile="L1S L2W"
REC="ensure_usb_storage_kernel_module_not_available"
FSN="nix_ensure_usb_storage_kernel_module_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.9"
RNA="Ensure unused filesystems kernel modules are not available"
profile="L1S L1W"
REC="ensure_unused_filesystems_kernel_modules_not_available"
FSN="nix_ensure_unused_filesystems_kernel_modules_not_available.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2 - Configure Filesystem Partitions

# 1.1.2.1 - Configure /tmp

RN="1.1.2.1.1"
RNA="Ensure /tmp is a separate partition"
profile="L1S L1W"
REC="ensure_tmp_separate_partition"
FSN="nix_ensure_tmp_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.1.2"
RNA="Ensure nodev option set on /tmp partition"
profile="L1S L1W"
REC="ensure_nodev_set_tmp_partition"
FSN="nix_ensure_nodev_set_tmp_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.1.3"
RNA="Ensure nosuid option set on /tmp partition"
profile="L1S L1W"
REC="ensure_nosuid_set_tmp_partition"
FSN="nix_ensure_nosuid_set_tmp_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.1.4"
RNA="Ensure noexec option set on /tmp partition"
profile="L1S L1W"
REC="ensure_noexec_set_tmp_partition"
FSN="nix_ensure_noexec_set_tmp_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2.2 - Configure /dev/shm

RN="1.1.2.2.1"
RNA="Ensure /dev/shm is a separate partition"
profile="L1S L1W"
REC="ensure_dev_shm_separate_partition"
FSN="nix_ensure_dev_shm_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.2.2"
RNA="Ensure nodev option set on /dev/shm partition"
profile="L1S L1W"
REC="ensure_nodev_set_dev_shm_partition"
FSN="nix_ensure_nodev_set_dev_shm_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.2.3"
RNA="Ensure nosuid option set on /dev/shm partition"
profile="L1S L1W"
REC="ensure_nosuid_set_dev_shm_partition"
FSN="nix_ensure_nosuid_set_dev_shm_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.2.4"
RNA="Ensure noexec option set on /dev/shm partition"
profile="L1S L1W"
REC="ensure_noexec_set_dev_shm_partition"
FSN="nix_ensure_noexec_set_dev_shm_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2.3 - Configure /home

RN="1.1.2.3.1"
RNA="Ensure separate partition exists for /home"
profile="L2S L2W"
REC="ensure_home_separate_partition"
FSN="nix_ensure_home_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.3.2"
RNA="Ensure nodev option set on /home partition"
profile="L1S L1W"
REC="ensure_nodev_set_home_partition"
FSN="nix_ensure_nodev_set_home_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.3.3"
RNA="Ensure nosuid option set on /home partition"
profile="L1S L1W"
REC="ensure_nosuid_set_home_partition"
FSN="nix_ensure_nosuid_set_home_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2.4 - Configure /var

RN="1.1.2.4.1"
RNA="Ensure separate partition exists for /var"
profile="L2S L2W"
REC="ensure_var_separate_partition"
FSN="nix_ensure_var_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.4.2"
RNA="Ensure nodev option set on /var partition"
profile="L1S L1W"
REC="ensure_nodev_set_var_partition"
FSN="nix_ensure_nodev_set_var_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.4.3"
RNA="Ensure nosuid option set on /var partition"
profile="L1S L1W"
REC="ensure_nosuid_set_var_partition"
FSN="nix_ensure_nosuid_set_var_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2.5 - Configure /var/tmp

RN="1.1.2.5.1"
RNA="Ensure separate partition exists for /var/tmp"
profile="L2S L2W"
REC="ensure_var_tmp_separate_partition"
FSN="nix_ensure_var_tmp_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.5.2"
RNA="Ensure nodev option set on /var/tmp partition"
profile="L1S L1W"
REC="ensure_nodev_set_var_tmp_partition"
FSN="nix_ensure_nodev_set_var_tmp_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.5.3"
RNA="Ensure nosuid option set on /var/tmp partition"
profile="L1S L1W"
REC="ensure_nosuid_set_var_tmp_partition"
FSN="nix_ensure_nosuid_set_var_tmp_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.5.4"
RNA="Ensure noexec option set on /var/tmp partition"
profile="L1S L1W"
REC="ensure_noexec_set_var_tmp_partition"
FSN="nix_ensure_noexec_set_var_tmp_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2.6 - Configure /var/log

RN="1.1.2.6.1"
RNA="Ensure separate partition exists for /var/log"
profile="L2S L2W"
REC="ensure_var_log_separate_partition"
FSN="nix_ensure_var_log_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.6.2"
RNA="Ensure nodev option set on /var/log partition"
profile="L1S L1W"
REC="ensure_nodev_set_var_log_partition"
FSN="nix_ensure_nodev_set_var_log_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.6.3"
RNA="Ensure nosuid option set on /var/log partition"
profile="L1S L1W"
REC="ensure_nosuid_set_var_log_partition"
FSN="nix_ensure_nosuid_set_var_log_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.6.4"
RNA="Ensure noexec option set on /var/log partition"
profile="L1S L1W"
REC="ensure_noexec_set_var_log_partition"
FSN="nix_ensure_noexec_set_var_log_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.1.2.7 - Configure /var/log/audit

RN="1.1.2.7.1"
RNA="Ensure separate partition exists for /var/log/audit"
profile="L2S L2W"
REC="ensure_var_log_audit_separate_partition"
FSN="nix_ensure_var_log_audit_separate_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.7.2"
RNA="Ensure nodev option set on /var/log/audit partition"
profile="L1S L1W"
REC="ensure_nodev_set_var_log_audit_partition"
FSN="nix_ensure_nodev_set_var_log_audit_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.7.3"
RNA="Ensure nosuid option set on /var/log/audit partition"
profile="L1S L1W"
REC="ensure_nosuid_set_var_log_audit_partition"
FSN="nix_ensure_nosuid_set_var_log_audit_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2.7.4"
RNA="Ensure noexec option set on /var/log/audit partition"
profile="L1S L1W"
REC="ensure_noexec_set_var_log_audit_partition"
FSN="nix_ensure_noexec_set_var_log_audit_partition.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.2 - Package Management

# 1.2.1 - Configure Package Repositories

RN="1.2.1.1"
RNA="Ensure GPG keys are configured"
profile="L1S L1W"
REC="ensure_gpg_keys_configured"
FSN="nix_ensure_gpg_keys_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.2.1.2"
RNA="Ensure gpgcheck is globally activated"
profile="L1S L1W"
REC="fed_ensure_gpgcheck_globally_activated"
FSN="nix_fed_ensure_gpgcheck_globally_activated.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.2.1.3"
RNA="Ensure repo_gpgcheck is globally activated"
profile="L2S L2W"
REC="fed_ensure_repo_gpgcheck_globally_activated"
FSN="nix_fed_ensure_repo_gpgcheck_globally_activated.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.2.1.4"
RNA="Ensure package manager repositories are configured"
profile="L1S L1W"
REC="ensure_package_manager_repositories_configured"
FSN="nix_ensure_package_manager_repositories_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.2.2 - Configure Package Updates

RN="1.2.2.1"
RNA="Ensure updates, patches, and additional security software are installed"
profile="L1S L1W"
REC="ensure_updates_patches_security_software_installed"
FSN="nix_ensure_updates_patches_security_software_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.3 - Mandatory Access Control

# 1.3.1 - Configure SELinux

RN="1.3.1.1"
RNA="Ensure SELinux is installed"
profile="L1S L1W"
REC="fed_ensure_selinux_installed"
FSN="nix_fed_ensure_selinux_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.2"
RNA="Ensure SELinux is not disabled in bootloader configuration"
profile="L1S L1W"
REC="fed34_ensure_selinux_not_disabled_bootloader_configuration"
FSN="nix_fed34_ensure_selinux_not_disabled_bootloader_configuration.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.3"
RNA="Ensure SELinux policy is configured"
profile="L1S L1W"
REC="fed_ensure_selinux_policy_configured"
FSN="nix_fed_ensure_selinux_policy_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.4"
RNA="Ensure the SELinux mode is not disabled"
profile="L1S L1W"
REC="fed_ensure_selinux_state_enforcing_or_permissive"
FSN="nix_fed_ensure_selinux_state_enforcing_or_permissive.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.5"
RNA="Ensure the SELinux mode is enforcing"
profile="L2S L2W"
REC="fed_ensure_selinux_state_enforcing"
FSN="nix_fed_ensure_selinux_state_enforcing.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.6"
RNA="Ensure no unconfined services exist"
profile="L2S L2W"
REC="fed_ensure_no_unconfined_services_exist"
FSN="nix_fed_ensure_no_unconfined_services_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.7"
RNA="Ensure the MCS Translation Service (mcstrans) is not installed"
profile="L1S L1W"
REC="fed_ensure_mcstrans_not_installed"
FSN="nix_fed_ensure_mcstrans_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.1.8"
RNA="Ensure SETroubleshoot is not installed"
profile="L1S"
REC="fed_ensure_setroubleshoot_not_installed"
FSN="nix_fed_ensure_setroubleshoot_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.4 - Configure Bootloader

RN="1.4.1"
RNA="Ensure bootloader password is set"
profile="L1S L1W"
REC="fed_ensure_bootloader_password_set"
FSN="nix_fed_ensure_bootloader_password_set.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.4.2"
RNA="Ensure access to bootloader config is configured"
profile="L1S L1W"
REC="fed34_ensure_permissions_bootloader_config_configured"
FSN="nix_fed34_ensure_permissions_bootloader_config_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.5 - Configure Additional Process Hardening

RN="1.5.1"
RNA="Ensure address space layout randomization is enabled"
profile="L1S L1W"
REC="ensure_address_space_layout_randomization_enabled"
FSN="nix_ensure_address_space_layout_randomization_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.5.2"
RNA="Ensure ptrace_scope is restricted"
profile="L1S L1W"
REC="ensure_ptrace_scope_restricted"
FSN="nix_ensure_ptrace_scope_restricted.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.5.3"
RNA="Ensure core dump backtraces are disabled"
profile="L1S L1W"
REC="ensure_core_dump_backtraces_disabled"
FSN="nix_ensure_core_dump_backtraces_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.5.4"
RNA="Ensure core dump storage is disabled"
profile="L1S L1W"
REC="ensure_core_dump_storage_disabled"
FSN="nix_ensure_core_dump_storage_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.6 - Configure system wide crypto policy

RN="1.6.1"
RNA="Ensure system wide crypto policy is not set to legacy"
profile="L1S L1W"
REC="fed_ensure_system-wide_crypto_policy_not_legacy"
FSN="nix_fed_ensure_system-wide_crypto_policy_not_legacy.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.2"
RNA="Ensure system wide crypto policy is not set in sshd configuration"
profile="L1S L1W"
REC="fed_ensure_system-wide_crypto_policy_not_over-ridden"
FSN="nix_fed_ensure_system-wide_crypto_policy_not_over-ridden.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.3"
RNA="Ensure system wide crypto policy disables sha1 hash and signature support"
profile="L1S L1W"
REC="fed_ensure_system_wide_crypto_policy_disables_sha1_hash_and_signature"
FSN="nix_fed_ensure_system_wide_crypto_policy_disables_sha1_hash_and_signature.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.4"
RNA="Ensure system wide crypto policy disables macs less than 128 bits"
profile="L1S L1W"
REC="fed_ensure_system_wide_crypto_policy_disables_macs_less_than_128bits"
FSN="nix_fed_ensure_system_wide_crypto_policy_disables_macs_less_than_128bits.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.5"
RNA="Ensure system wide crypto policy disables cbc for ssh"
profile="L1S L1W"
REC="fed_ensure_system_wide_crypto_policy_disables_cbc_for_ssh"
FSN="nix_fed_ensure_system_wide_crypto_policy_disables_cbc_for_ssh.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.6"
RNA="Ensure system wide crypto policy disables chacha20-poly1305 for ssh"
profile="L1S L1W"
REC="fed_ensure_system_wide_crypto_policy_disables_chacha20_poly1305"
FSN="nix_fed_ensure_system_wide_crypto_policy_disables_chacha20_poly1305.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.7"
RNA="Ensure system wide crypto policy disables EtM for ssh"
profile="L1S L1W"
REC="fed_ensure_system_wide_crypto_policy_disables_etm_for_ssh"
FSN="nix_fed_ensure_system_wide_crypto_policy_disables_etm_for_ssh.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.7 - Configure Command Line Warning Banners

RN="1.7.1"
RNA="Ensure message of the day is configured properly"
profile="L1S L1W"
REC="ensure_motd_configured"
FSN="nix_ensure_motd_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.2"
RNA="Ensure local login warning banner is configured properly"
profile="L1S L1W"
REC="ensure_local_login_warning_banner_configured"
FSN="nix_ensure_local_login_warning_banner_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.3"
RNA="Ensure remote login warning banner is configured properly"
profile="L1S L1W"
REC="ensure_remote_login_warning_banner_configured"
FSN="nix_ensure_remote_login_warning_banner_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.4"
RNA="Ensure access to /etc/motd is configured"
profile="L1S L1W"
REC="ensure_access_etc_motd_configured"
FSN="nix_ensure_access_etc_motd_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.5"
RNA="Ensure access to /etc/issue is configured"
profile="L1S L1W"
REC="ensure_access_etc_issue_configured"
FSN="nix_ensure_access_etc_issue_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.6"
RNA="Ensure access to /etc/issue.net is configured"
profile="L1S L1W"
REC="ensure_access_etc_issue_net_configured"
FSN="nix_ensure_access_etc_issue_net_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 1.8 - Configure GNOME Display Manager

RN="1.8.1"
RNA="Ensure GNOME Display Manager is removed"
profile="L2S"
REC="ensure_gdm_removed"
FSN="nix_ensure_gdm_removed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.2"
RNA="Ensure GDM login banner is configured"
profile="L1S L1W"
REC="ensure_gdm_login_banner_configured"
FSN="nix_ensure_gdm_login_banner_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.3"
RNA="Ensure GDM disable-user-list option is enabled"
profile="L1S L1W"
REC="ensure_gdm_disable-user-list_option_enabled"
FSN="nix_ensure_gdm_disable-user-list_option_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.4"
RNA="Ensure GDM screen locks when the user is idle"
profile="L1S L1W"
REC="ensure_gdm_screen_locks_when_user_idle"
FSN="nix_ensure_gdm_screen_locks_when_user_idle.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.5"
RNA="Ensure GDM screen locks cannot be overridden"
profile="L1S L1W"
REC="ensure_gdm_screen_locks_cannot_be_overridden"
FSN="nix_ensure_gdm_screen_locks_cannot_be_overridden.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.6"
RNA="Ensure GDM automatic mounting of removable media is disabled"
profile="L1S L2W"
REC="ensure_gdm_auto_mount_removable_media_disabled"
FSN="nix_ensure_gdm_auto_mount_removable_media_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.7"
RNA="Ensure GDM disabling automatic mounting of removable media is not overridden"
profile="L1S L2W"
REC="ensure_gdm_disable_auto_mount_cannot_be_overridden"
FSN="nix_ensure_gdm_disable_auto_mount_cannot_be_overridden.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.8"
RNA="Ensure GDM autorun-never is enabled"
profile="L1S L1W"
REC="ensure_gdm_autorun-never_enabled"
FSN="nix_ensure_gdm_autorun-never_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.9"
RNA="Ensure GDM autorun-never is not overridden"
profile="L1S L1W"
REC="ensure_gdm_autorun-never_cannot_be_overridden"
FSN="nix_ensure_gdm_autorun-never_cannot_be_overridden.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.10"
RNA="Ensure XDMCP is not enabled"
profile="L1S L1W"
REC="fed_ensure_xdmcp_not_enabled"
FSN="nix_fed_ensure_xdmcp_not_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 2 - Services

# 2.1 - Configure Server Services

RN="2.1.1"
RNA="Ensure autofs services are not in use"
profile="L1S L2W"
REC="ensure_autofs_services_not_in_use"
FSN="nix_ensure_autofs_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.2"
RNA="Ensure avahi daemon services are not in use"
profile="L1S L2W"
REC="ensure_avahi_daemon_services_not_in_use"
FSN="nix_ensure_avahi_daemon_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.3"
RNA="Ensure dhcp server services are not in use"
profile="L1S L1W"
REC="ensure_dhcp_server_services_not_in_use"
FSN="nix_ensure_dhcp_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.4"
RNA="Ensure dns server services are not in use"
profile="L1S L1W"
REC="ensure_dns_server_services_not_in_use"
FSN="nix_ensure_dns_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.5"
RNA="Ensure dnsmasq services are not in use"
profile="L1S L1W"
REC="ensure_dnsmasq_services_not_in_use"
FSN="nix_ensure_dnsmasq_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.6"
RNA="Ensure samba file server services are not in use"
profile="L1S L1W"
REC="ensure_samba_file_server_services_not_in_use"
FSN="nix_ensure_samba_file_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.7"
RNA="Ensure ftp server services are not in use"
profile="L1S L1W"
REC="ensure_ftp_server_services_not_in_use"
FSN="nix_ensure_ftp_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.8"
RNA="Ensure message access server services are not in use"
profile="L1S L1W"
REC="ensure_message_access_server_services_not_in_use"
FSN="nix_ensure_message_access_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.9"
RNA="Ensure network file system services are not in use"
profile="L1S L1W"
REC="ensure_network_file_system_services_not_in_use"
FSN="nix_ensure_network_file_system_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.10"
RNA="Ensure nis server services are not in use"
profile="L1S L1W"
REC="ensure_nis_server_services_not_in_use"
FSN="nix_ensure_nis_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.11"
RNA="Ensure print server services are not in use"
profile="L1S"
REC="ensure_print_server_services_not_in_use"
FSN="nix_ensure_print_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.12"
RNA="Ensure rpcbind services are not in use"
profile="L1S L1W"
REC="ensure_rpcbind_services_not_in_use"
FSN="nix_ensure_rpcbind_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.13"
RNA="Ensure rsync services are not in use"
profile="L1S L1W"
REC="ensure_rsync_service_not_in_use"
FSN="nix_ensure_rsync_service_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.14"
RNA="Ensure snmp services are not in use"
profile="L1S L1W"
REC="ensure_snmp_server_not_installed"
FSN="nix_ensure_snmp_server_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.15"
RNA="Ensure telnet server services are not in use"
profile="L1S L1W"
REC="fed_ensure_telnet_server_not_installed"
FSN="nix_fed_ensure_telnet_server_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.16"
RNA="Ensure tftp server services are not in use"
profile="L1S L1W"
REC="ensure_tftp_server_services_not_in_use"
FSN="nix_ensure_tftp_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.17"
RNA="Ensure web proxy server services are not in use"
profile="L1S L1W"
REC="ensure_web_proxy_server_services_not_in_use"
FSN="nix_ensure_web_proxy_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.18"
RNA="Ensure web server services are not in use"
profile="L1S L1W"
REC="ensure_web_server_services_not_in_use"
FSN="nix_ensure_web_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.19"
RNA="Ensure xinetd services are not in use"
profile="L1S L1W"
REC="ensure_xinetd_services_not_in_use"
FSN="nix_ensure_xinetd_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.20"
RNA="Ensure X window server services are not in use"
profile="L2S"
REC="ensure_X_window_server_services_not_in_use"
FSN="nix_ensure_X_window_server_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.21"
RNA="Ensure mail transfer agents are configured for local-only mode"
profile="L1S L1W"
REC="ensure_mail_transfer_agent_configured_local_only"
FSN="nix_ensure_mail_transfer_agent_configured_local_only.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.22"
RNA="Ensure only approved services are listening on a network interface"
profile="L1S L1W"
REC="ensure_only_approved_services_listening_network_interface"
FSN="nix_ensure_only_approved_services_listening_network_interface.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 2.2 - Configure Client Services

RN="2.2.1"
RNA="Ensure ftp client is not installed"
profile="L1S L1W"
REC="ensure_ftp_client_not_installed"
FSN="nix_ensure_ftp_client_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.2"
RNA="Ensure ldap client is not installed"
profile="L2S L2W"
REC="ensure_ldap_client_not_installed"
FSN="nix_ensure_ldap_client_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.3"
RNA="Ensure nis client is not installed"
profile="L1S L1W"
REC="ensure_nis_client_not_installed"
FSN="nix_ensure_nis_client_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.4"
RNA="Ensure telnet client is not installed"
profile="L1S L1W"
REC="ensure_telnet_client_not_installed"
FSN="nix_ensure_telnet_client_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.5"
RNA="Ensure tftp client is not installed"
profile="L1S L1W"
REC="ensure_tftp_client_not_installed"
FSN="nix_ensure_tftp_client_not_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 2.3 - Configure Time Synchronization

RN="2.3.1"
RNA="Ensure time synchronization is in use"
profile="L1S L1W"
REC="fed_ensure_time_synchronization_in_use"
FSN="nix_fed_ensure_time_synchronization_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.3.2"
RNA="Ensure chrony is configured"
profile="L1S L1W"
REC="fed_chrony_configured"
FSN="nix_fed_chrony_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.3.3"
RNA="Ensure chrony is not run as the root user"
profile="L1S L1W"
REC="ensure_chrony_not_run_as_root"
FSN="nix_ensure_chrony_not_run_as_root.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 2.4 - Job Schedulers

# 2.4.1 - Configure cron

RN="2.4.1.1"
RNA="Ensure cron daemon is enabled and active"
profile="L1S L1W"
REC="ensure_cron_daemon_enabled_active"
FSN="nix_ensure_cron_daemon_enabled_active.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.2"
RNA="Ensure permissions on /etc/crontab are configured"
profile="L1S L1W"
REC="ensure_permissions_etc_crontab_configured"
FSN="nix_ensure_permissions_etc_crontab_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.3"
RNA="Ensure permissions on /etc/cron.hourly are configured"
profile="L1S L1W"
REC="ensure_permissions_etc_cron_hourly_configured"
FSN="nix_ensure_permissions_etc_cron_hourly_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.4"
RNA="Ensure permissions on /etc/cron.daily are configured"
profile="L1S L1W"
REC="ensure_permissions_etc_cron_daily_configured"
FSN="nix_ensure_permissions_etc_cron_daily_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.5"
RNA="Ensure permissions on /etc/cron.weekly are configured"
profile="L1S L1W"
REC="ensure_permissions_etc_cron_weekly_configured"
FSN="nix_ensure_permissions_etc_cron_weekly_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.6"
RNA="Ensure permissions on /etc/cron.monthly are configured"
profile="L1S L1W"
REC="ensure_permissions_etc_cron_monthly_configured"
FSN="nix_ensure_permissions_etc_cron_monthly_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.7"
RNA="Ensure permissions on /etc/cron.d are configured"
profile="L1S L1W"
REC="ensure_permissions_etc_cron_d_configured"
FSN="nix_ensure_permissions_etc_cron_d_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.4.1.8"
RNA="Ensure crontab is restricted to authorized users"
profile="L1S L1W"
REC="ensure_crontab_restricted_authorized_users"
FSN="nix_ensure_crontab_restricted_authorized_users.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 2.4.2 - Configure at

RN="2.4.2.1"
RNA="Ensure at is restricted to authorized users"
profile="L1S L1W"
REC="fed_ensure_at_restricted_authorized_users"
FSN="nix_fed_ensure_at_restricted_authorized_users.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 3 - Network

# 3.1 - Configure Network Devices

RN="3.1.1"
RNA="Ensure IPv6 status is identified"
profile="L1S L1W"
REC="fed_ensure_ipv6_status_identified"
FSN="nix_fed_ensure_ipv6_status_identified.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.1.2"
RNA="Ensure wireless interfaces are disabled"
profile="L1S"
REC="ensure_wireless_interfaces_disabled"
FSN="nix_ensure_wireless_interfaces_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.1.3"
RNA="Ensure bluetooth services are not in use"
profile="L1S L2W"
REC="fed28_ensure_bluetooth_services_not_in_use"
FSN="nix_fed28_ensure_bluetooth_services_not_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 3.2 - Configure Network Kernel Modules

RN="3.2.1"
RNA="Ensure dccp kernel module is not available"
profile="L2S L2W"
REC="ensure_dccp_disabled"
FSN="nix_ensure_dccp_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.2.2"
RNA="Ensure tipc kernel module is not available"
profile="L2S L2W"
REC="ensure_tipc_disabled"
FSN="nix_ensure_tipc_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.2.3"
RNA="Ensure rds kernel module is not available"
profile="L2S L2W"
REC="ensure_rds_disabled"
FSN="nix_ensure_rds_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.2.4"
RNA="Ensure sctp kernel module is not available"
profile="L2S L2W"
REC="ensure_sctp_disabled"
FSN="nix_ensure_sctp_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 3.3 - Configure Network Kernel Parameters

RN="3.3.1"
RNA="Ensure ip forwarding is disabled"
profile="L1S L1W"
REC="ensure_ip_forwarding_disabled"
FSN="nix_ensure_ip_forwarding_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.2"
RNA="Ensure packet redirect sending is disabled"
profile="L1S L1W"
REC="ensure_packet_redirect_sending_disabled"
FSN="nix_ensure_packet_redirect_sending_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.3"
RNA="Ensure bogus icmp responses are ignored"
profile="L1S L1W"
REC="ensure_bogus_icmp_responses_ignored"
FSN="nix_ensure_bogus_icmp_responses_ignored.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.4"
RNA="Ensure broadcast icmp requests are ignored"
profile="L1S L1W"
REC="ensure_broadcast_icmp_requests_ignored"
FSN="nix_ensure_broadcast_icmp_requests_ignored.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.5"
RNA="Ensure icmp redirects are not accepted"
profile="L1S L1W"
REC="ensure_icmp_redirects_not_accepted"
FSN="nix_ensure_icmp_redirects_not_accepted.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.6"
RNA="Ensure secure icmp redirects are not accepted"
profile="L1S L1W"
REC="ensure_secure_icmp_redirects_not_accepted"
FSN="nix_ensure_secure_icmp_redirects_not_accepted.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.7"
RNA="Ensure reverse path filtering is enabled"
profile="L1S L1W"
REC="ensure_reverse_path_filtering_enabled"
FSN="nix_ensure_reverse_path_filtering_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.8"
RNA="Ensure source routed packets are not accepted"
profile="L1S L1W"
REC="ensure_source_routed_packets_not_accepted"
FSN="nix_ensure_source_routed_packets_not_accepted.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.9"
RNA="Ensure suspicious packets are logged"
profile="L1S L1W"
REC="ensure_suspicious_packets_logged"
FSN="nix_ensure_suspicious_packets_logged.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.10"
RNA="Ensure tcp syn cookies is enabled"
profile="L1S L1W"
REC="ensure_tcp_syn_cookies_enabled"
FSN="nix_ensure_tcp_syn_cookies_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.11"
RNA="Ensure ipv6 router advertisements are not accepted"
profile="L1S L1W"
REC="ensure_ipv6_router_advertisements_not_accepted"
FSN="nix_ensure_ipv6_router_advertisements_not_accepted.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 4 - Host Based Firewall

# 4.1 - Configure a firewall utility

RN="4.1.1"
RNA="Ensure nftables is installed"
profile="L1S L1W"
REC="fed_ensure_nftables_installed"
FSN="nix_fed_ensure_nftables_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.2"
RNA="Ensure a single firewall configuration utility is in use"
profile="L1S L1W"
REC="fed_ensure_single_firewall_configuration_utility"
FSN="nix_fed_ensure_single_firewall_configuration_utility.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 4.2 - Configure FirewallD

RN="4.2.1"
RNA="Ensure firewalld drops unnecessary services and ports"
profile="L1S L1W"
REC="fed_ensure_firewalld_drops_unnecessary_services_and_ports"
FSN="nix_fed_ensure_firewalld_drops_unnecessary_services_and_ports.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.2"
RNA="Ensure firewalld loopback traffic is configured"
profile="L1S L1W"
REC="fed28_ensure_nftables_loopback_traffic_is_configured"
FSN="nix_fed28_ensure_nftables_loopback_traffic_is_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 4.3 - Configure NFTables

RN="4.3.1"
RNA="Ensure nftables base chains exist"
profile="L1S L1W"
REC="fed_ensure_nftables_base_chains_exist"
FSN="nix_fed_ensure_nftables_base_chains_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.3.2"
RNA="Ensure nftables established connections are configured"
profile="L1S L1W"
REC="fed_ensure_nftables_outbound_established_connections_configured"
FSN="nix_fed_ensure_nftables_outbound_established_connections_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.3.3"
RNA="Ensure nftables default deny firewall policy"
profile="L1S L1W"
REC="fed_ensure_nftables_default_deny_firewall_policy"
FSN="nix_fed_ensure_nftables_default_deny_firewall_policy.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.3.4"
RNA="Ensure nftables loopback traffic is configured"
profile="L1S L1W"
REC="fed_ensure_nftables_loopback_traffic_is_configured"
FSN="nix_fed_ensure_nftables_loopback_traffic_is_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5 - Access Control

# 5.1 - Configure SSH Server

RN="5.1.1"
RNA="Ensure permissions on /etc/ssh/sshd_config are configured"
profile="L1S L1W"
REC="fed_ensure_permissions_sshd_config_configured"
FSN="nix_fed_ensure_permissions_sshd_config_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.2"
RNA="Ensure permissions on SSH private host key files are configured"
profile="L1S L1W"
REC="ensure_permissions_ssh_private_hostkey_files_configured"
FSN="nix_ensure_permissions_ssh_private_hostkey_files_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.3"
RNA="Ensure permissions on SSH public host key files are configured"
profile="L1S L1W"
REC="ensure_permissions_ssh_public_hostkey_files_configured"
FSN="nix_ensure_permissions_ssh_public_hostkey_files_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.4"
RNA="Ensure sshd Ciphers are configured"
profile="L1S L1W"
REC="ssh7_ensure_strong_ciphers_used"
FSN="nix_ssh7_ensure_strong_ciphers_used.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.5"
RNA="Ensure sshd KexAlgorithms is configured"
profile="L1S L1W"
REC="ssh7_ensure_strong_key_exchange_algorithms_used"
FSN="nix_ssh7_ensure_strong_key_exchange_algorithms_used.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.6"
RNA="Ensure sshd MACs are configured"
profile="L1S L1W"
REC="ssh7_ensure_strong_mac_algorithms_used"
FSN="nix_ssh7_ensure_strong_mac_algorithms_used.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.7"
RNA="Ensure sshd access is configured"
profile="L1S L1W"
REC="ensure_sshd_access_configured"
FSN="nix_ensure_sshd_access_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.8"
RNA="Ensure sshd Banner is configured"
profile="L1S L1W"
REC="ensure_ssh_warning_banner_configured"
FSN="nix_ensure_ssh_warning_banner_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.9"
RNA="Ensure sshd ClientAliveInterval and ClientAliveCountMax are configured"
profile="L1S L1W"
REC="ensure_sshd_clientaliveinterval_and_clientalivecountmax_configured"
FSN="nix_ensure_sshd_clientaliveinterval_and_clientalivecountmax_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.10"
RNA="Ensure sshd DisableForwarding is enabled"
profile="L1W L2S"
REC="ensure_sshd_disableforwarding_enabled"
FSN="nix_ensure_sshd_disableforwarding_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.11"
RNA="Ensure sshd GSSAPIAuthentication is disabled"
profile="L1W L2S"
REC="ensure_sshd_gssapiauthentication_disabled"
FSN="nix_ensure_sshd_gssapiauthentication_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.12"
RNA="Ensure sshd HostbasedAuthentication is disabled"
profile="L1S L1W"
REC="ensure_sshd_hostbasedauthentication_disabled"
FSN="nix_ensure_sshd_hostbasedauthentication_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.13"
RNA="Ensure sshd IgnoreRhosts is enabled"
profile="L1S L1W"
REC="ensure_sshd_ignorerhosts_enabled"
FSN="nix_ensure_sshd_ignorerhosts_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.14"
RNA="Ensure sshd LoginGraceTime is configured"
profile="L1S L1W"
REC="ensure_sshd_logingracetime_configured"
FSN="nix_ensure_sshd_logingracetime_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.15"
RNA="Ensure sshd LogLevel is configured"
profile="L1S L1W"
REC="ensure_sshd_loglevel_configured"
FSN="nix_ensure_sshd_loglevel_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.16"
RNA="Ensure sshd MaxAuthTries is configured"
profile="L1S L1W"
REC="ensure_sshd_maxauthtries_configured"
FSN="nix_ensure_sshd_maxauthtries_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.17"
RNA="Ensure sshd MaxStartups is configured"
profile="L1S L1W"
REC="ensure_sshd_maxstartups_configured"
FSN="nix_ensure_sshd_maxstartups_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.18"
RNA="Ensure sshd MaxSessions is configured"
profile="L1S L1W"
REC="ensure_sshd_access_configured"
FSN="nix_ensure_sshd_access_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.19"
RNA="Ensure sshd PermitEmptyPasswords is disabled"
profile="L1S L1W"
REC="ensure_sshd_permitemptypasswords_disabled"
FSN="nix_ensure_sshd_permitemptypasswords_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.20"
RNA="Ensure sshd PermitRootLogin is disabled"
profile="L1S L1W"
REC="ensure_sshd_permitrootlogin_disabled"
FSN="nix_ensure_sshd_permitrootlogin_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.21"
RNA="Ensure sshd PermitUserEnvironment is disabled"
profile="L1S L1W"
REC="ensure_sshd_permituserenvironment_disabled"
FSN="nix_ensure_sshd_permituserenvironment_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.22"
RNA="Ensure sshd UsePAM is enabled"
profile="L1S L1W"
REC="ensure_sshd_usepam_enabled"
FSN="nix_ensure_sshd_usepam_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.2 - Configure privilege escalation

RN="5.2.1"
RNA="Ensure sudo is installed"
profile="L1S L1W"
REC="ensure_sudo_installed"
FSN="nix_ensure_sudo_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.2"
RNA="Ensure sudo commands use pty"
profile="L1S L1W"
REC="ensure_sudo_commands_pty"
FSN="nix_ensure_sudo_commands_pty.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.3"
RNA="Ensure sudo log file exists"
profile="L1S L1W"
REC="ensure_sudo_logfile_exists"
FSN="nix_ensure_sudo_logfile_exists.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.4"
RNA="Ensure users must provide password for escalation"
profile="L2S L2W"
REC="ensure_user_must_provide_password_for_escalation"
FSN="nix_ensure_user_must_provide_password_for_escalation.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.5"
RNA="Ensure re-authentication for privilege escalation is not disabled globally"
profile="L1S L1W"
REC="ensure_reauth_for_escalation_not_disabled"
FSN="nix_ensure_reauth_for_escalation_not_disabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.6"
RNA="Ensure sudo authentication timeout is configured correctly"
profile="L1S L1W"
REC="ensure_sudo_authentication_timeout_configured"
FSN="nix_ensure_sudo_authentication_timeout_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.7"
RNA="Ensure access to the su command is restricted"
profile="L1S L1W"
REC="ensure_access_su_command_restricted"
FSN="nix_ensure_access_su_command_restricted.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.3 - Pluggable Authentication Modules

# 5.3.1 - Configure PAM software packages

RN="5.3.1.1"
RNA="Ensure latest version of pam is installed"
profile="L1S L1W"
REC="fed_ensure_latest_version_pam_installed"
FSN="nix_fed_ensure_latest_version_pam_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.1.2"
RNA="Ensure latest version of authselect is installed"
profile="L1S L1W"
REC="ensure_authselect_installed"
FSN="nix_ensure_authselect_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.1.3"
RNA="Ensure latest version of libpwquality is installed"
profile="L1S L1W"
REC="ensure_libpwquality_installed"
FSN="nix_ensure_libpwquality_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.3.2 - Configure authselect

RN="5.3.2.1"
RNA="Ensure active authselect profile includes pam modules"
profile="L1S L1W"
REC="fed_ensure_active_authselect_profile_includes_pam_modules"
FSN="nix_fed_ensure_active_authselect_profile_includes_pam_modules.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.2.2"
RNA="Ensure pam_faillock module is enabled"
profile="L1S L1W"
REC="fed_ensure_pam_faillock_module_enabled"
FSN="nix_fed_ensure_pam_faillock_module_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.2.3"
RNA="Ensure pam_pwquality module is enabled"
profile="L1S L1W"
REC="fed_ensure_pam_pwquality_module_enabled"
FSN="nix_fed_ensure_pam_pwquality_module_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.2.4"
RNA="Ensure pam_pwhistory module is enabled"
profile="L1S L1W"
REC="fed_ensure_pam_pwhistory_module_enabled"
FSN="nix_fed_ensure_pam_pwhistory_module_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.2.5"
RNA="Ensure pam_unix module is enabled"
profile="L1S L1W"
REC="fed_ensure_pam_unix_module_enabled"
FSN="nix_fed_ensure_pam_unix_module_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.3.3 - Configure PAM Arguments

# 5.3.3.1 - Configure pam_faillock module

RN="5.3.3.1.1"
RNA="Ensure password failed attempts lockout is configured"
profile="L1S L1W"
REC="fed_ensure_password_failed_attempts_lockout_configured"
FSN="nix_fed_ensure_password_failed_attempts_lockout_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.1.2"
RNA="Ensure password unlock time is configured"
profile="L1S L1W"
REC="fed_ensure_password_unlock_time_configured"
FSN="nix_fed_ensure_password_unlock_time_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.1.3"
RNA="Ensure password failed attempts lockout includes root account"
profile="L2S L2W"
REC="fed_ensure_password_failed_attempts_lockout_includes_root"
FSN="nix_fed_ensure_password_failed_attempts_lockout_includes_root.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.3.3.2 - Configure pam_pwquality module

RN="5.3.3.2.1"
RNA="Ensure password number of changed characters is configured"
profile="L1S L1W"
REC="ensure_number_changed_chars_password_configured"
FSN="nix_ensure_number_changed_chars_password_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.2.2"
RNA="Ensure password length is configured"
profile="L1S L1W"
REC="fed_ensure_password_length_configured"
FSN="nix_fed_ensure_password_length_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.2.3"
RNA="Ensure password complexity is configured"
profile="L1S L1W"
REC="fed_ensure_password_complexity_configured"
FSN="nix_fed_ensure_password_complexity_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.2.4"
RNA="Ensure password same consecutive characters is configured"
profile="L1S L1W"
REC="ensure_max_number_consecutive_chars_password_configured"
FSN="nix_ensure_max_number_consecutive_chars_password_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.2.5"
RNA="Ensure password maximum sequential characters is configured"
profile="L1S L1W"
REC="fed_ensure_password_maximum_sequential_characters_configured"
FSN="nix_fed_ensure_password_maximum_sequential_characters_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.2.6"
RNA="Ensure password dictionary check is enabled"
profile="L1S L1W"
REC="ensure_prevent_dictionary_words_in_password_configured"
FSN="nix_ensure_prevent_dictionary_words_in_password_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.2.7"
RNA="Ensure password quality is enforced for the root user"
profile="L1S L1W"
REC="fed_ensure_password_quality_enforced_for_root_user"
FSN="nix_fed_ensure_password_quality_enforced_for_root_user.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.3.3.3 - Configure pam_pwhistory module

RN="5.3.3.3.1"
RNA="Ensure password history remember is configured"
profile="L1S L1W"
REC="fed_ensure_password_history_remember_configured"
FSN="nix_fed_ensure_password_history_remember_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.3.2"
RNA="Ensure password history is enforced for the root user"
profile="L1S L1W"
REC="fed_ensure_password_history_enforced_for_root_user"
FSN="nix_fed_ensure_password_history_enforced_for_root_user.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.3.3"
RNA="Ensure pam_pwhistory includes use_authtok"
profile="L1S L1W"
REC="fed_ensure_pam_pwhistory_includes_use_authtok"
FSN="nix_fed_ensure_pam_pwhistory_includes_use_authtok.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.3.3.4 - Configure pam_unix module

RN="5.3.3.4.1"
RNA="Ensure pam_unix does not include nullok"
profile="L1S L1W"
REC="fed_ensure_pam_unix_does_not_include_nullok"
FSN="nix_fed_ensure_pam_unix_does_not_include_nullok.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.4.2"
RNA="Ensure pam_unix does not include remember"
profile="L1S L1W"
REC="fed_ensure_pam_unix_does_not_include_remember"
FSN="nix_fed_ensure_pam_unix_does_not_include_remember.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.4.3"
RNA="Ensure pam_unix includes a strong password hashing algorithm"
profile="L1S L1W"
REC="fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm"
FSN="nix_fed_ensure_pam_unix_incldues_strong_password_hashing_algorithm.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3.4.4"
RNA="Ensure pam_unix includes use_authtok"
profile="L1S L1W"
REC="fed_ensure_pam_unix_includes_use_authtok"
FSN="nix_fed_ensure_pam_unix_includes_use_authtok.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.4 - User Accounts and Environment

# 5.4.1 - Configure shadow password suite parameters

RN="5.4.1.1"
RNA="Ensure password expiration is configured"
profile="L1S L1W"
REC="ensure_password_expiration_configured"
FSN="nix_ensure_password_expiration_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.2"
RNA="Ensure minimum password days is configured"
profile="L2S L2W"
REC="ensure_minimum_password_age_configured"
FSN="nix_ensure_minimum_password_age_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.3"
RNA="Ensure password expiration warning days is configured"
profile="L1S L1W"
REC="ensure_password_expiration_warning_days_configured"
FSN="nix_ensure_password_expiration_warning_days_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.4"
RNA="Ensure strong password hashing algorithm is configured"
profile="L1S L1W"
REC="ensure_strong_password_hashing_algorithm_configured"
FSN="nix_ensure_strong_password_hashing_algorithm_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.5"
RNA="Ensure inactive password lock is configured"
profile="L1S L1W"
REC="ensure_inactive_password_lock_configured"
FSN="nix_ensure_inactive_password_lock_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.6"
RNA="Ensure all users last password change date is in the past"
profile="L1S L1W"
REC="ensure_all_users_last_password_change_in_past"
FSN="nix_ensure_all_users_last_password_change_in_past.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.4.2 - Configure root and system accounts and environment

RN="5.4.2.1"
RNA="Ensure root is the only UID 0 account"
profile="L1S L1W"
REC="ensure_root_only_uid_0_account"
FSN="nix_ensure_root_only_uid_0_account.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.2"
RNA="Ensure root is the only GID 0 account"
profile="L1S L1W"
REC="ensure_root_only_gid_0_account"
FSN="nix_ensure_root_only_gid_0_account.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.3"
RNA="Ensure group root is the only GID 0 group"
profile="L1S L1W"
REC="ensure_group_root_only_gid_0_group"
FSN="nix_ensure_group_root_only_gid_0_group.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.4"
RNA="Ensure root account access is controlled"
profile="L1S L1W"
REC="fed_ensure_root_password_is_set"
FSN="nix_fed_ensure_root_password_is_set.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.5"
RNA="Ensure root path integrity"
profile="L1S L1W"
REC="ensure_root_path_integrity"
FSN="nix_ensure_root_path_integrity.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.6"
RNA="Ensure root user umask is configured"
profile="L1S L1W"
REC="fed_ensure_user_root_umask_configured"
FSN="nix_fed_ensure_user_root_umask_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.7"
RNA="Ensure system accounts do not have a valid login shell"
profile="L1S L1W"
REC="ensure_system_accounts_secured"
FSN="nix_ensure_system_accounts_secured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2.8"
RNA="Ensure accounts without a valid login shell are locked"
profile="L1S L1W"
REC="ensure_accounts_without_login_shell_locked"
FSN="nix_ensure_accounts_without_login_shell_locked.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 5.4.3 - Configure user default environment

RN="5.4.3.1"
RNA="Ensure nologin is not listed in /etc/shells"
profile="L2S L2W"
REC="ensure_nologin_not_listed_etc_shells"
FSN="nix_ensure_nologin_not_listed_etc_shells.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.3.2"
RNA="Ensure default user shell timeout is configured"
profile="L1S L1W"
REC="ensure_default_user_shell_timeout_configured"
FSN="nix_ensure_default_user_shell_timeout_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.3.3"
RNA="Ensure default user umask is configured"
profile="L1S L1W"
REC="ensure_default_user_umask_027_more_restrictive_v2"
FSN="nix_ensure_default_user_umask_027_more_restrictive_v2.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6 - Logging and Auditing

# 6.1 - Configure Integrity Checking

RN="6.1.1"
RNA="Ensure AIDE is installed"
profile="L1S L1W"
REC="ensure_aide_installed"
FSN="nix_ensure_aide_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.2"
RNA="Ensure filesystem integrity is regularly checked"
profile="L1S L1W"
REC="ensure_filesystem_integrity_regularly_checked"
FSN="nix_ensure_filesystem_integrity_regularly_checked.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.3"
RNA="Ensure cryptographic mechanisms are used to protect the integrity of audit tools"
profile="L1S L1W"
REC="fed_ensure_cryptographic_mechanisms_used_protect_integrity_audit_tools"
FSN="nix_fed_ensure_cryptographic_mechanisms_used_protect_integrity_audit_tools.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.2 - System Logging

# 6.2.1 - Configure systemd-journald service

RN="6.2.1.1"
RNA="Ensure journald service is enabled and active"
profile="L1S L1W"
REC="ensure_journald_service_enabled"
FSN="nix_ensure_journald_service_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.1.2"
RNA="Ensure journald log file access is configured"
profile="L1S L1W"
REC="ensure_journald_default_file_permissions_configured"
FSN="nix_ensure_journald_default_file_permissions_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.1.3"
RNA="Ensure journald log file rotation is configured"
profile="L1S L1W"
REC="ensure_journald_log_rotation_configured"
FSN="nix_ensure_journald_log_rotation_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.1.4"
RNA="Ensure only one logging system is in use"
profile="L1S L1W"
REC="ensure_only_one_logging_system_in_use"
FSN="nix_ensure_only_one_logging_system_in_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.2.2 - Configure journald

RN="6.2.2.2"
RNA="Ensure journald ForwardToSyslog is disabled"
profile="L1S L1W"
REC="ensure_journald_configured_not_send_logs_rsyslog"
FSN="nix_ensure_journald_configured_not_send_logs_rsyslog.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.2.3"
RNA="Ensure journald Compress is configured"
profile="L1S L1W"
REC="ensure_journald_configured_compress_large_files"
FSN="nix_ensure_journald_configured_compress_large_files.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.2.4"
RNA="Ensure journald Storage is configured"
profile="L1S L1W"
REC="ensure_journald_configured_write_logfiles_disk"
FSN="nix_ensure_journald_configured_write_logfiles_disk.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.2.2.1 - Configure systemd-journal-remote

RN="6.2.2.1.1"
RNA="Ensure systemd-journal-remote is installed"
profile="L1S L1W"
REC="ensure_systemd-journal-remote_installed"
FSN="nix_ensure_systemd-journal-remote_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.2.1.2"
RNA="Ensure systemd-journal-upload authentication is configured"
profile="L1S L1W"
REC="ensure_systemd-journal-remote_configured"
FSN="nix_ensure_systemd-journal-remote_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.2.1.3"
RNA="Ensure systemd-journal-upload is enabled and active"
profile="L1S L1W"
REC="ensure_systemd_journal_upload_enabled_active"
FSN="nix_ensure_systemd_journal_upload_enabled_active.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.2.1.4"
RNA="Ensure systemd-journal-remote service is not in use"
profile="L1S L1W"
REC="ensure_systemd_journal_remote_not_use"
FSN="nix_ensure_systemd_journal_remote_not_use.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.2.3 - Configure rsyslog

RN="6.2.3.1"
RNA="Ensure rsyslog is installed"
profile="L1S L1W"
REC="ensure_rsyslog_installed"
FSN="nix_ensure_rsyslog_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.2"
RNA="Ensure rsyslog service is enabled and active"
profile="L1S L1W"
REC="ensure_rsyslog_service_enabled_running"
FSN="nix_ensure_rsyslog_service_enabled_running.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.3"
RNA="Ensure journald is configured to send logs to rsyslog"
profile="L1S L1W"
REC="ensure_journald_configured_send_logs_rsyslog"
FSN="nix_ensure_journald_configured_send_logs_rsyslog.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.4"
RNA="Ensure rsyslog log file creation mode is configured"
profile="L1S L1W"
REC="ensure_rsyslog_default_file_permissions_configured"
FSN="nix_ensure_rsyslog_default_file_permissions_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.5"
RNA="Ensure rsyslog logging is configured"
profile="L1S L1W"
REC="ensure_logging_configured"
FSN="nix_ensure_logging_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.6"
RNA="Ensure rsyslog is configured to send logs to a remote log host"
profile="L1S L1W"
REC="ensure_rsyslog_configured_send_logs_remote_host"
FSN="nix_ensure_rsyslog_configured_send_logs_remote_host.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.7"
RNA="Ensure rsyslog is not configured to receive logs from a remote client"
profile="L1S L1W"
REC="ensure_journald_not_configured_receive_logs_from_remote_client"
FSN="nix_ensure_journald_not_configured_receive_logs_from_remote_client.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3.8"
RNA="Ensure rsyslog logrotate is configured"
profile="L1S L1W"
REC="ensure_logrotate_configured"
FSN="nix_ensure_logrotate_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.2.4 - Configure Logfiles

RN="6.2.4.1"
RNA="Ensure access to all logfiles has been configured"
profile="L1S L1W"
REC="ensure_logfiles_appropriate_permissions_and_ownership"
FSN="nix_ensure_logfiles_appropriate_permissions_and_ownership.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.3 - System Auditing

# 6.3.1 - Configure auditd Service

RN="6.3.1.1"
RNA="Ensure auditd packages are installed"
profile="L2S L2W"
REC="fed_ensure_auditd_installed"
FSN="nix_fed_ensure_auditd_installed.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.1.2"
RNA="Ensure auditing for processes that start prior to auditd is enabled"
profile="L2S L2W"
REC="fed_ensure_auditing_processes_start_prior_auditd_enabled"
FSN="nix_fed_ensure_auditing_processes_start_prior_auditd_enabled.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.1.3"
RNA="Ensure audit_backlog_limit is sufficient"
profile="L2S L2W"
REC="fed_ensure_audit_backlog_limit_sufficient"
FSN="nix_fed_ensure_audit_backlog_limit_sufficient.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.1.4"
RNA="Ensure auditd service is enabled and active"
profile="L2S L2W"
REC="ensure_auditd_service_enabled_running"
FSN="nix_ensure_auditd_service_enabled_running.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.3.2 - Configure Data Retention

RN="6.3.2.1"
RNA="Ensure audit log storage size is configured"
profile="L2S L2W"
REC="ensure_audit_log_storage_size_configured"
FSN="nix_ensure_audit_log_storage_size_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.2.2"
RNA="Ensure audit logs are not automatically deleted"
profile="L2S L2W"
REC="ensure_audit_logs_not_automatically_deleted"
FSN="nix_ensure_audit_logs_not_automatically_deleted.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.2.3"
RNA="Ensure system is disabled when audit logs are full"
profile="L2S L2W"
REC="fed_ensure_system_is_disabled_when_audit_logs_are_full"
FSN="nix_fed_ensure_system_is_disabled_when_audit_logs_are_full.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.2.4"
RNA="Ensure system warns when audit logs are low on space"
profile="L2S L2W"
REC="fed_ensure_system_warns_audit_logs_low_space"
FSN="nix_fed_ensure_system_warns_audit_logs_low_space.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.3.3 - Configure auditd Rules

RN="6.3.3.1"
RNA="Ensure changes to system administration scope (sudoers) is collected"
profile="L2S L2W"
REC="ensure_changes_sudoers_collected"
FSN="nix_ensure_changes_sudoers_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.2"
RNA="Ensure actions as another user are always logged"
profile="L2S L2W"
REC="ensure_actions_another_user_always_logged"
FSN="nix_ensure_actions_another_user_always_logged.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.3"
RNA="Ensure events that modify the sudo log file are collected"
profile="L2S L2W"
REC="ensure_events_modify_sudo_log_file_collected"
FSN="nix_ensure_events_modify_sudo_log_file_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.4"
RNA="Ensure events that modify date and time information are collected"
profile="L2S L2W"
REC="fed_ensure_events_modify_date_time_information_collected"
FSN="nix_fed_ensure_events_modify_date_time_information_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.5"
RNA="Ensure events that modify the system's network environment are collected"
profile="L2S L2W"
REC="fed_ensure_events_modify_systems_network_environment_collected"
FSN="nix_fed_ensure_events_modify_systems_network_environment_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.6"
RNA="Ensure use of privileged commands are collected"
profile="L2S L2W"
REC="ensure_use_privileged_commands_collected"
FSN="nix_ensure_use_privileged_commands_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.7"
RNA="Ensure unsuccessful file access attempts are collected"
profile="L2S L2W"
REC="ensure_unsuccessful_file_access_attempts_collected"
FSN="nix_ensure_unsuccessful_file_access_attempts_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.8"
RNA="Ensure events that modify user/group information are collected"
profile="L2S L2W"
REC="ensure_events_modify_user_group_information_collected"
FSN="nix_ensure_events_modify_user_group_information_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.9"
RNA="Ensure discretionary access control permission modification events are collected"
profile="L2S L2W"
REC="fed_ensure_dac_permission_modification_events_collected"
FSN="nix_fed_ensure_dac_permission_modification_events_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.10"
RNA="Ensure successful file system mounts are collected"
profile="L2S L2W"
REC="fed_ensure_successful_file_system_mounts_collected"
FSN="nix_fed_ensure_successful_file_system_mounts_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.11"
RNA="Ensure session initiation information is collected"
profile="L2S L2W"
REC="ensure_session_initiation_information_collected"
FSN="nix_ensure_session_initiation_information_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.12"
RNA="Ensure login and logout events are collected"
profile="L2S L2W"
REC="fed_ensure_login_logout_events_collected"
FSN="nix_fed_ensure_login_logout_events_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.13"
RNA="Ensure file deletion events by users are collected"
profile="L2S L2W"
REC="fed_ensure_file_deletion_events_by_users_collected"
FSN="nix_fed_ensure_file_deletion_events_by_users_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.14"
RNA="Ensure events that modify the system's Mandatory Access Controls are collected"
profile="L2S L2W"
REC="fed_ensure_events_modify_systems_mac_collected"
FSN="nix_fed_ensure_events_modify_systems_mac_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.15"
RNA="Ensure successful and unsuccessful attempts to use the chcon command are collected"
profile="L2S L2W"
REC="ensure_successful_and_unsuccessful_use_of_chcon_command_recorded"
FSN="nix_ensure_successful_and_unsuccessful_use_of_chcon_command_recorded.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.16"
RNA="Ensure successful and unsuccessful attempts to use the setfacl command are collected"
profile="L2S L2W"
REC="ensure_successful_and_unsuccessful_use_of_setfacl_command_recorded"
FSN="nix_ensure_successful_and_unsuccessful_use_of_setfacl_command_recorded.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.17"
RNA="Ensure successful and unsuccessful attempts to use the chacl command are collected"
profile="L2S L2W"
REC="ensure_successful_and_unsuccessful_use_of_chacl_command_recorded"
FSN="nix_ensure_successful_and_unsuccessful_use_of_chacl_command_recorded.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.18"
RNA="Ensure successful and unsuccessful attempts to use the usermod command are collected"
profile="L2S L2W"
REC="ensure_successful_and_unsuccessful_use_of_usermod_commands_recorded"
FSN="nix_ensure_successful_and_unsuccessful_use_of_usermod_commands_recorded.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.19"
RNA="Ensure kernel module loading unloading and modification is collected"
profile="L2S L2W"
REC="ensure_kernel_module_loading_unloading_collected"
FSN="nix_ensure_kernel_module_loading_unloading_collected.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.20"
RNA="Ensure the audit configuration is immutable"
profile="L2S L2W"
REC="ensure_audit_configuration_immutable"
FSN="nix_ensure_audit_configuration_immutable.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.3.21"
RNA="Ensure the running and on disk configuration is the same"
profile="L2S L2W"
REC="ensure_running_and_disk_configuration"
FSN="nix_ensure_running_and_disk_configuration.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 6.3.4 - Configure auditd File Access

RN="6.3.4.1"
RNA="Ensure the audit log file directory mode is configured"
profile="L2S L2W"
REC="ensure_audit_log_dir_750_or_more_restricted"
FSN="nix_ensure_audit_log_dir_750_or_more_restricted.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.2"
RNA="Ensure audit log files mode is configured"
profile="L2S L2W"
REC="ensure_audit_log_files_mode_640"
FSN="nix_ensure_audit_log_files_mode_640.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.3"
RNA="Ensure audit log files owner is configured"
profile="L2S L2W"
REC="ensure_only_authorized_users_own_audit_log_files"
FSN="nix_ensure_only_authorized_users_own_audit_log_files.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.4"
RNA="Ensure audit log files group owner is configured"
profile="L2S L2W"
REC="ensure_only_authorized_groups_assigned_ownership_audit_log_files"
FSN="nix_ensure_only_authorized_groups_assigned_ownership_audit_log_files.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.5"
RNA="Ensure audit configuration files mode is configured"
profile="L2S L2W"
REC="ensure_audit_config_files_mode_640"
FSN="nix_ensure_audit_config_files_mode_640.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.6"
RNA="Ensure audit configuration files owner is configured"
profile="L2S L2W"
REC="ensure_audit_config_files_owned_root"
FSN="nix_ensure_audit_config_files_owned_root.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.7"
RNA="Ensure audit configuration files group owner is configured"
profile="L2S L2W"
REC="ensure_audit_config_files_group_root"
FSN="nix_ensure_audit_config_files_group_root.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.8"
RNA="Ensure audit tools mode is configured"
profile="L2S L2W"
REC="ensure_audit_tools_files_mode_755"
FSN="nix_ensure_audit_tools_files_mode_755.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.9"
RNA="Ensure audit tools owner is configured"
profile="L2S L2W"
REC="ensure_audit_tools_files_owned_root"
FSN="nix_ensure_audit_tools_files_owned_root.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.3.4.10"
RNA="Ensure audit tools group owner is configured"
profile="L2S L2W"
REC="ensure_audit_tools_files_group_root"
FSN="nix_ensure_audit_tools_files_group_root.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 7 - System Maintenance

# 7.1 - System File Permissions

RN="7.1.1"
RNA="Ensure permissions on /etc/passwd are configured"
profile="L1S L1W"
REC="ensure_perms_etc_passwd"
FSN="nix_ensure_perms_etc_passwd.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.2"
RNA="Ensure permissions on /etc/passwd- are configured"
profile="L1S L1W"
REC="ensure_perms_etc_passwd_dash"
FSN="nix_ensure_perms_etc_passwd_dash.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.3"
RNA="Ensure permissions on /etc/group are configured"
profile="L1S L1W"
REC="ensure_perms_etc_group"
FSN="nix_ensure_perms_etc_group.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.4"
RNA="Ensure permissions on /etc/group- are configured"
profile="L1S L1W"
REC="ensure_perms_etc_group_dash"
FSN="nix_ensure_perms_etc_group_dash.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.5"
RNA="Ensure permissions on /etc/shadow are configured"
profile="L1S L1W"
REC="fed_ensure_perms_etc_shadow"
FSN="nix_fed_ensure_perms_etc_shadow.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.6"
RNA="Ensure permissions on /etc/shadow- are configured"
profile="L1S L1W"
REC="fed_ensure_perms_etc_shadow_dash"
FSN="nix_fed_ensure_perms_etc_shadow_dash.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.7"
RNA="Ensure permissions on /etc/gshadow are configured"
profile="L1S L1W"
REC="fed_ensure_perms_etc_gshadow"
FSN="nix_fed_ensure_perms_etc_gshadow.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.8"
RNA="Ensure permissions on /etc/gshadow- are configured"
profile="L1S L1W"
REC="fed_ensure_perms_etc_gshadow_dash"
FSN="nix_fed_ensure_perms_etc_gshadow_dash.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.9"
RNA="Ensure permissions on /etc/shells are configured"
profile="L1S L1W"
REC="ensure_perms_etc_shells_configured"
FSN="nix_ensure_perms_etc_shells_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.10"
RNA="Ensure permissions on /etc/security/opasswd are configured"
profile="L1S L1W"
REC="ensure_perms_etc_opasswd_configured"
FSN="nix_ensure_perms_etc_opasswd_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.11"
RNA="Ensure world writable files and directories are secured"
profile="L1S L1W"
REC="ensure_world_writable_files_dirs_secured"
FSN="nix_ensure_world_writable_files_dirs_secured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.12"
RNA="Ensure no files or directories without an owner and a group exist"
profile="L1S L1W"
REC="ensure_no_files_or_dirs_without_owner_and_group_exist"
FSN="nix_ensure_no_files_or_dirs_without_owner_and_group_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.1.13"
RNA="Ensure SUID and SGID files are reviewed"
profile="L1S L1W"
REC="ensure_suid_sgid_files_reviewed"
FSN="nix_ensure_suid_sgid_files_reviewed.sh"
total_recommendations=$((total_recommendations+1))
runrec

# 7.2 - Local User and Group Settings

RN="7.2.1"
RNA="Ensure accounts in /etc/passwd use shadowed passwords"
profile="L1S L1W"
REC="ensure_accounts_in_etc_passwd_use_shadowed_passwords"
FSN="nix_ensure_accounts_in_etc_passwd_use_shadowed_passwords.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.2"
RNA="Ensure /etc/shadow password fields are not empty"
profile="L1S L1W"
REC="ensure_etc_shadow_password_fields_not_empty"
FSN="nix_ensure_etc_shadow_password_fields_not_empty.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.3"
RNA="Ensure all groups in /etc/passwd exist in /etc/group"
profile="L1S L1W"
REC="ensure_all_groups_etc_passwd_exist_etc_group"
FSN="nix_ensure_all_groups_etc_passwd_exist_etc_group.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.4"
RNA="Ensure no duplicate UIDs exist"
profile="L1S L1W"
REC="ensure_no_duplicate_uid_exist"
FSN="nix_ensure_no_duplicate_uid_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.5"
RNA="Ensure no duplicate GIDs exist"
profile="L1S L1W"
REC="ensure_no_duplicate_gid_exist"
FSN="nix_ensure_no_duplicate_gid_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.6"
RNA="Ensure no duplicate user names exist"
profile="L1S L1W"
REC="ensure_no_duplicate_user_names_exist"
FSN="nix_ensure_no_duplicate_user_names_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.7"
RNA="Ensure no duplicate group names exist"
profile="L1S L1W"
REC="ensure_no_duplicate_group_names_exist"
FSN="nix_ensure_no_duplicate_group_names_exist.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.8"
RNA="Ensure local interactive user home directories are configured"
profile="L1S L1W"
REC="ensure_local_interactive_user_home_dir_configured"
FSN="nix_ensure_local_interactive_user_home_dir_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

RN="7.2.9"
RNA="Ensure local interactive user dot files access is configured"
profile="L1S L1W"
REC="ensure_local_interactive_user_dot_files_access_configured"
FSN="nix_ensure_local_interactive_user_dot_files_access_configured.sh"
total_recommendations=$((total_recommendations+1))
runrec

# # End of recommendations

# Update grub.cfg permissions (again)
[ -f /boot/grub/grub.cfg ] && chmod og-rwx /boot/grub/grub.cfg
[ -f /boot/grub2/grub.cfg ] && chmod og-rwx /boot/grub2/grub.cfg

# Provide summary report
summary_report

# End of build kit
