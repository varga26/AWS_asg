packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "grafana_alloy" {
  ami_name        = "grafana-alloy-{{timestamp}}"
  ami_description = "Grafana Dashboard and Grafana Alloy telemetry collector"
  instance_type   = "t3.small"
  region          = "us-east-1"
  
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 15
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

  tags = {
    Name        = "grafana-alloy"
    Version     = "1.0"
    BuildDate   = timestamp()
    Environment = "production"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

build {
  name    = "grafana-alloy-builder"
  sources = ["source.amazon-ebs.grafana_alloy"]

  provisioner "shell" {
    inline = [
      "echo 'Updating system...'",
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https software-properties-common wget gpg",
      
      "echo 'Adding Grafana repository...'",
      "sudo mkdir -p /etc/apt/keyrings/",
      "wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null",
      "echo \"deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main\" | sudo tee -a /etc/apt/sources.list.d/grafana.list",
      
      "echo 'Installing Grafana, Prometheus, and Grafana Alloy...'",
      "sudo apt-get update -y",
      "sudo apt-get install -y grafana alloy prometheus",
      
      "echo 'Configuring Prometheus for remote write...'",
      "echo 'ARGS=\"--web.enable-remote-write-receiver\"' | sudo tee /etc/default/prometheus",
      
      "echo 'Enabling services to start on boot...'",
      "sudo systemctl enable grafana-server",
      "sudo systemctl enable alloy",
      "sudo systemctl enable prometheus",
      
      "echo 'Cleaning up...'",
      "sudo apt-get clean",
      "unset HISTFILE"
    ]
  }

  post-processor "manifest" {
    output     = "packer-manifest-grafana.json"
    strip_path = true
  }
}
