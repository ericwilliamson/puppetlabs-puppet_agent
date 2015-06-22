# == Class: puppet_agent
#
# Upgrades Puppet 3.8 to Puppet 4+ (Puppet-Agent from Puppet Collection 1).
# Makes the upgrade easier by migrating SSL certs and config files to the new
# Puppet-Agent paths and removing deprecated settings that are no longer
# supported by Puppet 4.
#
# === Parameters
#
# [package_name]
#   The package to upgrade to, i.e. `puppet-agent`.
# [service_names]
#   An array of services to start, normally `puppet` and `mcollective`.
#   None will be started if the array is empty.
#
class puppet_agent (
  $arch          = $::architecture,
  $package_name  = $::puppet_agent::params::package_name,
  $service_names = $::puppet_agent::params::service_names,
  $source        = undef,
) inherits ::puppet_agent::params {

  validate_re($arch, ['^x86$','^x64$','^i386$','^amd64$','^x86_64$','^power$'])

  if versioncmp("$::clientversion", '3.8.0') < 0 {
    fail('upgrading requires Puppet 3.8')
  }
  elsif versioncmp("$::clientversion", '4.0.0') >= 0 {
    info('puppet_agent performs no actions on Puppet 4+')
  }
  else {

    # Need to determine if we are going to use cgi and patterns will continue to match
    # https://puppetlabs.com/misc/pe-files prior to setting, also package installs work
    # some distros so it will not be needed
    $_source = "https://${::servername}:8140/packages/4.0.0-rc4-267-g113f2d8/${::platform_tag}"
#   if $source == undef {
#     case $::osfamily {
#       'RedHat', 'Amazon': {
#         # The OS version used in our yum repo url.
#         # Yes there is supposed to be an f before releasever for Fedora.
#         # $releasever is an OS level variable, not a puppet one.
#         $yum_os_version = $::operatingsystem ? {
#           'Fedora' => 'fedora/f$releasever',
#           default  => 'el/$releasever',
#         }

#         $_source = "https://yum.puppetlabs.com/${yum_os_version}/PC1/${::architecture}"
#       }
#       'Debian': {
#         $_source = 'http://apt.puppetlabs.com'
#       }
#       'Windows': {
#         $_arch = $::kernelmajversion ?{
#           /^5\.\d+/ => 'x86', # x64 is never allowed on windows 2003
#           default   => $::puppet_agent::arch,
#         }

#         $_source = "https://downloads.puppetlabs.com/windows/puppet-agent-${_arch}-latest.msi"
#       }
#       default: {
#         $_source = undef
#       }
#     }
#   }
#   else {
#     $_source = $source
#   }

    class { '::puppet_agent::prepare': } ->
    class { '::puppet_agent::install': } ->
    class { '::puppet_agent::config': } ~>
    class { '::puppet_agent::service': }

    contain '::puppet_agent::prepare'
    contain '::puppet_agent::install'
    contain '::puppet_agent::config'
    contain '::puppet_agent::service'
  }
}
