# retrieves data for image used to create server
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

# Creates Public Web server
resource "aws_instance" "aws-web-server" {

  count = length(var.pub_web_subnets_cidr)

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.aws-public-subnet[count.index].id

  vpc_security_group_ids = [
    aws_security_group.aws-web-sg.id
  ]

  tags = {
    Name = "${var.application_name}-${var.application_env}-web-server-${count.index + 1}"
    Env  = var.application_env
  }
  #Userdata stalls webserver on Public EC2
  user_data = file("script.sh")

  depends_on = [
    aws_nat_gateway.aws-web-nat-gateway
  ]
}

# Public Security Group
resource "aws_security_group" "aws-web-sg" {
  description = "Access for inbound/outbound"
  name        = "aws-web-sg"
  vpc_id      = aws_vpc.aws-vpc.id

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
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  /* ingress { 
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    #security_group_id = sgr-03f6c72a0990d1fad
    #security_group_id = sg-08a3f3b1deda230c2 / app1-lb-sg
  }
*/

  tags = {
    Name = "${var.application_name}-aws-web-sg"
  }
}
