resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
}


# Setup public subnet
resource "aws_subnet" "Mahidhar_public_subnets" {
  count      = length(var.cidr_public_subnet)
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "Subnet-Public : Public Subnet ${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "Mahidhar_private_subnets" {
  count      = length(var.cidr_private_subnet)
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "Subnet-Private : Private Subnet ${count.index + 1}"
  }
}

# setting up ALB and listeners & target groups

resource "aws_alb_target_group" "tf_alb_tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_alb" "tf_alb" {
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.tf_alb_sg.id]
  subnets = var.cidr_public_subnet
  enable_deletion_protection = false
}

resource "aws_alb_listener" "tf_alb_lsnr" {
  load_balancer_arn = aws_alb.tf_alb.id
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.tf_alb_tg.id
    type = "forward"
  }
}


# Internet Gateway

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
}



# Route Table configuration

resource "aws_route_table" "incoming_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
}

resource "aws_route_table_association" "in_rta" {
  count = length(var.cidr_public_subnet)
  subnet_id      = element(aws_subnet.Mahidhar_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.incoming_rt.id
}

