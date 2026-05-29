#include "Benchmark.h"

#include "Algoritmos.h"

#include <chrono>
#include <iostream>
#include <queue>
#include <random>
#include <vector>

namespace benchmark {
namespace {
std::vector<Paciente> generarPacientes(int n) {
    std::vector<Paciente> pacientes;
    pacientes.reserve(n);

    std::mt19937 rng(42);
    std::uniform_int_distribution<int> gravedad(1, 4);
    const long long base = timestampActual();

    for (int i = 0; i < n; ++i) {
        pacientes.push_back({
            "Paciente " + std::to_string(i + 1),
            "DNI" + std::to_string(10000000 + i),
            20 + (i % 60),
            gravedad(rng),
            "Sintoma simulado",
            base + i
        });
    }

    return pacientes;
}

template <typename Funcion>
long long medirMilisegundos(Funcion funcion) {
    const auto inicio = std::chrono::high_resolution_clock::now();
    funcion();
    const auto fin = std::chrono::high_resolution_clock::now();
    return std::chrono::duration_cast<std::chrono::milliseconds>(fin - inicio).count();
}
}

void ejecutar() {
    const std::vector<int> tamanios = {100, 1000, 5000, 10000};

    std::cout << "\n=== Benchmark de algoritmos ===\n"
              << "N\tQuickSort(ms)\tMergeSort(ms)\tPriorityQueue push(ms)\n";

    for (int n : tamanios) {
        auto q = generarPacientes(n);
        auto m = q;
        auto p = q;

        const long long tQuick = medirMilisegundos([&]() {
            algoritmos::quickSort(q, 0, static_cast<int>(q.size()) - 1);
        });

        const long long tMerge = medirMilisegundos([&]() {
            algoritmos::mergeSort(m, 0, static_cast<int>(m.size()) - 1);
        });

        const long long tCola = medirMilisegundos([&]() {
            std::priority_queue<Paciente> cola;
            for (const Paciente& paciente : p) {
                cola.push(paciente);
            }
        });

        std::cout << n << '\t' << tQuick << "\t\t" << tMerge
                  << "\t\t" << tCola << '\n';
    }
}
}
