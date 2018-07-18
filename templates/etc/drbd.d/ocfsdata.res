# {{ ansible_managed }}

# Source : https://www.lisenet.com/2016/o2cb-cluster-with-dual-primary-drbd-and-ocfs2-on-oracle-linux-7/

resource ocfsdata {
 protocol C;
 meta-disk internal;
 device {{ disk['device'] }};
 disk {{ disk['use_partition'] }};
 handlers {
  split-brain "/usr/lib/drbd/notify-split-brain.sh root";
 }
 startup {
  wfc-timeout 20;
  become-primary-on both;
 }
 net {
  allow-two-primaries yes;
  after-sb-0pri discard-zero-changes;
  after-sb-1pri discard-secondary;
  after-sb-2pri disconnect;
  rr-conflict disconnect;
  csums-alg sha1;
 }
 disk {
  on-io-error detach;
  resync-rate 10M; # 100Mbps dedicated link
  # All cluster file systems require fencing
  fencing resource-and-stonith;
 }
 syncer {
  verify-alg sha1;
 }
 on ora1 {
  address  {{ hostvars[host]['ansible_' + drbd_interface]['ipv4']['address'] }}:7789;
 }
 on ora2 {
  address  {{ hostvars[host]['ansible_' + drbd_interface]['ipv4']['address'] }}:7789;
 }
}
