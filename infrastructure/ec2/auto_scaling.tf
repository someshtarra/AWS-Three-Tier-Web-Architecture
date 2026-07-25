# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Auto Scaling Group (ASG) & Launch Templates
# ==============================================================================

resource "aws_launch_template" "web_template" {
  name_prefix   = "banking-web-template-"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"

  user_data = filebase64("${path.module}/../scripts/user_data_web.sh")

  iam_instance_profile {
    name = var.ec2_ssm_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "banking-web-node"
      Environment = "production"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "banking-web-asg"
  vpc_zone_identifier = [var.private_web_2a_id, var.private_web_2b_id]
  target_group_arns   = [var.web_target_group_arn]

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }
}
