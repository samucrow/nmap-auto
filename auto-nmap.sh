#!/bin/bash

# Función de NMAP
function escaneo() {

    archivo_target=~/.config/polybar/shapes/scripts/target
    archivo_resultado="escaneo_nmap"  # Archivo de salida del escaneo
    cancelado=0 # Variable para controlar si se ha cancelado el escaneo

    # Configuramos el trap para capturar la señal de interrupción (Ctrl+C) y eliminar el archivo resultante
    trap "echo -e '\e[1;31m Escaneo cancelado. Eliminando archivo de resultados... \e[0m'; rm -f $archivo_resultado; cancelado=1" SIGINT

    # Verificamos si el archivo tiene contenido
    if [ $(wc -w < "$archivo_target") -gt 0 ]; then

        # Ahora leeremos el archivo para encontrar una IP válida.
        busqueda_ip=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$archivo_target" | head -n 1)

        # Comprobamos si se encontró una IP válida
        if [ -z "$busqueda_ip" ]; then
            echo -e "\e[1;31m No se encontró ninguna IP válida en el archivo. Asegúrate de agregar una IP con el comando 'settarget'. \e[0m"
            return 1  # Salir si no se encontró IP
        fi

        # Realizamos el escaneo con la IP encontrada
        nmap -p- --open -sCV -sS -n -Pn -vvv $busqueda_ip -oN $archivo_resultado 2>/dev/null

	# Comprobamos si se ha cancelado el escaneo
	if [ $cancelado -eq 1 ]; then
	   return 1  # Salir si se ha cancelado el escaneo
	fi

        # Comprobamos si hubo un error en el escaneo
         if [ $? -ne 0 ]; then
            echo -e "\e[1;31m Hubo un problema al realizar el escaneo, prueba a poner una IP válida en el target con el comando 'settarget'. Y ACUÉRDATE QUE DEBES SER ROOT PARA ESCANEAR! \e[0m"
            rm -f $archivo_resultado  # Eliminar el archivo de resultado del escaneo si falló
            return 1  # Salir si el escaneo falló
        fi

        # Comprobamos si el escaneo encontró algún puerto abierto (o IP activa)
        if ! grep -q "open" $archivo_resultado; then
            echo -e "\e[1;33m El escaneo no encontró ninguna IP activa o puertos abiertos en el objetivo. \e[0m"
            rm -f $archivo_resultado  # Eliminar el archivo si no hay resultados útiles
            return 1  # Salir si no se encontraron puertos abiertos
        fi

        echo -e "\e[1;32m Escaneo completado exitosamente. \e[0m"

    else
        # Si el archivo está vacío o no tiene palabras, mostramos un mensaje de error
        echo -e "\e[1;34m No has añadido ningún objetivo!! Dime cuál es la IP a la que debo hacer el escaneo con el comando 'settarget' :) \e[0m"
        return 1  # Salir si no se encontró contenido en el archivo
    fi
}
