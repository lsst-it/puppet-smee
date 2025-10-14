# @summary
#   Manages the smee.io webhook proxy service client
#
# @param image
#   The OCI image to use for the service.

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
  String[1] $image,
  Stdlib::HTTPSUrl $url,
  String $path = '/',
  Integer $port = 3000,
) {
  $nobody = 65534

  quadlets::quadlet { 'smee.container':
    ensure          => present,
    active          => true,
    unit_entry      => {
      'Description' => 'smee.io webhook proxy client',
      'Requires'    => 'network-online.target',
      'After'       => 'network-online.target',
    },
    container_entry => {
      'Image'   => $image,
      'Exec'    => "--url '${url}' --path '${path}' --port '${port}'",
      'Network' => 'host',
      'User'    => $nobody,
      'Group'   => $nobody,
      'Tmpfs'   => ['/run'],
    },
    service_entry   => {
      'Restart' => 'always',
    },
    install_entry   => {
      'WantedBy' => 'default.target',
    },
  }
}
