#ifndef HOSPITAL_H
#define HOSPITAL_H

#include "GestorMedicos.h"
#include "HistorialMedico.h"
#include "Paciente.h"

#include <queue>
#include <vector>

class Hospital {
public:
    void registrarPaciente(Paciente paciente);
    Paciente atenderSiguientePaciente();
    void asignarSiguientePaciente();
    void registrarMedico(const std::string& nombre);

    void mostrarColaPrioridad() const;
    void mostrarHistorial(const std::string& dni) const;
    void mostrarPacientesOrdenados() const;
    void mostrarEstadisticas() const;

    void cargarDatosDemo();
    void ejecutarBenchmark() const;

private:
    std::priority_queue<Paciente> colaPacientes_;
    std::vector<Paciente> pacientesRegistrados_;
    HistorialMedico historial_;
    GestorMedicos medicos_;
};

#endif
