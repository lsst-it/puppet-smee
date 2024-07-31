# @summary
#   Manages the smee.io webhook proxy service client
#
# @param url
#   URL to the smee topic to watch for webhook events.
#
# @param packages
#   URL to the smee topic to watch for webhook events.
#
# @param binary
#   Path to smee client binary.
#
# @param exec_start
#   Systemd `ExecStart` string.
#
# @param path
#   URL path to post proxied requests to.
#
# @param port
#   Local HTTP server port.
#
# @param version
#   Version of the smee-client package to install.
#
class smee (
  Stdlib::HTTPSUrl $url,
  Array[String] $packages,
  Stdlib::Absolutepath $binary,
  Stdlib::Absolutepath $exec_start,
  String $path = '/',
  Integer $port = 3000,
  String $version = '2.0.0',
) {
  stdlib::ensure_packages($packages)

  group { 'smee':
    ensure => present,
    system => true,
  }
  -> user { 'smee':
    ensure     => present,
    gid        => 'smee',
    home       => '/',
    managehome => false,
    shell      => '/sbin/nologin',
    system     => true,
  }

  exec { 'install-smee':
    creates   => $binary,
    command   => "npm install --global smee-client@${version}",
    subscribe => Package[$packages],
    path      => [
      '/opt/rh/rh-nodejs10/root/usr/bin',  # needed for EL7
      '/usr/sbin',
      '/usr/bin',
    ],
  }

  $service_unit = @("EOT")
    [Unit]
    Description=smee.io webhook daemon

    [Service]
    Type=simple
    User=smee
    Group=smee
    ExecStart=${exec_start} \
      --url ${url} \
      -P ${path} \
      -p ${port}
    Restart=on-failure
    RestartSec=10
    PrivateTmp=yes
    PrivateDevices=yes
    ProtectSystem=yes
    ProtectHome=yes

    [Install]
    WantedBy=default.target
    | EOT

  systemd::unit_file { 'smee.service':
    ensure    => 'present',
    active    => true,
    content   => $service_unit,
    enable    => true,
    subscribe => Exec['install-smee'],
    require   => User['smee'],
  }
}
