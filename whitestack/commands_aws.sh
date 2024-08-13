# Listar los perfiles de AWS
cat ~/.aws/config
aws configure list-profiles

# Listar las credenciales de AWS
cat ~/.aws/credentials

# Eliminar un perfil de AWS
sed -i '/test-account/d' ~/.aws/config
rm -rf ~/.aws/credentials

# Crear un perfil de AWS
aws configure --profile test-account



# Configurar direccionamiento de red
sudo ifconfig ens34 10.0.0.2 netmask 255.255.255.0
sudo route add default gw 10.0.0.1 ens34
route -n


#
sudo vim /usr/lib/sysctl.d/50-default.conf
sudo sysctl --system

# Añadir usuario al sudoers
echo "ehbc    ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
sudo -l -U ehbc


# Pause:3.9
kubeadm config images list | sort" [v1.26.0]
sudo rm -f /etc/kubernetes/manifests/*.yaml