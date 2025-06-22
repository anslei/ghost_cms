provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu22" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
resource "aws_instance" "ghost" {
  ami           = data.aws_ami.ubuntu22.id
  instance_type = "t2.micro"              # Free Tier eligible
  key_name      = var.key_name            # SSH key (see next step)
  user_data     = file("../scripts/install_ghost.sh") # Shell script to run
  vpc_security_group_ids = [aws_security_group.ghost_sg.id] # to use the security group we have just created

  tags = {
    Name = "GhostCMS"
  }
}

resource "aws_security_group" "ghost_sg" {
  name_prefix = "ghost_sg_"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22      # Allow SSH login
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # From anywhere
  }

  ingress {
    from_port   = 2368     # Ghost CMS default port to avoid changing the config
    to_port     = 2368 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"    # All traffic out is allowed
    cidr_blocks = ["0.0.0.0/0"]
  }
}
