# ORI-ARM-Cluster

Vamos a crear un cluster de kubernetes gratuito, con K3S, en la nube gratuita de Oracle.

## Creamos nuestra instancia

Vamos a comnezar a crear nuestra instancia, una vez hemos creado nuestra cuenta en Oracle Free nos vamos a dirigir al buscador superior, y vamos a escribir _instance_.

![Abrir menú de instancia](/Img/AbrirMen%C3%BAInstancia.png)

Una vez dentro, hacemos click en _Create instance_.

![Crear instancia](/Img/empezamosCreacion.png)

Le asignamos un nombre a nuestra máquina.

![Asignar nombre](/Img/asignarNombre.png)

Luego vamos directamente a crear nuestra imagen. Primero vamos a establecer la imagen que usaremos, que será _Ubuntu 20.04_.

![Imagen y máquina](/Img/imageAndShape.png)
![Imagen Ubuntu 20.04](/Img/ImagenUbuntu20.04.png)

Y a continuación configuramos nuestra máquina.

![Máquina ARM](/Img/seleccionamosM%C3%A1quinaARM.png)
![24GB y 4CPU](/Img/24gby4cpu.png)

Luego vamos a crear nuestra red interna (primary network y subnet).

![Creación de red](/Img/creamosLaRed.png)

**Importante**, hay que descargar la clave pública, sino luego no nos podemos conectar a nuestra instancia.

![Descargamos clave](/Img/descargamosClaveSSH.png)

Por último, configuramos la capacidad de disco de nuestra máquina. La máxima capacidad por cada cuenta es de 200GB.

![200GB](/Img/200GB.png)

Una vez hemos seguido todos estos pasos, ya podemos crear nuestra instancia.

## Abrimos puertos en la web de Oracle Cloud Free Tier

Una vez creada la instancia, tenemos que abrir los puertos de nuestra red para que Kubernetes pueda funcionar correctamente.

Dentro de nuestra instancia en la plataforma de Oracle, hacemos click en nuestra _Virtual cloud network_.

![Virtual network](/Img/abrirPuertos1.png)

Se abrirá un nuevo menú donde podemos ver que existe nuestra subnet, hacemos click sobre nuestra subnet.

![Subnet](/Img/abrirPuertos2.png)

Luego abrimos la _Security list_.

![Security list](/Img/abrirPuertos3.png)

Y ahora sí, añadimos nuestras _Ingress Rules_, tienen que quedar tal que así.

![Abrimos los puertos](/Img/abrirPuertos4.png)

## Abrimos puertos dentro del sistema operativo

Primero actualizamos el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

Abrimos los puertos de nuestro sistema; dependiendo del sistema operativo que estés corriendo tendrás que usar un comando u otro, aunque yo recomiendo abrirlos todos (usar todos los comandos).

```bash
sudo apt -y install firewalld
firewall-cmd --permanent --zone=public --add-port=6443/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload
```

```bash
sudo ufw allow 6443
sudo ufw allow 443
sudo ufw allow 80
```

```bash
iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

Podemos comprobar si se han abierto los puertos **[en esta web](https://www.yougetsignal.com/tools/open-ports/)**, aunque es posible que tarde en actualizarse. Yo recomiendo continuar con la instalación, y si luego hay problemas con los puertos entonces volver a este punto.

## Instalamos Docker

Estos son los comandos para instalar Docker.

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
```

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

```bash
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

También podemos agregar docker en un grupo de confianza, para que no tengamos que usar _sudo_ cada vez que queramos usarlo.

```bash
sudo usermod -aG docker ${USER}
newgrp docker
```

Por último, actualizamos el sistema de nuevo

```bash
sudo apt update -y && sudo apt upgrade -y && sudo systemctl reboot -y
```

## Instalamos k3s

```bash
curl -sfL https://get.k3s.io | sh -s - --docker
```

Comprobamos que _kubectl_ funciona correctamente.

```bash
sudo kubectl get nodes -o wide
```

Damos permisos al config, y lo copiamos al .kube

```bash
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

En la configuración, debemos añadir la línea `insecure-skip-tls-verify: true`

Y también comentar el certificado, como vemos en la imagen.

![Config example](Img/exampleConfig.png)
