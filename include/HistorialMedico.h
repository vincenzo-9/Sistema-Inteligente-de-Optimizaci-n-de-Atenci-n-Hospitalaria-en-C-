#ifndef HISTORIAL_MEDICO_H
#define HISTORIAL_MEDICO_H

#include "Paciente.h"

#include <string>
#include <unordered_map>
#include <vector>

class HistorialMedico {
public:
    void agregar(const Paciente& paciente);
    std::vector<Paciente> buscar(const std::string& dni) const;
    int totalPacientesConHistorial() const;
    int totalAtenciones() const;

private:
    std::unordered_map<std::string, std::vector<Paciente>> historial_;
};

#endif
