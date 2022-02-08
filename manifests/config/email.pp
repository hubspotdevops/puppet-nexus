# @summary Manage the nexus repository manager email settings
#
# @param enabled
#   Enable to let nexus repository manager send emails.
# @param host
#   The smtp host to connect to.
# @param port
#   The port to connect to send emails.
# @param username
#   The username to connect to the smtp server.
# @param password
#   The password to connect to the smtp server.
# @param from_address
#   The email address used to set as From-Header.
# @param subject_prefix
#   Prefix which will be added to all emails.
# @param start_tls_enabled
#  Enable STARTTLS support for insecure connections.
# @param start_tls_required
#   Require STARTTLS support.
# @param ssl_on_connect_enabled
#   Enable SSL/TLS encryption upon connection.
# @param ssl_server_identity_check_enabled
#   Enable server identity check.
# @param nexus_trust_store_enabled
#   Use certificates stored in the Nexus truststore to connect to external systems.
#
# @example
#   include nexus::config::email
#
class nexus::config::email (
  Boolean $enabled = false,
  Stdlib::Host $host = 'localhost',
  Stdlib::Port $port = 25,
  String $username = '',
  Optional[String] $password = undef,
  String[1] $from_address = 'nexus@example.org',
  String $subject_prefix = '',
  Boolean $start_tls_enabled = false,
  Boolean $start_tls_required = false,
  Boolean $ssl_on_connect_enabled = false,
  Boolean $ssl_server_identity_check_enabled = false,
  Boolean $nexus_trust_store_enabled = false,
) {
  nexus_setting { 'email':
    attributes => {
      'enabled'                       => $enabled,
      'host'                          => $host,
      'port'                          => $port,
      'username'                      => $username,
      'password'                      => $password,
      'fromAddress'                   => $from_address,
      'subjectPrefix'                 => $subject_prefix,
      'startTlsEnabled'               => $start_tls_enabled,
      'startTlsRequired'              => $start_tls_required,
      'sslOnConnectEnabled'           => $ssl_on_connect_enabled,
      'sslServerIdentityCheckEnabled' => $ssl_server_identity_check_enabled,
      'nexusTrustStoreEnabled'        => $nexus_trust_store_enabled,
    },
  }
}
