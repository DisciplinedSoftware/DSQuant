#pragma once

#include <cmath>
#include <concepts>
#include <cstddef>

namespace dsquant {

/// @brief Calculate the mean of a range of values
/// @tparam T Value type (must be arithmetic)
/// @param begin Start iterator
/// @param end End iterator
/// @return The arithmetic mean
template<std::floating_point T>
constexpr T mean(const T* begin, const T* end) noexcept {
    if (begin == end) return T{0};

    T sum = T{0};
    std::size_t count = 0;

    for (auto it = begin; it != end; ++it) {
        sum += *it;
        ++count;
    }

    return sum / static_cast<T>(count);
}

/// @brief Calculate the variance of a range of values
/// @tparam T Value type (must be floating point)
/// @param begin Start iterator
/// @param end End iterator
/// @return The sample variance
/// @note Uses two-pass algorithm for better performance
template<std::floating_point T>
constexpr T variance(const T* begin, const T* end) noexcept {
    if (begin == end) return T{0};

    // First pass: calculate mean
    const T avg = mean(begin, end);

    // Second pass: calculate sum of squared differences
    T sum_sq_diff = T{0};
    std::size_t count = 0;

    for (auto it = begin; it != end; ++it) {
        const T diff = *it - avg;
        sum_sq_diff += diff * diff;
        ++count;
    }

    return count > 1 ? sum_sq_diff / static_cast<T>(count - 1) : T{0};
}

/// @brief Calculate the standard deviation of a range of values
/// @tparam T Value type (must be floating point)
/// @param begin Start iterator
/// @param end End iterator
/// @return The sample standard deviation
template<std::floating_point T>
constexpr T standard_deviation(const T* begin, const T* end) noexcept {
    return std::sqrt(variance(begin, end));
}

void foo();

} // namespace dsquant
