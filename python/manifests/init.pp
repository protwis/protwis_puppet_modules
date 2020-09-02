
# install packages inside the virtualenv with pip
define puppet::install::pip (
  $pip_package = $title
) {
  exec { "install-$pip_package":
    command => "/env/bin/pip3 install $pip_package",
    timeout => 1800,
    require => [Package["postgresql", "postgresql-contrib"], Exec["create-virtualenv"]]
  }
}

class python {

  $packages = $operatingsystem ? {
    "Ubuntu" => [
      "python3",
      "python3-dev",
      "python3-venv",
      "python3-pip",
      # for python2, will be removed
      "python3-biopython",
      "python3-openbabel",
      "python3-rdkit",
      "python3-yaml",
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
    "Fedora" => [
      "python3",
      "python3-devel",
      "python3-virtualenv",
      "python3-pip",
      # for python2, will be removed
      "python3-biopython",
      "python3-openbabel",
      "python3-rdkit",
      "python3-pyyaml",
      "libpq-devel",
    ],
  }

  # install packages
  package { $packages:
    ensure  => present,
    require => Exec["update-package-repo"]
  }

  # create a python3 symlink, because the names of the executable differ between OSes
  file { "/usr/local/bin/python3":
    ensure => "link",
    target => "/usr/bin/python3",
    require => $operatingsystem ? {
      "CentOS" => Package["python3"],
      "Ubuntu" => Package["python3"],
      "Fedora" => Package["python3"],
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
    command => "python3 -m venv /env",
  }

  $pip_packages = [
    "ipython",
    "django",
    "django-debug-toolbar",
    "django-extensions",
    "psycopg2-binary",
    "biopython",
    "xlrd",
    "numpy",
    "PyYAML",
    "djangorestframework",
    "django-rest-swagger",
    "XlsxWriter",
    "sphinx",
    "openpyxl",
    "xmltodict",
    "pandas",
    "django-polymorphic",
    "mmtf-python",
    "scipy",
    "sklearn",
    "freesasa",
    "lxml",
    "reportlab",
    "svglib",
    "jq",
    "chembl_webresource_client",
    "google-api-python-client",
    "oauth2client",
    "gunicorn"
  ]

  puppet::install::pip { $pip_packages: }

  # download and install dssp
  exec { "download-dssp":
    command => "/usr/bin/wget -q ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2.0.4-linux-amd64 -O /env/bin/dssp",
    creates => "/env/bin/dssp",
    require => Exec["create-virtualenv"],
  }

  file { "/env/bin/dssp":
    mode    => "0755",
    require => Exec["download-dssp"],
  }

  # download and install MODELLER for Ubuntu
  exec { "download-modeller":
    command => "curl https://salilab.org/modeller/9.24/modeller_9.24-1_amd64.deb -o /tmp/modeller_9.24-1_amd64.deb",
    creates => "/tmp/modeller_9.24-1_amd64.deb",
    require => Exec["create-virtualenv"],
  }
  exec { "install-modeller":
    command => "sudo env KEY_MODELLER=MODELIRANJE dpkg -i /tmp/modeller_9.24-1_amd64.deb",
    require => Exec["download-modeller"],
  }
  exec { "move-modeller":
    command => "sudo mv /usr/lib/modeller9.24/modlib/modeller /env/lib/python3.8/site-packages/",
    creates => "/env/lib/python3.8/site-packages/modeller",
    require => Exec["install-modeller"],
  }
  exec { "move_modeller.so":
    command => "sudo mv /usr/lib/modeller9.24/lib/x86_64-intel8/python3.3/_modeller.so /env/lib/python3.8/site-packages/",
    creates => "/env/lib/python3.8/site-packages/_modeller.so",
    require => Exec["install-modeller"],
  }
}

# # download and install MODELLER for Fedora/RedHat
# exec { "download-modeller":
#   command =>
#     "curl https://salilab.org/modeller/9.24/modeller-9.24-1.x86_64.rpm -o /tmp/modeller-9.24-1.x86_64.rpm",
#   creates => "/tmp/modeller-9.24-1.x86_64.rpm",
#   require => Exec["create-virtualenv"],
# }
# exec { "install-modeller":
#   command => "sudo env KEY_MODELLER=MODELIRANJE rpm -Uvh /tmp/modeller-9.24-1.x86_64.rpm",
#   require => Exec["download-modeller"],
# }
# exec { "move-modeller":
#   command => "sudo mv /usr/lib/modeller9.24/modlib/modeller /env/lib/python3.8/site-packages/",
#   creates => "/env/lib/python3.8/site-packages/modeller",
#   require => Exec["install-modeller"],
# }
# exec { "move_modeller.so":
#   command => "sudo mv /usr/lib/modeller9.24/lib/x86_64-intel8/python3.3/_modeller.so /env/lib/python3.8/site-packages/",
#   creates => "/env/lib/python3.8/site-packages/_modeller.so",
#   require => Exec["install-modeller"],
# }
# }
