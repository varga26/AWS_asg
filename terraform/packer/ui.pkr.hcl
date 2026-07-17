packer {
  required_version = ">= 1.8.0"
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for builder"
  default     = "t3.micro"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 25
}

source "amazon-ebs" "openwebui" {
  ami_name        = "openwebui-frontend-{{timestamp}}"
  ami_description = "OpenWebUI frontend for Ollama"
  instance_type   = var.instance_type
  region          = var.region

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
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
    Name        = "openwebui-frontend"
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
  name    = "openwebui-builder"
  sources = ["source.amazon-ebs.openwebui"]

  provisioner "shell" {
    inline = [
      "echo 'Updating system packages...'",
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "echo 'Creating 2GB swap file for Open WebUI runtime stability...'",
      "sudo fallocate -l 2G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Installing Open WebUI as a Python app...'",
      "sudo apt-get install -y python3 python3-venv python3-pip",
      "sudo useradd --system --home /var/lib/openwebui --shell /usr/sbin/nologin openwebui",
      "sudo mkdir -p /opt/openwebui /var/lib/openwebui",
      "sudo python3 -m venv /opt/openwebui/venv",
      "sudo /opt/openwebui/venv/bin/python -m pip install --upgrade pip",
      "sudo /opt/openwebui/venv/bin/pip install open-webui",
      "sudo chown -R openwebui:openwebui /var/lib/openwebui",
      "sudo /opt/openwebui/venv/bin/python -c \"import importlib.metadata; print('Open WebUI version:', importlib.metadata.version('open-webui'))\""
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Creating OpenWebUI systemd service...'",
      "cat <<'EOF' | sudo tee /etc/systemd/system/openwebui.service",
      "[Unit]",
      "Description=Open WebUI",
      "After=network-online.target",
      "Wants=network-online.target",
      "",
      "[Service]",
      "Type=simple",
      "Restart=always",
      "RestartSec=5",
      "User=openwebui",
      "Group=openwebui",
      "WorkingDirectory=/var/lib/openwebui",
      "EnvironmentFile=-/etc/openwebui.env",
      "Environment=DATA_DIR=/var/lib/openwebui",
      "NoNewPrivileges=true",
      "ExecStart=/opt/openwebui/venv/bin/open-webui serve --host 0.0.0.0 --port 8080",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      "sudo touch /etc/openwebui.env",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable openwebui.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Cleaning up...'",
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "echo 'Installing CloudWatch Agent...'",
      "wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i -E ./amazon-cloudwatch-agent.deb",
      "sudo systemctl enable amazon-cloudwatch-agent",
      "rm ./amazon-cloudwatch-agent.deb",

      "unset HISTFILE",
      "echo 'OpenWebUI image ready!'"
    ]
  }

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}
