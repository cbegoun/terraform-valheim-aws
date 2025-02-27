resource "aws_instance" "valheim" {
  ami                         = "ami-0d5856887e273397a" # Amazon Linux 2 AMI
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.valheim_key.key_name
  vpc_security_group_ids      = [aws_security_group.valheim_sg.id, aws_security_group.rdp.id]
  subnet_id                   = aws_subnet.valheim.id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/powershell/startup.ps1.tpl", {
    server_name     = var.server_name
    server_world    = var.world_name
    server_password = var.server_password
  })

  tags = {
    Name = "ValheimServer"
  }
}