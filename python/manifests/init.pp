class python {
    # package install list
    $packages = [
        "python3-pip",
        "ipython3",
        # for python2, will be removed
        "python-biopython",
        "python-openbabel",
        "python-rdkit",
        "python-yaml",
    ]

    # install packages
    package { $packages:
        ensure => present,
        require => Exec["update-package-repo"]
    }

    # install django
    exec { "install-django":
        command => "pip3 install django",
        require => Package["python3-pip"]
    }

    # install debug-toolbar
    exec { "install-debug-toolbar":
        command => "pip3 install django-debug-toolbar",
        require => Package["python3-pip"]
    }

    # install biopython
    exec { "install-biopython":
        command => "pip3 install biopython",
        require => Package["python3-pip"]
    }

    # install xlrd
    exec { "install-xlrd":
        command => "pip3 install xlrd",
        require => Package["python3-pip"]
    }

    # install psycopg2
    exec { "install-psycopg2":
        command => "pip3 install psycopg2",
        require => Package["python3-pip", "postgresql", "postgresql-contrib", "postgresql-server-dev-all"],
    }

    # install numpy
    exec { "install-numpy":
        command => "pip3 install numpy",
        require => Package["python3-pip"],
    }

    # install PyYAML
    exec { "install-pyyaml":
        command => "pip3 install PyYAML",
        require => Package["python3-pip"],
    }

    # install django rest framework
    exec { "install-djangorestframework":
        command => "pip3 install djangorestframework",
        require => [Package["python3-pip"], Exec["create-virtualenv"]]
    }

    # install django rest swagger
    exec { "install-django-rest-swagger":
        command => "pip3 install django-rest-swagger",
        require => [Package["python3-pip"], Exec["create-virtualenv"]]
    }

    # install XlsxWriter
    exec { "install-xlsxwriter":
        command => "pip3 install XlsxWriter",
        require => Package["python3-pip"],
    }

    # install Sphinx
    exec { "install-sphinx":
        command => "pip3 install sphinx",
        require => Package["python3-pip"],
    }
}