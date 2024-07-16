class barman::systemd::create_unit_path {
  exec { 'mkdir /usr/local/lib/systemd/system':
    command => 'mkdir -p --mode=0755 /usr/local/lib/systemd/system',
    path    => '/usr/bin:/bin',
    unless  => 'test -d /usr/local/lib/systemd/system',
    umask   => '0022',
    user    => 'root',
  }
}
