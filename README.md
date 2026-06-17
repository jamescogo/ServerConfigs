# ServerConfigs
Server Configuration Notes For RockyLinux 10

Setting Up Firewall settings for WireGuard
firewall-cmd --permanent --new-policy int_to_ext_fwd
firewall-cmd --permanent --policy int_to_ext_fwd --add-ingress-zone internal
firewall-cmd --permanent --policy int_to_ext_fwd --add-egress-zone external
firewall-cmd --permanent --policy int_to_ext_fwd --set-priority 100
firewall-cmd --permanent --policy int_to_ext_fwd --set-target ACCEPT

firewall-cmd --permanent --zone=external --add-masquerade
firewall-cmd --permanent --zone=internal --add-forward
systemctl restart firewalld.service

