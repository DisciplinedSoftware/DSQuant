#ifndef DSQUANT_FIBONACCI_HPP
#define DSQUANT_FIBONACCI_HPP

#include <cstdint>

namespace dsquant {

/**
 * @brief Calculate the nth Fibonacci number
 * @param n The position in the Fibonacci sequence (0-indexed)
 * @return The nth Fibonacci number
 * @note n must be non-negative
 */
uint64_t fibonacci(unsigned int n);

} // namespace dsquant

#endif // DSQUANT_FIBONACCI_HPP
