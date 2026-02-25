#include <array>
#include <dsquant/statistics.hpp>
#include <iomanip>
#include <iostream>

int main() {
    using namespace dsquant;

    std::cout << "DSQuant - Basic Statistics Example\n";
    std::cout << "===================================\n\n";

    // Sample data: daily returns
    std::array<double, 10> returns = {0.012, -0.008, 0.015, 0.003, -0.002, 0.010, 0.007, -0.005, 0.011, 0.004};

    std::cout << "Sample data (daily returns):\n";
    for (size_t i = 0; i < returns.size(); ++i) {
        std::cout << "  Day " << (i + 1) << ": " << std::fixed << std::setprecision(4) << returns[i] << "\n";
    }

    double const avg = mean(returns.data(), returns.data() + returns.size());
    double const var = variance(returns.data(), returns.data() + returns.size());
    double const stddev = standard_deviation(returns.data(), returns.data() + returns.size());

    std::cout << "\nStatistical measures:\n";
    std::cout << "  Mean:               " << std::fixed << std::setprecision(6) << avg << "\n";
    std::cout << "  Variance:           " << std::fixed << std::setprecision(8) << var << "\n";
    std::cout << "  Standard Deviation: " << std::fixed << std::setprecision(6) << stddev << "\n";

    // Annualized statistics (assuming 252 trading days)
    double const annualized_return = avg * 252;
    double const annualized_volatility = stddev * std::sqrt(252.0);

    std::cout << "\nAnnualized statistics (252 trading days):\n";
    std::cout << "  Expected Return:    " << std::fixed << std::setprecision(2) << (annualized_return * 100) << "%\n";
    std::cout << "  Volatility:         " << std::fixed << std::setprecision(2) << (annualized_volatility * 100)
              << "%\n";

    // TODO: To remove once there is at least one linker dependency is included on the library. This
    // is just to ensure that the library is linked correctly.
    dsquant::foo();  // Call the function defined in statistics.cpp to ensure it's linked correctly

    return 0;
}
