

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

node "c" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.0.100',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  network_config { 'eth2':
    ipaddress => '172.20.30.100',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
  }

  sysctl::value { "net.ipv4.ip_forward": value => "1"}
}

node "b" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '172.20.30.44',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 192.168.0.0/24 via 172.20.30.100 dev eth1',
      ],
      'pre-down' => [
        'ip route del 192.168.0.0/24 via 172.20.30.100 dev eth1',
      ],
    },
  }
}

node "a" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.0.44',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 172.20.30.0/24 via 192.168.0.100 dev eth1',
      ],
      'pre-down' => [
        'ip route del 172.20.30.0/24 via 192.168.0.100 dev eth1',
      ],
    },
  }
}

node "d" {
  # eth0 = private network mit floating ip

  network_config { 'eth1':
    ipaddress => '192.168.0.44',
    method    => 'static',
    netmask   => '255.255.255.0',
    onboot    => 'true',
    options   => {
      'post-up' => [
        'ip route add 172.10.20.0/23 via 192.168.0.22 dev eth1',
      ],
      'pre-down' => [
        'ip route del 172.10.20.0/23 via 192.168.0.22 dev eth1',
      ],
    },
  }
}
 
