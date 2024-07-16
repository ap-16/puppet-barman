# == Class: barman::systemd::systemctl
#
# This class:
#
# * activation and enabling of systemd.unit barman.target
#
# === Parameters
#
# @param host_group
#   Tag the different host groups for the backup
#   (default value is set from the 'settings' class).
# @param enabled
#   enable (default/true) or disable (false) barman.target
# @param active
#   start (default/true) or stop (false) barman.target
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
class barman::systemd::systemctl (
  Optional[String]    $host_group                             = $barman::host_group,
  Optional[Boolean]   $enabled                                = true,
  Optional[Boolean]   $active                                 = true,
) {

 tag "barman-${barman::host_group}"
 if $facts['service_provider'] == 'systemd' {
  exec{ "barman systemctl daemon-reload":
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    before      => [ Exec[ "barman systemctl enabled", 
                           "barman systemctl active" ]
                   ],
  }
  if $enabled {
    exec{ "barman systemctl enabled":
      command     => "/usr/bin/systemctl enable barman.target",
      unless      => "/usr/bin/systemctl is-enabled barman.target",
    }
  } else {
    exec{ "barman systemctl enabled":
      command     => "/usr/bin/systemctl disable barman.target",
      onlyif      => "/usr/bin/systemctl is-enabled barman.target",
    }
  }
  if $active {
    exec{ "barman systemctl active":
      command     => "/usr/bin/systemctl restart barman.target",
      unless      => "/usr/bin/systemctl is-active barman.target",
    }
  } else {
    exec{ "barman systemctl active":
      command     => "/usr/bin/systemctl stop barman.target",
      onlyif      => "/usr/bin/systemctl is-active barman.target",
    }
  }

 }
}
