#include "../fibonacci.hpp"
#include <iostream>
#include <cassert>

int main() {
    std::cout << "Running Fibonacci tests..." << std::endl;
    
    // Test base cases
    assert(dsquant::fibonacci(0) == 0);
    std::cout << "✓ fibonacci(0) = 0" << std::endl;
    
    assert(dsquant::fibonacci(1) == 1);
    std::cout << "✓ fibonacci(1) = 1" << std::endl;
    
    // Test small values
    assert(dsquant::fibonacci(2) == 1);
    std::cout << "✓ fibonacci(2) = 1" << std::endl;
    
    assert(dsquant::fibonacci(3) == 2);
    std::cout << "✓ fibonacci(3) = 2" << std::endl;
    
    assert(dsquant::fibonacci(4) == 3);
    std::cout << "✓ fibonacci(4) = 3" << std::endl;
    
    assert(dsquant::fibonacci(5) == 5);
    std::cout << "✓ fibonacci(5) = 5" << std::endl;
    
    assert(dsquant::fibonacci(6) == 8);
    std::cout << "✓ fibonacci(6) = 8" << std::endl;
    
    // Test larger values
    assert(dsquant::fibonacci(10) == 55);
    std::cout << "✓ fibonacci(10) = 55" << std::endl;
    
    assert(dsquant::fibonacci(20) == 6765);
    std::cout << "✓ fibonacci(20) = 6765" << std::endl;
    
    std::cout << std::endl << "All tests passed!" << std::endl;
    
    return 0;
}
