#!/bin/bash

POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
PRIMARY_IP=$(hostname -I | awk '{print $2}')

# Actualizar la imagen de pause
sudo ctr images pull registry.k8s.io/pause:3.9

# Actualizar la imagen de sandbox del contenedor
sudo kubeadm config images pull --image-repository registry.k8s.io --kubernetes-version $(kubeadm version -o short)

#  Iniciar el cluster de kubernetes
sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $PRIMARY_IP | tee kubeadm_init_output.txt

# Crear el directorio .kube y copiar el archivo de configuración
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Verificar que el nodo esté listo
kubectl get pods -n kube-system

# Instalar Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
