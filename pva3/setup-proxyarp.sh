#!/bin/bash

set -e

cleanup() {
  exitcode=$?
  if [ "$exitcode" != "0" ]; then
    echo "ERROR: something went wrong" >&2
  fi

  exit $exitcode
}

trap cleanup EXIT

get_floating_ip() {
  openstack floating ip list -f json | jq -r '.[] | select(.Port == null) | ."Floating IP Address"' |  head -1
}

get_network_id() {
  openstack network list -c ID -c Name -f json | jq -r ".[] | select(.Name == \"$1\") | .ID"
}

get_port_id() {
  openstack port list -f json | jq -r ".[] | select(.Name == \"$1\") | .ID"
}

get_server_id() {
  openstack server list -f json | jq -r ".[] | select(.Name == \"$1\") | .ID"
}

for net in ffhs_net_a ffhs_net_b ffhs_net_c; do
  openstack network create --disable-port-security "$net" &
done

wait

openstack port create --network ffhs_net_a ffhs_net_a_port1 &
openstack port create --network ffhs_net_a ffhs_net_a_port2 &

openstack port create --network ffhs_net_b ffhs_net_b_port1 &
openstack port create --network ffhs_net_b ffhs_net_b_port2 &
openstack port create --network ffhs_net_b ffhs_net_b_port3 &

openstack port create --network ffhs_net_c ffhs_net_c_port1 &
openstack port create --network ffhs_net_c ffhs_net_c_port2 &

network_id_private=$(get_network_id private)

for name in r1 r2 c1 c2 c3; do
  openstack server create \
    --flavor c1.micro \
    --image "Debian Jessie 8.1 (SWITCHengines)" \
    --key-name=switchy \
    --nic net-id=$network_id_private \
    --user-data userdata-proxyarp.txt \
    --wait $name & 
done

wait

# Dumm warten damit der initialisierungsprozess fertig wird
# besser wäre ein Login und prüfen ob  /var/lib/cloud/instance/boot-finished existiert.
# ansonsten wird jedes verfügbare interface automatisch mit DHCP konfiguriert.
#
sleep 60

nova remove-secgroup r1 default
nova add-secgroup r1 ssh
nova remove-secgroup r2 default
nova add-secgroup r2 ssh
nova remove-secgroup c1 default
nova add-secgroup c1 ssh
nova remove-secgroup c2 default
nova add-secgroup c2 ssh
nova remove-secgroup c3 default
nova add-secgroup c3 ssh

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port1) c1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port2) r1

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port1) r1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port2) c2
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port3) r2

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_c_port1) r2
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_c_port2) c3

openstack server add floating ip r1 $(get_floating_ip)
openstack server add floating ip r2 $(get_floating_ip)
openstack server add floating ip c1 $(get_floating_ip)
openstack server add floating ip c2 $(get_floating_ip)
openstack server add floating ip c3 $(get_floating_ip)

