# For Application Load Balancer

resource "aws_security_group" "tf_alb_sg" {
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_private_subnet
  }
}

# Security group for Webserver i.e private instances
resource "aws_security_group" "tf_webserver_sg" {
  vpc_id = aws_vpc.tf_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_public_subnet
  }
}