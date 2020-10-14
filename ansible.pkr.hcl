source "lxd" "ansible" {
  image = "images:fedora/32"
  profile = "default"
  output_image = "fedora/32/ansible"

  publish_properties = {
    description = "Fedora with Ansible"
  }
}

build {
  sources = ["source.lxd.ansible"]

  provisioner "shell" {
    inline = [
      "dnf -y install ansible microdnf",
      "mkdir /tmp/packer-ansible"
    ]
  }

  provisioner "file" {
    source = "ansible/hosts"
    destination = "/etc/ansible/hosts"
  }
}
