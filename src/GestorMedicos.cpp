#include "GestorMedicos.h"

#include <climits>
#include <iostream>
#include <stdexcept>

void GestorMedicos::registrarMedico(const std::string& nombre) {
    cargaMedicos_.try_emplace(nombre, 0);
}

std::string GestorMedicos::asignarMedico(const Paciente& paciente) {
    if (cargaMedicos_.empty()) {
        throw std::runtime_error("No hay medicos registrados");
    }

    std::string elegido;
    int menorCarga = INT_MAX;
    for (const auto& [medico, carga] : cargaMedicos_) {
        if (carga < menorCarga) {
            menorCarga = carga;
            elegido = medico;
        }
    }

    ++cargaMedicos_[elegido];
    std::cout << "Paciente " << paciente.nombre << " asignado a " << elegido << ".\n";
    return elegido;
}

void GestorMedicos::mostrarCarga() const {
    std::cout << "\n=== Carga de medicos ===\n";
    for (const auto& [medico, carga] : cargaMedicos_) {
        std::cout << medico << ": " << carga << " paciente(s)\n";
    }
}

bool GestorMedicos::hayMedicos() const {
    return !cargaMedicos_.empty();
}

int GestorMedicos::totalMedicos() const {
    return static_cast<int>(cargaMedicos_.size());
}
