# frozen_string_literal: true

configure_beaker do |host|
  install_package(host, 'git')
  clone_git_repo_on(host, '/etc/puppetlabs/code/environments/production/modules',
                    name: 'scl',
                    path: 'https://github.com/lsst-it/puppet-scl',
                    rev: 'production')
end
