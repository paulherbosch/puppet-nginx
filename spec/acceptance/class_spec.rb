require 'spec_helper_acceptance'

describe "nginx class:" do

  context 'default parameters' do
    it 'should run successfully' do
      pp = "class { 'nginx': }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe package('nginx') do
    it { is_expected.to be_installed }
  end

  describe service('nginx') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

end
