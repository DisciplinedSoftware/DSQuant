#include "fibonacci.hpp"

namespace dsquant {

uint64_t fibonacci(int n) {
    if (n <= 1) {
        return n;
    }
    
    uint64_t a = 0, b = 1;
    for (int i = 2; i <= n; ++i) {
        uint64_t temp = a + b;
        a = b;
        b = temp;
    }
    
    return b;
}

} // namespace dsquant
