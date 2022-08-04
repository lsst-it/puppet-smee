# frozen_string_literal: true

require 'spec_helper'

describe 'smee' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'without any parameters' do
        it { is_expected.to compile.and_raise_error(%r{expects a value for parameter 'url'}) }
      end

      describe 'with url param' do
        let(:params) do
          {
            url: 'https://foo.example.org',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end # context "on #{os}" do
  end # on_supported_os.each do |os, facts|
end
