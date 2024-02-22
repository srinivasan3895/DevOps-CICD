resource "aws_security_group" "demo-efs" {
  name        = "terraform-efs"
  description = "Communication to efs"
  vpc_id      = aws_vpc.demo.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-efs"
  }
}

resource "aws_efs_file_system" "demo" {
  creation_token = "efs-eks"
  tags = {
    Name = "EKS"
  }
}

resource "aws_efs_mount_target" "demo" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  file_system_id = aws_efs_file_system.demo.id
  subnet_id      = aws_subnet.demo.*.id[count.index]
  security_groups = ["${aws_security_group.demo-efs.id}"]
}

resource "aws_efs_access_point" "demo" {
  file_system_id = aws_efs_file_system.demo.id
}
