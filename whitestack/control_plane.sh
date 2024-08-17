#!/bin/bash

# Descargar las imagenes de los componentes de Kubernetes 
sudo kubeadm config images pull

# Variables de entorno
POD_CIDR=172.16.0.0/16
CRI_SOCKET=unix:///run/containerd/containerd.sock
PRIMARY_IP=$(hostname -I | awk '{print $1}')
HOSTNAME_CP=c1-cp-01

# Inicializar cluster
#sudo kubeadm init --pod-network-cidr=$POD_CIDR --cri-socket=$CRI_SOCKET --upload-certs --control-plane-endpoint=$HOSTNAME_CP 
sudo kubeadm init --pod-network-cidr=$POD_CIDR --cri-socket=$CRI_SOCKET --upload-certs --apiserver-advertise-address $PRIMARY_IP 
# Configurar kubectl
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Verificar los pods
kubectl get pods -n kube-system

# Install Calico
wget https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo 'source <(kubectl completion bash)' >>~/.bashrc

# Reload sourcefile again (located on home)
source .bashrc 

# Verificar control plane
kubectl get pods --all-namespaces