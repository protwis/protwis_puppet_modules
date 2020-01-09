class adminer {

    # package install list
    $packages = [
        "libapache2-mod-php",
        "php-pgsql",
        "apache2",
        "php",
    ]

    # install packages
    package { $packages:
        ensure => present,
        require => Exec["update-package-repo"]
    }
    
    file { '/var/www/html/adminer/':
        ensure => 'directory',
        require => Package["apache2"],
    }

    exec { "fetch-adminer":
        command => "wget http://www.adminer.org/latest.php -O /var/www/html/adminer/index.php",
        creates => "/var/www/html/adminer/index.php",
        require => Package["apache2"],
    }

    # starts the apache2 service once the packages installed, and monitors changes to its configuration files and
    # reloads if nesessary
        service { "apache2":
        ensure => running,
        require => Package["apache2"],
    }
}
