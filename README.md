![Interfaz grafica del sistema hospitalario](interfaz.png)

# Sistema Hospitalario ADA en C++

Proyecto base para el informe de Analisis y Diseno de Algoritmos. Implementa una cola de prioridad para pacientes, historial medico con hash table, ordenamientos QuickSort/MergeSort, asignacion voraz de medicos y benchmarking simple.

## Estructura

```text
.
├── include/              # Headers del sistema
├── src/                  # Implementacion de modulos
├── docs/                 # Informe y material del proyecto
├── data/                 # Datos de prueba
├── .vscode/              # Configuracion para VS Code
├── main.cpp              # Menu principal
├── Makefile              # Compilacion rapida con g++
└── CMakeLists.txt        # Compilacion con CMake
```

## Requisitos

- C++17 o superior.
- macOS/Linux: `g++`, `clang++` o herramientas de compilacion equivalentes.
- Windows: MinGW-w64, MSYS2 o CMake con un compilador C++.
- La interfaz grafica incluida usa Cocoa, por eso funciona en macOS.

## Ejecutar en macOS

Version consola:

```bash
make
./hospital
```

Interfaz grafica:

```bash
make gui
open build/HospitalGUI.app
```

Tambien puedes compilar y abrir en un solo paso:

```bash
make open-gui
```

## Ejecutar en Linux

Con Make:

```bash
make
./hospital
```

Compilacion manual:

```bash
g++ main.cpp src/*.cpp -Iinclude -o hospital -std=c++17
./hospital
```

Con CMake:

```bash
cmake -S . -B build
cmake --build build
./build/hospital
```

## Ejecutar en Windows

Con MinGW-w64 o MSYS2:

```bash
g++ main.cpp src/*.cpp -Iinclude -o hospital.exe -std=c++17
hospital.exe
```

Si usas PowerShell y estas en la carpeta del proyecto:

```powershell
g++ main.cpp src/*.cpp -Iinclude -o hospital.exe -std=c++17
.\hospital.exe
```

Con CMake:

```powershell
cmake -S . -B build
cmake --build build
.\build\Debug\hospital.exe
```

Si CMake genera el ejecutable en otra carpeta, revisa dentro de `build`.
