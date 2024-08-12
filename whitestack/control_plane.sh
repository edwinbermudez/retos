#!/bin/bash

POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
PRIMARY_IP=$(hostname -I | awk '{print $2}')

#  Descargar las imágenes de kubernetes
sudo kubeadm config images pull

#  Iniciar el cluster de kubernetes
sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $PRIMARY_IP

# Crear el directorio .kube y copiar el archivo de configuración
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Verificar que el nodo esté listo
kubectl get pods -n kube-system

# Instalar Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
