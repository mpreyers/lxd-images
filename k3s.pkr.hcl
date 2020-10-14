source "lxd" "k3s" {
  image = "fedora/32/ansible"
  profile = "k3s"
  output_image = "fedora/32/k3s"

  publish_properties = {
    description = "Fedora based k3s"
  }
}

build {
  sources = ["source.lxd.k3s"]

  provisioner "file" {
    source = "ansible/hosts"
    destination = "/etc/ansible/hosts"
  }

  provisioner "file" {
    source = "ansible/playbooks"
    destination = "/tmp/packer-ansible"
  }

  provisioner "ansible-local" {
    playbook_file = "ansible/k3s.include.yml"
    staging_directory = "/tmp/packer-ansible"
  }

  provisioner "shell" {
    inline = [
      "rm -rf /etc/ansible/hosts /etc/dnf/protected.d /tmp/packer-ansible",
      "dnf -y erase ansible findutils geolite2-city gettext glibc-all-langpack openssh vim-minimal",
      "microdnf -y remove dnf dnf-data python3 python3-dnf python3-gpg python3-hawkey python3-libcomps python3-libdnf python3-rpm python3-setuptools yum python-setuptools-wheel python-pip-wheel python3-libs systemd-udev",
      "rm -rf /var/cache/dnf/*"
    ]
  }
}
