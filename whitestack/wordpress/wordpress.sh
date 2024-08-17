# WORDPRESSS 
helm search hub wordpress  --max-col-width=0
https://artifacthub.io/packages/helm/bitnami/wordpress


# Racher.io - local-path-provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl get storageclass
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl get storageclass

# repositorio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Version mas reciente de wordpress
helm search repo wordpress --versions | head -n 10 | tail -n 1 | awk '{print $2}'

# Verificar valores y readme
helm show readme bitnami/wordpress --version $($(helm search repo wordpress --versions | head -n 10 | tail -n 1 | awk '{print $2}'))
helm show values bitnami/wordpress --version $(helm search repo wordpress --versions | head -n 10 | tail -n 1 | awk '{print $2}')


kubectl create namespace wordpress
helm install wordpress bitnami/wordpress --values=wordpress-values.yaml --namespace nswordpress --version $(helm search repo wordpress --versions | head -n 10 | tail -n 1 | awk '{print $2}')


# Install NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx -f nginx-values.yaml

# Create a Namespace for WordPress
kubectl create namespace wordpress


# Create a Values File for WordPress
cat <<EOF > wordpress-values.yaml
wordpressUsername: admin
wordpressPassword: admin_password
wordpressEmail: admin@example.com
wordpressFirstName: First
wordpressLastName: Last
wordpressBlogName: My Blog

mariadb:
  enabled: true
  auth:
    rootPassword: root_password
    username: wordpress
    password: wordpress_password
    database: wordpress

persistence:
  enabled: true
  storageClass: "standard"  # Adjust based on your cluster's storage class
  accessMode: ReadWriteOnce
  size: 10Gi

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 200m
    memory: 512Mi

livenessProbe:
  httpGet:
    path: /wp-login.php
    port: http
  initialDelaySeconds: 120
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /wp-login.php
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - name: wordpress.example.com
      path: /
  tls:
    - hosts:
        - wordpress.example.com
      secretName: wordpress-tls
EOF

# Install WordPress Using Helm
helm install my-wordpress bitnami/wordpress --namespace wordpress -f wordpress-values.yaml

kubectl apply -f pv-wordpress.yaml
kubectl apply -f pvc-wordpress.yaml
kubectl apply -f pv-mariadb.yaml
kubectl apply -f pvc-mariadb.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install wordpress bitnami/wordpress --values=wordpress-values.yaml --namespace wordpress

helm install my-wordpress oci://registry-1.docker.io/bitnamicharts/wordpress

helm install wordpress bitnami/wordpress --values=wp-values.yaml --namespace wordpress


helm upgrade my-wordpress bitnami/wordpress --namespace wordpress --set persistence.storageClass=gp2,mariadb.primary.persistence.storageClass=gp2
helm install my-wordpress bitnami/wordpress --namespace wordpress --set persistence.existingClaim=wordpress-pvc,mariadb.primary.persistence.existingClaim=wordpress-pvc

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-wordpress bitnami/wordpress -n my-namespace --set wordpress.image.tag=latest --set persistence.enabled=true

kubectl patch pvc my-wordpress -n wordpress -p '{"spec":{"storageClassName":"gp2"}}'
kubectl create storageclass gpp2 --parameters=replica=3


# Install wordpress
kubectl create namespace wordpress
helm install wordpress bitnami/wordpress --namespace wordpress -f wp-values.yaml
helm upgrade wordpress bitnami/wordpress --namespace wordpress -f wp-values.yaml


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

helm upgrade wordpress bitnami/wordpress --namespace wordpress -f wp-values.yaml -f external-values.yaml