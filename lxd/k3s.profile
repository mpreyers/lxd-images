name: k3s
config:
  boot.autostart: "false"
  linux.kernel_modules: ip_vs,ip_vs_rr,ip_vs_wrr,ip_vs_sh,ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter,xt_conntrack
  raw.lxc: |
    lxc.init.cmd=/sbin/init systemd.unified_cgroup_hierarchy=0
    lxc.mount.auto=proc:rw sys:rw cgroup:rw
    lxc.cgroup.devices.allow=
    lxc.cgroup.devices.deny=
    lxc.cap.drop=
  security.nesting: "true"
  security.privileged: "true"
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
  btrfspooldev:
    type: unix-block
    source: /dev/root
    path: /dev/root
