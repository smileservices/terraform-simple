terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}
variable "pub_key" {}


provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "x1g9" {
  name = "x1g9"
}

resource "digitalocean_droplet" "very-small" {
  count              = 1
  name               = "very-small-${count.index}"
  region             = "sgp1" // Change to your desired region
  size               = "s-1vcpu-512mb-10gb" // Smallest instance size
  image              = "ubuntu-22-04-x64" // Image to use for the VM
  ssh_keys           = [data.digitalocean_ssh_key.x1g9.id] // Add SSH keys if necessary

  tags = ["testing"] // Optional tags for organization

 connection {
   type        = "ssh"
   user        = "root"
   private_key = file(var.pvt_key) // Path to your private SSH key
   host        = self.ipv4_address
 }

  provisioner "remote-exec" {
    # to make sure the droplet is available
    inline = ["sudo apt update", "echo Droplet Ready!"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.pvt_key) // Path to your private SSH key
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' ansible/setup_app.yaml"
  }

}

output "ip_addresses" {
  value = digitalocean_droplet.very-small[*].ipv4_address
}
