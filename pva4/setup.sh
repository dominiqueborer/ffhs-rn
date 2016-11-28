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

for net in ffhs_net_a ffhs_net_b ffhs_net_c ffhs_net_d; do
  openstack network create --disable-port-security "$net" &
done

wait

openstack port create --network ffhs_net_a ffhs_net_a_port1 &
openstack port create --network ffhs_net_a ffhs_net_a_port2 &
openstack port create --network ffhs_net_a ffhs_net_a_port3 &
openstack port create --network ffhs_net_b ffhs_net_b_port1 &
openstack port create --network ffhs_net_b ffhs_net_b_port2 &
openstack port create --network ffhs_net_b ffhs_net_b_port3 &
openstack port create --network ffhs_net_c ffhs_net_c_port1 &
openstack port create --network ffhs_net_d ffhs_net_d_port1 &

network_id_private=$(get_network_id private)

for name in r1 r2 a c d; do
  openstack server create \
    --flavor c1.micro \
    --image "Debian Jessie 8.1 (SWITCHengines)" \
    --key-name=switchy \
    --nic net-id=$network_id_private \
    --user-data userdata.txt \
    --wait $name & 
done

wait

# Dumm warten damit der initialisierungsprozess fertig wird
# besser wäre ein Login und prüfen ob  /var/lib/cloud/instance/boot-finished existiert.
# ansonsten wird jedes verfügbare interface automatisch mit DHCP konfiguriert.
#
sleep 60

#r1_id=$(get_server_id r1)
#r2_id=$(get_server_id r2)
#a_id=$(get_server_id a)
#c_id=$(get_server_id c)
#d_id=$(get_server_id d)

# Funktioniert nicht, Switch Support weiss auch nicht weiter
#openstack port set --device $r1_id --device-owner compute:None --vnic-type normal $(get_port_id ffhs_net_a_port1)
#openstack port set --device $r1_id --device-owner compute:None --vnic-type normal $(get_port_id ffhs_net_b_port1)
#openstack port set --device $r2_id --device-owner compute:None --vnic-type normal $(get_port_id ffhs_net_b_port2)
#openstack port set --device $r2_id --device-owner compute:None --vnic-type normal $(get_port_id ffhs_net_c_port1)
#openstack port set --device $r2_id --device-owner compute:None --vnic-type normal $(get_port_id ffhs_net_d_port1)

# Darum halt per nova
nova remove-secgroup r1 default
nova add-secgroup r1 ssh
nova remove-secgroup r2 default
nova add-secgroup r2 ssh
nova remove-secgroup a default
nova add-secgroup a ssh
nova remove-secgroup c default
nova add-secgroup c ssh
nova remove-secgroup d default
nova add-secgroup d ssh

nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port1) r1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port2) c
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_a_port3) d
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port1) r1
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port2) r2
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_b_port3) a
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_c_port1) r2
nova interface-attach --port-id $(neutron port-show -F id -f value ffhs_net_d_port1) r2

openstack server add floating ip r1 $(get_floating_ip)
openstack server add floating ip r2 $(get_floating_ip)
openstack server add floating ip a $(get_floating_ip)
openstack server add floating ip c $(get_floating_ip)
openstack server add floating ip d $(get_floating_ip)







