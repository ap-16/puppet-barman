define barman::systemd::backup_timer (
    String                             $server_name,
    String                             $backup_mday,
    String                             $backup_wday,
    String                             $backup_hour,
    String                             $backup_minute,
    Optional[String]                   $more_unit_entries              = undef,
    Optional[String]                   $more_timer_entries             = undef,
    Optional[String]                   $more_install_entries           = undef,
    Optional[String]                   $host_group                     = $barman::host_group,
    Enum['present', 'absent']          $ensure                         = present,
    #String                             $tag,
) {

  #tag $tag

  file { "/usr/local/lib/systemd/system/barmanbackup_${server_name}.timer":
    ensure  => $ensure ? { 'present' => 'file', default => 'absent' },
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barman.timer.epp", {
                    host_group           => $host_group,
                    postgres_server_id   => $name,
                    backup_mday          => $backup_mday,
                    backup_wday          => $backup_wday,
                    backup_hour          => $backup_hour,
                    backup_minute        => $backup_minute,
                    more_unit_entries    => $more_unit_entries,
                    more_service_entries => $more_service_entries,
                    more_install_entries => $more_install_entries,
    }),
    #require => Barman::Systemd::Create_unit_path,
    require => Exec[ 'mkdir /usr/local/lib/systemd/system' ],
    notify  => Exec[ "barman systemctl daemon-reload" ],
    #tag     => $tag,
  } ->
  file { "/usr/local/lib/systemd/system/barman.target.d/uphold_barmanbackup_${server_name}.timer.conf":
    ensure  => $ensure ?{ 'present' => 'file', default => 'absent' },
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barman.target.drop-in.upholds.epp", {
                        upholds              => "barmanbackup_${server_name}.timer",
                    }),
    notify  => Exec[ "barman systemctl daemon-reload" ],
    tag     => "barman-${barman::host_group}",
  }

}
