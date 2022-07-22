# @summary
#   Manage smee.io webhook proxy service client
#
# @param url
#   URL to the smee topic to watch for webhook events.
#
# @param path
#   URL path to post proxied requests to.
#
# @param port
#   Local HTTP server port.
#
class smee (
  Stdlib::HTTPSUrl $url,
  String $path = '/',
  Integer $port = 3000,
) {
  $node_pkgs = [
    'rh-nodejs10',
    'rh-nodejs10-npm',
  ]

  ensure_packages($node_pkgs)

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
    creates   => '/opt/rh/rh-nodejs10/root/usr/bin/smee',
    command   => 'npm install --global smee-client',
    subscribe => Package[$node_pkgs],
    path      => [
      '/opt/rh/rh-nodejs10/root/usr/bin',
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
    ExecStart=/usr/bin/scl enable rh-nodejs10 -- \
      /opt/rh/rh-nodejs10/root/usr/bin/smee \
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
