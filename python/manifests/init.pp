
# install packages inside the virtualenv with pip
define puppet::install::pip ($pip_package = $title) {
    exec { "install-$pip_package":
        command => "/env/bin/pip3 install $pip_package",
        timeout => 1800,
        require => [Package["postgresql", "postgresql-contrib"], Exec["create-virtualenv"]]
    }
}

class python {

    $packages = $operatingsystem ? {
        "Ubuntu" => [
                "python3.7",
                "python3.7-dev",
                "python3.7-venv",
                "python3-pip",
                # for python2, will be removed
                "python-biopython",
                "python-openbabel",
                "python-rdkit",
                "python-yaml",
                "libpq-dev",
        ],
        "CentOS" => [
                "python37",
                "python37-devel",
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
        target => "/usr/bin/python3.7",
        require => $operatingsystem ? {
            "CentOS" => Package["python37"],
            "Ubuntu" => Package["python3.7"],
        }
    }

    # install pip
    # exec { "install-pip":
    #    cwd => "/tmp",
    #    command => $operatingsystem ? {
    #        "CentOS" => "wget https://bootstrap.pypa.io/get-pip.py;python3 get-pip.py",
    #        "Ubuntu" => "apt install -y python3-pip",
    #    },
    #}


    # create virtualenv
    exec { "create-virtualenv":
        command => "python3.7 -m venv /env",
    }

    $pip_packages = ["ipython", "django", "django-debug-toolbar", "psycopg2-binary", "biopython", "xlrd", "numpy", "PyYAML",
        "djangorestframework", "django-rest-swagger", "XlsxWriter", "sphinx", "openpyxl", "xmltodict", "pandas",
        "django-polymorphic", "mmtf-python", "scipy", "sklearn", "freesasa"]

    puppet::install::pip { $pip_packages: }

    # download and install dssp
    exec { "download-dssp":
        command => "/usr/bin/wget -q ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2.0.4-linux-amd64 -O /env/bin/dssp",
        creates => "/env/bin/dssp",
        require => Exec["create-virtualenv"],
    }

    file { "/env/bin/dssp":
        mode => "0755",
        require => Exec["download-dssp"],
    }

    # download and install MODELLER
    exec { "download-modeller":
        command => "/usr/bin/wget -q https://salilab.org/modeller/9.23/modeller_9.23-1_amd64.deb -O /env/lib/mod9.23-1_install.deb",
        creates => "/env/lib/mod9.23-1_install.deb",
        require => Exec["create-virtualenv"],
    }
    exec { "install-modeller":
        command => "sudo env KEY_MODELLER=MODELIRANJE dpkg -i /env/lib/mod9.23-1_install.deb",
        require => Exec["download-modeller"],
    }
    exec { "move-modeller":
        command => "sudo mv /usr/lib/python3.7/dist-packages/modeller /env/lib/python3.7/site-packages/",
        creates => "/env/lib/python3.7/site-packages/modeller",
        require => Exec["install-modeller"],
    }
    exec { "move_modeller.so":
        command => "sudo mv /usr/lib/python3.7/dist-packages/_modeller.so /env/lib/python3.7/site-packages/",
        creates => "/env/lib/python3.7/site-packages/_modeller.so",
        require => Exec["install-modeller"],
    }
}
