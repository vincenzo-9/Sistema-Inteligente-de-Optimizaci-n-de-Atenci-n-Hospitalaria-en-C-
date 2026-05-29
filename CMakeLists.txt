cmake_minimum_required(VERSION 3.16)
project(SistemaHospitalarioADA LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(hospital
    main.cpp
    src/Algoritmos.cpp
    src/Benchmark.cpp
    src/GestorMedicos.cpp
    src/HistorialMedico.cpp
    src/Hospital.cpp
)

target_include_directories(hospital PRIVATE include)

if (MSVC)
    target_compile_options(hospital PRIVATE /W4)
else()
    target_compile_options(hospital PRIVATE -Wall -Wextra -pedantic)
endif()
