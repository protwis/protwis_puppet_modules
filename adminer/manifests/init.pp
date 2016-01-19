class adminer {

    # package install list
    $packages = [
        "apache2",
        "adminer",
    ]

    # install packages
    package { $packages:
        ensure => present,
        require => Exec["update-package-repo"]
    }

    # configure adminer
    file { "/etc/apache2/conf-enabled/adminer.conf":
        ensure => link,
        target => "/etc/adminer/apache.conf",
        require => Package["adminer"],
        notify => Service["apache2"],
    }

    # starts the apache2 service once the packages installed, and monitors changes to its configuration files and
    # reloads if nesessary
        service { "apache2":
        ensure => running,
        require => Package["apache2"],
    }
}
