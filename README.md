# Guía de Born2Beroot
## Basada en la hoja de evaluación

En esta guía se proporcionarán los pasos para la configuración de la máquina virtual exigida en el Subject del proyecto. No obstante, para seguir estos pasos, seguiremos la hoja de la evaluación en lugar del subject, ya que esta cubre más y podemos ver de un modo preciso cómo hacer las demostraciones.

Durante toda la evaluación, se recuerda al evaluador que el estudiante evaluado tiene que ser capaz de ayudarle en todo momento. Es decir, entiende lo que haces.

## Configuración inicial
- Antes de intentar conectarse a la máquina, se pedirá una contraseña. Esta es la de la encriptación del disco sda5.

<span style="background-color: black; color: white; font-family: 'Courier New', monospace;">Please, unlock disk sda5_crypt:</span>

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
  >
Con este comando, nos saldrá algo similar a 

