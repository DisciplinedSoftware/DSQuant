#include <nanobench.h>

#include <dsquant/statistics.hpp>
#include <random>
#include <vector>

int main() {
    using namespace dsquant;

    // Create benchmark data
    std::vector<double> small_data(100);
    std::vector<double> medium_data(1000);
    std::vector<double> large_data(10000);

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 100.0);

    for (auto& v : small_data)
        v = dis(gen);
    for (auto& v : medium_data)
        v = dis(gen);
    for (auto& v : large_data)
        v = dis(gen);

    // Benchmark mean calculation
    ankerl::nanobench::Bench().run("mean (100 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            mean(small_data.data(), small_data.data() + small_data.size()));
    });

    ankerl::nanobench::Bench().run("mean (1000 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            mean(medium_data.data(), medium_data.data() + medium_data.size()));
    });

    ankerl::nanobench::Bench().run("mean (10000 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            mean(large_data.data(), large_data.data() + large_data.size()));
    });

    // Benchmark variance calculation
    ankerl::nanobench::Bench().run("variance (100 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            variance(small_data.data(), small_data.data() + small_data.size()));
    });

    ankerl::nanobench::Bench().run("variance (1000 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            variance(medium_data.data(), medium_data.data() + medium_data.size()));
    });

    ankerl::nanobench::Bench().run("variance (10000 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            variance(large_data.data(), large_data.data() + large_data.size()));
    });

    // Benchmark standard deviation calculation
    ankerl::nanobench::Bench().run("standard_deviation (100 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            standard_deviation(small_data.data(), small_data.data() + small_data.size()));
    });

    ankerl::nanobench::Bench().run("standard_deviation (1000 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            standard_deviation(medium_data.data(), medium_data.data() + medium_data.size()));
    });

    ankerl::nanobench::Bench().run("standard_deviation (10000 elements)", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            standard_deviation(large_data.data(), large_data.data() + large_data.size()));
    });

    return 0;
}
