# @summary
#   Manage smee.io webhook daemon
#
# @param url
#   URL to the smee topic to watch for webhook events.
#
class smee (
  Stdlib::HTTPSUrl $url,
) {
  $node_pkgs = [
    'rh-nodejs10',
    'rh-nodejs10-npm',
  ]

  ensure_packages($node_pkgs)

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
    ExecStart=/usr/bin/scl enable rh-nodejs10 -- \
      /opt/rh/rh-nodejs10/root/usr/bin/smee \
      --url ${url} \
      -P /payload \
      -p 8088
    Restart=on-failure
    RestartSec=10

    [Install]
    WantedBy=default.target
    | EOT

  systemd::unit_file { 'smee.service':
    ensure    => 'present',
    active    => true,
    content   => $service_unit,
    enable    => true,
    subscribe => Exec['install-smee'],
  }
}
