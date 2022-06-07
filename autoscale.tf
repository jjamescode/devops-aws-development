#Launch Configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name_prefix     = "custom-launch-config"
  image_id        = data.aws_ami.amazon_linux_private.id
  instance_type   = "t2.micro"
  key_name        = var.bastion_key_name
  security_groups = [aws_security_group.aws-private-sg.id]
  user_data       = file("script.sh")
}

#Autoscaling Group
resource "aws_autoscaling_group" "custom-group-autoscaling" {
  name = "custom-group-autoscaling"
  launch_configuration      = aws_launch_configuration.custom-launch-config.name
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 100
  target_group_arns            = ["${aws_lb_target_group.app1.arn}"]
  force_delete              = true

vpc_zone_identifier   = [aws_subnet.aws-public-subnet[0].id, 
                        aws_subnet.aws-public-subnet[1].id,]

  tag {
    key                 = "Name"
    value               = "${var.application_name}-this"
    propagate_at_launch = true
  }
}
