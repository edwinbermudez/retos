  # Creacion de una instancia de AWS EC2 personalizada


# Definir la instancia EC2
resource "aws_instance" "k8s_vm_custom" {
  depends_on = [ aws_subnet.k8s_public_subnet, aws_security_group.k8s_sg_custom ]
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name      = var.aws_key_name
  subnet_id     =  aws_subnet.k8s_public_subnet[0].id
  vpc_security_group_ids = [ aws_security_group.k8s_sg_custom.id ]
  tags = {
    Name = "k8s_vm_custom"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl
              
              # Descargar y ejecutar el script de la configuracion del nodo
              curl -O https://raw.githubusercontent.com/edwinbermudez/retos/main/whitestack/configuracion_nodo.sh
              sudo chmod +x configuracion_nodo.sh
              sudo ./configuracion_nodo.sh >> configuracion_nodo.log

              # Descargar y ejecutar el script de la configuracion del nodo
              curl -O https://raw.githubusercontent.com/edwinbermudez/retos/main/whitestack/control_plane.sh
              sudo chmod +x control_plane.sh
              sudo ./control_plane.sh >> control_plane.log
              EOF
}

resource "aws_security_group" "k8s_sg_custom" {
  vpc_id = aws_vpc.k8s_vpc.id
  ingress {
    from_port   = var.sg_from_port
    to_port     = var.sg_to_port
    protocol    = var.sg_protocol
    cidr_blocks = var.sg_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Crear la imagen AMI dorada a partir de la instancia EC2
#resource "aws_ami_from_instance" "gold_ami" {
#    depends_on = [ aws_instance.k8s_vm_gold ]
#    name = "gold-ami"
#    source_instance_id = aws_instance.k8s_vm_gold.id
#    tags = {
#        Name = "gold-ami"
#    }
#}
