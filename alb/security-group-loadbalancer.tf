#Security Group for Public Load Balancer
module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws/"

  name        = "${var.application_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.aws-vpc.id

  egress_rules = ["all-all"]
}

#Create AWS ALB
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"
  
#4 required variables here
name = "${var.application_name}-alb"

  load_balancer_type = "application"

  vpc_id             = aws_vpc.aws-vpc.id
  subnets            = aws_subnet.aws-public-subnet
  security_groups    = [module.alb_sg.aws-web-sg.id]

#Listeners
http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
]

#Target Groups
  target_groups = [
    # App1 Target Group = TG Index = 0  
    {
      name_prefix          = "app1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        #path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"

# App1 Target Group - Targets       
      targets = {
        my_ec2 = {
          count = length(var.priv_app_subnets_cidr)  
          target_id = aws_instance.aws-private-ec2[count.index].id
          port      = 80
        }
        #my_ec2_again = {
        #  target_id = aws_instance.this.id
        #  port      = 8080
        }
      }
      tags = {
        Env  = var.application_env
      }
    }











  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = "i-0123456789abcdefg"
          port = 80
        }
        my_other_target = {
          target_id = "i-a1b2c3d4e5f6g7h8i"
          port = 8080
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]


  tags = {
    Environment = "Test"
  }
}


