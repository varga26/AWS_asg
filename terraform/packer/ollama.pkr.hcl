packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ollama" {
  ami_name        = "ollama-backend-{{timestamp}}"
  ami_description = "Ollama backend for Open WebUI"
  instance_type = "t3.micro"
  region        = "us-east-1"
  
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
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
    Name        = "ollama-backend"
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
  name    = "ollama-builder"
  sources = ["source.amazon-ebs.ollama"]

  provisioner "shell" {
    inline = [
      "echo 'Creating 4GB Swap file to prevent Out of Memory errors...'",
      "sudo fallocate -l 4G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab",

      "sudo apt-get update -y",
      "sudo apt-get install -y curl",

      "curl -fsSL https://ollama.com/install.sh | sh",

      "sudo mkdir -p /etc/systemd/system/ollama.service.d",
      "echo '[Service]' | sudo tee /etc/systemd/system/ollama.service.d/override.conf",
      "echo 'Environment=\"OLLAMA_HOST=0.0.0.0\"' | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf",

      "sudo systemctl daemon-reload",
      "sudo systemctl restart ollama",
      "sleep 10",

      "echo 'Downloading Qwen 2.5 0.5B model into image...'",
      "ollama pull qwen2.5:0.5b",

      "echo 'Adding Grafana repository...'",
      "sudo apt-get install -y apt-transport-https software-properties-common wget gpg",
      "sudo mkdir -p /etc/apt/keyrings/",
      "wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null",
      "echo \"deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main\" | sudo tee -a /etc/apt/sources.list.d/grafana.list",
      
      "echo 'Installing Grafana Alloy...'",
      "sudo apt-get update -y",
      "sudo apt-get install -y alloy",
      "sudo systemctl enable alloy",
      "echo 'Installing CloudWatch Agent...'",
      "wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i -E ./amazon-cloudwatch-agent.deb",
      "sudo systemctl enable amazon-cloudwatch-agent",
      "rm ./amazon-cloudwatch-agent.deb",

      "sudo apt-get clean",
      "unset HISTFILE"
    ]
  }

  post-processor "manifest" {
    output     = "packer-manifest-ollama.json"
    strip_path = true
  }
}
