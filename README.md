# Guía de Born2Beroot
### Basada en la hoja de evaluación

En esta guía se proporcionarán los pasos para la configuración de la máquina virtual exigida en el Subject del proyecto. No obstante, para seguir estos pasos, seguiremos la hoja de la evaluación en lugar del subject, ya que esta cubre más y podemos ver de un modo preciso cómo hacer las demostraciones.

Durante toda la evaluación, se recuerda al evaluador que el estudiante evaluado tiene que ser capaz de ayudarle en todo momento. Es decir, entiende lo que haces.

## Índice

1. [Configuración inicial](#configuración-inicial)
2. [Usuarios y grupos](#usuarios-y-grupos)
3. [Políticas de contraseñas](#políticas-de-contraseñas)
4. [Hostname y particiones](#hostname-y-particiones)
5. [SUDO](#sudo)
6. [UFW](#ufw)
7. [SSH](#ssh)


---

## Configuración inicial
- Antes de intentar conectarse a la máquina, se pedirá una contraseña. Esta es la de la encriptación del disco sda5.

`Please unlock disk sda5_crypt: `

- Asegúrate de que la máquina no tiene un entorno gráfico al iniciarla.
    Esto se puede ver escribiendo el comando
  
  > ```bash
  > echo $DISPLAY
  > ```
  y saldrá un salto de línea, si no hay entorno gráfico. Esto podemos compararlo con la terminal usual de nuestro sistema, que mostrará :0 en su lugar. 

**Ejemplo de máquina sin entorno gráfico:**

> ~$ echo $DISPLAY  
>   
> ~$      

**Ejemplo de máquina con entorno gráfico:**

> ~$ echo $DISPLAY     
> :0     
> ~$         

- Comprueba que el servicio UFW está iniciado:

Vamos a configurar UFW (Uncomplicated FireWall). Esta es una herramienta fácil de usar para gestionar el firewall en sistemas Linux. Está diseñada para hacer que la configuración del firewall sea sencilla, permitiendo a los usuarios permitir o bloquear el tráfico de red con comandos básicos. UFW se utiliza para proteger tu sistema controlando qué conexiones entrantes o salientes están permitidas.  

Primero lo instalaremos en nuestro sistema, con `sudo apt install ufw`. A continuación, lo habilitaremos con `sudo ufw enable`. Esto hará que se ejecute automáticamente en futuros arranques del sistema, así como que se inicie en el momento.  

```bash
sudo apt install ufw   
sudo ufw enable   
```

Ahora, para demostrar al evaluador que el servicio UFW está iniciado correctamente, podemos ejecutar cualquiera de estos comandos:  

> ```bash
> sudo ufw status
> ```

> ```bash
> sudo service ufw status
> ```

> ```bash
> sudo systemctl ufw status
> ```

- Comprueba que el servicio SSH está iniciado:

SSH (Secure Shell) es un protocolo que permite conectarte de manera segura a otra máquina a través de una red, utilizando cifrado. Es muy común en servidores para gestionar y controlar sistemas remotamente de manera segura. SSH protege la comunicación entre el cliente y el servidor para evitar que terceros puedan ver o modificar los datos.  

Lo instalamos como ya sabemos, con `sudo apt install ssh` y lo habilitaremos con System Control, ejecutando `sudo systemctl enable ssh`, que hará que se ejecute en futuros arranques del sistema, seguido de `sudo systemctl start ssh`, que lo iniciará al momento.

```bash
sudo apt install ssh   
sudo systemctl enable ssh   
sudo systemctl start ssh   
```

Para demostrar que está correctamente iniciado, podemos hacerlo de forma similar a UFW, ejecutando cualquiera de estos comandos:  

> ```bash
> sudo service ssh status
> ```

> ```bash
> sudo systemctl ssh status
> ```

- Comprueba que el sistema operativo es Debian o Rocky. En este caso, demostraremos que es Debian, viendo la cabecera del archivo `/etc/os-release`
 > ```bash
 > head -n 2 /etc/os-release
 > ```
Con este comando, nos saldrá algo similar a 

> PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"  
> NAME="Debian GNU/Linux"

Otra forma válida sería mostrar la arquitectura del sistema con `uname -a`. 

### Evaluación de Configuración Inicial:
- [x] Se pide una contraseña al encender la máquina (sda5_crypt)
- [x] El servicio UFW está activo
- [x] El servicio SSH está funcionando correctamente
- [x] El sistema no tiene entorno gráfico


## Usuarios y grupos
- El subject solicita que un usuario con el login del estudiante evaluado esté presente en la máquina virtual. Comprueba que existe y que pertenece a los grupos "sudo" y "user42".
- El evaluador deberá crear un usuario y el estudiante evaluado, un grupo llamado "evaluating", en el cual meterá al usuario recién creado.

  Para crear un usuario ejecutaremos el comando `sudo adduser user_name`. De forma paralela, para crear un grupo, ejecutaremos `sudo addgroup group_name`. Para añadir el usuario creado al grupo elegido, escribiremos el comando `sudo adduser user_name group_name`.
  Veamos un ejemplo simplificado con mi login:

> ~$ sudo adduser juanherr  
> [sudo] contraseña para user:  
> Añadiendo el usuario 'juanherr' ...  
> ~$             

> ~$ sudo addgroup evaluating  
> Añadiendo el grupo 'evaluating' ...   
> Hecho.  
> ~$ sudo adduser juanherr evaluating  
> Añadiendo al usuario 'juanherr' al grupo 'evaluating' ...  
> Hecho.   
> ~$         

Ahora tenemos el nuevo user "juanherr" dentro del grupo "evaluating". Para demostrar esto, podemos hacer dos cosas: ver los usuarios que están dentro de un grupo, con el comando `getent group group_name` o viendo los grupos a los que pertenece el usuario, con el comando `groups user_name`.

> ~$ getent group evaluating    
> evaluating:x:juanherr    
> ~$             

> ~$ groups juanherr  
> juanherr : users evaluating   
> ~$              

## Políticas de contraseñas 

- Asegúrate de que las normas expuestas en el subject respecto a la política de contraseñas se ha seguido correctamente.

  La política de contraseñas del subject es la siguiente:

        Para configurar una política de contraseñas fuerte, deberás cumplir los siguientes
      requisitos:
      • Tu contraseña debe expirar cada 30 días.
      • El número mínimo de días permitido antes de modificar una contraseña deberá ser 2.
      • El usuario debe recibir un mensaje de aviso 7 días antes de que su contraseña expire.
      • Tu contraseña debe tener como mínimo 10 caracteres de longitud. Debe contener una mayúscula,
      una minúscula y un número. Por cierto, no puede tener más de 3 veces consecutivas el mismo carácter.
      • La contraseña no puede contener el nombre del usuario.
      • La siguiente regla no se aplica a la contraseña para root: La contraseña debe tener al menos
       7 caracteres que no sean parte de la antigua contraseña.
      • Evidentemente, tu contraseña para root debe seguir esta política

Vamos por partes.
Primero vamos a configurar la política de la 'edad' de la contraseña. Esto es, los tres primeros puntos. Para ello, modificaremos el archivo `/etc/login.defs`. Recomiendo usar el editor nano con la flag -l para ver las líneas, ya que es muy extenso.

```bash
sudo nano -l /etc/login.defs
```
Nos dirigimos a la línea 165 y modificamos esos tres valores, de esta forma:

![image](https://github.com/user-attachments/assets/d02e5c53-7739-437c-a06e-69116a49c937)

Como esta modificación no es retroactiva, tendremos que cambiar las reglas asociadas a nuestro usuario y a root con el comando `chage`. Para listar las reglas de expiración, renovación y avisos de nuestra contraseña, escribiremos

```bash
sudo chage -l user_name    
```
y, al final, nos aparecerá algo como: 

> ~$ sudo chage -l root            
>  [...]                         
> Número de días mínimo entre cambio de contraseña             : 0             
> Número de días máximo entre cambio de contraseña             : 99999      
> Número de días de aviso antes de que caduque la contraseña   : 7     
> ~$                    

Para modificarlas a 2, 30 y 7, respectivamente, como exige el subject, utilizaremos las flags -m (mínimo), -M (máximo) y -W (warning, aviso).
```bash
sudo chage -m 2 user_name      
sudo chage -M 30 user_name     
sudo chage -W 7 user_name
```
Esto lo repetiremos para nuestro usuario y para root. 

Ahora configuraremos el resto de reglas. En este caso, con nano también, editaremos el archivo `/etc/security/pwquality.conf`. 

`difok` es el número mínimo de caracteres que deben ser diferentes (Different OK) entre la contraseña nueva y la antigua. Lo cambiaremos en otro lugar, ya que NO SE APLICA A ROOT.     
`minlen` es la longitud mínima de la contraseña (minimun length). Lo establecemos en 10 caracteres.   
`dcredit` es el mínimo número de caracteres numéricos (digit) exigido cuando el valor es negativo. Lo establecemos en -1.   
`ucredit` es el mínimo número de caracteres alfabéticos en mayúscula (uppercase). Ponemos -1.    
`lcredit` es el número mínimo de caracteres alfabéticos en minúscula (lowercase). Ponemos -1.    
`ocredit` se refiere a otros (other) tipo de caracteres, como !%&. El subject no pide nada.    
`minclass`es el número mínimo de clases de caracteres requeridos por la contraseña. Debe ser 3 (dígitos, mayúsculas y minúsculas).   
`maxrepeat` indica el número máximo de caracteres consecutivos en la nueva contraseña. Ponemos 3.    

Debe quedar algo así:

![image](https://github.com/user-attachments/assets/ea4049a7-f7dd-4fa2-9466-c36f64db87a0)

Más abajo, en el documento, nos encontramos con tres reglas más que debemos activar: 

`usercheck = 1` previene de utilizar el nombre del usuario en la contraseña.
`retry = 3` es el número de intentos para poner bien la contraseña. 
`enforce_for_root` aplica todas estas medidas a la contraseña de root. Por eso NO hemos activado aquí el `difok`.

![image](https://github.com/user-attachments/assets/68021216-5e76-4577-b3e3-66fcb63989be)

Ahora sí, vamos a exigir que la nueva contraseña tenga al menos 7 caracteres diferentes a los de la contraseña antigua, para todos los usuarios excepto para root. Con este fin, añadiremos algunos módulos al archivo `/etc/pam.d/common-password`. 

En la parte de los requisitos que se relacionan con pam_pwquality.so (haciendo referencia al archivo que hemos modificado previamente), añadimos después de `retry=3` lo siguiente: `difok=7 user!=root`. Así cumplimos el último criterio del subject. 

![image](https://github.com/user-attachments/assets/59dfd4db-7a4e-446b-961e-ec2dc09cf8d7)

## Hostname y particiones

### Hostname

- Comprueba que el hostname de la máquina virtual sigue el siguiente formato: login42 (login del estudiante evaluado).
- Modifica este hostname reemplazando su login por el tuyo. Después, reinicia la máquina. Si tras reiniciar el hostname no se ha actualizado, la evaluación termina aquí.

Los criterios de evaluación son claros. Nuestro hostname, que hemos definido al crear la máquina virtual, tiene que ser nuestro login seguido de 42. En nuestra línea de comandos debería verse esto:

> login@login42:~$ _           

Para demostrar el hostname, con ejecutar el comando `hostname` debería de ser suficiente, ya que nos devuelve únicamente su nombre:

> login@login42:\~$ hostname                           
> login42        
> login@login42:\~$ 

Ahora cambiaremos el hostname editando el archivo `/etc/hostname` y `/etc/hosts`. Podemos usar nano para cambiar el nombre al login nuevo, seguido de 42. Guardamos y después hacemos `sudo reboot`. Al iniciar, nos debería salir lo siguiente:

> login@newlogin42:~$ _

y, haciendo `hostname`, saldrá el nuevo hostname. Ahora podemos devolverlo al original.

### Particiones

- Ahora debemos mostrar las particiones para esta máquina virtual y comparar el resultado con el del subject.
 
Para ello, ejecutaremos el comando _list block_ `lsblk`. Esto nos mostrará algo similar a lo siguiente, dependiendo de si hemos decidido hacer el bonus o no:
    
<p align="center">
  <img src="https://github.com/user-attachments/assets/c080c851-db74-4ced-a7b6-eb3bf1de94ee" alt="Sin Bonus" width="500">
  <br>
  <em>Sin bonus</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/c110823e-6285-4d0e-a356-3da28e948cdb" alt="Con Bonus" width="500">
  <br>
  <em>Con bonus</em>
</p>

## SUDO 

- Comprueba que el programa sudo está instalado correctamente en la máquina virtual.

Para demostrar esto tenemos varias alternativas, como es habitual. La más sencilla es `sudo --version`, que nos mostrará la versión de sudo instalada, lo cual implica que existe. Otra forma, que devuelve algo más de información, es `dpkg -l sudo`, que nos devolverá una tabla con el nombre del programa, la versión, la arquitectura y una pequeña descripción. 

- Asignamos el usuario que hemos creado al evaluador al grupo sudo, como hemos hecho antes con el grupo evaluating.

  > ~$ sudo adduser newuser sudo     
  > [sudo] contraseña para login:        
  > Añadiendo el usuario 'newuser' al grupo 'sudo' ...        
  > Hecho.      
  > ~$     

- Ahora debemos poder mostrar el valor de sudo con algún ejemplo. Podemos hacer una comparativa con un comando ejecutado sin sudo y con sudo (añadiéndole privilegios de super usuario). Vamos a probar a listar los elementos del directorio /root. 

  > login@login42:\~$ ls /root        
  > ls: no se puede abrir el directorio '/root': Permiso denegado        
  > login@login42:\~$ sudo ls /root        
  > login@login42:\~$ _

- A continuación, vamos a mostrar la implementación de las normas fijadas por el enunciado para sudo.

  ![image](https://github.com/user-attachments/assets/b816b971-616b-4fd8-b31e-f60336315b4f)

Antes de implementar nada vamos a crear una carpeta `/var/log/sudo` y un archivo `sudo_log`dentro. Podemos hacer `sudo mkdir /var/log/sudo` y `sudo touch /var/log/sudo/sudo_log`. Aquí es donde archivaremos los inputs y outputs de los comandos ejecutados con sudo. 

Si entramos en el archivo `/etc/sudoers` podemos modificar todas las normas que aplicaremos a sudo. Para ello, por ser un archivo extremadamente sensible, deberemos editarlo de forma segura, a través de la modificación de un archivo temporal. Esto se hace editando con el comando `visudo`.

  ```bash
  sudo visudo
  ```

En los `Defaults`del archivo, añadiremos todas estas reglas:

Defaults        passwd_tries=3
Defaults        badpass_message="¡Contraseña incorrecta! Inténtalo de nuevo."
Defaults        logfile="/var/log/sudo/sudo_log"
Defaults        requiretty
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

Dejando las que ya había, quedaría algo así: 

![image](https://github.com/user-attachments/assets/ab1343d3-8739-4a01-97aa-4982eba7150a)

- El evaluador comprobará que `/var/log/sudo` existe y que tiene al menos un archivo. Asimismo, comprobará el contenido del archivo que encuentre, en nuestro caso, `sudo_log`, donde encontrará el historial de inputs y outputs de los comandos ejecutados con sudo, haciendo, por ejemplo, `sudo cat /var/log/sudo/sudo_log`.
- Ahora deberá ejecutar un comando con sudo para comprobar que se actualiza en tiempo real. Un ejemplo sería `sudo nano prueba`, que abrirá un archivo nuevo para editar con nano. Al cerrar, si ejecuta `sudo tail -n 1 /var/log/sudo/sudo_log`, podrá ver el último comando ejecutado con sudo, que será `sudo nano prueba`, demostrando que todo funciona correctamente.

> [!NOTE]
> He usado `tail` en vez de `cat` para mostrar la última línea (-n 1) y no todo el archivo entero. De forma análoga, podría usar `head -n #` para mostrar las \# primeras líneas.

## UFW

- Debemos mostrar al evaluador que UFW está correctamente instalado en la VM. Como hicimos al principio, podemos ejecutar `sudo service ufw status` y se nos indicará que está cargado, habilitado y activo.

Añadir reglas a UFW es bastante sencillo. Simplemente, tenemos que escribir el comando `sudo ufw allow #`, donde `#` es el puerto que queremos permitir. De modo que haremos

```bash
sudo ufw allow 4242   
```

- Ahora debemos demostrar al evaluador que existe al menos una regla para el puerto 4242, ejecutaremos el comando `sudo ufw status`. Si hemos hecho el bonus, deberían salir otras también.
  Ejemplo:
```
> login@login42:~$ sudo ufw status              
> Status: active                          
>                         
> To                Action        From                      
> --                ------        ----                              
> 4242              ALLOW         Anywhere                        
> 4242 (v6)         ALLOW         Anywhere (v6)                           
>                           
> login@login42:~$                
```
- Ahora tenemos que añadir una nueva regla para el puerto 8080, comprobar que está correctamente añadida y eliminarla.

Añadimos la regla:  

> login@login42:\~$ sudo ufw allow 8080                         
> Rule added                    
> Rule added (v6)                 
> login@login42:\~$                                   

Vemos que está correctamente añadida
```
> login@login42:~$ sudo ufw status                          
> Status: active                           
>                                      
> To                Action        From                            
> --                ------        ----                        
> 4242              ALLOW         Anywhere                  
> 8080              ALLOW         Anywhere                   
> 4242 (v6)         ALLOW         Anywhere (v6)                     
> 8080 (v6)         ALLOW         Anywhere (v6)                                    
>                              
> login@login42:~$                 
```
Ahora la eliminamos. Para ello, tenemos que numerar la lista de reglas y eliminar el número asignado a la regla que queremos quitar. Haremos `sudo ufw status numbered`
```
> login@login42:~$ sudo ufw status                             
> Status: active                                   
>                                       
>         To                Action        From                              
>         --                ------        ----                             
> [ 1]    4242              ALLOW         Anywhere                  
> [ 2]    8080              ALLOW         Anywhere                   
> [ 3]    4242 (v6)         ALLOW         Anywhere (v6)                     
> [ 4]    8080 (v6)         ALLOW         Anywhere (v6)                               
>                                       
> login@login42:~$
```

Una vez numerados, con el comando `sudo ufw delete #` podremos eliminar el número `#`. Por ejemplo, en este caso, haríamos `sudo ufw delete 2`. Después, volveremos a numerar los restantes y a eliminar el siguiente.  

> [!WARNING]
> Por seguridad, no podemos eliminar más de una regla a la vez, por lo que, por cada una que eliminemos, debemos volver a ejecutar `sudo ufw status numbered` para ver la nueva asignación de números a los puertos.   

## SSH 

- En la evaluación se pide comprobar que el servicio SSH está correctamente instalado. Podemos hacerlo de varias formas. La más sencilla es buscar con `dpkg` los paquetes instalados, listarlos y filtrar los que contengan _openssh_.
```bash
dpgk -l | grep openssh   
```

- Vamos a habilitar el puerto 4242. Para ello, abrimos el archivo /etc/ssh/sshd_config con el editor nano y descomentamos la línea #Port 22, y la cambiamos por 4242. Asimismo, nos aseguramos de descomentar la línea PermitRootLogin y asignarle el valor "no". Esto evitará que podamos conectarnos a root con SSH.

El resultado sería algo así:  

  ![image](https://github.com/user-attachments/assets/4f2c812f-c92c-493f-b210-65524a2fba08)

- Ahora llega la parte interesante: vamos a conectarnos con otro usuario a través de SSH.   

Lo primero que haremos será obtener la ip local del usuario con el que nos vamos a conectar. Esto se hace con el comando:  
```bash
hostname -I   
```

Ahora podemos realizar la conexión usando:

```
ssh newuser@iplocal -p 4242   
```
donde:
- `newuser` es el usuario con el que nos queremos conectar.  
- `iplocal` es el resultado de `hostname -I`.

Al ejecutar el comando, nos pedirá una confirmación para conectarnos (la primera vez) y la contraseña de `newuser`. Tras aceptar e introducir la contraseña, estaremos conectados al nuevo usuario a través de SSH.

## Seguimiento del script

- Durante la evaluación del proyecto, debe aparecer cada 10 minutos un script en la terminal, como indica el subject:  

![image](https://github.com/user-attachments/assets/79f169ea-2534-4fa4-9f80-632df38ceff7)

Primero vamos a crear el script y después procederemos a utilizar cron para que se ejecute.  

### Creación del Script

Un script es un archivo de texto que contiene una serie de comandos que el sistema ejecutará de forma secuencial. Esto es, deberemos incluir sendos comandos para visualizar todo lo que se nos pide. 

> [!INFO]   
> Mi script está subido al repositorio como archivo, por lo que no me explayaré aquí explicando los comandos.   
> Se ruega verificar que funciona, ya que puede variar dependiendo del idioma del sistema. En mi caso, está en español.   

- Arquitectura del sistema operativo y su versión del kernel:   
      Para mostrar esto, podemos ejecutar `uname` (Unix name), que muestra cierta información del sistema. Con la flag `-a` o `--all`, mostrará toda la información.  

- El número de núcleos físicos:
      Esta información la podemos sacar de la información mostrada por el comando `lscpu` (list CPU). Para ello, debemos multiplicar el número de sockets por los núcleos que tiene cada socket.

- El número de núcleos virtuales:
      De igual manera, en `lscpu` encontramos este valor en 'CPU(s)'.

- La memoria RAM disponible actualmente en tu servidor y su porcentaje de uso.
      La información sobre memoria RAM y memoria swap está disponible con el comando `free`. En este caso, como nos pide la RAM, filtraremos con `grep` la línea que pone 'Mem'. Por defecto, la información aparece en bytes, pero podemos sacarla en megabytes con `-m` o `--mega`. Para sacar el porcentaje, dividimos la usada entre la total y multiplicamos por 100. Como se ve en el script, sacamos 2 decimales con `"scale=2"`, asociado a la herramienta `bc`.  

> [!WARNING]
> Para poder usar decimales y, en general, realizar cálculos matemáticos en scripts o desde comandos, es conveniente utilizar `bc` (Basic calculator).  
> Podemos instalarla con `sudo apt install bc`.  

- La memoria disponible actualmente en tu servidor y su utilización como un porcentaje.
      Para sacar la carga de la CPU podemos usar el comando `top`. Este comando es en tiempo real, similar a lo que sería el administrador de tareas de Windows. Para nuestro fin, podemos sacar un solo lote, utilizando una captura del estado actual. Para ello, podemos utilizar `-bn1` (**b** batch mode; **n** número de iteraciones). Filtrando ahora por _load average_, podemos ver la información que nos es necesaria.

- La fecha y hora del último reinicio.
      Esta información la podemos extraer del comando `who -b`. (**-b** boot)

- Si LVM está activo o no.
      Para comprobar si LVM (_Logical Volume Manager_, administrador de volúmenes lógicos (particiones)) está activo o no, podemos utilizar el comando list block `lsblk`, que nos mostrará las particiones, y filtrar por LVM con `grep`. La salida la llevamos a `/dev/null`, que es un archivo especial que descarta sin mostrar las salidas de un comando. Ahora podemos mostrar 'yes' si hay coincidencia o 'no' si no la hay.

- El número de conexiones activas.
      Esta información la podemos obtener de `netstat`. Para ello debemos haber instalado previamente net-tools con `sudo apt install net-tools`. Con `-nt` podemos mostrar en formato numérico (**-n**) las conexiones TCP (**-t**).

- El número de usuarios del servidor.
      Esto lo podemos ver con `users` y contando el número de palabras de la salida, con `wc -w` (word count, words).

- La dirección IPv4 de tu servidor y su MAC (Media Access Control)
      La ip la hemos sacado antes con `hostname -I`. El MAC lo podemos sacar con `ip link` y filtrando con `grep "ether"`.

- El número de comandos ejecutados con sudo.
      Para hacer este recuento, solo necesitamos listar los elementos del archivo `/var/log/sudo/sudo_log` que hemos creado con anterioridad.






