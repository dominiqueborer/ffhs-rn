openstack server list -f value -c ID | xargs -n1 nova delete 
for i in $(neutron port-list -F name -f value | grep Net); do neutron port-delete $i; done
for i in $(neutron subnet-list -F name -f value | grep Net); do neutron subnet-delete $i; done
for i in $(neutron net-list -F name -f value | grep Net); do neutron net-delete $i; done
for i in $(openstack port list -f value -c ID | xargs -n1); do openstack port delete $i; done
for i in $(openstack network list -f value -c ID | xargs -n1); do openstack network delete $i; done
