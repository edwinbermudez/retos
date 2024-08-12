#!/bin/bash

# SO: Ubuntu 22.04.4 LTS (Jammy Jellyfish)

# Preparación de la máquina virtual
sudo apt install net-tools curl htop openssh-server -y
sudo ifconfig ens34 10.0.0.10 netmask 255.255.255.0
sudo ifconfig ens34 10.0.0.11 netmask 255.255.255.0
sudo ifconfig ens34 10.0.0.12 netmask 255.255.255.0
sudo ifconfig ens34 10.0.0.13 netmask 255.255.255.0

# Configurar hostname de la máquina virtual
sudo hostnamectl set-hostname c1-cp-01
sudo hostnamectl set-hostname c1-wn-01
sudo hostnamectl set-hostname c1-wn-02
sudo hostnamectl set-hostname c1-wn-03

# Backup del archivo de configuración de netplan
sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

# Crear archivo de configuración de netplan para la interfaz de red ens34
sudo cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens34:
      dhcp4: no
      addresses:
        - 10.0.0.10/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF

# Aplicar la configuración de netplan
sudo netplan apply

ifconfig ens34 | grep inet

# Configurar default gateway
sudo route del default gw 10.0.0.1
sudo route add default gw 192.168.131.2 dev ens33
route -n

# c1-cp-01
#sed -i '/127.0.1.1/d' /etc/hosts

# c1-wn-01 
#sed -i '/localhost/s/$/ c1-wn-01/' /etc/hosts


# Configurar hostname de la máquina virtual
sudo hostname c1-cp-01
sudo hostname c1-wn-01
sudo hostname c1-wn-02
sudo hostname c1-wn-03

# añadir las direcciones IP de los nodos al archivo /etc/hosts
sudo sed -i '/127.0.0.1/a 10.0.0.10 c1-cp-01' /etc/hosts
sudo sed -i '/c1-cp-01/a 10.0.0.11 c1-wn-01' /etc/hosts
sudo sed -i '/c1-wn-01/a 10.0.0.12 c1-wn-02' /etc/hosts
sudo sed -i '/c1-wn-02/a 10.0.0.13 c1-wn-03' /etc/hosts
sed -i '/127.0.1.1/d' /etc/hosts

#####################################################################################
# Desactivar el swap memory en la máquina virtual
#sudo swapoff -a  # temporal
sudo sed -i '/[[:space:]]swap[[:space:]]/ s/^\(.*\)$/#\1/' /etc/fstab  # Permanente

#  Verificar la MAC address de la máquina virtual y product_uuid sean unicos
ifconfig -a | grep ether | awk '{print $2}'
sudo cat /sys/class/dmi/id/product_uuid

# Revisar puertos abiertos
sudo netstat -tulnp
# Verificar que el puerto 6443 esté abierto
sudo netstat -tuln | grep 6443
# Probando la conexión al puerto 6443
nc 127.0.0.1 6443 -v


kubelet --version
kubeadm version
kubectl version --client
containerd --version







#_________________ Instalación de Helm _______________________#
# https://helm.sh/docs/intro/install/

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
tar -zxvf helm-v3.0.0-linux-amd64.tar.gz