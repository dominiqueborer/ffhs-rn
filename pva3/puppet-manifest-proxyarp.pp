

Network_config {
  ensure      => 'present',
  family      => 'inet',
}


network_config { 'eth0':
  method  => 'dhcp',
  onboot  => 'true',
}

# enable some basic security
sysctl::value { "net.ipv4.conf.all.rp_filter": value => "1"}

# log when rp_filter blocks packages
sysctl::value { "net.ipv4.conf.all.log_martians": value => "1"}

file { '/etc/network/interfaces.d/eth0':
  ensure => 'absent',
}
file { '/etc/network/interfaces.d/eth1':
  ensure => 'absent',
}

node "r1" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.0.1',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  network_config { 'eth2':
    ipaddress => '192.168.100.1',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  sysctl::value { "net.ipv4.ip_forward": value => "1"}
}

node "r2" {
  # eth0 = private network mit floating ip

  sysctl::value { "net.ipv4.ip_forward": value => "1"}
  sysctl::value { "net.ipv4.conf.eth1.proxy_arp": value => "1"}
  sysctl::value { "net.ipv4.conf.eth2.proxy_arp": value => "1"}

  network_config { 'eth1':
    ipaddress => '192.168.100.2',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.0.0/24 via 192.168.100.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.0.0/24 via 192.168.100.1 dev eth1',
      ],
    },
  }
  network_config { 'eth2':
    ipaddress => '192.168.100.2',
    method    => 'static',
    netmask   => '255.255.255.255',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.100.33/32 dev eth2',
      ],
      'pre-down' => [
        'ip route del 192.168.100.33/32 dev eth2',
      ],
    },
  }
}

node "c1" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.0.11',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.100.0/24 via 192.168.0.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.100.0/24 via 192.168.0.1 dev eth1',
      ],
    },
  }
}

node "c2" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.100.22',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.0.0/24 via 192.168.100.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.0.0/24 via 192.168.100.1 dev eth1',
      ],
    },
  }
}

node "c3" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.100.33',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.0.0/24 via 192.168.100.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.0.0/24 via 192.168.100.1 dev eth1',
      ],
    },
  }
}
