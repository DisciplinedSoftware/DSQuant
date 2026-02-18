#include "../fibonacci.hpp"
#include <iostream>
#include <chrono>
#include <iomanip>

const int DEFAULT_ITERATIONS = 1000000;

void benchmark_fibonacci(int n, int iterations = DEFAULT_ITERATIONS) {
    auto start = std::chrono::high_resolution_clock::now();
    
    uint64_t result = 0;
    for (int i = 0; i < iterations; ++i) {
        result = dsquant::fibonacci(n);
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start);
    
    double avg_time_ns = static_cast<double>(duration.count()) / iterations;
    
    std::cout << "fibonacci(" << std::setw(2) << n << ") = " 
              << std::setw(20) << result 
              << " | avg time: " << std::fixed << std::setprecision(2)
              << avg_time_ns << " ns" << std::endl;
}

int main() {
    std::cout << "Fibonacci Benchmark" << std::endl;
    std::cout << "===================" << std::endl;
    std::cout << std::endl;
    
    // Benchmark different values
    benchmark_fibonacci(0);
    benchmark_fibonacci(1);
    benchmark_fibonacci(5);
    benchmark_fibonacci(10);
    benchmark_fibonacci(20);
    benchmark_fibonacci(30);
    benchmark_fibonacci(40);
    benchmark_fibonacci(50);
    
    std::cout << std::endl;
    std::cout << "Benchmark complete!" << std::endl;
    
    return 0;
}
