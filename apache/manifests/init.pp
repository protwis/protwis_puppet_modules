class apache {
    # install apache
    $apache_packages = $osfamily ? {
        "Debian" => ["apache2"],
        "RedHat" => ["httpd", "httpd-devel"],
    }
    $apache_main_package = $apache_packages[0]
    package { $apache_packages:
        ensure => present,
        require => Exec["update-package-repo"],
    } ->
    # install mod_wsgi
    case $osfamily {
        'Debian': {
            package { "libapache2-mod-wsgi-py3":
                ensure => present,
                require => [ Exec["update-package-repo"], Package[$apache_main_package] ],
            }
        }
        'RedHat': {
            exec { "install-mod_wsgi":
                cwd => "/protwis",
                command => "bash /protwis/conf/protwis_puppet_modules/apache/scripts/mod_wsgi.sh",
                timeout => 3600,
                require => [ File["/usr/local/bin/python3"], Package[$apache_main_package, "python34-devel"] ],
            }->
            exec { "enable-mod_wsgi":
                command => "echo 'LoadModule wsgi_module modules/mod_wsgi.so' >> /etc/httpd/conf/httpd.conf",
            }
        }
    }

    # create dirs
    file { "/etc/$apache_main_package/sites-available":
    ensure => directory,
        recurse => true,
        purge => true,
        force => true,
        before => File["/etc/$apache_main_package/sites-available/000-default.conf"],
        require => Package[$apache_main_package],
    }
    file { "/etc/$apache_main_package/sites-enabled":
        ensure => directory,
        recurse => true,
        purge => true,
        force => true,
        before => File["/etc/$apache_main_package/sites-enabled/000-default.conf"],
        require => Package[$apache_main_package],
    }
    # this is to allow logging under apache
    file { "/var/www/logs":
        ensure => directory,
        recurse => true,
        purge => true,
        force => true,
        mode   => '0777',
        before => File["/etc/$apache_main_package/sites-enabled/000-default.conf"],
        require => Package[$apache_main_package],
    }

    # add sites-enabled dir to main apache config (RedHat OSes only)
    if $osfamily == 'RedHat' {
        exec { "add-sites-enabled-dir":
            command => "echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf",
            require => File["/etc/$apache_main_package/sites-enabled"],
        }
    }

    # allow traffic on port 80 (RedHat OSes only)
    if $osfamily == 'RedHat' {
        exec { "open-port-80":
            command => "firewall-cmd --zone=public --add-port=80/tcp",
        }
        exec { "open-port-80-permanent":
            command => "firewall-cmd --zone=public --add-port=80/tcp --permanent",
        }
    }

    # create apache config
    file { "/etc/$apache_main_package/sites-available/000-default.conf":
        ensure => present,
        recurse => true,
        source => "/protwis/conf/protwis_puppet_modules/apache/config/virtualhost",
        require => Package[$apache_main_package],
    }

    # symlink apache site to the site-enabled directory
    file { "/etc/$apache_main_package/sites-enabled/000-default.conf":
        ensure => link,
        target => "/etc/$apache_main_package/sites-available/000-default.conf",
        require => File["/etc/$apache_main_package/sites-available/000-default.conf"],
        notify => Service[$apache_main_package],
    }

    # generate blast database and collect static files before starting apache
    exec { "build_blast_db":
        cwd => "/protwis/sites/protwis",
        command => "/protwis/env/bin/python3 manage.py build_blast_database",
        environment => ["LC_ALL=en_US.UTF-8"],
        require => Exec["import-db-dump", "install-psycopg2"],
    }
    exec { "collect-static":
        cwd => "/protwis/sites/protwis",
        command => "/protwis/env/bin/python3 manage.py collectstatic --noinput",
        require => Exec["import-db-dump", "install-psycopg2"],
    }

    # starts the apache2 service once the packages installed, and monitors changes to its configuration files and
    # reloads if nesessary
    service { $apache_main_package:
        ensure => running,
        require => [ Package[$apache_main_package], Exec["collect-static"] ],
        subscribe => [
            File["/etc/$apache_main_package/sites-available/000-default.conf"]
        ],
    }
}
