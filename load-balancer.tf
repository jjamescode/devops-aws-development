#Create AWS ALB 
resource "aws_lb" "app1" {
  name               = "${var.application_name}-lb-app1"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.aws-public-subnet[0].id,
    aws_subnet.aws-public-subnet[1].id
  ]

  security_groups = [aws_security_group.lb-sg.id]

  tags = {
    Name = "${var.application_env}-lb"
  }

}

# App1 Target Group = TG Index = 0  
resource "aws_lb_target_group" "app1" {
  name     = "${var.application_name}-lb-target-group"
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws-vpc.id
  #target_type = "ip"
  port = 80

  health_check {
    path     = "/"
    port     = 80
    protocol = "HTTP"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

#Listeners
resource "aws_lb_listener" "app1" {
  load_balancer_arn = aws_lb.app1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1.arn
  }
}

#ALB Security Group
resource "aws_security_group" "lb-sg" {
  name        = "${var.application_name}-lb-sg"
  description = "Allow access to ALB"
  vpc_id      = aws_vpc.aws-vpc.id

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


  tags = {
    Name = "${var.application_env}-lg-sq"
  }

}

