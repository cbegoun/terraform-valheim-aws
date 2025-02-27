resource "aws_instance" "valheim" {
  ami                         = "ami-0d5856887e273397a"
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.valheim.key_name
  vpc_security_group_ids      = [aws_security_group.valheim_sg.id, aws_security_group.rdp.id]
  subnet_id                   = aws_subnet.valheim.id
  associate_public_ip_address = true

  user_data = <<EOF
<powershell>
$serverName = "${var.server_name}"
$worldName = "${var.world_name}"
$serverPassword = "${var.server_password}"

Invoke-WebRequest -Uri "https://github.com/cbegoun/terraform-valheim-aws/blob/main/powershell/setup_valheim_server.ps1" -OutFile "C:\setup_valheim_server.ps1"
Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File C:\setup_valheim_server.ps1" -Wait
</powershell>
EOF

  tags = {
    Name = "ValheimServer"
  }
}