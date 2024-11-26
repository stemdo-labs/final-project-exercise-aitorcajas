# PROYECTO FINAL

## Infraestructura - Terraform

Para empezar cree la infraestructura con la ayuda de terraform, lo he dividido en un `main.tf` con dos módulos y dos recursos en el archivo principal usando variables.

### Networks

El `main.tf` ejecuta uno de los módulos llamado `networks` que se encarga de las redes, este módulo despliega dos vnet, una para las máquinas virtuales y otra para el cluster, de estas dos vnets naces dos subnets y un peering para unirlas y así poder transferir datos entre ambas. <br>

También crea un grupo de seguridad por la creación de una IP pública para así poder acceder a la máquina de backups la cual explicaré su función principal más adelante, este grupo tiene unas reglas de seguridad para permitir acceder por el puerto 22 y así permitir conexión ssh.

### Virtual Machines

El otro módulo crea las máquinas virtuales, crea las dos interfaces de red, la de la máquina de backups con la IP pública, ambas interfaces tienen IPs privadas estáticas porque necesitaremos saber cual va a ser la de la máquina de la base de datos en determinadas ocasiones.

### Cluster & Container Registry

El cluster y el container registry he decidido montarlos en el archivo principal en vez de meterlos en un módulo porque me parecía que los dos recursos no tienen concordancia para meterlos en un mismo módulo, y al fin y al cabo porque llevan una configuración simple por la que que no veía necesario un módulo aparte. <br>

Toda la parte de la infraestructura está automatizada al hacer una pull request esta mostrará el `terraform plan` antes de poder mergear, y al hacer un push a la rama main aplicará un `terraform apply` levantando toda la infraestructura.

## Automatización de Operaciones y Recuperación ante Desastres - Ansible

Para esta parte era por lo que necesitabamos la IP pública y saber cuál sería la IP privada de nuestra máquina virtual de la base de datos. La IP pública la usaremos para conectarnos a la máquina de backups y así usar esta como runner para instalar ansible, az CLI, etc. <br>

Empezamos por ejecutar el workflow llamado `ansible.yml` el cual instalará ansible y varias dependencias para ejecutar un playbook que se lanzará a nuestra máquina de la base de datos, cuya IP sabemos y tenemos escrita en el inventario. En la máquina de la base de datos se instalará PostgreSQL, se creará un usuario y se asignará una base de datos a ese usuario sobre la que vamos a trabajar. <br>

Para el backup he configurado un workflow que como runner tenga la máquina de backups para que haga un backup diario y lo suba a un contenedor de la cuenta de almacenamiento proporcionada. El disaster recovery no he tenido tiempo de acabarlo, pero conseguí descargar el backup de la cuenta de almacenamiento.

## Harbor

Antes de hablar de lo que conlleva el despliegue de los charts en el cluster quiero hablar de la configuración de un workflow el cual sube los dos charts a Harbor preparados para recoger las imágenes de los proyectos una vez esten listas.

## Despliegue en Kubernetes

### CI

La parte del CI del proyecto conlleva los otros dos repositorios, el de backend y el de frontend, en estos proyectos he desarrollado un workflow el cual llama a un workflow reusable del repositorio principal al hacer un commit en la rama main de ambos repositorios. Este workflow llama a una action para tagear la imagen y después buildearla y subirla al container registry creado en la infraestructura.

### CD

La parte del CD una vez haya acabado el pusheo de la imagen correspondiente de backend o frontend descarga el chart de helm para desplegar en el cluster con esta nueva imagen. El chart del frontend genera un servicio tipo `LoadBalancer` el cual nos da una IP pública para así poder acceder a la aplicación.

#### Notas

Falta mejorar el despliegue de los charts para usar la imagen actualizada porque de momento uso siempre la misma imagen y creo que sería mejor crear un reusable para el CI y otro para el CD y llamarlos desde un workflow principal a uno en cada job. También falta acabar el disaster recovery más todo lo opcional.
