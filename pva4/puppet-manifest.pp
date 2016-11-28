

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
    ipaddress => '192.168.1.1',
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

  network_config { 'eth3':
    ipaddress => '192.168.101.1',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  sysctl::value { "net.ipv4.ip_forward": value => "1"}
}

node "r2" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.2.1',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  network_config { 'eth2':
    ipaddress => '192.168.100.2',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  network_config { 'eth3':
    ipaddress => '192.168.101.2',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  sysctl::value { "net.ipv4.ip_forward": value => "1"}
}

node "r3" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.3.1',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  network_config { 'eth2':
    ipaddress => '192.168.100.3',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  network_config { 'eth3':
    ipaddress => '192.168.101.3',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  sysctl::value { "net.ipv4.ip_forward": value => "1"}
}

node "a" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.1.2',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.2.0/24 via 192.168.0.1 dev eth1',
		'ip route add 192.168.3.0/24 via 192.168.0.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.2.0/24 via 192.168.0.1 dev eth1',
		'ip route del 192.168.3.0/24 via 192.168.0.1 dev eth1',
      ],
    },
  }
}

node "b" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.2.2',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.1.0/24 via 192.168.0.1 dev eth1',
		'ip route add 192.168.3.0/24 via 192.168.0.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.1.0/24 via 192.168.0.1 dev eth1',
		'ip route del 192.168.3.0/24 via 192.168.0.1 dev eth1',
      ],
    },
  }
}

node "c" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.3.2',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.2.0/24 via 192.168.0.1 dev eth1',
		'ip route add 192.168.1.0/24 via 192.168.0.1 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.2.0/24 via 192.168.0.1 dev eth1',
		'ip route del 192.168.1.0/24 via 192.168.0.1 dev eth1',
      ],
    },
  }
}
 
