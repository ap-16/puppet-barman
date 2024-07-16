# == Resource: barman::server
#
# This resource creates a barman configuration for a postgresql instance.
#
# NOTE: The resource is called in the 'postgres' class.
#
# === Parameters
#
# Many of the main configuration parameters can ( and *must*) be passed in
# order to perform overrides.
#
# [*conninfo*] - Postgres connection string. *Mandatory*.
# [*ssh_command*] - Command to open an ssh connection to Postgres. *Mandatory*.
# [*activate*] - Whether this server is active in the barman configuration.
# [*ensure*] - Ensure (or not) that single server Barman configuration files are
#              created. The default value is 'present'. Just 'absent' or
#              'present' are the possible settings.
# [*conf_template*] - path of the template file to build the Barman
#                     configuration file.
# [*description*] - Description of the configuration file: it is automatically
#                   set when the resource is used.
# [*archiver*] - Whether the log shipping backup mechanism is active or not.
# [*archiver_batch_size*] - Setting this option enables batch processing of WAL
#                           files. The default processes all currently available
#                           files.
# [*backup_directory*] - Directory where backup data for a server will be placed.
# [*backup_method*] - Configure the method barman used for backup execution. If
#                     set to rsync (default), barman will execute backup using the
#                     rsync command. If set to postgres barman will use the
#                     pg_basebackup command to execute the backup.
# [*backup_options*] - Behavior for backup operations: possible values are
#                      exclusive_backup (default) and concurrent_backup.
# @param recovery_options
# The restore command to write in the recovery.conf.
#                        Possible values are 'get-wal' and undef. Default: undef.
# @param recovery_staging_path
#                        A path to a location on the recovery host (either the
#                        barman server or a remote host if --remote-ssh-command
#                        is also used) where files for a compressed backup will be
#                        staged before being uncompressed to the destination directory.
#                        Backups will be staged in their own directory within
#                        the staging path according to the following naming convention:
#                        "barman-staging-SERVER_NAME-BACKUP_ID".
#                        The staging directory within the staging path will be removed
#                        at the end of the recovery process.
#                        This option is required when recovering from compressed backups
#                        and has no effect otherwise.
#                        Global/Server. 
# @param bandwidth_limit
# This option allows you to specify a maximum transfer rate
#                       in kilobytes per second. A value of zero specifies no
#                       limit (default).
# [*basebackups_directory*] - Directory where base backups will be placed.
# [*basebackup_retry_sleep*] - Number of seconds of wait after a failed copy,
#                              before retrying Used during both backup and
#                              recovery operations. Positive integer, default 30.
# [*basebackup_retry_times*] - Number of retries of base backup copy, after an
#                              error. Used during both backup and recovery
#                              operations. Positive integer, default 0.
# [*check_timeout*] - Maximum execution time, in seconds per server, for a barman
#                     check command. Set to 0 to disable the timeout. Positive
#                     integer, default 30.
# [*compression*] - Compression algorithm. Currently supports 'gzip' (default),
#                   'bzip2', and 'custom'. Disabled if false.
# @param create_slot
#   When set to auto and slot_name is defined, Barman automatically attempts
#   to create the replication slot if not present. When set to manual (default),
#   the replication slot needs to be manually created.
#   Global/Server. 
# @param custom_compression_filter
# Customised compression algorithm applied to WAL
#                                 files.
# @param custom_compression_magic
#   Customised compression magic which is checked in the beginning of a WAL file
#   to select the custom algorithm. If you are using a custom compression filter
#   then setting this will prevent barman from applying the custom compression
#   to WALs which have been pre-compressed with that compression.
#   If you do not configure this then custom compression will still be applied
#   but any pre-compressed WAL files will be compressed again during WAL archive.
#   Global/Server.
# @param custom_decompression_filter
# Customised decompression algorithm applied to
#                                   compressed WAL files; this must match the
#                                   compression algorithm.
# [*errors_directory*] - Directory that contains WAL files that contain an error.
# [*immediate_checkpoint*] - Force the checkpoint on the Postgres server to
#                            happen immediately and start your backup copy
#                            process as soon as possible. Disabled if false
#                            (default)
# [*incoming_wals_directory*] - Directory where incoming WAL files are archived
#                               into. Requires archiver to be enabled.
# [*last_backup_maximum_age*] - This option identifies a time frame that must
#                               contain the latest backup. If the latest backup is
#                               older than the time frame, barman check command
#                               will report an error to the user. If empty
#                               (default), latest backup is always considered
#                               valid. Syntax for this option is: "i (DAYS |
#                               WEEKS | MONTHS)" where i is a integer greater than
#                               zero, representing the number of days | weeks |
#                               months of the time frame.
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
# @param max_incoming_wals_queue
#   Maximum number of WAL files in the incoming queue
#   (in both streaming and archiving pools) that are allowed
#   before barman check returns an error (that does not block backups).
#   Default: None (disabled).
#   Global/Server.
# @param minimum_redundancy
# Minimum number of backups to be retained. Default 0.
# @param network_compression
# This option allows you to enable data compression for
#                           network transfers. Defaults to false.
# @param parallel_jobs] - Number of parallel workers used to copy files during
#                    backup or recovery. Requires backup mode = rsync.
# @param parallel_jobs_start_batch_period
#   The time period in seconds over which a single batch of jobs will be started. Default: 1 second. 
# @param parallel_jobs_start_batch_size
#   Maximum number of parallel jobs to start in a single batch. Default: 10 jobs. 
# @param path_prefix
# One or more absolute paths, separated by colon, where Barman
#                   looks for executable files.
# [*post_archive_retry_script*] - Hook script launched after a WAL file is
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
# [*retention_policy_mode*] - Can only be set to auto (retention policies are
#                             automatically enforced by the barman cron command)
# [*reuse_backup*] - Incremental backup is a kind of full periodic backup which
#                    saves only data changes from the latest full backup
#                    available in the catalogue for a specific PostgreSQL
#                    server. Disabled if false. Default false.
# [*slot_name*] - Physical replication slot to be used by the receive-wal
#                 command when streaming_archiver is set to on. Requires
#                 postgreSQL >= 9.4. Default: undef (disabled).
# @param snapshot_disks
#   A comma-separated list of disks which should be included in a backup taken
#   using cloud snapshots.
#   Required when the snapshot value is specified for backup_method. 
#   Server.
# @param snapshot_gcp_project
#   The ID of the GCP project which owns the instance and storage volumes
#   defined by snapshot_instance and snapshot_disks.
#   Required when the snapshot value is specified for backup_method and snapshot_provider is set to gcp. 
#   Global/Server.
# @param snapshot_instance
#   The name of the VM or compute instance where the storage volumes are attached.
#   Required when the snapshot value is specified for backup_method. 
#   Server.
# @param snapshot_provider
#   The name of the cloud provider which should be used to create snapshots.
#   Supported values: gcp. 
#   Global/Server. Required when the snapshot value is specified for backup_method.
# @param snapshot_zone
#   The name of the availability zone where the compute instance and disks
#   to be backed up in a snapshot backup are located. Server.
#   Required when the snapshot value is specified for backup_method. 
# @param streaming_archiver
# This option allows you to use the PostgreSQL's
#                          streaming protocol to receive transaction logs from a
#                          server. This activates connection checks as well as
#                          management (including compression) of WAL files. If
#                          set to off (default) barman will rely only on
#                          continuous archiving for a server WAL archive
#                          operations, eventually terminating any running
#                          pg_receivexlog for the server.
# @param backup_compression
#                          The compression to be used during the backup process.
#                          Only supported when backup_method = postgres.
#                          Can either be unset or gzip,lz4 or zstd.
#                          If unset then no compression will be used during
#                          the backup. Use of this option requires that the
#                          CLI application for the specified compression algorithm
#                          is available on the Barman server (at backup time)
#                          and the PostgreSQL server (at recovery time).
#                          Note that the lz4 and zstd algorithms require
#                          PostgreSQL 15 (beta) or later.
#                          Global/Server. 
# @param backup_compression_format
#                          The format pg_basebackup should use when writing
#                          compressed backups to disk. Can be set to either
#                          plain or tar. If unset then a default of tar
#                          is assumed. The value plain can only be used
#                          if the server is running PostgreSQL 15 or later
#                          and if backup_compression_location is server.
#                          Only supported when backup_method = postgres.
#                          Global/Server. 
# @param backup_compression_level
#                          An integer value representing the compression level
#                          to use when compressing backups. Allowed values
#                          depend on the compression algorithm specified
#                          by backup_compression.
#                          Only supported when backup_method = postgres.
#                          Global/Server. 
# @param backup_compression_location
#                          The location (either client or server) where
#                          compression should be performed during the backup.
#                          The value server is only allowed if the server
#                          is running PostgreSQL 15 or later.
#                          Global/Server.
# @param backup_compression_workers
#                          The number of compression threads to be used
#                          during the backup process. Only supported when
#                          backup_compression = zstd is set.
#                          Default value is 0. In this case default
#                          compression behavior will be used.
# @param streaming_archiver_batch_size
#                          This option allows you to activate batch
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
# [*wal_retention_policy*] - WAL archive logs retention policy. Currently, the
#                            only allowed value for wal_retention_policy is the
#                            special value main, that maps the retention policy
#                            of archive logs to that of base backups.
# [*wals_directory*] - Directory which contains WAL files.
# [*custom_lines*] - DEPRECATED. Custom configuration directives (e.g. for
#                    custom compression). Defaults to empty.
# === Examples
#
#  barman::server { 'main':
#    conninfo           => 'user=postgres host=server1 password=pg123',
#    ssh_command        => 'ssh postgres@server1',
#    compression        => 'bzip2',
#    pre_backup_script  => '/usr/bin/touch /tmp/started',
#    post_backup_script => '/usr/bin/touch /tmp/stopped',
#    custom_lines       => '; something'
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
define barman::server (
  String                         $conninfo,
  String                         $ssh_command,
  Barman::ServerName             $server_name                   = $title,
  Boolean                        $active                        = true,
  Enum['present', 'absent']      $ensure                        = 'present',
  String                         $conf_template                 = 'barman/server.conf.epp',
  String                         $description                   = $title,
  Boolean                        $archiver                      = $barman::archiver,
  Optional[Integer]              $archiver_batch_size           = $barman::archiver_batch_size,
  Optional[Stdlib::Absolutepath] $backup_directory              = undef,
  Optional[Barman::BackupCompression]          $backup_compression            = undef,
  Optional[Barman::BackupCompressionFormat]    $backup_compression_format     = undef,
  Optional[String]                             $backup_compression_level      = undef,
  Optional[Barman::BackupCompressionLocation]  $backup_compression_location   = undef,
  Optional[Integer]                            $backup_compression_workers    = undef,
  Barman::BackupMethod           $backup_method                 = $barman::backup_method,
  Barman::BackupOptions          $backup_options                = $barman::backup_options,
  Optional[Integer]              $bandwidth_limit               = $barman::bandwidth_limit,
  Optional[Stdlib::Absolutepath] $basebackups_directory         = undef,
  Optional[Integer]              $basebackup_retry_sleep        = $barman::basebackup_retry_sleep,
  Optional[Integer]              $basebackup_retry_times        = $barman::basebackup_retry_times,
  Optional[Integer]              $check_timeout                 = $barman::check_timeout,
  Variant[String,Boolean]        $compression                   = $barman::compression,
  Optional[Barman::CreateSlot]   $create_slot                   = $barman::create_slot,
  Optional[String]               $custom_compression_filter     = $barman::custom_compression_filter,
  Optional[Any]                  $custom_compression_magix      = $barman::custom_compression_magix,
  Optional[String]               $custom_decompression_filter   = $barman::custom_decompression_filter,
  Optional[Stdlib::Absolutepath] $errors_directory              = undef,
  Boolean                        $immediate_checkpoint          = $barman::immediate_checkpoint,
  Optional[Stdlib::Absolutepath] $incoming_wals_directory       = undef,
  Barman::BackupAge              $last_backup_maximum_age       = $barman::last_backup_maximum_age,
  Optional[String]               $last_backup_minimum_size      = $barman::last_backup_minimum_size,
  Barman::BackupAge              $last_wal_maximum_age          = $barman::last_wal_maximum_age,
  Optional[Integer]              $max_incoming_wals_queue       = $barman::max_incoming_wals_queue,
  Optional[Integer]              $minimum_redundancy            = $barman::minimum_redundancy,
  Optional[Boolean]              $network_compression           = $barman::network_compression,
  Optional[Integer]              $parallel_jobs                 = $barman::parallel_jobs,
  Optional[Integer]              $parallel_jobs_start_batch_period  = $barman::parallel_jobs_start_batch_period,
  Optional[Integer]              $parallel_jobs_start_batch_size    = $barman::parallel_jobs_start_batch_size,
  Optional[Stdlib::Absolutepath] $path_prefix                   = $barman::path_prefix,
  Optional[String]               $post_archive_retry_script     = $barman::post_archive_retry_script,
  Optional[String]               $post_archive_script           = $barman::post_archive_script,
  Optional[String]               $post_backup_retry_script      = $barman::post_backup_retry_script,
  Optional[String]               $post_backup_script            = $barman::post_backup_script,
  Optional[String]               $post_delete_retry_script      = $barman::post_delete_retry_script,
  Optional[String]               $post_delete_script            = $barman::post_delete_script,
  Optional[String]               $post_recovery_retry_script    = $barman::post_recovery_retry_script,
  Optional[String]               $post_recovery_script          = $barman::post_recovery_script,
  Optional[String]               $post_wal_delete_retry_script  = $barman::post_wal_delete_retry_script,
  Optional[String]               $post_wal_delete_script        = $barman::post_wal_delete_script,
  Optional[String]               $pre_archive_retry_script      = $barman::pre_archive_retry_script,
  Optional[String]               $pre_archive_script            = $barman::pre_archive_script,
  Optional[String]               $pre_backup_retry_script       = $barman::pre_backup_retry_script,
  Optional[String]               $pre_backup_script             = $barman::pre_backup_script,
  Optional[String]               $pre_delete_retry_script       = $barman::pre_delete_retry_script,
  Optional[String]               $pre_delete_script             = $barman::pre_delete_script,
  Optional[String]               $pre_recovery_retry_script     = $barman::pre_recovery_retry_script,
  Optional[String]               $pre_recovery_script           = $barman::pre_recovery_script,
  Optional[String]               $pre_wal_delete_retry_script   = $barman::pre_wal_delete_retry_script,
  Optional[String]               $pre_wal_delete_script         = $barman::pre_wal_delete_script,
  Optional[String]               $primary_ssh_command           = $barman::primary_ssh_command,
  Barman::RecoveryOptions        $recovery_options              = $barman::recovery_options,
  Optional[Stdlib::Absolutepath] $recovery_staging_path         = $barman::recovery_staging_path,
  Barman::RetentionPolicy        $retention_policy              = $barman::retention_policy,
  Barman::RetentionPolicyMode    $retention_policy_mode         = $barman::retention_policy_mode,
  Barman::ReuseBackup            $reuse_backup                  = $barman::reuse_backup,
  Optional[String]               $slot_name                     = $barman::slot_name,
  Optional[String]               $snapshot_disks                = undef,
  Optional[String]               $snapshot_gcp_project          = undef,
  Optional[String]               $snapshot_instance             = undef,
  Optional[String]               $snapshot_provider             = undef,
  Optional[String]               $snapshot_zone                 = undef,
  Boolean                        $streaming_archiver            = $barman::streaming_archiver,
  Optional[Integer]              $streaming_archiver_batch_size = $barman::streaming_archiver_batch_size,
  Optional[String]               $streaming_archiver_name       = $barman::streaming_archiver_name,
  Optional[String]               $streaming_backup_name         = $barman::streaming_backup_name,
  Optional[String]               $streaming_conninfo            = undef,
  Optional[Stdlib::Absolutepath] $streaming_wals_directory      = undef,
  Optional[String]               $tablespace_bandwidth_limit    = $barman::tablespace_bandwidth_limit,
  Barman::WalRetention           $wal_retention_policy          = $barman::wal_retention_policy,
  Optional[Stdlib::Absolutepath] $wals_directory                = undef,
  Optional[String]               $custom_lines                  = $barman::custom_lines,
) {

  # check if 'description' has been correctly configured
  validate_re($ensure, '^(present|absent)$', "${ensure} is not a valid value (ensure = present|absent).")

  # check if backup_options has correct values
  validate_re($backup_options, [ '^exclusive_backup$', '^concurrent_backup$', 'Invalid backup option please use exclusive_backup or concurrent_backup' ])

  # check if 'description' has been correctly configured
  validate_re($name, '^[0-9a-z_\-/]*$', "${name} is not a valid name. Please only use lowercase letters, numbers, slashes, underscores and hyphens.")

  # check if immediate checkpoint is a boolean
  validate_bool($immediate_checkpoint)

  # check to make sure basebackup_retry_times is a numerical value
  if $basebackup_retry_times != false {
    validate_integer($basebackup_retry_times, undef, 0)
  }

  # check to make sure basebackup_retry_sleep is a numerical value
  if $basebackup_retry_sleep != false {
    validate_integer($basebackup_retry_sleep, undef, 0)
  }

  # check if minimum_redundancy is a number
  validate_integer($minimum_redundancy, undef, 0)

  # check to make sure last_backup_maximum_age identifies (DAYS | WEEKS | MONTHS) greater then 0
  if $last_backup_maximum_age != false {
    validate_re($last_backup_maximum_age, [ '^[1-9][0-9]* (DAY|WEEK|MONTH)S?$' ])
  }

  # check to make sure retention_policy has correct value
  validate_re($retention_policy, [ '^(^$|REDUNDANCY [1-9][0-9]*|RECOVERY WINDOW OF [1-9][0-9]* (DAY|WEEK|MONTH)S?)$' ])

  # check to make sure retention_policy_mode is set to auto
  validate_re($retention_policy_mode, [ '^auto$' ])

  # check to make sure wal_retention_policy is set to main
  validate_re($wal_retention_policy, [ '^main$' ])

  validate_bool($archiver)

  if $archiver_batch_size != undef {
    validate_integer($archiver_batch_size)
  }

  if $backup_method != undef {
    validate_re($backup_method, '^(rsync|postgres)$')
  }

  if $bandwidth_limit != undef {
    validate_integer($bandwidth_limit)
  }

  if $check_timeout != undef {
    validate_integer($check_timeout)
  }

  if $custom_compression_filter != undef {
    validate_string($custom_compression_filter)
  }

  if $custom_decompression_filter != undef {
    validate_string($custom_decompression_filter)
  }

  if $network_compression != undef {
    validate_bool($network_compression)
  }

  if $path_prefix != undef {
    validate_absolute_path($path_prefix)
  }

  if $slot_name != undef {
    validate_string($slot_name)
  }

  validate_bool($streaming_archiver)

  if $streaming_archiver_batch_size != undef {
    validate_integer($streaming_archiver_batch_size)
  }

  if $streaming_archiver_name != undef {
    validate_string($streaming_archiver_name)
  }

  if $streaming_backup_name != undef {
    validate_string($streaming_backup_name)
  }

  if $tablespace_bandwidth_limit != undef {
    validate_string($tablespace_bandwidth_limit)
  }

  # check to make sure reuse_backup has correct value
  if $reuse_backup != false {
    validate_re($reuse_backup, [ '^(off|link|copy)$' ])
  }

  if $custom_lines != '' {
    notice 'The \'custom_lines\' option is deprecated. Please use $conf_template for custom configuration'
  }

  file { "/etc/barman.conf.d/${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $barman::group,
    content => epp($conf_template, {
                     archiver                      => $archiver,
                     compression                   => $compression,
                     immediate_checkpoint          => $immediate_checkpoint,
                     max_incoming_wals_queue       => $max_incoming_wals_queue,
                     minimum_redundancy            => $minimum_redundancy,
                     snapshot_disks                => $snapshot_disks,
                     snapshot_gcp_project          => $snapshot_gcp_project,
                     snapshot_instance             => $snapshot_instance,
                     snapshot_provider             => $snapshot_provider,
                     snapshot_zone                 => $snapshot_zone,
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
                     streaming_wals_directory      => $streaming_wals_directory,

                     name                          => $name,
                     server_name                   => $server_name,
                     description                   => $description,
                     ssh_command                   => $ssh_command,
                     conninfo                      => $conninfo,
                     active                        => $active,
                     backup_directory              => $backup_directory,
                     basebackups_directory         => $basebackups_directory,
                     errors_directory              => $errors_directory,
                     incoming_wals_directory       => $incoming_wals_directory,
                     streaming_conninfo            => $streaming_conninfo,
                     wals_directory                => $wals_directory,
               }),
  }

  # Run 'barman check' to create Barman configuration directories
  exec { "barman-check-${name}":
    command     => "barman check ${name} || true",
    provider    => shell,
    subscribe   => File["/etc/barman.conf.d/${name}.conf"],
    refreshonly => true
  }
  if($barman::autoconfigure) {
    # export configuration for the pg_hba.conf
    if ($streaming_archiver or $backup_method == 'postgres') {
      @@postgresql::server::pg_hba_rule { "barman ${::hostname} client access (replication)":
        description => "barman ${::hostname} client access",
        type        => 'host',
        database    => 'replication',
        user        => $barman::settings::dbuser,
        address     => $barman::autoconfigure::exported_ipaddress,
        auth_method => 'md5',
        tag         => "barman-${barman::host_group}",
      }
    }
    @@postgresql::server::pg_hba_rule { "barman ${::hostname} client access":
      description => "barman ${::hostname} client access",
      type        => 'host',
      database    => $barman::settings::dbname,
      user        => $barman::settings::dbuser,
      address     => $barman::autoconfigure::exported_ipaddress,
      auth_method => 'md5',
      tag         => "barman-${barman::host_group}",
    }
  }

}
