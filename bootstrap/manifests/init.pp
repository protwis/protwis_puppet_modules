class bootstrap {

  # silence puppet and vagrant annoyance about the puppet group
  group { "puppet":
    ensure => "present",
  }

  # enable the multiverse (non-free) software repositories
  exec { "enable-alt-repos":
    command => $operatingsystem ? {
        "CentOS" => "yum -y install epel-release",
        "Ubuntu" => 'sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list',
    }
  }

  # ensure that package repository up to date before beginning (Ubuntu only)
  exec { "update-package-repo":
    command => $operatingsystem ? {
        "Ubuntu" => "apt-get update",
        default => "w",
    },
    require => Exec["enable-alt-repos"],
  }

  exec { "set-locale":
    command => "bash /protwis/conf/protwis_puppet_modules/bootstrap/scripts/locale.sh",
    require => Exec["update-package-repo"],
  }
}
