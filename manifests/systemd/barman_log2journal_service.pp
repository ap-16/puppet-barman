class barman::systemd::barman_log2journal_service (
    Optional[String]                   $more_unit_entries              = undef,
    Optional[String]                   $more_service_entrie            = undef,
    Optional[String]                   $more_install_entries           = undef,
    Stdlib::Absolutepath               $log_file_path,
    Optional[String]                   $host_group                     = $barman::host_group,
    Enum['present', 'absent']          $ensure                         = present,
    #String                             $tag,
) {

  #tag $tag


  file { "/usr/local/lib/systemd/system/barmanlog2journal.service":
    ensure  => $ensure ? { 'present' => 'file', default => 'absent' },
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barman.log2journal.service.epp", {
                    conf_file_path       => $conf_file_path,
                    server_file_path     => $server_file_path,
                    more_unit_entries    => $more_unit_entries,
                    more_service_entries => $more_service_entries,
                    more_install_entries => $more_install_entries,
    }),
    #require => Barman::Systemd::Create_unit_path,
    require => Exec[ 'mkdir /usr/local/lib/systemd/system' ],
    notify  => Exec[ "barman systemctl daemon-reload" ],
    #tag     => $tag,
  } ->
  service { 'barmanlog2journal.service':
    ensure   => 'running',
    provider => 'systemd',
    require  => Exec[ "barman systemctl daemon-reload" ],
  }

}
