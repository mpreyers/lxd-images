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
      "rm -rf /etc/ansible/hosts /tmp/packer-ansible",
      "dnf -y erase ansible"
    ]
  }
}
