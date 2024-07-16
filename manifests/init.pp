# == Class: barman
#
# This class installs Barman (Backup and recovery manager for Postgres).
#
# === Parameters
#
# @param user
#   The Barman user. Default `barman`.
# @param group
#   The group of the Barman user
# @param ensure
#   Ensure that Barman is installed. The default value is 'present'.
#   Otherwise it will be set as 'absent'.
# @param dbuser
#   Username used for connecting to the database
# @param dbname
# @param conf_template
#   Path of the EPP template of the barman.conf configuration
#    file. The default value does not need to be changed.
# @param logrotate_template
#   Path of the EPP template of the logrotate.conf file.
#   The default value does not need to be changed.
# @param home
#   A different place for backups than the default. Will be symlinked
#   to the default (/var/lib/barman). You should not change this
#     value after the first setup.
# @param logfile
#   A different log file. The default is '/var/log/barman/barman.log'
# @param log_level
#   Level of logging. The default is INFO
#   (DEBUG, INFO, WARNING, ERROR, CRITICAL). Global.
# @param archiver
#   Whether the log shipping backup mechanism is active or not (defaults to true)
# @param archiver_batch_size
#   Setting this option enables batch processing of WAL files.
#   The default processes all currently available files.
# @param backup_directory
#   Directory where backup data for a server will be placed.
# @param backup_compression,
#   The compression to be used during the backup process. Only supported when backup_method = postgres.
#   Can either be unset or gzip,lz4 or zstd. If unset then no compression will be used during the backup.
#   Use of this option requires that the CLI application for the specified compression algorithm
#   is available on the Barman server (at backup time) and the PostgreSQL server (at recovery time).
#   Note that the lz4 and zstd algorithms require PostgreSQL 15 (beta) or later.
#   Global/Server
# @param backup_compression_format
#   The format pg_basebackup should use when writing compressed backups to disk.
#   Can be set to either plain or tar. If unset then a default of tar is assumed.
#   The value plain can only be used if the server is running PostgreSQL 15 or later
#   and if backup_compression_location is server. Only supported when backup_method = postgres.
#   Global/Server.
# @param backup_compression_level
#   An integer value representing the compression level to use when compressing backups.
#   Allowed values depend on the compression algorithm specified by backup_compression.
#   Only supported when backup_method = postgres.
#   Global/Server.
# @param backup_compression_location
#   The location (either client or server) where compression should be performed
#   during the backup. The value server is only allowed if the server is running
#   PostgreSQL 15 or later.
#   Global/Server.
# @param backup_compression_workers
#   The number of compression threads to be used during the backup process.
#   Only supported when backup_compression = zstd is set. Default value is 0.
#   In this case default compression behavior will be used.
# @param backup_method
#   Configure the method barman used for backup execution. If set to rsync (default),
#   barman will execute backup using the rsync command. If set to postgres barman will use the
#   pg_basebackup command to execute the backup.
# @param backup_options
#   Behavior for backup operations: possible values are exclusive_backup (default) and concurrent_backup.
# @param recovery_options
#   The restore command to write in the recovery.conf.
#   Possible values are 'get-wal' and undef. Default: undef.
# @param recovery_staging_path
#   A path to a location on the recovery host (either the barman server or a remote host
#   if --remote-ssh-command is also used) where files for a compressed backup will be staged
#   before being uncompressed to the destination directory. Backups will be staged in their
#   own directory within the staging path according to the following naming convention:
#   "barman-staging-SERVER_NAME-BACKUP_ID".
#   The staging directory within the staging path will be removed at the end of
#   the recovery process. This option is required when recovering from
#   compressed backups and has no effect otherwise.
#   Global/Server.
# @param bandwidth_limit
#   This option allows you to specify a maximum transfer rate in kilobytes per second.
#   A value of zero specifies no limit (default).
# @param barman_lock_directory
#   Global option for a directory for lock files.
# @param check_timeout
#  Maximum execution time, in seconds per server, for a barman
#  check command. Set to 0 to disable the timeout. Positive integer, default 30.
# @param compression
#   Compression algorithm. Currently supports 'gzip' (default),
#   'bzip2', and 'custom'. Disabled if false.
# @param create_slot
#   When set to auto and slot_name is defined, Barman automatically attempts
#   to create the replication slot if not present. When set to manual (default),
#   the replication slot needs to be manually created.
#   Global/Server.
# @param custom_compression_filter
#   Customised compression algorithm applied to WAL files.
# @param custom_compression_magic
#   Customised compression magic which is checked in the beginning of a WAL file
#   to select the custom algorithm. If you are using a custom compression filter
#   then setting this will prevent barman from applying the custom compression
#   to WALs which have been pre-compressed with that compression.
#   If you do not configure this then custom compression will still be applied
#   but any pre-compressed WAL files will be compressed again during WAL archive.
#   Global/Server.
# @param custom_decompression_filter
#   Customised decompression algorithm applied to compressed WAL files; this must match the
#   compression algorithm.
# @param forward_config_path
#   Parameter which determines whether a passive node should forward its
#   configuration file path to its primary node during cron or sync-info commands.
#   Set to true if you are invoking barman with the -c/--config option and
#   your configuration is in the same place on both the passive and primary barman servers.
#   Defaults to false.
# @param immediate_checkpoint
#   Force the checkpoint on the Postgres server to happen immediately and start your backup copy
#   process as soon as possible. Disabled if false (default)
# @param basebackup_retry_times
#   Number of retries fo data copy during base backup after an error. Default = 0
# @param basebackup_retry_sleep
#   Number of seconds to wait after after a failed copy, before retrying. Default = 30
# @param max_incoming_wals_queue
#   Maximum number of WAL files in the incoming queue
#   (in both streaming and archiving pools) that are allowed
#   before barman check returns an error (that does not block backups).
#   Default: None (disabled).
#   Global/Server.
# @param minimum_redundancy
#   Minimum number of required backups (redundancy). Default = 0
# @param network_compression
# This option allows you to enable data compression for network transfers. Defaults to false.
# @param parallel_jobs
#  Number of parallel workers used to copy files during backup or recovery. Requires backup mode = rsync.
# @param parallel_jobs_start_batch_period
#   The time period in seconds over which a single batch of jobs will be started. Default: 1 second.
# @param parallel_jobs_start_batch_size
#   Maximum number of parallel jobs to start in a single batch. Default: 10 jobs.
# @param path_prefix
# One or more absolute paths, separated by colon, where Barman
#                   looks for executable files.
# [*last_backup_maximum_age*] - Time frame that must contain the latest backup
#                               date. If the latest backup is older than the
#                               time frame, barman check command will report an
#                               error to the user. Empty if false (default).
# @param last_backup_minimum_size
#   This option identifies lower limit to the acceptable size of the latest successful backup.
#   If the latest backup is smaller than the specified size, barman check command will report
#   an error to the user. If empty (default), latest backup is always considered valid.
#   Syntax for this option is: "i (k|Ki|M|Mi|G|Gi|T|Ti)" where i is an integer greater than zero,
#   with an optional SI or IEC suffix. k=kilo=1000, Ki=Kibi=1024 and so forth.
#   Note that the suffix is case-sensitive.
#   Global/Server.
# @param last_wal_maximum_age
#   This option identifies a time frame that must contain the latest WAL file archived.
#   If the latest WAL file is older than the time frame, barman check command will report
#   an error to the user. If empty (default), the age of the WAL files is not checked.
#   Syntax is the same as last_backup_maximum_age (above).
#   Global/Server.
#   Location of Barman's log file. Global.
# @param post_archive_retry_script
# Hook script launched after a WAL file is
#                                 archived by maintenance. Being this a retry hook
#                                 script, Barman will retry the execution of the
#                                 script until this either returns a SUCCESS (0),
#                                 an ABORT_CONTINUE (62) or an ABORT_STOP (63)
#                                 code. In a post archive scenario, ABORT_STOP has
#                                 currently the same effects as ABORT_CONTINUE.
# [*post_archive_script*] - Hook script launched after a WAL file is archived by
#                           maintenance, after 'post_archive_retry_script'.
# [*post_backup_retry_script*] - Hook script launched after a base backup. Being
#                                this a retry hook script, Barman will retry the
#                                execution of the script until this either returns
#                                a SUCCESS (0), an ABORT_CONTINUE (62) or an
#                                ABORT_STOP (63) code. In a post backup scenario,
#                                ABORT_STOP has currently the same effects as
#                                ABORT_CONTINUE.
# [*post_backup_script*] - Hook script launched after a base backup, after
#                          'post_backup_retry_script'.
# @param post_delete_retry_script
#    Hook script launched after the deletion of a backup.
#    Being this a retry hook script, Barman will retry the execution
#    of the script until this either returns a SUCCESS (0), an ABORT_CONTINUE (62)
#    or an ABORT_STOP (63) code. In a post delete scenario, ABORT_STOP
#    has currently the same effects as ABORT_CONTINUE.
#    Global/Server.
# @param post_delete_script
#    Hook script launched after the deletion of a backup, after 'post_delete_retry_script'. Global/Server.
# @param post_recovery_retry_script
#    Hook script launched after a recovery. Being this a retry hook script,
#    Barman will retry the execution of the script until this either returns
#    a SUCCESS (0), an ABORT_CONTINUE (62) or an ABORT_STOP (63) code.
#    In a post recovery scenario, ABORT_STOP has currently the same effects as ABORT_CONTINUE.
#    Global/Server.
# @param post_recovery_script
#    Hook script launched after a recovery, after 'post_recovery_retry_script'.
#    Global/Server.
# @param post_wal_delete_retry_script
#    Hook script launched after the deletion of a WAL file.
#    Being this a retry hook script, Barman will retry the execution
#    of the script until this either returns a SUCCESS (0), an ABORT_CONTINUE (62)
#    or an ABORT_STOP (63) code. In a post delete scenario, ABORT_STOP has currently
#    the same effects as ABORT_CONTINUE.
#    Global/Server.
# @param post_wal_delete_script
#    Hook script launched after the deletion of a WAL file,
#    after 'post_wal_delete_retry_script'.
#    Global/Server.
# @param pre_archive_retry_script
# Hook script launched before a WAL file is
#                                archived by maintenance, after
#                                'pre_archive_script'. Being this a retry hook
#                                script, Barman will retry the execution of the
#                                script until this either returns a SUCCESS (0),
#                                an ABORT_CONTINUE (62) or an ABORT_STOP (63)
#                                code. Returning ABORT_STOP will propagate the
#                                failure at a higher level and interrupt the WAL
#                                archiving operation.
# [*pre_archive_script*] - Hook script launched before a WAL file is archived by
# 			   maintenance.
# [*pre_backup_retry_script*] - Hook script launched before a base backup, after
#                               'pre_backup_script'. Being this a retry hook
#                               script, Barman will retry the execution of the
#                               script until this either returns a SUCCESS (0), an
#                               ABORT_CONTINUE (62) or an ABORT_STOP (63) code.
#                               Returning ABORT_STOP will propagate the failure at
#                               a higher level and interrupt the backup operation.
# @param pre_backup_script
# Hook script launched before a base backup.
# @param pre_delete_retry_script
#    Hook script launched before the deletion of a backup, after 'pre_delete_script'.
#    Being this a retry hook script, Barman will retry the execution of the script
#    until this either returns a SUCCESS (0), an ABORT_CONTINUE (62) or an ABORT_STOP (63) code.
#    Returning ABORT_STOP will propagate the failure at a higher level and interrupt the backup deletion.
#    Global/Server.
# @param pre_delete_script
#    Hook script launched before the deletion of a backup. Global/Server.
# @param pre_recovery_retry_script
#    Hook script launched before a recovery, after 'pre_recovery_script'.
#    Being this a retry hook script, Barman will retry the execution of the script
#    until this either returns a SUCCESS (0), an ABORT_CONTINUE (62) or an ABORT_STOP (63) code.
#    Returning ABORT_STOP will propagate the failure at a higher level and interrupt the recover operation.
#    Global/Server.
# @param pre_recovery_script
#    Hook script launched before a recovery. Global/Server.
# @param pre_wal_delete_retry_script
#    Hook script launched before the deletion of a WAL file, after 'pre_wal_delete_script'.
#    Being this a retry hook script, Barman will retry the execution of the script until this
#    either returns a SUCCESS (0), an ABORT_CONTINUE (62) or an ABORT_STOP (63) code.
#    Returning ABORT_STOP will propagate the failure at a higher level
#    and interrupt the WAL file deletion.
#    Global/Server.
# @param pre_wal_delete_script
#    Hook script launched before the deletion of a WAL file. Global/Server.
# @param primary_conninfo
#
#   The connection string used by Barman to connect to the primary Postgres server
#   during backup of a standby Postgres server. Barman will use this connection
#   to carry out any required WAL switches on the primary during the backup
#   of the standby. This allows backups to complete even when archive_mode = always
#   is set on the standby and write traffic to the primary is not sufficient
#   to trigger a natural WAL switch.
#
#   If primary_conninfo is set then it must be pointing to a primary Postgres instance
#   and conninfo must be pointing to a standby Postgres instance.
#   Furthermore both instances must share the same systemid.
#   If these conditions are not met then barman check will fail.
#
#   The primary_conninfo value must be a libpq connection string; consult
#   the PostgreSQL manual for more information. Commonly used keys are:
#   host, hostaddr, port, dbname, user, password. Server.
#
# @param primary_ssh_command
#   Parameter that identifies a Barman server as passive. In a passive node,
#   the source of a backup server is a Barman installation rather than a PostgreSQL server.
#   If primary_ssh_command is specified, Barman uses it to establish a connection
#   with the primary server.
#   Empty by default, it can also be set globally.
# @param retention_policy
# Base backup retention policy, based on redundancy or
#                        recovery window. Default empty (no retention enforced).
#                        Value must be greater than or equal to the server
#                        minimum redundancy level (if not is is assigned to
#                        that value and a warning is generated).
# [*wal_retention_policy*] - WAL archive logs retention policy. Currently, the
#                            only allowed value for wal_retention_policy is the
#                            special value main, that maps the retention policy
#                            of archive logs to that of base backups.
# [*retention_policy_mode*] - Can only be set to auto (retention policies are
#                             automatically enforced by the barman cron command)
# [*reuse_backup*] - Incremental backup is a kind of full periodic backup which
#                    saves only data changes from the latest full backup
#                    available in the catalogue for a specific PostgreSQL
#                    server. Disabled if false. Default false.
# [*slot_name*] - Physical replication slot to be used by the receive-wal
#                 command when streaming_archiver is set to on. Requires
#                 postgreSQL >= 9.4. Default: undef (disabled).
# [*streaming_archiver*] - This option allows you to use the PostgreSQL's
#                          streaming protocol to receive transaction logs from a
#                          server. This activates connection checks as well as
#                          management (including compression) of WAL files. If
#                          set to off (default) barman will rely only on
#                          continuous archiving for a server WAL archive
#                          operations, eventually terminating any running
#                          pg_receivexlog for the server.
# [*streaming_archiver_batch_size*] - This option allows you to activate batch
#                                     processing of WAL files for the
#                                     streaming_archiver process, by setting it to
#                                     a value > 0. Otherwise, the traditional
#                                     unlimited processing of the WAL queue is
#                                     enabled.
# [*streaming_archiver_name*] - Identifier to be used as application_name by the
#                               receive-wal command. Only available with
#                               pg_receivexlog >= 9.3. By default it is set to
#                               barman_receive_wal.
# [*streaming_backup_name*] - Identifier to be used as application_name by the
#                             pg_basebackup command. Only available with
#                             pg_basebackup >= 9.3. By default it is set to
#                             barman_streaming_backup.
# [*streaming_conninfo*] - Connection string used by Barman to connect to the
#                          Postgres server via streaming replication protocol. By
#                          default it is set to the same value as *conninfo*.
# [*streaming_wals_directory*] - Directory where WAL files are streamed from the
#                                PostgreSQL server to Barman.
# [*tablespace_bandwidth_limit*] - This option allows you to specify a maximum
#                                  transfer rate in kilobytes per second, by
#                                  specifying a comma separated list of
#                                  tablespaces (pairs TBNAME:BWLIMIT). A value of
#                                  zero specifies no limit (default).
# [*custom_lines*] - DEPRECATED. Custom configuration directives (e.g. for
#                    custom compression). Defaults to empty.
# [*barman_fqdn*] - The fqdn of the Barman server. It will be exported in
#                   several resources in the PostgreSQL server. Puppet
#                   automatically set this.
# [*autoconfigure*] - This is the main parameter to enable the
#                     autoconfiguration of the backup of a given PostgreSQL
#                     server. Defaults to false.
# [*exported_ipaddress*] - The ipaddress exported to the PostgreSQL server
#                          during atutoconfiguration. Defaults to
#                          "${::ipaddress}/32".
# [*host_group*] -  Tag used to collect and export resources during
#                   autoconfiguration. Defaults to 'global'.
# [*manage_package_repo*] - Configure PGDG repository. It is implemented
#                           internally by declaring the `postgresql::globals`
#                           class. If you need to customize the
#                           `postgresql::globals` class declaration, keep the
#                           `manage_package_repo` parameter disabled in `barman`
#                           module and enable it directly in
#                           `postgresql::globals` class.
# [*purge_unknown_conf*] - Whether or not barman conf files not included in
#                          puppetdb will be removed by puppet.
#
# === Facts
#
# The module generates a fact called '*barman_key*' which has the content of
#  _/var/lib/barman/.ssh/id_rsa.pub_, in order to automatically handle the
#  key exchange on the postgres server via puppetdb.
# If the file doesn't exist, a key will be generated.
#
# === Examples
#
# The class can be used right away with defaults:
# ---
#  include barman
# ---
#
# All parameters that are supported by barman can be changed:
# ---
#  class { barman:
#    logfile  => '/var/log/barman/something_else.log',
#    compression => 'bzip2',
#    pre_backup_script => '/usr/bin/touch /tmp/started',
#    post_backup_script => '/usr/bin/touch /tmp/stopped',
#    custom_lines => '; something'
#  }
# ---
#
# === Authors
#
# * Giuseppe Broccolo <giuseppe.broccolo@2ndQuadrant.it>
# * Giulio Calacoci <giulio.calacoci@2ndQuadrant.it>
# * Francesco Canovai <francesco.canovai@2ndQuadrant.it>
# * Marco Nenciarini <marco.nenciarini@2ndQuadrant.it>
# * Gabriele Bartolini <gabriele.bartolini@2ndQuadrant.it>
# * Alessandro Grassi <alessandro.grassi@2ndQuadrant.it>
#
# Many thanks to Alessandro Franceschi <al@lab42.it>
#
# === Copyright
#
# Copyright 2012-2017 2ndQuadrant Italia
#
class barman (
  String                             $user,
  String                             $group,
  String                             $ensure,
  Boolean                            $archiver,
  Boolean                            $autoconfigure,
  Variant[String,Boolean]            $compression,
  String                             $dbuser,
  Stdlib::Absolutepath               $home,
  String                             $home_mode,
  String                             $host_group,
  String                             $dbname,
  Optional[Boolean]                  $forward_config_path           = undef,
  Boolean                            $immediate_checkpoint,
  Stdlib::Absolutepath               $logfile,
  Barman::LogLevel                   $log_level,
  Boolean                            $manage_package_repo,
  Boolean                            $manage_ssh_host_keys,
  Optional[Integer]                  $max_incoming_wals_queue       = undef,
  Integer                            $minimum_redundancy,
  Boolean                            $purge_unknown_conf,
  Boolean                            $streaming_archiver,
  String                             $archive_cmd_type,
  Integer                            $hba_entry_order,
  String                             $conf_file_path                = $barman::conf_file_path,
  String                             $conf_template                 = 'barman/barman.conf.epp',
  String                             $logrotate_template            = 'barman/logrotate.conf.epp',
  String                             $barman_fqdn                   = $facts['networking']['fqdn'],
  Optional[Integer]                  $archiver_batch_size           = undef,
  Optional[Barman::BackupCompression]          $backup_compression            = undef,
  Optional[Barman::BackupCompressionFormat]    $backup_compression_format     = undef,
  Optional[String]                             $backup_compression_level      = undef,
  Optional[Barman::BackupCompressionLocation]  $backup_compression_location   = undef,
  Optional[Integer]                            $backup_compression_workers    = undef,
  Barman::BackupMethod               $backup_method                 = undef,
  Barman::BackupOptions              $backup_options                = undef,
  Optional[Integer]                  $bandwidth_limit               = undef,
  Optional[String]                   $barman_lock_directory         = undef,
  Optional[Integer]                  $basebackup_retry_sleep        = undef,
  Optional[Integer]                  $basebackup_retry_times        = undef,
  Optional[Integer]                  $check_timeout                 = undef,
  Optional[Barman::CreateSlot]       $create_slot                   = undef,
  Optional[String]                   $custom_compression_filter     = undef,
  Optional[Any]                      $custom_compression_magic      = undef,
  Optional[String]                   $custom_decompression_filter   = undef,
  Stdlib::IP::Address                $exported_ipaddress            = "${facts['networking']['ip']}/32",
  Barman::BackupAge                  $last_backup_maximum_age        = undef,
  Optional[String]                   $last_backup_minimum_size       = undef,
  Barman::BackupAge                  $last_wal_maximum_age           = undef,
  Optional[Boolean]                  $network_compression            = undef,
  Optional[Integer]                  $parallel_jobs                  = undef,
  Optional[Integer]                  $parallel_jobs_start_batch_period    = undef,
  Optional[Integer]                  $parallel_jobsstart_batch_size       = undef,
  Optional[Stdlib::Absolutepath]     $path_prefix                    = undef,
  Optional[String]                   $post_archive_retry_script      = undef,
  Optional[String]                   $post_archive_script            = undef,
  Optional[String]                   $post_backup_retry_script       = undef,
  Optional[String]                   $post_backup_script             = undef,
  Optional[String]                   $post_delete_retry_script       = undef,
  Optional[String]                   $post_delete_script             = undef,
  Optional[String]                   $post_recovery_retry_script     = undef,
  Optional[String]                   $post_recovery_script           = undef,
  Optional[String]                   $post_wal_delete_retry_script   = undef,
  Optional[String]                   $post_wal_delete_script         = undef,
  Optional[String]                   $pre_archive_retry_script       = undef,
  Optional[String]                   $pre_archive_script             = undef,
  Optional[String]                   $pre_backup_retry_script        = undef,
  Optional[String]                   $pre_backup_script              = undef,
  Optional[String]                   $pre_delete_retry_script        = undef,
  Optional[String]                   $pre_delete_script              = undef,
  Optional[String]                   $pre_recovery_retry_script      = undef,
  Optional[String]                   $pre_recovery_script            = undef,
  Optional[String]                   $pre_wal_delete_retry_script    = undef,
  Optional[String]                   $pre_wal_delete_script          = undef,
  Optional[String]                   $primary_conninfo               = undef,
  Optional[String]                   $primary_ssh_command            = undef,
  Barman::RecoveryOptions            $recovery_options               = undef,
  Optional[Stdlib::Absolutepath]     $recovery_staging_path          = undef,
  Barman::RetentionPolicy            $retention_policy               = undef,
  Barman::RetentionPolicyMode        $retention_policy_mode          = undef,
  Barman::ReuseBackup                $reuse_backup                   = undef,
  Optional[String]                   $slot_name                      = undef,
  Optional[Integer]                  $streaming_archiver_batch_size  = undef,
  Optional[String]                   $streaming_archiver_name        = undef,
  Optional[String]                   $streaming_backup_name          = undef,
  Optional[String]                   $tablespace_bandwidth_limit     = undef,
  Barman::WalRetention               $wal_retention_policy           = undef,
  Optional[String]                   $custom_lines                   = undef,
  Optional[Hash]                     $servers                        = undef,
  Optional[Stdlib::Absolutepath]     $streaming_wals_directory       = undef,
) {
  # when hash data is in servers, then fire-off barman::server define with that hash data
  if ($servers) {
    create_resources('barman::server', deep_merge(hiera_hash('barman::servers', {}), $servers))
  }

  # Ensure creation (or removal) of Barman files and directories
  $ensure_file = $ensure ? {
    'absent' => 'absent',
    default  => 'present',
  }
  $ensure_directory = $ensure ? {
    'absent' => 'absent',
    default  => 'directory',
  }

  if $manage_package_repo {
    if defined(Class['postgresql::globals']) {
      fail('Class postgresql::globals is already defined. Set barman class manage_package_repo parameter to false (preferred) or remove the other definition.')
    } else {
      class { 'postgresql::globals':
        manage_package_repo => true,
      }
    }
  }
  package { 'barman':
    ensure => $ensure,
    tag    => 'postgresql',
  }

  file { '/etc/barman.conf.d':
    ensure  => $ensure_directory,
    purge   => $purge_unknown_conf,
    recurse => true,
    owner   => 'root',
    group   => $group,
    #mode    => '0750',
    mode    => 'u+rwX,g-w,o-rwx',
    require => Package['barman'],
  }

  if $conf_file_path == '/etc/barman/barman.conf' {
    file { '/etc/barman':
      ensure  => $ensure_directory,
      purge   => $purge_unknown_conf,
      recurse => true,
      owner   => 'root',
      group   => $group,
      mode    => '0750',
      require => Package['barman'],
      before  => File['/etc/barman/barman.conf'],
    }
  }

  file { $conf_file_path:
    ensure  => $ensure_file,
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    content => epp($conf_template, {
                     user                          => $user,
                     archiver                      => $archiver,
                     compression                   => $compression,
                     home                          => $home,
                     forward_config_path           => $forward_config_path,
                     immediate_checkpoint          => $immediate_checkpoint,
                     logfile                       => $logfile,
                     log_level                     => $log_level,
                     max_incoming_wals_queue       => $max_incoming_wals_queue,
                     minimum_redundancy            => $minimum_redundancy,
                     streaming_archiver            => $streaming_archiver,
                     archiver_batch_size           => $archiver_batch_size,
                     backup_compression            => $backup_compression,
                     backup_compression_format     => $backup_compression_format,
                     backup_compression_level      => $backup_compression_level,
                     backup_compression_location   => $backup_compression_location,
                     backup_compression_workers    => $backup_compression_workers,
                     backup_method                 => $backup_method,
                     backup_options                => $backup_options,
                     bandwidth_limit               => $bandwidth_limit,
                     barman_lock_directory         => $barman_lock_directory,
                     basebackup_retry_sleep        => $basebackup_retry_sleep,
                     basebackup_retry_times        => $basebackup_retry_times,
                     check_timeout                 => $check_timeout,
                     create_slot                   => $create_slot,
                     custom_compression_filter     => $custom_compression_filter,
                     custom_compression_magic      => $custom_compression_magic,
                     custom_decompression_filter   => $custom_decompression_filter,
                     last_backup_maximum_age       => $last_backup_maximum_age,
                     last_backup_minimum_size      => $last_backup_minimum_size,
                     last_wal_maximum_age          => $last_wal_maximum_age,
                     network_compression           => $network_compression,
                     parallel_jobs                 => $parallel_jobs,
                     parallel_jobs_start_batch_period  => $parallel_jobs_start_batch_period,
                     parallel_jobs_start_batch_size    => $parallel_jobs_start_batch_size,
                     path_prefix                   => $path_prefix,
                     post_archive_retry_script     => $post_archive_retry_script,
                     post_archive_script           => $post_archive_script,
                     post_backup_retry_script      => $post_backup_retry_script,
                     post_backup_script            => $post_backup_script,
                     post_delete_retry_script      => post_delete_retry_script,
                     post_delete_script            => post_delete_script,
                     post_recovery_retry_script    => post_recovery_retry_script,
                     post_recovery_script          => post_recovery_script,
                     post_wal_delete_retry_script  => post_wal_delete_retry_script,
                     post_wal_delete_script        => post_wal_delete_script,
                     pre_archive_retry_script      => $pre_archive_retry_script,
                     pre_archive_script            => $pre_archive_script,
                     pre_backup_retry_script       => $pre_backup_retry_script,
                     pre_backup_script             => $pre_backup_script,
                     pre_delete_retry_script       => $pre_delete_retry_script,
                     pre_delete_script             => $pre_delete_script,
                     pre_recovery_retry_script     => $pre_recovery_retry_script,
                     pre_recovery_script           => $pre_recovery_script,
                     pre_wal_delete_retry_script   => $pre_wal_delete_retry_script,
                     pre_wal_delete_script         => $pre_wal_delete_script,
                     primary_conninfo              => $primary_conninfo,
                     primary_ssh_command           => $primary_ssh_command,
                     recovery_options              => $recovery_options,
                     recovery_staging_path         => $recovery_staging_path,
                     retention_policy              => $retention_policy,
                     retention_policy_mode         => $retention_policy_mode,
                     reuse_backup                  => $reuse_backup,
                     slot_name                     => $slot_name,
                     streaming_archiver_batch_size => $streaming_archiver_batch_size,
                     streaming_archiver_name       => $streaming_archiver_name,
                     streaming_backup_name         => $streaming_backup_name,
                     tablespace_bandwidth_limit    => $tablespace_bandwidth_limit,
                     wal_retention_policy          => $wal_retention_policy,
                     custom_lines                  => $custom_lines,
               }),
  }

  file { $home:
    ensure  => $ensure_directory,
    owner   => $user,
    group   => $group,
    mode    => '0750',
    require => Package['barman']
  }

  # Run 'barman check all' to create Barman backup directories
  exec { 'barman-check-all':
    command     => '/usr/bin/barman check all',
    subscribe   => File[$home],
    refreshonly => true
  }

  file { '/etc/logrotate.d/barman':
    ensure  => $ensure_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp($logrotate_template, {
                     logfile                       => $logfile,
                     user                          => $user,
                     group                         => $group,
               }),
    require => Package['barman'],
  }

  # Set the autoconfiguration
  if $autoconfigure {
    class { '::barman::autoconfigure':
      exported_ipaddress => $exported_ipaddress,
      host_group         => $host_group,
      }
  }
}
