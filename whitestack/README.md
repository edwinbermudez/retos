## Aprovisionar clúster de kubernetes sobre máquinas virtuales Ubuntu 22

1. Realizar instalación y actualización de paquetes.

``` sh
sudo apt update && sudo apt -y upgrade
sudo apt install net-tools curl htop openssh-server  apt-transport-https-y
```

2. Comentar las lineas para evitar errors.

``` sh
sudo sed -i 's/^\-net\.ipv4\.conf\.all\.accept_source_route/#&/' /usr/lib/sysctl.d/50-default.conf
sudo sed -i 's/^\-net\.ipv4.conf.all\.promote_secondaries/#&/' /usr/lib/sysctl.d/50-default.conf
sudo sysctl --system
```

3. Configurar hostname en cada una de las máquinas virtuales

``` sh
sudo hostnamectl set-hostname c1-cp-01
sudo hostnamectl set-hostname c1-wn-01
sudo hostnamectl set-hostname c1-wn-02
sudo hostnamectl set-hostname c1-wn-03
```