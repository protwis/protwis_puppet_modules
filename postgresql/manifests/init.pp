class postgresql {
    # package install list
    $packages = $osfamily ? {
        "Debian" => [
            "postgresql",
            "postgresql-contrib",
            "postgresql-server-dev-all",
        ],
        "RedHat" => [
            "postgresql",
            "postgresql-contrib",
            "postgresql-server",
            "postgresql-devel",
        ],
    }

    # install packages
    package { $packages:
        ensure => present,
        require => Exec["update-package-repo"]
    }

    # RedHat distros require extra commands to init postgres
    if $osfamily == "RedHat" {
        exec { "init-postgres-db":
            command => "/usr/bin/true",
            unless => "postgresql-setup initdb", # if this command fails (DB already initialized, do nothing)
            require => Package['postgresql'],
        }

        exec { "allow-postgres-password-auth":
            command => 'sed -i "s/ident/md5/g" /var/lib/pgsql/data/pg_hba.conf',
            require => Exec['init-postgres-db'],
        }

        exec { "start-postgres-server":
            command => 'systemctl start postgresql;systemctl enable postgresql',
            require => Exec['allow-postgres-password-auth'],
        }
    }
}
