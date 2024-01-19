# create application load balancer 
resource "aws_lb" "alb" {
  name               = "project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.alb_subnets[*]


  tags = {
    Name = "${var.project_name}_alb"
  }
}

# generate target group
resource "aws_lb_target_group" "alb_target_group" {
  name     = "project-target-group"
  port     = 80
  target_type = "instance"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 60
    matcher             = 200
    interval            = 300
    path                = "/"
  }

  tags = {
    Name = "${var.project_name}_target_group"
  }
}

# make target group attachement 
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count = length(var.public_subnets_cidr)
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = var.ec2_ids[count.index]
}

# create listener on port 80 with a forward action 
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# use data to retrieve route53 details
data "aws_route53_zone" "my_host_zone" {
  name         = var.domain_name
  private_zone = false
}

# create route53 record
resource "aws_route53_record" "my_subdomain_1" {
  zone_id = data.aws_route53_zone.my_host_zone.zone_id
  name    = var.subdomain_name_1
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}





