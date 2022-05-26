#Create AWS ALB
resource "aws_lb" "app1" {
  name               = "${var.application_name}-main"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.aws-public-subnet[0].id,
    aws_subnet.aws-public-subnet[1].id
  ]

  security_groups = [aws_security_group.lb.id]

  tags = local.common_tags

}

# App1 Target Group = TG Index = 0  
resource "aws_lb_target_group" "app1" {
  name        = "${var.application_name}-app1"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws-vpc.id
  target_type = "ip"
  port        = 8000

  health_check {
    path = "/app1/index.html"
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
resource "aws_security_group" "lb" {
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
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App1 Target Group - Targets Register Instance      
resource "aws_lb_target_group_attachment" "app1" {
  count            = length(var.priv_app_subnets_cidr)
  target_group_arn = aws_lb_target_group.app1.arn
  target_id        = aws_instance.aws-private-ec2[count.index].id
  port             = 80
}

#tags = merge(
#  local.common_tags,
#  map("Name", "${local.prefix"-lb")