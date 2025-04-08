data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
    provider = aws
}

resource "aws_instance" "valheim" {
  ami               = data.aws_ami.windows_2022.id
  instance_type     = "t3.medium"
  key_name          = var.key_pair_name
  network_interface {
    network_interface_id = aws_network_interface.valheim_eni.id
    device_index         = 0
  }

    user_data = base64encode(templatefile("${path.module}/scripts/userdata.ps1.tftpl", {
        server_name = var.valheim_server_name,
        world_name  = var.valheim_world_name,
        server_pass = var.valheim_password
        }))
        
  tags = {
    Name = "valheim-server"
  }
}

resource "aws_eip_association" "valheim_eip_assoc" {
  instance_id   = aws_instance.valheim.id
  allocation_id = aws_eip.valheim_eip.id
}