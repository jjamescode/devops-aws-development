# retrieves data for image used to create server
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

# Creates server
resource "aws_instance" "task1_public_bastion" {
  count         = length(var.pub_web_subnets_cidr)
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.task1_public_web[count.index].id

  vpc_security_group_ids = [
    aws_security_group.task1_bastion.id
  ]

  tags = {
    Name = "task1_bastion-${count.index + 1}"
  }
}

# Public Security Group
resource "aws_security_group" "task1_bastion" {
  description = "Access for inbound/outbound"
  name        = "task1_bastion_security_group"
  vpc_id      = aws_vpc.task1_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
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
    Name = "task1_bastion_security"
  }
}
