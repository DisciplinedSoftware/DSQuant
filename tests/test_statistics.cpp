#include <array>
#include <boost/ut.hpp>
#include <dsquant/statistics.hpp>

using namespace boost::ut;
using namespace dsquant;

suite<"Statistics Suite"> statistics_suite = [] {
    "mean calculation"_test = [] {
        std::array<double, 5> data = {1.0, 2.0, 3.0, 4.0, 5.0};
        const double result = mean(data.data(), data.data() + data.size());
        expect(that % result == 3.0) << "mean of 1,2,3,4,5 should be 3.0";
    };

    "mean of empty range"_test = [] {
        std::array<double, 0> data = {};
        const double result = mean(data.data(), data.data() + data.size());
        expect(that % result == 0.0) << "mean of empty range should be 0.0";
    };

    "variance calculation"_test = [] {
        std::array<double, 5> data = {1.0, 2.0, 3.0, 4.0, 5.0};
        const double result = variance(data.data(), data.data() + data.size());
        // Sample variance of {1,2,3,4,5} is 2.5
        expect(that % std::abs(result - 2.5) < 0.0001) << "variance should be approximately 2.5";
    };

    "standard deviation calculation"_test = [] {
        std::array<double, 5> data = {1.0, 2.0, 3.0, 4.0, 5.0};
        const double result = standard_deviation(data.data(), data.data() + data.size());
        // Standard deviation of {1,2,3,4,5} is sqrt(2.5) ≈ 1.5811
        expect(that % std::abs(result - 1.5811) < 0.001)
            << "standard deviation should be approximately 1.5811";
    };

    "mean with single element"_test = [] {
        std::array<double, 1> data = {42.0};
        const double result = mean(data.data(), data.data() + data.size());
        expect(that % result == 42.0) << "mean of single element should be that element";
    };
};
