#include "Hospital.h"

#include <exception>
#include <iostream>
#include <limits>
#include <string>

namespace {
int leerEntero(const std::string& mensaje, int minimo, int maximo) {
    int valor{};
    while (true) {
        std::cout << mensaje;
        if (std::cin >> valor && valor >= minimo && valor <= maximo) {
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            return valor;
        }

        std::cout << "Entrada invalida. Intente nuevamente.\n";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
}

std::string leerLinea(const std::string& mensaje) {
    std::string valor;
    std::cout << mensaje;
    std::getline(std::cin, valor);
    return valor;
}

void registrarPaciente(Hospital& hospital) {
    Paciente p;
    p.nombre = leerLinea("Nombre: ");
    p.dni = leerLinea("DNI: ");
    p.edad = leerEntero("Edad: ", 0, 130);
    p.gravedad = leerEntero("Gravedad (1=Critico, 2=Urgente, 3=Moderado, 4=Leve): ", 1, 4);
    p.sintomas = leerLinea("Sintomas: ");

    hospital.registrarPaciente(p);
}

void buscarHistorial(const Hospital& hospital) {
    const std::string dni = leerLinea("DNI a buscar: ");
    hospital.mostrarHistorial(dni);
}

void menu() {
    std::cout << "\n=== SISTEMA HOSPITALARIO ADA ===\n"
              << "1. Registrar nuevo paciente\n"
              << "2. Ver cola de prioridad\n"
              << "3. Atender siguiente paciente\n"
              << "4. Asignar medico automaticamente\n"
              << "5. Buscar paciente / historial\n"
              << "6. Ordenar lista de pacientes\n"
              << "7. Ver estadisticas\n"
              << "8. Benchmark de algoritmos\n"
              << "9. Cargar datos de demostracion\n"
              << "0. Salir\n"
              << "================================\n";
}
}

int main() {
    Hospital hospital;
    hospital.registrarMedico("Dra. Ana Torres");
    hospital.registrarMedico("Dr. Luis Rojas");
    hospital.registrarMedico("Dra. Maria Perez");

    bool activo = true;
    while (activo) {
        menu();
        const int opcion = leerEntero("Seleccione una opcion: ", 0, 9);

        try {
            switch (opcion) {
                case 1:
                    registrarPaciente(hospital);
                    break;
                case 2:
                    hospital.mostrarColaPrioridad();
                    break;
                case 3:
                    hospital.atenderSiguientePaciente();
                    break;
                case 4:
                    hospital.asignarSiguientePaciente();
                    break;
                case 5:
                    buscarHistorial(hospital);
                    break;
                case 6:
                    hospital.mostrarPacientesOrdenados();
                    break;
                case 7:
                    hospital.mostrarEstadisticas();
                    break;
                case 8:
                    hospital.ejecutarBenchmark();
                    break;
                case 9:
                    hospital.cargarDatosDemo();
                    break;
                case 0:
                    activo = false;
                    break;
            }
        } catch (const std::exception& ex) {
            std::cout << "Error: " << ex.what() << '\n';
        }
    }

    std::cout << "Sistema finalizado.\n";
    return 0;
}
