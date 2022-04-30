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
resource "aws_instance" "aws-private-ec2" {
  count         = length(var.priv_app_subnets_cidr)
  ami           = data.aws_ami.amazon_linux_private.id
  instance_type = "t2.micro"
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.aws-private-subnet[count.index].id

  vpc_security_group_ids = [
    aws_security_group.aws-private-sg.id
  ]

  tags = {
    Name = "${var.application_name}-private-ec2-${count.index + 1}"
    Env  = var.application_env
  }
}

# Private Security Group
resource "aws_security_group" "aws-private-sg" {
  description = "Access for inbound"
  name        = "aws-private-sg"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    protocol = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-private-sg"
  }
}
