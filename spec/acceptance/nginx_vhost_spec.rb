require 'spec_helper_acceptance'

describe "nginx::resource::vhost define:" do
  context 'new vhost on port 80' do
    it 'should configure a nginx vhost' do

      pp = "
      class { 'nginx': }
      nginx::resource::vhost { 'www.puppetlabs.com':
        ensure   => present,
        www_root => '/var/www/www.puppetlabs.com',
      }
      host { 'www.puppetlabs.com': ip => '127.0.0.1', }
      file { ['/var/www','/var/www/www.puppetlabs.com']: ensure => directory }
      file { '/var/www/www.puppetlabs.com/index.html': ensure  => file, content => 'Hello from www\n', }
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

    describe service('nginx') do
      it { is_expected.to be_running }
    end
    
    describe port(80) do
      it { is_expected.to be_listening }
    end

    it 'should answer to www.puppetlabs.com' do
      shell("/usr/bin/curl http://www.puppetlabs.com:80") do |r|
        expect(r.stdout).to eq("Hello from www\n")
        expect(r.exit_code).to be_zero
      end
    end
  end
end
