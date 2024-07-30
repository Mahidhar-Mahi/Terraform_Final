# EC2 Instance

resource "aws_launch_configuration" "tf_lc" {
  image_id = "ami-0ff4c8fb495a5a50d"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.tf_webserver_sg.id]
  user_data = <<-EOF
            #!/bin/bash
            echo "Hello " > index.html
            hostname >> index.html
            nohup busybox httpd -f  &
            EOF
  lifecycle {
    create_before_destroy = true
  }
}



# Auto Scaling

resource "aws_autoscaling_group" "tf_webserver_asg" {
  launch_configuration = aws_launch_configuration.tf_lc.id
  min_size             = 2
  max_size             = 3
  vpc_zone_identifier  = tolist(aws_subnet.Mahidhar_private_subnets.*.id)
  target_group_arns    = [aws_alb_target_group.tf_alb_tg.arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Techtest"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Candidate"
    value               = var.candidate
    propagate_at_launch = true
  }
}