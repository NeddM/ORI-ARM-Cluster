# Aviso importante
echo "IMPORTANTE"
echo "Ejecuta esto como super usuario"
echo ""

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Abrimos los puertos
sudo apt -y install firewalld
firewall-cmd --permanent --zone=public --add-port=6443/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

sudo ufw allow 6443
sudo ufw allow 443
sudo ufw allow 80 

iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT


# Instalamos docker
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Agregamos Docker como 
sudo usermod -aG docker ${USER}
newgrp docker

sudo apt update -y && sudo apt upgrade -y && sudo systemctl reboot -y

# Instalamos k3s
curl -sfL https://get.k3s.io | sh -s - --docker

clear

sudo kubectl get nodes -o wide
sleep 1

token=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Damos permisos al config, y lo copiamos al .kube
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

echo "Añadir la siguiente línea en la configuración"
echo "insecure-skip-tls-verify: true"

