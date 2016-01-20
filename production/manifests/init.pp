class production {
    # copy production settings to local settings file
    file { "/protwis/sites/protwis/protwis/settings_local.py":
        ensure => present,
        source => "/protwis/sites/protwis/protwis/settings_local_production.py",
        before => Exec["build_blast_db"],
    }
}
