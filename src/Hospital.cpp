#include "Hospital.h"

#include "Algoritmos.h"
#include "Benchmark.h"

#include <algorithm>
#include <iostream>
#include <stdexcept>

void Hospital::registrarPaciente(Paciente paciente) {
    if (paciente.timestamp == 0) {
        paciente.timestamp = timestampActual();
    }

    colaPacientes_.push(paciente);
    pacientesRegistrados_.push_back(paciente);
    historial_.agregar(paciente);

    std::cout << "Paciente registrado con prioridad "
              << nombreGravedad(paciente.gravedad) << ".\n";
}

Paciente Hospital::atenderSiguientePaciente() {
    if (colaPacientes_.empty()) {
        throw std::runtime_error("No hay pacientes en cola");
    }

    const Paciente siguiente = colaPacientes_.top();
    colaPacientes_.pop();
    std::cout << "Atendiendo: " << siguiente << '\n';
    return siguiente;
}

void Hospital::asignarSiguientePaciente() {
    const Paciente paciente = atenderSiguientePaciente();
    medicos_.asignarMedico(paciente);
}

void Hospital::registrarMedico(const std::string& nombre) {
    medicos_.registrarMedico(nombre);
}

void Hospital::mostrarColaPrioridad() const {
    std::priority_queue<Paciente> copia = colaPacientes_;
    int posicion = 1;

    std::cout << "\n=== Cola de prioridad ===\n";
    if (copia.empty()) {
        std::cout << "No hay pacientes en espera.\n";
        return;
    }

    while (!copia.empty()) {
        std::cout << posicion++ << ". " << copia.top() << '\n';
        copia.pop();
    }
}

void Hospital::mostrarHistorial(const std::string& dni) const {
    const auto registros = historial_.buscar(dni);

    std::cout << "\n=== Historial medico ===\n";
    if (registros.empty()) {
        std::cout << "No se encontraron registros para DNI " << dni << ".\n";
        return;
    }

    for (const Paciente& paciente : registros) {
        std::cout << paciente << '\n';
    }
}

void Hospital::mostrarPacientesOrdenados() const {
    std::vector<Paciente> ordenados = pacientesRegistrados_;

    if (!ordenados.empty()) {
        algoritmos::mergeSort(ordenados, 0, static_cast<int>(ordenados.size()) - 1);
    }

    std::cout << "\n=== Pacientes ordenados por prioridad ===\n";
    for (const Paciente& paciente : ordenados) {
        std::cout << paciente << '\n';
    }
}

void Hospital::mostrarEstadisticas() const {
    std::cout << "\n=== Estadisticas ===\n"
              << "Pacientes registrados: " << pacientesRegistrados_.size() << '\n'
              << "Pacientes en cola: " << colaPacientes_.size() << '\n'
              << "Pacientes con historial: " << historial_.totalPacientesConHistorial() << '\n'
              << "Atenciones guardadas: " << historial_.totalAtenciones() << '\n'
              << "Medicos registrados: " << medicos_.totalMedicos() << '\n';
    medicos_.mostrarCarga();
}

void Hospital::cargarDatosDemo() {
    const long long base = timestampActual();
    const std::vector<Paciente> demo = {
        {"Carlos Mendez", "70000001", 65, 1, "Dolor toracico severo", base + 1},
        {"Lucia Ramos", "70000002", 8, 2, "Fiebre alta persistente", base + 2},
        {"Pedro Salas", "70000003", 34, 4, "Resfrio comun", base + 3},
        {"Ana Villanueva", "70000004", 29, 3, "Dolor abdominal", base + 4},
        {"Rosa Paredes", "70000005", 72, 1, "Dificultad respiratoria", base + 5},
    };

    for (const Paciente& paciente : demo) {
        registrarPaciente(paciente);
    }
}

void Hospital::ejecutarBenchmark() const {
    benchmark::ejecutar();
}
