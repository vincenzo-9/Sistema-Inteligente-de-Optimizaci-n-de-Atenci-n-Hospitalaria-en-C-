#ifndef GESTOR_MEDICOS_H
#define GESTOR_MEDICOS_H

#include "Paciente.h"

#include <map>
#include <string>
#include <vector>

struct Asignacion {
    Paciente paciente;
    std::string medico;
};

class GestorMedicos {
public:
    void registrarMedico(const std::string& nombre);
    std::string asignarMedico(const Paciente& paciente);
    void mostrarCarga() const;
    bool hayMedicos() const;
    int totalMedicos() const;

private:
    std::map<std::string, int> cargaMedicos_;
};

#endif
