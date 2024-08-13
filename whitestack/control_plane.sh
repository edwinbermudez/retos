#!/bin/bash

# Variables de entorno
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
PRIMARY_IP=$(hostname -I | awk '{print $1}')

# Inicializar cluster
sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $PRIMARY_IP | tee kubeadm_init_output.txt

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

# Verificar control plane
kubectl get pods --all-namespaces