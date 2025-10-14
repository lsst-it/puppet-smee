# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'smee class' do
  shell('dnf install -y podman-docker') # used by serverspec

  include_examples 'the example', 'smee.pp'

  it_behaves_like 'an idempotent resource'

  describe service('smee') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe docker_container('systemd-smee') do
    its(['Config.Image']) { is_expected.to eq 'ghcr.io/lsst-it/smee-client:4.3.1' }
    its(['Config.User']) { is_expected.to eq '65534:65534' }
    its(['HostConfig.NetworkMode']) { is_expected.to eq 'host' }
    its(['Args']) { is_expected.to include('--url') }
    its(['Args']) { is_expected.to include('https://smee.io/WfmVJamW8LnOgVy') }
    its(['Args']) { is_expected.to include('--path') }
    its(['Args']) { is_expected.to include('/payload') }
    its(['Args']) { is_expected.to include('--port') }
    its(['Args']) { is_expected.to include('1234') }
  end
end
