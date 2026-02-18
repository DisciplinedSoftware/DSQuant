#ifndef DSQUANT_FIBONACCI_HPP
#define DSQUANT_FIBONACCI_HPP

#include <cstdint>

namespace dsquant {

/**
 * @brief Calculate the nth Fibonacci number
 * @param n The position in the Fibonacci sequence (0-indexed)
 * @return The nth Fibonacci number
 */
uint64_t fibonacci(int n);

} // namespace dsquant

#endif // DSQUANT_FIBONACCI_HPP
