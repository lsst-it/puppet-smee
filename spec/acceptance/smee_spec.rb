# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'smee class' do
  context 'with url' do
    let(:pp) do
      <<-PP
        if versioncmp($facts['os']['release']['major'],'7') <= 0 {
          class { scl: } -> Class['smee']
        }

        class { smee:
          url  => 'https://foo.example.org',
        }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe service('smee') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    # rubocop:disable RSpec/RepeatedDescription
    describe process('node') do
      its(:user) { is_expected.to eq 'root' }
      its(:args) { is_expected.to match %r{--url https://foo.example.org} }
      its(:args) { is_expected.to match %r{-P /payload} }
      its(:args) { is_expected.to match %r{-p 8088} }
    end
    # rubocop:enable RSpec/RepeatedDescription
  end
end
