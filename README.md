# Guía de Born2Beroot
## Basada en la hoja de evaluación

En esta guía se proporcionarán los pasos para la configuración de la máquina virtual exigida en el Subject del proyecto. No obstante, para seguir estos pasos, seguiremos la hoja de la evaluación en lugar del subject, ya que esta cubre más y podemos ver de un modo preciso cómo hacer las demostraciones.

Durante toda la evaluación, se recuerda al evaluador que el estudiante evaluado tiene que ser capaz de ayudarle en todo momento. Es decir, entiende lo que haces.

## Configuración inicial
- Antes de intentar conectarse a la máquina, se pedirá una contraseña. Esta es la de la encriptación del disco sda5.
  
![image](https://github.com/user-attachments/assets/ad4ffdf2-9fda-453b-978a-bb3918f8acae)

- Asegúrate de que la máquina no tiene un entorno gráfico al iniciarla.
    Esto se puede ver escribiendo el comando
  
  > ```bash
  > echo $DISPLAY
  > ```
  y saldrá un salto de línea, si no hay entorno gráfico. Esto podemos compararlo con la terminal usual de nuestro sistema, que mostrará :0 en su lugar. 

**Ejemplo de máquina sin entorno gráfico:**

> ~% echo $DISPLAY  
>   
> ~%  

**Ejemplo de máquina con entorno gráfico:**

> ~% echo $DISPLAY  
> :0  
> ~%  

- Comprueba que el servicio UFW está iniciado:

Para comprobar esto, tenemos varias formas de hacerlo:

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

Para esto, podemos hacerlo de forma similar al UFW:

> ```bash
> sudo service ssh status
> ```

> ```bash
> sudo systemctl ssh status
> ```

- Comprueba que el sistema operativo es Debian o Rocky. En este caso, demostraremos que es Debian, viendo la cabecera del archivo /etc/os-release
 > ```bash
 > head -n 2 /etc/os-release
 > ```
Con este comando, nos saldrá algo similar a 

> PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"  
> NAME="Debian GNU/Linux"

## Usuario
- El subject solicita que un usuario con el login del estudiante evaluado esté presente en la máquina virtual. Comprueba que existe y que pertenece a los grupos "sudo" y "user42".
- El evaluador deberá crear un usuario y el estudiante evaluado, un grupo llamado "evaluating", en el cual meterá al usuario recién creado.

  Para crear un usuario ejecutaremos el comando `sudo adduser user_name`. De forma paralela, para crear un grupo, ejecutaremos `sudo addgroup group_name`. Para añadir el usuario creado al grupo elegido, escribiremos el comando `sudo adduser user_name group_name`.
  Veamos un ejemplo simplificado con mi login:

> ~% sudo adduser juanherr  
> [sudo] contraseña para user:  
> Añadiendo el usuario 'juanherr' ...  
> ~%   

> ~% sudo addgroup evaluating  
> Añadiendo el grupo 'evaluating' ...   
> Hecho.  
> ~% sudo adduser juanherr evaluating  
> Añadiendo al usuario 'juanherr' al grupo 'evaluating' ...  
> Hecho.   
> ~%

Ahora tenemos el nuevo user "juanherr" dentro del grupo "evaluating". Para demostrar esto, podemos hacer dos cosas: ver los usuarios que están dentro de un grupo, con el comando `getent group group_name` o viendo los grupos a los que pertenece el usuario, con el comando `groups user_name`.

> ~% getent group evaluating    
> evaluating:x:juanherr    
> ~%   

> ~% groups juanherr  
> juanherr : users evaluating   
> ~%   

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

Ahora configuraremos el resto de reglas. En este caso, con nano también, editaremos el archivo `/etc/security/pwquality.conf`. 

`difok` lo cambiaremos en otro lugar, ya que NO SE APLICA A ROOT. Es el número de caracteres que no son parte de la antigua contraseña.
`minlen` es la longitud mínima de la contraseña. Lo establecemos en 10 caracteres.
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

