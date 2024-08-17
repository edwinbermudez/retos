#!/bin/bash

# SO: Ubuntu 22.04.4 LTS (Jammy Jellyfish)

# Actualizar paquetes del sistema
sudo apt update && sudo apt -y upgrade
sudo apt install net-tools curl htop openssh-server  apt-transport-https-y

# Comentar las siguientes lineas en el archivo /etc/sysctl.d/50-default.conf
sudo sed -i 's/^\-net\.ipv4\.conf\.all\.accept_source_route/#&/' /usr/lib/sysctl.d/50-default.conf
sudo sed -i 's/^\-net\.ipv4.conf.all\.promote_secondaries/#&/' /usr/lib/sysctl.d/50-default.conf
sudo sysctl --system

# Configurar hostname de la máquina virtual
sudo hostnamectl set-hostname c1-cp-01
sudo hostnamectl set-hostname c1-wn-01
sudo hostnamectl set-hostname c1-wn-02
sudo hostnamectl set-hostname c1-wn-03

# Backup del archivo de configuración de netplan
sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

# Crear archivo de configuración de netplan para la interfaz de red ens34, se debe cambiar la dirección IP de acuerdo a la configuración de la red de la máquina virtual.
sudo cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.80.46/24
      routes: 
        - to: default
          via: 192.168.80.1
      nameservers:
        addresses:
          - 192.168.80.1
EOF

# Aplicar la configuración de netplan
sudo netplan apply

ifconfig ens33 | grep i

# añadir las direcciones IP de los nodos al archivo /etc/hosts
sudo sed -i '/127.0.0.1/a 192.168.80.44 c1-cp-01' /etc/hosts
sudo sed -i '/c1-cp-01/a 192.168.80.45 c1-wn-01' /etc/hosts
sudo sed -i '/c1-wn-01/a 192.168.80.46 c1-wn-02' /etc/hosts
sudo sed -i '/c1-wn-02/a 192.168.80.47 c1-wn-03' /etc/hosts
sudo sed -i '/127.0.1.1/d' /etc/hosts




# c1-cp-01
#sed -i '/127.0.1.1/d' /etc/hosts

# c1-wn-01 
#sed -i '/localhost/s/$/ c1-wn-01/' /etc/hosts
# 




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


# Cambiar la versión de la imagen de pause a la ultima versión
#sudo sed -i 's|registry.k8s.io/pause:3.8|registry.k8s.io/pause:3.10|g' /etc/containerd/config.toml
#grep -n 'pause' /etc/containerd/config.toml


# Identificar el dispositivo
sudo fdisk -l

# Crear un sistema de archivos ext4
sudo mkfs.ext4 /dev/sdb1

# Crear un directorio de montaje
sudo mkdir /mnt/datos

# Montar el disco
sudo mount /dev/sdb1 /mnt/datos

# Agregar al archivo fstab para montaje automático
sudo nano /etc/fstab
# Agregar una línea al final:
/dev/sdb1 /mnt/datos ext4 defaults 0 2


# TNSTALAR NFS SERVER
sudo apt update
sudo apt install nfs-kernel-server

sudo chown nobody:nogroup /mnt/datos
sudo chmod 777 /mnt/datos

sudo sed -i '$ a\/mnt/datos 192.168.0.0/24(rw,sync,no_subtree_check)' /etc/exports

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# Validar que fs se esta compartiendo
sudo exportfs -v

# Configurar los clientes NFS
sudo apt update
sudo apt install nfs-common -y

sudo mkdir -p /mnt/datos
sudo mount 192.168.80.44:/mnt/datos /mnt/datos

df -h | grep 192.168.80.44

# Agregar la configuración al archivo /etc/fstab
sudo sed -i '$ a\192.168.80.44:/mnt/datos /mnt/datos nfs defaults 0 0' /etc/fstab




#_________________ Instalación de Helm _______________________#
# https://helm.sh/docs/intro/install/

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
tar -zxvf helm-v3.0.0-linux-amd64.tar.gz

