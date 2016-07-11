class python {

    $packages = $operatingsystem ? {
        "Ubuntu" => [
                "python3.4",
                "python3-pip",
		"python3-lxml",
                # for python2, will be removed
                "python-biopython",
                "python-openbabel",
                "python-rdkit",
                "python-yaml",
        ],
        "CentOS" => [
                "python34",
                "python34-devel",
                # for python2, will be removed
                "python-biopython",
                "python-openbabel",
                #"python-rdkit",
                "PyYAML",
        ],
    }

    # install packages
    package { $packages:
        ensure => present,
        require => Exec["update-package-repo"]
    }

    # create a python3 symlink, because the names of the executable differ between OSes
    file { "/usr/local/bin/python3":
        ensure => "link",
        target => "/usr/bin/python3.4",
        require => $operatingsystem ? {
            "CentOS" => Package["python34"],
            "Ubuntu" => Package["python3.4"],
        }
    } ->
    # install pip
    exec { "install-pip":
        cwd => "/tmp",
        command => $operatingsystem ? {
            "CentOS" => "wget https://bootstrap.pypa.io/get-pip.py;python3 get-pip.py",
            "Ubuntu" => "apt install -y python3-pip",
        },
    }

    # install virtualenv (using the system wide pip3 installation)
    exec { "install-virtualenv":
        command => "pip3 install virtualenv",
        require => Exec["install-pip"],
    }

    # create virtualenv
    exec { "create-virtualenv":
        command => "virtualenv -p python3 /env",
        require => Exec["install-virtualenv"],
    }

    # install packages inside the virtualenv with pip
    define puppet::install::pip ($pip_package = $title) {
        exec { "install-$pip_package":
            command => "/env/bin/pip3 install $pip_package",
            timeout => 1800,
            require => [Package["postgresql", "postgresql-contrib"], Exec["create-virtualenv"]]
        }
    }

    $pip_packages = ["ipython", "django", "django-debug-toolbar", "psycopg2", "biopython", "xlrd", "numpy", "PyYAML",
        "djangorestframework", "django-rest-swagger", "XlsxWriter", "sphinx","openpyxl", "requests", "chardet", "urllib3"]

    puppet::install::pip { $pip_packages: }
}
