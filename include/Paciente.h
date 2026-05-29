#ifndef PACIENTE_H
#define PACIENTE_H

#include <chrono>
#include <iostream>
#include <string>

struct Paciente {
    std::string nombre;
    std::string dni;
    int edad = 0;
    int gravedad = 4;
    std::string sintomas;
    long long timestamp = 0;

    bool operator<(const Paciente& otro) const {
        if (gravedad != otro.gravedad) {
            return gravedad > otro.gravedad;
        }
        return timestamp > otro.timestamp;
    }
};

inline long long timestampActual() {
    const auto ahora = std::chrono::system_clock::now().time_since_epoch();
    return std::chrono::duration_cast<std::chrono::milliseconds>(ahora).count();
}

inline std::string nombreGravedad(int gravedad) {
    switch (gravedad) {
        case 1:
            return "Critico";
        case 2:
            return "Urgente";
        case 3:
            return "Moderado";
        case 4:
            return "Leve";
        default:
            return "Desconocido";
    }
}

inline std::ostream& operator<<(std::ostream& os, const Paciente& p) {
    os << "[" << nombreGravedad(p.gravedad) << "] "
       << p.nombre << " | DNI: " << p.dni
       << " | Edad: " << p.edad
       << " | Sintomas: " << p.sintomas;
    return os;
}

#endif
