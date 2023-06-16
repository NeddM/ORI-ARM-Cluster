system_update() {
	sudo apt update && sudo apt upgrade -y
}

open_ports() {
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
}

install_docker() {
	sudo apt-get update
	sudo apt-get install ca-certificates curl gnupg

	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg

	echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# Adding Dcoker to usermod
	sudo usermod -aG docker ${USER}
	newgrp docker

	# Updating and restarting the service
	sudo apt update -y && sudo apt upgrade -y && sudo systemctl reboot -y
}

install_k3s() {
	curl -sfL https://get.k3s.io | sh -s - --docker

	clear

	sudo kubectl get nodes -o wide
	sleep 1

	token=$(sudo cat /var/lib/rancher/k3s/server/node-token)
}

setting_config() {
	# Damos permisos al config, y lo copiamos al .kube
	sudo chmod 644 /etc/rancher/k3s/k3s.yaml

	mkdir ~/.kube
	sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

	echo "Ahora añade la siguiente línea a la configuración:"
	echo "insecure-skip-tls-verify: true"
	echo "También tienes que comentar los certificados."
}

main() {
	if [ "$EUID" -ne 0 ]; then
		echo "Ejecuta este script como super usuario"
		exit
	fi

	system_update
	open_ports
	install_docker
	install_k3s
	setting_config
}

main
