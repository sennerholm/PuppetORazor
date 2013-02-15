node default {

}

node puppet {
  class { 'sudo':
    config_file_replace => false,
  }
  include razor

#Include a DNS + DHCP server

 dnsmasq::conf { 'another-config':
   ensure => present,
   content =>
"dhcp-range=192.168.19.100,192.168.19.150,12h\ndhcp-boot=pxelinux.0\ndhcp-o
ption=3,192.168.19.2\ndhcp-option=6,192.168.19.5\ndomain=purevirtual.lab\ne
xpand-hosts\ndhcp-host=puppet,192.168.19.5\nserver=8.8.8.8\n",
 }

#Create a Puppet broker to automatically deploy services after OS
installation

 rz_broker { 'puppet_broker':
  ensure => present,
  plugin => 'puppet',
  metadata => {
    broker_version => '2.7.18',
    server => 'puppet.purevirtual.lab',
  }
 }

#Install Ubuntu 12.04.1

rz_image { "ubuntu_precise_image":
  ensure  => present,
  type    => 'os',
  version => '12.04.1',
  source  =>
"http://ftp.sunet.se/pub/os/Linux/distributions/ubuntu/ubuntu-cd/12.04.1/ub
untu-12.04.1-server-amd64.iso",
}

rz_model { 'install_ubuntu_precise':
  ensure => present,
  description => 'Ubuntu Precise',
  image => 'ubuntu_precise_image',
  metadata => {'domainname' => 'purevirtual.lab', 'hostname_prefix' =>
'ubuntu-', 'root_password' => 'password'},
  template => 'ubuntu_precise',
}

rz_policy { 'ubuntu_precise_policy':
  ensure  => present,
  broker  => 'puppet_broker',
  model   => 'install_ubuntu_precise',
  enabled => 'true',
  tags    => ['memsize_1GiB'],
  template => 'linux_deploy',
  maximum => 10,
}

#Install CentOS 6.3

rz_image { "centos_6_3_image":
  ensure  => present,
  type    => 'os',
  version => '6.3',
  source  =>
"http://ftp.sunet.se/pub/Linux/distributions/centos/6/isos/x86_64/CentOS-6.
3-x86_64-minimal.iso",
}

rz_model { 'install_centos_6_3':
  ensure => present,
  description => 'Centos_6.3',
  image => 'centos_6_3_image',
  metadata => {'domainname' => 'purevirtual.lab', 'hostname_prefix' =>
'centos-', 'root_password' => 'password'},
  template => 'centos_6',
}

rz_policy { 'centos_6_3_policy':
  ensure  => present,
  broker  => 'puppet_broker',
  model   => 'install_centos_6_3',
  enabled => 'true',
  tags    => ['memsize_2GiB'],
  template => 'linux_deploy',
  maximum => 10,
}

}

#Make sure all Ubuntu nodes have the webserver Lighttpd installed

node /ubuntu/ {
  include lighttpd
}

#Make sure all Ubuntu nodes have the webserver Lighttpd installed

node /centos/ {
  include wordpress
    firewall { '100 allow http':
    proto       => 'tcp',
    dport       => '80',
    action        => 'accept',
  }
}

