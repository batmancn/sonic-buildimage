#!/bin/bash

run_cmd () {
    echo "$1"
    eval $1
}

cfg_load_common() {
    run_cmd "cat $1"
    run_cmd "config load -y $1"
}

check_common() {
    sleep 5
    run_cmd "tail -10 /var/log/syslog | grep ERR"
    run_cmd "tail -10 /var/log/syslog | grep bgp"
    run_cmd "docker exec bgp bash -c \"sonic-cfggen -d -y /etc/sonic/deployment_id_asn_map.yml -t /usr/share/sonic/templates/bgpd.conf.j2\""
}

test_bgp_redistribute_static() {
    echo "test_bgp_redistribute_static"
    cfg_load_common "bgp_redistribute_static.add.json"
    check_common
    cfg_load_common "bgp_redistribute_static.del.json"
    check_common
}

test_bgp_policy_prefixlist() {
    echo "test_bgp_policy_prefixlist"
    cfg_load_common "bgp_policy_prefixlist.add.json"
    check_common
    cfg_load_common "bgp_policy_prefixlist.del.json"
    check_common
}

test_bgp_policy_routemap() {
    echo "test_bgp_policy_routemap"
    cfg_load_common "bgp_policy_routemap.add.json"
    check_common
    cfg_load_common "bgp_policy_routemap.del.json"
    check_common
}

test_bgp_peer_range() {
    echo "test_bgp_peer_range"
    cfg_load_common "bgp_peer_range.add.json"
    check_common
    cfg_load_common "bgp_peer_range.del.json"
    check_common
}

test_bgp_peer_group() {
    echo "test_bgp_peer_group"
    cfg_load_common "bgp_peer_group.add.json"
    check_common
    cfg_load_common "bgp_peer_group.del.json"
    check_common
}

test_bgp_neighbor_remote() {
    echo "test_bgp_neighbor_remote"
    cfg_load_common "bgp_neighbor_remote.add.json"
    check_common
    cfg_load_common "bgp_neighbor_remote.del.json"
    check_common
}

test_bgp_neighbor_policy() {
    echo "test_bgp_neighbor_policy"
    cfg_load_common "bgp_neighbor_policy.add.json"
    check_common
    cfg_load_common "bgp_neighbor_policy.del.json"
    check_common
}

test_bgp_neighbor() {
    echo "test_bgp_neighbor"
    cfg_load_common "bgp_neighbor.add.json"
    check_common
    cfg_load_common "bgp_neighbor.del.json"
    check_common
}

test_aspath_list() {
    echo "test_aspath_list"
    cfg_load_common "bgp_policy_aspathlist.add.json"
    check_common
    cfg_load_common "bgp_policy_aspathlist.del.json"
    check_common
}

test_community_list() {
    echo "test_community_list"
    cfg_load_common "bgp_policy_communitylist.add.json"
    check_common
    cfg_load_common "bgp_policy_communitylist.del.json"
    check_common
}

test_vlan_loopback_interface() {
    echo "test_vlan_loopback_interface"
    cfg_load_common "bgp_vlan_loopback_interface.add.json"
    check_common
    cfg_load_common "bgp_vlan_loopback_interface.del.json"
    check_common
}

test_static_ip() {
    echo "test_static_ip"
    # add static ip
    cfg_load_common "bgp_static_route.add.json"
    # check in route stack
    check_common
    run_cmd "docker exec bgp bash -c \"sonic-cfggen -d -t /usr/share/sonic/templates/zebra.conf.j2\""
    # update static ip
    cfg_load_common "bgp_static_route.update.json"
    # check in route stack
    check_common
    run_cmd "docker exec bgp bash -c \"sonic-cfggen -d -t /usr/share/sonic/templates/zebra.conf.j2\""
    # del static ip
    cfg_load_common "bgp_static_route.del.json"
    # check
    check_common
    run_cmd "docker exec bgp bash -c \"sonic-cfggen -d -t /usr/share/sonic/templates/zebra.conf.j2\""
}

test_bgp_accesslist() {
    echo "test_bgp_accesslist"
    cfg_load_common "bgp_accesslist.add.json"
    check_common
    cfg_load_common "bgp_accesslist.update.json"
    check_common
    cfg_load_common "bgp_accesslist.del.json"
    check_common
}

test_misc() {
    # test gr, maximum path, router id
    echo "test_misc"
    cfg_load_common "bgp_gracefullrestart.add.json"
    cfg_load_common "bgp_maximunpath.add.json"
    cfg_load_common "bgp_routerid.add.json"
    check_common
    cfg_load_common "bgp_gracefullrestart.del.json"
    cfg_load_common "bgp_maximunpath.del.json"
    cfg_load_common "bgp_routerid.del.json"
}

test_bgp_asn() {
    echo "test_bgp_asn"
    cfg_load_common "bgp_asn.set.json"
    check_common
}

# tee ./log/copp_`date "+%Y-%m-%d_%H_%M_%S" `.log
test_bgp_asn # pass
test_static_ip # pass
test_bgp_policy_routemap # pass
test_vlan_loopback_interface # pass, j2 file only export loopback0 interface
test_community_list # pass
test_aspath_list # pass
test_bgp_neighbor # pass
test_bgp_neighbor_policy # pass
test_bgp_neighbor_remote # pass
test_bgp_peer_group # pass
test_bgp_peer_range # pass, but have space line, working
test_bgp_policy_prefixlist # pass
test_bgp_redistribute_static # pass
test_bgp_accesslist # pass
test_misc # pass