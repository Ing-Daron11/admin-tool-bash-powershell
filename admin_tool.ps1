function Show-Menu {
    Write-Host "
  ____        _           ____           _                 _       _           _         __  __                  
 |  _ \  __ _| |_ __ _   / ___|___ _ __ | |_ ___ _ __     / \   __| |_ __ ___ (_)_ __   |  \/  | ___ _ __  _   _ 
 | | | |/ _` | __/ _` | | |     / _ \ '_ \| __/ _ \ '__|   / _ \ / _` | '_ ` _ \| | '_ \  | |\/| |/ _ \ '_ \| | | |
 | |_| | (_| | || (_| | | |__|  __/ | | | ||  __/ |     / ___ \ (_| | | | | | | | | | | |  | |  | |  __/ | | | |_| |
 |____/ \__,_|\__\__,_|  \____\___|_| |_|\__\___|_|    /_/   \_\__,_|_| |_| |_|_|_| |_| |_|  |_|\___|_| |_|\__,_|
    " -ForegroundColor cyan

    Write-Host "1. Mostrar los 5 procesos que mas CPU consumen" -ForegroundColor Yellow
    Write-Host "2. Mostrar los discos conectados y su espacio disponible" -ForegroundColor Yellow
    Write-Host "3. Mostrar el archivo mas grande de un directorio especificado" -ForegroundColor Yellow
    Write-Host "4. Mostrar memoria libre y uso de swap" -ForegroundColor Yellow
    Write-Host "5. Mostrar numero de conexiones de red activas (ESTABLISHED)" -ForegroundColor Yellow
    Write-Host "0. Salir" -ForegroundColor Green
    Write-Host "cls -> Limpiar la pantalla" -ForegroundColor Green
}

do {
    Show-Menu
    $opcion = Read-Host "Seleccione una opcion"

    if ([string]::IsNullOrWhiteSpace($opcion)) {
        Write-Host "No ingresaste ninguna opcion. Intenta de nuevo."
        continue
    }

    switch ($opcion) {
        "1" {
            Write-Host "`nProcesos que mas CPU consumen:"
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -Property Id, ProcessName, CPU
        }
        "2" {
            Write-Host "`nDiscos conectados y su espacio:"
            Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="Tamaño (GB)";Expression={[math]::Round(($_.Used + $_.Free) / 1GB, 2)}}, @{Name="Libre (GB)";Expression={[math]::Round($_.Free / 1GB, 2)}} | Format-Table
        }
        "3" {
            $ruta = Read-Host "`nIngrese el path completo del directorio"

            if ([string]::IsNullOrWhiteSpace($ruta)) {
                Write-Host "No ingresaste una ruta. Intenta de nuevo."
                continue
            }

            if (Test-Path $ruta) {
                $archivo = Get-ChildItem -Path $ruta -Recurse -File -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 1
                if ($archivo) {
                    Write-Host "`nArchivo mas grande encontrado:"
                    Write-Host "Ruta: $($archivo.FullName)"
                    Write-Host "Tamano: $([math]::Round($archivo.Length / 1MB, 2)) MB"
                } else {
                    Write-Host "No se encontraron archivos en ese directorio."
                }
            } else {
                Write-Host "Ruta invalida. Intente de nuevo."
            }
        }
        "4" {
            Write-Host "`nInformacion de memoria y swap:"
            $memInfo = Get-CimInstance Win32_OperatingSystem
            $memLibre = [math]::Round($memInfo.FreePhysicalMemory * 1KB, 2)
            $swapUsado = [math]::Round(($memInfo.TotalVirtualMemorySize - $memInfo.FreeVirtualMemory) * 1KB, 2)
            $swapTotal = [math]::Round($memInfo.TotalVirtualMemorySize * 1KB, 2)
            $porcentajeSwap = [math]::Round(($swapUsado / $swapTotal) * 100, 2)

            Write-Host "Memoria fisica libre: $memLibre bytes"
            Write-Host "Swap usado: $swapUsado bytes"
            Write-Host "Porcentaje de swap usado: $porcentajeSwap%"
        }
        "5" {
            Write-Host "`nConexiones de red activas (ESTABLISHED):"
            $conexiones = Get-NetTCPConnection -State Established
            $total = $conexiones.Count
            Write-Host "`nNúmero de conexiones de red activas (ESTABLISHED): $total`n"

            if ($total -gt 0) {
                $conexiones | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State |
                    Format-Table -AutoSize
            } else {
                Write-Host "No hay conexiones en estado ESTABLISHED."
            }
        }
        "0" {
            Write-Host "Saliendo.... ( ^_^)~" -ForegroundColor cyan
        }
        "cls" {
            Clear-Host
        }
        default {
            Write-Host "Opcion invalida. Intente de nuevo."
        }
    }

    if ($opcion -ne "0" -and $opcion -ne "cls") {
        Write-Host "=========================================="
    }

} while ($opcion -ne "0")
