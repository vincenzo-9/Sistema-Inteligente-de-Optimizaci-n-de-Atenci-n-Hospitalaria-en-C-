#include "HistorialMedico.h"

void HistorialMedico::agregar(const Paciente& paciente) {
    historial_[paciente.dni].push_back(paciente);
}

std::vector<Paciente> HistorialMedico::buscar(const std::string& dni) const {
    const auto it = historial_.find(dni);
    if (it == historial_.end()) {
        return {};
    }
    return it->second;
}

int HistorialMedico::totalPacientesConHistorial() const {
    return static_cast<int>(historial_.size());
}

int HistorialMedico::totalAtenciones() const {
    int total = 0;
    for (const auto& [_, atenciones] : historial_) {
        total += static_cast<int>(atenciones.size());
    }
    return total;
}
