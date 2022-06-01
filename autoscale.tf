#Launch Configuration
resource "aws_launch_configuration" "server1-autoscaling" {
  name_prefix     = "${local.prefix}-autoscale-config"
  image_id        = data.aws_ami.amazon_linux_private.id
  instance_type   = "t2.micro"
  key_name        = var.bastion_key_name
  security_groups = aws_security_group.aws-private-sg.id


  lifecycle {
    create_before_destroy = true
  }
}

#Autoscaling Group
resource "aws_autoscaling_group" "server1-autoscaling" {
  name                      = "server1-autoscaling"
  launch_configuration      = aws_launch_configuration.server1-autoscaling.name
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }


  lifecycle {
    create_before_destroy = true
  }
}

