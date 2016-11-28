#!/bin/bash


# net_a = "192.168.1.0"
# net_b = "192.168.100.0"
# net_c = "192.168.101.0"
# net_d = "192.168.102.0"
# net_e = "192.168.2.0"
# net_f = "192.168.3.0"


userdata_yaml=$(echo $(basename $0 .sh).yaml | sed 's/^setup/userdata/')

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

for net in ffhs_net_a ffhs_net_b ffhs_net_c ffhs_net_d ffhs_net_e ffhs_net_f; do
  openstack network create --disable-port-security "$net" &
done

wait

openstack port create --network ffhs_net_a ffhs_net_a_port1 &
openstack port create --network ffhs_net_a ffhs_net_a_port2 &


openstack port create --network ffhs_net_a ffhs_net_b_port1 &
openstack port create --network ffhs_net_a ffhs_net_b_port2 &

openstack port create --network ffhs_net_a ffhs_net_c_port1 &
openstack port create --network ffhs_net_a ffhs_net_c_port2 &

openstack port create --network ffhs_net_a ffhs_net_d_port1 &
openstack port create --network ffhs_net_a ffhs_net_d_port2 &

openstack port create --network ffhs_net_a ffhs_net_e_port1 &
openstack port create --network ffhs_net_a ffhs_net_e_port2 &

openstack port create --network ffhs_net_b ffhs_net_f_port1 &
openstack port create --network ffhs_net_b ffhs_net_f_port2 &

network_id_private=$(get_network_id private)

for name in ffhs-r1 ffhs-r2 ffhs-r3 ffhs-pc1 ffhs-pc2 ffhs-pc3 ; do
  openstack server create \
    --flavor c1.micro \
    --image "Debian Jessie 8 (SWITCHengines)" \
    --key-name="$KEYPAIR" \
    --nic net-id=$network_id_private \
    --user-data $userdata_yaml \
    --wait $name & 
done

wait

# Dumm warten damit der initialisierungsprozess fertig wird
# besser wäre ein Login und prüfen ob  /var/lib/cloud/instance/boot-finished existiert.
# ansonsten wird jedes verfügbare interface automatisch mit DHCP konfiguriert.
#
sleep 60

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port1) ffhs-pc1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port2) ffhs-r1

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port1) ffhs-r1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port2) ffhs-r2

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_c_port1) ffhs-r1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_c_port2) ffhs-r3

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_d_port1) ffhs-r2
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_d_port2) ffhs-r3

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_e_port1) ffhs-r2
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_e_port2) ffhs-pc2

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_f_port1) ffhs-r3
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_f_port2) ffhs-pc3

openstack server add floating ip ffhs-r1 $(get_floating_ip)
openstack server add floating ip ffhs-r2 $(get_floating_ip)
openstack server add floating ip ffhs-r3 $(get_floating_ip)