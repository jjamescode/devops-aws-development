#Launch Configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name_prefix     = "custom-launch-config"
  image_id        = data.aws_ami.amazon_linux_private.id
  instance_type   = "t2.micro"
  key_name        = var.bastion_key_name
  security_groups = [aws_security_group.aws-private-sg.id]
  user_data       = file("script.sh")

  lifecycle {
    create_before_destroy = true
  }
}

#Autoscaling Group
resource "aws_autoscaling_group" "custom-group-autoscaling" {
  availability_zones = ["us-east-1a"]
  name = "custom-group-autoscaling"
# We want this to explicitly depend on the launch config above
  depends_on = [aws_launch_configuration.custom-launch-config]
  launch_configuration      = aws_launch_configuration.custom-launch-config.name
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 100
  health_check_type         = "ELB"
  target_group_arns            = ["${aws_lb_target_group.app1.arn}"]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "custom_ec2_instance"
    propagate_at_launch = true
  }


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "custom-attachment-elb" {
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.id
  lb_target_group_arn = aws_lb_target_group.app1.arn
}



#autoscaling config policy
resource "aws_autoscaling_policy" "custom-policy" {
  name                   = "custom-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
  policy_type            = "SimpleScaling"
}

#CloudWatch monitoring
resource "aws_cloudwatch_metric_alarm" "custom-alarm" {
  alarm_name          = "custom-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.custom-group-autoscaling.name
  }

  actions_enabled   = true
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.custom-policy.arn]
}

#Autoscaling descaling policy
resource "aws_autoscaling_policy" "custom-policy-descale" {
  name                   = "custom-policy-descale"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
  policy_type            = "SimpleScaling"
}



#Descaling CloudWatch
resource "aws_cloudwatch_metric_alarm" "custom-alarm-descale" {
  alarm_name          = "custom-alarm-descale"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.custom-group-autoscaling.name
  }

  actions_enabled   = true
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.custom-policy-descale.arn]
}
