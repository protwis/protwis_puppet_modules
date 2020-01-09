class import_db {
    require postgresql

    # create postgres user
    exec { "create-postgres-user":
        command => "expect -f /protwis/conf/protwis_puppet_modules/import_db/scripts/createuser.exp",
        require => $osfamily ? {
            "Debian" => Package["postgresql", "expect"],
            "RedHat" => [ Package["postgresql", "expect"], Exec["start-postgres-server"] ],
        }
    }

    # create postgres database
    exec { "create-postgres-db":
        command => "expect -f /protwis/conf/protwis_puppet_modules/import_db/scripts/createdb.exp",
        require => [ Exec["create-postgres-user"], Package["expect"], ],
    }

    # create db directory
    file { '/protwis/db':
        ensure => 'directory',
    }

    # download db dump
    exec { "dl-db-dump":
        command => "curl http://files.gpcrdb.org/protwis_full.sql.gz > /protwis/db/protwis.sql.gz",
        timeout => 3600,
        require => [Exec["create-postgres-db"], File['/protwis/db']],
    }

    # import db dump directly from gz
    exec { "import-db-dump":
         command => "expect -f /protwis/conf/protwis_puppet_modules/import_db/scripts/importdb.exp",
         timeout => 3600,
        require => [ Exec["dl-db-dump"], Package["expect"], ],
    }
}
