resource "aws_instance" "valheim" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.valheim_key.key_name
  vpc_security_group_ids = [aws_security_group.valheim_sg.id]
  subnet_id              = aws_subnet.valheim.id

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -aG docker ec2-user
              sudo docker run -d --name valheim-server -p 2456-2458:2456-2458/udp lloesche/valheim-server
              EOF

  tags = {
    Name = "ValheimServer"
  }
}