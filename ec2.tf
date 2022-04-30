# retrieves data for image used to create server
data "aws_ami" "amazon_linux_private" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

# Creates Private server
resource "aws_instance" "task1_private_ec2" {
  count         = length(var.priv_app_subnets_cidr)
  ami           = data.aws_ami.amazon_linux_private.id
  instance_type = "t2.micro"
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.task1_private_app[count.index].id

  vpc_security_group_ids = [
    aws_security_group.task1_private_ec2_sg.id
  ]

  tags = {
    Name = "task1_private_ec2-${count.index + 1}"
  }
}

# Private Security Group
resource "aws_security_group" "task1_private_ec2_sg" {
  description = "Access for inbound"
  name        = "task1_private_ec2_sg"
  vpc_id      = aws_vpc.task1_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "task1_private_ec2_sg"
  }
}
