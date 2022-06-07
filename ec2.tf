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

  count = length(var.priv_app_subnets_cidr)

  ami           = data.aws_ami.amazon_linux_private.id
  instance_type = "t2.micro"
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.aws-private-subnet[count.index].id

  vpc_security_group_ids = [
    aws_security_group.aws-private-sg.id
  ]

  #Userdata stalls webserver on Public EC2
  user_data = file("script.sh")

  tags = {
    Name = "${var.application_name}-private-ec2-${count.index + 1}"
    Env  = var.application_env
  }

  depends_on = [
    aws_nat_gateway.aws-web-nat-gateway
  ]
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
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.application_env}-private-sg"
  }
}
