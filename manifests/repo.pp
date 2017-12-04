# Repo installation
class wazuh::repo (
  $redhat_manage_epel = true,
  $deb_repo           = $::wazuh::params::deb_repo,
  $deb_key            = $::wazuh::params::deb_key,
  $deb_key_id         = $::wazuh::params::deb_key_id,
  $rpm_repo           = $::wazuh::params::rpm_repo,
  $rpm_key            = $::wazuh::params::rpm_key
) {
  case $::osfamily {
    'Debian' : {
      if ! defined(Package['apt-transport-https']) {
        ensure_packages(['apt-transport-https'], {'ensure' => 'present'})
      }
      # apt-key added by issue #34
      apt::key { 'wazuh':
        id     => $deb_key_id,
        source => $deb_key,
        server => 'pgp.mit.edu'
      }
      apt::source { 'wazuh':
        ensure   => present,
        comment  => 'This is the WAZUH repository',
        location => $deb_repo,
        release  => $::lsbdistcodename,
        repos    => 'main',
        include  => {
          'src' => false,
          'deb' => true,
        }
      }
    }
    'Linux', 'Redhat' : {
      # Set up OSSEC repo
      yumrepo { 'wazuh':
        descr    => 'WAZUH OSSEC Repository - www.wazuh.com',
        enabled  => true,
        gpgcheck => 1,
        gpgkey   => $rpm_key,
        baseurl  => $rpm_repo
      }

      if $redhat_manage_epel {
        # Set up EPEL repo
        # NOTE: This relies on the 'epel' module referenced in metadata.json
        package { 'inotify-tools':
          ensure  => present
        }
        include epel

        Class['epel'] -> Package['inotify-tools']
      }
    }
    default: { fail('This ossec module has not been tested on your distribution') }
  }
}
