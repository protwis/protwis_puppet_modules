class tools {

  # package install list
  $packages = $operatingsystem ? {
    "Ubuntu" => [
      "expect",
      "htop",
      "vim",
      "emacs",
      "tig",
      "clustalo",
      "ncbi-blast+",
    ],
    "CentOS" => [
      "expect",
      "htop",
      "vim",
      "emacs",
      "tig",
      "clustal-omega",
      # "ncbi-blast+",
    ],
  }

  # install packages
  package { $packages:
    ensure  => present,
    require => Exec["update-package-repo"]
  }
}
