# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_package(host, 'git')
  clone_git_repo_on(host, '/etc/puppetlabs/code/environments/production/modules',
                    name: 'scl',
                    path: 'https://github.com/lsst-it/puppet-scl',
                    rev: 'production')
end

shared_examples 'an idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end
