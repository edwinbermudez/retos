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