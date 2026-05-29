#include "Algoritmos.h"

#include <algorithm>

namespace algoritmos {
namespace {
bool prioridadPaciente(const Paciente& a, const Paciente& b) {
    if (a.gravedad != b.gravedad) {
        return a.gravedad < b.gravedad;
    }
    return a.timestamp < b.timestamp;
}

int particion(std::vector<Paciente>& pacientes, int izquierda, int derecha) {
    const Paciente pivote = pacientes[derecha];
    int i = izquierda - 1;

    for (int j = izquierda; j < derecha; ++j) {
        if (prioridadPaciente(pacientes[j], pivote)) {
            ++i;
            std::swap(pacientes[i], pacientes[j]);
        }
    }

    std::swap(pacientes[i + 1], pacientes[derecha]);
    return i + 1;
}

void fusionar(std::vector<Paciente>& pacientes, int izquierda, int medio, int derecha) {
    const std::vector<Paciente> izq(pacientes.begin() + izquierda, pacientes.begin() + medio + 1);
    const std::vector<Paciente> der(pacientes.begin() + medio + 1, pacientes.begin() + derecha + 1);
    int i = 0;
    int j = 0;
    int k = izquierda;

    while (i < static_cast<int>(izq.size()) && j < static_cast<int>(der.size())) {
        pacientes[k++] = prioridadPaciente(der[j], izq[i]) ? der[j++] : izq[i++];
    }

    while (i < static_cast<int>(izq.size())) {
        pacientes[k++] = izq[i++];
    }

    while (j < static_cast<int>(der.size())) {
        pacientes[k++] = der[j++];
    }
}
}

void quickSort(std::vector<Paciente>& pacientes, int izquierda, int derecha) {
    if (izquierda < derecha) {
        const int pivote = particion(pacientes, izquierda, derecha);
        quickSort(pacientes, izquierda, pivote - 1);
        quickSort(pacientes, pivote + 1, derecha);
    }
}

void mergeSort(std::vector<Paciente>& pacientes, int izquierda, int derecha) {
    if (izquierda < derecha) {
        const int medio = izquierda + (derecha - izquierda) / 2;
        mergeSort(pacientes, izquierda, medio);
        mergeSort(pacientes, medio + 1, derecha);
        fusionar(pacientes, izquierda, medio, derecha);
    }
}

int busquedaBinariaPorDni(const std::vector<Paciente>& pacientes, const std::string& dni) {
    int izquierda = 0;
    int derecha = static_cast<int>(pacientes.size()) - 1;

    while (izquierda <= derecha) {
        const int medio = izquierda + (derecha - izquierda) / 2;
        if (pacientes[medio].dni == dni) {
            return medio;
        }
        if (pacientes[medio].dni < dni) {
            izquierda = medio + 1;
        } else {
            derecha = medio - 1;
        }
    }

    return -1;
}

void bubbleSort(std::vector<Paciente>& pacientes) {
    for (std::size_t i = 0; i < pacientes.size(); ++i) {
        for (std::size_t j = 0; j + 1 < pacientes.size() - i; ++j) {
            if (prioridadPaciente(pacientes[j + 1], pacientes[j])) {
                std::swap(pacientes[j], pacientes[j + 1]);
            }
        }
    }
}
}
