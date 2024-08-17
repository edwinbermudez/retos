resource "aws_instance" "k8s_control_plane" {
  depends_on             = [aws_subnet.k8s_public_subnet, aws_security_group.k8s_sg_custom]
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type
  key_name               = var.aws_key_name
  subnet_id              = aws_subnet.k8s_private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.k8s_sg_custom.id]
  tags = {
    Name = "k8s-control-plane"
  }
}

resource "aws_instance" "k8s_worker_nodes" {
  depends_on             = [aws_subnet.k8s_private_subnet, aws_security_group.k8s_sg_custom]
  count                  = var.aws_worker_nodes_count
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type
  key_name               = var.aws_key_name
  subnet_id              = aws_subnet.k8s_private_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.k8s_sg_custom.id]
  tags = {
    Name = "k8s_worker_node_${count.index}"
  }
}

resource "aws_instance" "bastion" {
  depends_on             = [aws_subnet.k8s_public_subnet, aws_security_group.k8s_sg_custom]
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type_bastion
  key_name               = var.aws_key_name
  subnet_id              = aws_subnet.k8s_public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "bastion"
  }
}