#
sudo rm /etc/kubernetes/manifests/kube-apiserver.yaml
sudo rm /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo rm /etc/kubernetes/manifests/kube-scheduler.yaml
sudo rm /etc/kubernetes/manifests/etcd.yaml


sudo kubeadm reset
rm -rf $HOME/.kube
rm -rf /etc/cni/net.d

####################
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join c1-cp-01:6443 --token uo1614.dnymoftkmmc482px \
        --discovery-token-ca-cert-hash sha256:2caca2588828a7c23087b26e9070fe5c71da71f138dcbaa0c0979ef0b1179ad9 \
        --control-plane --certificate-key 08e50a54c6910e99d8de32f90dd7cb0fab6950d9cc25100243c439422701ca72

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join c1-cp-01:6443 --token uo1614.dnymoftkmmc482px \
        --discovery-token-ca-cert-hash sha256:2caca2588828a7c23087b26e9070fe5c71da71f138dcbaa0c0979ef0b1179ad9


# Crear un token desde el control plane
kubeadm token create --print-join-command | tee kubeadm_init_output.txt


# Añadir worker nodes
kubeadm join c1-cp-01:6443 --token w5xog3.4k9idy716ujrlvd4 --discovery-token-ca-cert-hash sha256:2caca2588828a7c23087b26e9070fe5c71da71f138dcbaa0c0979ef0b1179ad9


# Helm Chart
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami

# Instalar Kube-state-metrics
helm repo update
helm install kube-state-metrics bitnami/kube-state-metrics --set metrics.interval=30s

# Instalar Prometheus y Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

helm install prometheus prometheus-community/prometheus -f prometheus-values.yaml
helm install kube-state-metrics prometheus-community/kube-state-metrics -f kube-state-metrics-values.yaml
helm install grafana grafana/grafana -f grafana-values.yaml


kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


# Agregar dominio
kubectl -n kube-system edit configmap coredns
# Agregar el dominio en la sección de Corefile
# ehbc.com:53 {
#     errors
#     cache 30
#     forward . /etc/resolv.conf
# }



# Instalar Ingress Ngnix
helm install my-nginx bitnami/nginx --set service.type=LoadBalancer
kubectl get svc my-nginx

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# Instalar ingress nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx -f nginx-values.yaml

# Instalar Cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.0 --set installCRDs=true



# Install MetalLB
  # https://metallb.universe.tf/installation/

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.80.240-192.168.80.250

# Instalar MetalLB
kubectl create namespace metallb-system

kubectl edit configmap -n kube-system kube-proxy
# cambiar el valor false por true --  ARP: true

# Cambiar el valor de strictARP: false a strictARP: true en el ConfigMap kube-proxy
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

# Validar la instalación de MetalLB
k api-resources |grep metallb

cat <<EOF > first-pool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata: 
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.80.200 - 192.168.80.250
  autoAssign: true
EOF

# Aplicar la configuración de la dirección IP
kubectl -n metadallb-system apply -f first-pool.yaml

cat <<EOF > l2-advertisement.yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-l2-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
    - first-pool
EOF

kubectl -n metadallb-system apply -f l2-advertisement.yaml

# Validar L2Advertisement
kubectl get l2advertisement


# Instalar ingress Nginx
kubectl apply -f grafana-ingress.yaml
kubectl apply -f prometheus-ingress.yaml


# Instalar Cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true



# Instalar prometheus y grafana
# Agregar repositorios de Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Instalar Prometheus
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace

# Instalar Grafana
helm install grafana grafana/grafana --namespace monitoring

# Obtener la contraseña del administrador de Grafana
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Exponer el servicio de Grafana
kubectl patch svc grafana --namespace monitoring -p '{"spec": {"type": "LoadBalancer"}}'

# Obtener el puerto asignado al servicio de Grafana
kubectl get svc --namespace monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Kube-state-metrics
helm install kube-state-metrics prometheus-community/kube-state-metrics --namespace monitoring --create-namespace

# Instalar kube-prometheus-stack
helm install prometheus-operator prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=kube-prometheus-stack"

