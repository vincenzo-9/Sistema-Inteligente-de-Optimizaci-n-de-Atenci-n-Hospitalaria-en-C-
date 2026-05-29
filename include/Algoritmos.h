#ifndef ALGORITMOS_H
#define ALGORITMOS_H

#include "Paciente.h"

#include <vector>

namespace algoritmos {
void quickSort(std::vector<Paciente>& pacientes, int izquierda, int derecha);
void mergeSort(std::vector<Paciente>& pacientes, int izquierda, int derecha);
int busquedaBinariaPorDni(const std::vector<Paciente>& pacientes, const std::string& dni);
void bubbleSort(std::vector<Paciente>& pacientes);
}

#endif
