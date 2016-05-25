require 'spec_helper_acceptance'

describe "nginx::resource::vhost define:" do
  context 'new vhost on port 80' do
    it 'should configure a nginx vhost' do

      pp = "
      class { 'nginx': }
      nginx::resource::vhost { 'www.puppetlabs.com':
        ensure   => present,
        proxy    => 'http://puppetlabs-upstream'
      }

      nginx::resource::upstream { 'puppetlabs-upstream':
        ensure  => present,
        members => [
          'localhost:3000',
          'localhost:3001',
          'localhost:3002',
        ],
      }

      host { 'www.puppetlabs.com': ip => '127.0.0.1', }
      "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end


    describe file('/etc/nginx/sites-available/www.puppetlabs.com.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain "www.puppetlabs.com" }
    end

    describe file('/etc/nginx/sites-enabled/www.puppetlabs.com.conf') do
      it { is_expected.to be_linked_to '/etc/nginx/sites-available/www.puppetlabs.com.conf' }
    end

    describe file('/etc/nginx/conf.d/puppetlabs-upstream-upstream.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain "puppetlabs-upstream" }
      it { is_expected.to contain "localhost:3000" }
    end

    describe service('nginx') do
      it { is_expected.to be_running }
    end
    
    describe port(80) do
      it { is_expected.to be_listening }
    end

  end
end
