#!/bin/bash

# Actualizar paquetes del sistema
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Prerrequisitos

# 1. Desactivar el swap memory en la máquina virtual
sudo sed -i '/[[:space:]]swap[[:space:]]/ s/^\(.*\)$/#\1/' /etc/fstab
grep -n 'swap' /etc/fstab
sudo swapoff -a
sudo mount -a
echo "Swap memory desactivada"
free -h

# 2. Activar los módulos de kernel necesarios
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# 3. Cargar los módulos de kernel
sudo modprobe overlay
sudo modprobe br_netfilter

# 4. Configurar los parámetros persistentes del kernel
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 5. Aplicar los cambios sin reiniciar
sudo sysctl --system

# 6. Instalar containerd
# Instalacion de los paquetes necesarios
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Añadir el repositorio de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y

# Instalar containerd
sudo apt update
sudo apt-get install -y containerd.io

#Create a containerd configuration file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Verificar la version instalada de containerd
echo -e "\033[32mla versión instalada de containerd es $(containerd --version | awk '{print $3}')\033[0m"

# Modificar el archivo de configuración de containerd para que use systemd como cgroup
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Verificar que el cambio se haya realizado correctamente
if [ $? -eq 0 ]; then
    echo -e "\033[32m SystemdCgroup fue activado \033[0m"
    grep -n 'SystemdCgroup' /etc/containerd/config.toml
else
    echo -e "\033[31m SystemdCgroup no fue activado\033[0m"
    exit 1
fi

# Reiniciar el servicio de containerd
sudo systemctl restart containerd
sudo systemctl enable containerd.service

# Instalar los paquetes necesarios
sudo apt-get update

# Determinar la versión de kubernetes mas actualizada
KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')

sudo mkdir -p /etc/apt/keyrings

# Descarga la llaves publicas del repositorio de kubernetes
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Agregar el repositorio de kubernetes
sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
# Actualizar los paquetes
sudo apt-get update

# Instalar kubeadm, kubelet y kubectl
sudo apt-get install -y kubelet kubeadm kubectl

#  Marcar los paquetes como hold para evitar que se actualicen
sudo apt-mark hold kubelet kubeadm kubectl containerd

# Habilitar el servicio de kubelet
sudo systemctl enable --now kubelet

kubectl version --client && kubeadm version

# Configurar crictl para examinar los contenedores de containerd
sudo crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock

PRIMARY_IP=$(hostname -I | awk '{print $1}')

cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip ${PRIMARY_IP}'
EOF