define barman::systemd::backup_service (
    Optional[String]                   $more_unit_entries              = undef,
    Optional[String]                   $more_service_entrie            = undef,
    Optional[String]                   $more_install_entries           = undef,
    Optional[String]                   $assert_path_is_mount_point     = undef,
    Stdlib::Absolutepath               $barman_binary,
    Stdlib::Absolutepath               $conf_file_path,
    Stdlib::Absolutepath               $server_file_path,
    Optional[String]                   $host_group                     = $barman::host_group,
    Enum['present', 'absent']          $ensure                         = present,
    #String                             $tag,
) {

  #tag $tag

  file { "/usr/local/lib/systemd/system/barmanbackup_${name}.service":
    ensure  => $ensure ? { 'present' => 'file', default => 'absent' },
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp( "${module_name}/systemd/barman.service.epp", {
                    assert_path_is_mount_point => $assert_path_is_mount_point,
                    postgres_server_id         => $name,
                    barman_binary              => $barman_binary,
                    conf_file_path             => $conf_file_path,
                    server_file_path           => $server_file_path,
                    more_unit_entries          => $more_unit_entries,
                    more_service_entries       => $more_service_entries,
                    more_install_entries       => $more_install_entries,
    }),
    #require => Barman::Systemd::Create_unit_path,
    require => Exec[ 'mkdir /usr/local/lib/systemd/system' ],
    notify  => Exec[ "barman systemctl daemon-reload" ],
    #tag     => $tag,
  }

}
