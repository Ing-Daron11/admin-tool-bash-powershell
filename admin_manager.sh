#!/bin/bash

function show_menu() {
    echo -e "
  ____        _           ____           _                 _       _           _         __  __                  
 |  _ \  __ _| |_ __ _   / ___|___ _ __ | |_ ___ _ __     / \   __| |_ __ ___ (_)_ __   |  \/  | ___ _ __  _   _ 
 | | | |/ _\` | __/ _\` | | |   / _ \ '_ \| __/ _ \ '__|   / _ \ / _\` | '_ \` _ \| | '_ \  | |\/| |/ _ \ '_ \| | | |
 | |_| | (_| | || (_| | | |__|  __/ | | | ||  __/ |     / ___ \ (_| | | | | | | | | | | | |  | |  __/ | | | |_| |
 |____/ \__,_|\__\__,_|  \____\___|_| |_|\__\___|_|    /_/   \_\__,_|_| |_| |_|_|_| |_| |_|  |_|\___|_| |_|\__,_|

"

    echo -e "\e[33m1. Mostrar los 5 procesos que más CPU consumen\e[0m"
    echo -e "\e[33m2. Mostrar los discos conectados y su espacio disponible\e[0m"
    echo -e "\e[33m3. Mostrar el archivo más grande de un directorio especificado\e[0m"
    echo -e "\e[33m4. Mostrar memoria libre y uso de swap\e[0m"
    echo -e "\e[33m5. Mostrar número de conexiones de red activas (ESTABLISHED)\e[0m"
    echo -e "\e[32m0. Salir\e[0m"
    echo -e "\e[32mclear -> Limpiar la pantalla\e[0m"
}

while true; do
    show_menu
    echo -n "Seleccione una opción: "
    read opcion

    case "$opcion" in
        "1")
            echo -e "\nProcesos que más CPU consumen:"
            ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
            ;;
        "2")
            echo -e "\nDiscos conectados y su espacio disponible:"
            df -h --output=source,size,avail | grep -E "^/dev"
            ;;
        "3")
            read -p $'\nIngrese el path completo del directorio: ' ruta
            if [ -d "$ruta" ]; then
                echo -e "\nArchivo más grande en '$ruta':"
                find "$ruta" -type f -exec du -b {} + 2>/dev/null | sort -nr | head -n 1 | awk '{ printf "Tamaño: %.2f MB\nRuta: %s\n", $1/1024/1024, $2 }'
            else
                echo "Ruta inválida. Intente de nuevo."
            fi
            ;;
        "4")
            echo -e "\nInformación de memoria y swap:"
            mem_free=$(free -b | awk '/Mem:/ {print $4}')
            swap_used=$(free -b | awk '/Swap:/ {print $3}')
            swap_total=$(free -b | awk '/Swap:/ {print $2}')
            if [ "$swap_total" -ne 0 ]; then
                porcentaje_swap=$(( 100 * swap_used / swap_total ))
            else
                porcentaje_swap=0
            fi
            echo "Memoria libre: $mem_free bytes"
            echo "Swap usado: $swap_used bytes"
            echo "Porcentaje de swap usado: $porcentaje_swap%"
            ;;
        "5")
            echo -e "\nConexiones de red activas (ESTABLISHED):"
            conexiones=$(ss -tan state established | grep -v "Recv-Q" | wc -l)
            echo "Número de conexiones ESTABLISHED: $conexiones"
            ;;
        "0")
            echo -e "\nSaliendo... ( ^_^)~"
            break
            ;;
        "clear")
            clear
            ;;
        *)
            echo "Opción inválida. Intente de nuevo."
            ;;
    esac

    echo -e "\n==========================================\n"
done
