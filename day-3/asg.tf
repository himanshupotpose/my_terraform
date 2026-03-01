provider "aws" {
    region = "ap-south-1"
}

resource "aws_launch_template" "home_launch_template"{
    image_id = var.image_id
    instance_type = var.instance_type
    # launch_template_name = "${var.project}-home-lt"
    name = "${var.project}-${var.env}-home-lt"
    key_name = var.key_name
    tags = {
        env = var.env
    }
    vpc_security_group_ids = [aws_security_group.security_group.id]
    user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl enable apache2
    systemctl start apache2
    echo "<h1> HELLO WORLD </h1>" > /var/www/html/index.html
    EOF
    )
}



resource "aws_launch_template" "laptop_launch_template"{
    image_id = var.image_id
    instance_type = var.instance_type
    name = "${var.project}-${var.env}-laptop-lt"
    key_name = var.key_name
    tags = {
        env = var.env
    }
    vpc_security_group_ids = [aws_security_group.security_group.id]
    user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl enable apache2
    systemctl start apache2
    mkdir /var/www/html/laptop
    echo "<h1> SALE SALE SALE in Laptop </h1>" > /var/www/html/laptop/index.html
    EOF
    )
}

resource "aws_launch_template" "mobile_launch_template"{
    image_id = var.image_id
    instance_type = var.instance_type
    name = "${var.project}-${var.env}-mobile-lt"
    key_name = var.key_name
    tags = {
        env = var.env
    }
    vpc_security_group_ids = [aws_security_group.security_group.id]
    user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl enable apache2
    systemctl start apache2 
    mkdir /var/www/html/mobile
    echo "<h1> This is mobile page </h1>" > /var/www/html/mobile/index.html
    EOF
    )
}

resource "aws_autoscaling_group" "home_asg" {
    name = "${var.project}-${var.env}-home-asg"
    availability_zones = ["ap-south-1a", "ap-south-1b"]
    desired_capacity = 1
    max_size = 2
    min_size = 1
    
    launch_template {
      id = aws_launch_template.home_launch_template.id
      version = "$Latest"         
    }
}

resource "aws_autoscaling_policy" "home_asg_policy" {
    name                 = "${var.project}-${var.env}-home-asg-policy"
    autoscaling_group_name = aws_autoscaling_group.home_asg.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 60
    }
}


resource "aws_autoscaling_group" "mobile_asg" {
    name = "${var.project}-${var.env}-mobile-asg"
    availability_zones = ["ap-south-1a", "ap-south-1b"]
    desired_capacity = 1
    max_size = 2
    min_size = 1
    launch_template {
      id = aws_launch_template.mobile_launch_template.id
      version = "$Latest"
    }

}

resource "aws_autoscaling_policy" "mobile_asg_policy" {
  name                   = "${var.project}-${var.env}-mobile-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.mobile_asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

resource "aws_autoscaling_group" "laptop_asg" {
    name = "${var.project}-${var.env}-laptop-asg"
    availability_zones = ["ap-south-1a", "ap-south-1b"]
    desired_capacity = 1
    max_size = 2
    min_size = 1
    launch_template {
      id = aws_launch_template.laptop_launch_template.id
      version = "$Latest"
    }

}
    
resource "aws_autoscaling_policy" "laptop_asg_policy" {
  name                   = "${var.project}-${var.env}-laptop-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.laptop_asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

resource "aws_autoscaling_attachment" "home_tg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.home_asg.name
    lb_target_group_arn = aws_lb_target_group.home_target_group.arn
}

resource "aws_autoscaling_attachment" "laptop_tg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.laptop_asg.name
    lb_target_group_arn = aws_lb_target_group.laptop_target_group.arn
    depends_on = [
        aws_autoscaling_attachment.home_tg_attachment
    ]
}

resource "aws_autoscaling_attachment" "mobile_tg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.mobile_asg.name
    lb_target_group_arn = aws_lb_target_group.mobile_target_group.arn
    depends_on = [
        aws_autoscaling_attachment.laptop_tg_attachment
    ]
}
  
