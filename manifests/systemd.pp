# == Class: barman::systemd
#
# This class:
#
# * Creates the systemd.unit barman.target
# * realize all other systemd.units
#
# === Parameters
#
# @param host_group
#   Tag the different host groups for the backup
#   (default value is set from the 'settings' class).
# @param barman_binary
#   barman executable
# @param conf_file_path
#   barman basic configuration file
# @param more_barmantarget_unit_entries
#   additional config lines in the unit section of the barman.target
# @param more_barmantarget_install_entries
#   additional config lines in the install section of the barman.target
# @param more_barmancronservice_unit_entries
#   additional config lines in the unit section of the barmancron.service
# @param more_barmancronservice_service_entries
#   additional config lines in the service section of the barmancron.service
# @param more_barmancronservice_install_entries
#   additional config lines in the install section of the barmancron.service
# @param more_barmancrontimer_unit_entries
#   additional config lines in the unit section of the barmancron.timer
# @param more_barmancrontimer_timer_entries
#   additional config lines in the timer section of the barmancron.timer
# @param more_barmancrontimer_install_entries
#   additional config lines in the install section of the barmancron.timer
#
# generated systemd.units:
# have the substring `barman´ replaced by `barman${barman::host_group}´
# and are stored in directory `/usr/local/lib/systemd/system´ as told in
# man:systemd.unit(5) for `System units installed by the administrator´.
# Thus, single systemd.units can be deactivated using `systemctl mask´.
# Activation an enabling ist done only for  barman.target !
#
# === Authors
#
# * Andreas Papst <andreas.papst@univie.ac.at>
#
# === Copyright
#
# Copyright 2024 Andreas Papst
#
# === License
#
# Apache-2.0
#
class barman::systemd (
  Optional[String]    $host_group                             = $barman::host_group,
  Optional[String]    $assert_path_is_mount_point             = $barman::assert_path_is_mount_point,
  Optional[String]    $barman_binary                          = $barman::barman_binary,
  Optional[String]    $conf_file_path                         = $barman::conf_file_path,
  Optional[String]    $more_barmantarget_unit_entries         = undef,
  Optional[String]    $more_barmantarget_install_entries      = undef,
  Optional[String]    $more_barmancronservice_unit_entries    = undef,
  Optional[String]    $more_barmancronservice_service_entries = undef,
  Optional[String]    $more_barmancronservice_install_entries = undef,
  Optional[String]    $more_barmancrontimer_unit_entries      = undef,
  Optional[String]    $more_barmancrontimer_timer_entries     = undef,
  Optional[String]    $more_barmancrontimer_install_entries   = undef,
) {

  tag "barman-${barman::host_group}"
if $facts['service_provider'] == 'systemd' {
  require barman::systemd::create_unit_path
  #require barman::systemd::systemctl
  include  barman::systemd::systemctl
  file { "/usr/local/lib/systemd/system/barman.target":
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barman.target.epp", {
                        more_unit_entries    => $more_barmantarget_unit_entries,
                        more_install_entries => $more_barmantarget_install_entries,
                    }),
    require => Exec[ 'mkdir /usr/local/lib/systemd/system' ],
    notify  => Exec[ "barman systemctl daemon-reload" ],
    tag     => "barman-${barman::host_group}",
  } ->
  file { "/usr/local/lib/systemd/system/barman.target.d":
    ensure  => 'directory',
    owner   => root,
    group   => root,
    mode    => '0755',
    tag     => "barman-${barman::host_group}",
  } ->
  file { "/usr/local/lib/systemd/system/barmancron.service":
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barmancron.service.epp", {
                        barman_binary                          => $barman_binary,
                        conf_file_path                         => $conf_file_path,
                        assert_path_is_mount_point             => $assert_path_is_mount_point,
                        more_unit_entries    => $more_barmancronservice_unit_entries,
                        more_service_entries => $more_barmancronservice_service_entries,
                        more_install_entries => $more_barmancronservice_install_entries,
                    }),
    notify  => Exec[ "barman systemctl daemon-reload" ],
    tag     => "barman-${barman::host_group}",
  } ->
  file { "/usr/local/lib/systemd/system/barmancron.timer":
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barmancron.timer.epp", {
                        host_group                           => $host_group,
                        more_unit_entries    => $more_barmancrontimer_install_entries,
                        more_timer_entries   => $more_barmancrontimer_install_entries,
                        more_install_entries => $more_barmancrontimer_install_entries,
                    }),
    notify  => Exec[ "barman systemctl daemon-reload" ],
    tag     => "barman-${barman::host_group}",
  }
  file { "/etc/cron.d/barman":
    ensure  => 'absent',
    tag     => "barman-${barman::host_group}",
  }
  file { "/usr/local/lib/systemd/system/barman.target.d/uphold_barmancron.timer.conf":
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barman.target.drop-in.upholds.epp", {
                        upholds              => "barmancron.timer",
                    }),
    notify  => Exec[ "barman systemctl daemon-reload" ],
    tag     => "barman-${barman::host_group}",
  }

/*
  # Import all needed information for the 'server' class
  Barman::Systemd::Server <<| tag == "barman-${host_group}" |>> {
    require     => Class['barman'],
    notify  => Exec[ "barman systemctl daemon-reload" ],
  }
*/

}
}
