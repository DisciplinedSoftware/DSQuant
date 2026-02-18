#ifndef DSQUANT_FIBONACCI_HPP
#define DSQUANT_FIBONACCI_HPP

#include <cstdint>

namespace dsquant {

/**
 * @brief Calculate the nth Fibonacci number
 * @param n The position in the Fibonacci sequence (0-indexed)
 * @return The nth Fibonacci number
 * @note n must be non-negative. For n >= 94, overflow may occur as results exceed uint64_t max.
 */
uint64_t fibonacci(unsigned int n);

} // namespace dsquant

#endif // DSQUANT_FIBONACCI_HPP
