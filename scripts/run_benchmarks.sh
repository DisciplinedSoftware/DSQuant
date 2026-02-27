#!/bin/bash
# Benchmark runner script for DSQuant project
# Handles CPU frequency scaling and runs benchmarks

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Building DSQuant in release..."
"$SCRIPT_DIR/build.sh" --release

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    printf "%b\n" "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    printf "%b\n" "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    printf "%b\n" "${RED}[ERROR]${NC} $1" >&2
}

print_section() {
    printf "\n%b\n" "${BLUE}========================================${NC}"
    printf "%b\n" "${BLUE}$1${NC}"
    printf "%b\n\n" "${BLUE}========================================${NC}"
}

# Configuration
BUILD_DIR="${BUILD_DIR:-build}"
BENCHMARK_DIR="$BUILD_DIR/bin"
CPU_GOVERNOR_CHANGED=0
ORIGINAL_GOVERNOR=""
CPU_BOOST_CHANGED=0
ORIGINAL_BOOST=""
CPU_FREQ_LOCKED=0
declare -A ORIGINAL_MIN_FREQS

# Available benchmarks (executables starting with "benchmark_" in .build/bin)
declare -a AVAILABLE_BENCHMARKS

# Function to get available benchmarks
get_available_benchmarks() {
    AVAILABLE_BENCHMARKS=()
    if [[ -d "$BENCHMARK_DIR" ]]; then
        while IFS= read -r -d '' benchmark; do
            AVAILABLE_BENCHMARKS+=("$(basename "$benchmark")")
        done < <(find "$BENCHMARK_DIR" -maxdepth 1 -type f -executable -name "benchmark_*" -print0 2>/dev/null)
        
        # Also include fibonacci_benchmark if it exists
        if [[ -x "$BENCHMARK_DIR/fibonacci_benchmark" ]]; then
            AVAILABLE_BENCHMARKS+=("fibonacci_benchmark")
        fi
    fi
}

# Function to list available benchmarks
list_benchmarks() {
    print_info "Available benchmarks:"
    if [[ ${#AVAILABLE_BENCHMARKS[@]} -eq 0 ]]; then
        print_warning "No benchmarks found in $BENCHMARK_DIR"
        print_warning "Make sure the project is built with benchmarks enabled"
        exit 1
    fi
    for benchmark in "${AVAILABLE_BENCHMARKS[@]}"; do
        echo "  - $benchmark"
    done
}

# Function to check current CPU governor
get_current_governor() {
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
        cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    else
        echo "unknown"
    fi
}

# Function to disable CPU boost (Intel/AMD)
disable_cpu_boost() {
    local boost_path=""
    local current_boost=""
    
    # Check for AMD boost control
    if [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
        boost_path="/sys/devices/system/cpu/cpufreq/boost"
        current_boost=$(cat "$boost_path" 2>/dev/null)
        
        if [[ "$current_boost" == "0" ]]; then
            print_info "CPU boost already disabled"
            return 0
        fi
        
        print_info "Disabling CPU boost for more stable results..."
        if echo 0 | sudo tee "$boost_path" >/dev/null 2>&1; then
            ORIGINAL_BOOST="$current_boost"
            CPU_BOOST_CHANGED=1
            print_info "CPU boost disabled"
            return 0
        else
            print_warning "Failed to disable CPU boost (requires sudo)"
            return 1
        fi
    fi
    
    # Check for Intel turbo boost control
    if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
        boost_path="/sys/devices/system/cpu/intel_pstate/no_turbo"
        current_boost=$(cat "$boost_path" 2>/dev/null)
        
        if [[ "$current_boost" == "1" ]]; then
            print_info "Intel turbo boost already disabled"
            return 0
        fi
        
        print_info "Disabling Intel turbo boost for more stable results..."
        if echo 1 | sudo tee "$boost_path" >/dev/null 2>&1; then
            ORIGINAL_BOOST="$current_boost"
            CPU_BOOST_CHANGED=1
            print_info "Intel turbo boost disabled"
            return 0
        else
            print_warning "Failed to disable turbo boost (requires sudo)"
            return 1
        fi
    fi
    
    print_warning "CPU boost control not found - may still have frequency scaling"
    return 1
}

# Function to restore CPU boost
restore_cpu_boost() {
    if [[ $CPU_BOOST_CHANGED -eq 1 ]] && [[ -n "$ORIGINAL_BOOST" ]]; then
        local boost_path=""
        
        if [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
            boost_path="/sys/devices/system/cpu/cpufreq/boost"
        elif [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
            boost_path="/sys/devices/system/cpu/intel_pstate/no_turbo"
        fi
        
        if [[ -n "$boost_path" ]]; then
            print_info "Restoring CPU boost setting..."
            if echo "$ORIGINAL_BOOST" | sudo tee "$boost_path" >/dev/null 2>&1; then
                print_info "CPU boost setting restored"
            else
                print_warning "Failed to restore CPU boost setting"
            fi
        fi
    fi
}

# Function to lock CPU frequencies (set min = max)
lock_cpu_frequencies() {
    print_info "Locking CPU frequencies to maximum for stable benchmarks..."
    
    local cpu_count=0
    local success_count=0
    
    for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
        if [[ ! -d "$cpu_dir/cpufreq" ]]; then
            continue
        fi
        
        local cpu_num=$(basename "$cpu_dir" | sed 's/cpu//')
        local max_freq_file="$cpu_dir/cpufreq/scaling_max_freq"
        local min_freq_file="$cpu_dir/cpufreq/scaling_min_freq"
        
        if [[ ! -f "$max_freq_file" ]] || [[ ! -f "$min_freq_file" ]]; then
            continue
        fi
        
        local max_freq=$(cat "$max_freq_file" 2>/dev/null)
        local min_freq=$(cat "$min_freq_file" 2>/dev/null)
        
        if [[ -z "$max_freq" ]] || [[ -z "$min_freq" ]]; then
            continue
        fi
        
        cpu_count=$((cpu_count + 1))
        
        # Save original min frequency
        ORIGINAL_MIN_FREQS[$cpu_num]="$min_freq"
        
        # Set min frequency to max frequency
        if echo "$max_freq" | sudo tee "$min_freq_file" >/dev/null 2>&1; then
            success_count=$((success_count + 1))
        else
            print_warning "Failed to lock frequency for CPU $cpu_num"
        fi
    done
    
    if [[ $success_count -gt 0 ]]; then
        CPU_FREQ_LOCKED=1
        print_info "Locked frequencies for $success_count/$cpu_count CPUs"
        return 0
    else
        print_warning "Failed to lock CPU frequencies (requires sudo)"
        return 1
    fi
}

# Function to restore CPU frequencies
restore_cpu_frequencies() {
    if [[ $CPU_FREQ_LOCKED -eq 1 ]] && [[ ${#ORIGINAL_MIN_FREQS[@]} -gt 0 ]]; then
        print_info "Restoring CPU frequency limits..."
        
        for cpu_num in "${!ORIGINAL_MIN_FREQS[@]}"; do
            local min_freq_file="/sys/devices/system/cpu/cpu${cpu_num}/cpufreq/scaling_min_freq"
            local original_min="${ORIGINAL_MIN_FREQS[$cpu_num]}"
            
            if [[ -f "$min_freq_file" ]]; then
                echo "$original_min" | sudo tee "$min_freq_file" >/dev/null 2>&1
            fi
        done
        
        print_info "CPU frequency limits restored"
    fi
}

# Function to set CPU to performance mode
set_performance_mode() {
    local current_governor
    current_governor=$(get_current_governor)
    
    if [[ "$current_governor" == "unknown" ]]; then
        print_warning "CPU frequency scaling not available or not accessible"
        return 1
    fi
    
    local governor_changed=0
    
    if [[ "$current_governor" != "performance" ]]; then
        print_info "Current CPU governor: $current_governor"
        print_info "Setting CPU governor to performance mode..."
        
        if echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1; then
            ORIGINAL_GOVERNOR="$current_governor"
            CPU_GOVERNOR_CHANGED=1
            governor_changed=1
            print_info "CPU governor set to performance mode"
        else
            print_warning "Failed to set CPU governor (requires sudo)"
        fi
    else
        print_info "CPU governor already set to performance mode"
    fi
    
    # Disable CPU boost and lock frequencies unless --allow-turbo is set
    if [[ $ALLOW_TURBO -eq 1 ]]; then
        print_info "Turbo boost allowed - running with maximum performance (less stable)"
    else
        # Disable CPU boost for maximum stability
        disable_cpu_boost
        
        # Lock CPU frequencies to eliminate scaling
        lock_cpu_frequencies
    fi
    
    if [[ $governor_changed -eq 0 ]] && [[ $CPU_BOOST_CHANGED -eq 0 ]] && [[ $CPU_FREQ_LOCKED -eq 0 ]]; then
        print_warning "Benchmarks may have unstable results due to CPU frequency scaling"
        return 1
    fi
    
    return 0
}

# Function to restore CPU governor
restore_cpu_governor() {
    # Restore frequencies first
    restore_cpu_frequencies
    
    if [[ $CPU_GOVERNOR_CHANGED -eq 1 ]] && [[ -n "$ORIGINAL_GOVERNOR" ]]; then
        print_info "Restoring CPU governor to $ORIGINAL_GOVERNOR..."
        if echo "$ORIGINAL_GOVERNOR" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1; then
            print_info "CPU governor restored"
        else
            print_warning "Failed to restore CPU governor"
        fi
    fi
    
    # Also restore boost setting
    restore_cpu_boost
}

# Function to run a single benchmark
run_benchmark() {
    local benchmark_name="$1"
    local benchmark_path="$BENCHMARK_DIR/$benchmark_name"
    
    if [[ ! -x "$benchmark_path" ]]; then
        print_error "Benchmark not found or not executable: $benchmark_name"
        return 1
    fi
    
    print_section "Running: $benchmark_name"
    
    if "$benchmark_path"; then
        print_info "✓ $benchmark_name completed successfully"
        return 0
    else
        print_error "✗ $benchmark_name failed with exit code $?"
        return 1
    fi
}

# Function to display usage
usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [BENCHMARK...]

Run benchmarks with CPU performance optimizations.

Arguments:
  BENCHMARK...          One or more benchmark names to run
  --all                 Run all available benchmarks

Options:
  --list                List available benchmarks
  --no-perf-mode        Skip setting CPU to performance mode
  --allow-turbo         Allow turbo boost (faster but less stable results)
  --help                Show this help message

Examples:
  $0 --all                                    # Run all benchmarks (stable mode)
  $0 benchmark_statistics                     # Run specific benchmark
  $0 benchmark_statistics fibonacci_benchmark # Run multiple benchmarks
  $0 --list                                   # List available benchmarks
  $0 --allow-turbo --all                      # Run with turbo boost (faster, less stable)

Note: Setting CPU to performance mode, disabling boost, and locking frequencies
      requires sudo privileges. You may be prompted for your password.
      
      Default mode (without --allow-turbo) prioritizes reproducibility over speed.
      Use --allow-turbo for peak performance measurements.

EOF
}

# Trap to ensure CPU governor is restored on exit
trap restore_cpu_governor EXIT INT TERM

# Parse command line arguments
RUN_ALL=0
NO_PERF_MODE=0
ALLOW_TURBO=0
declare -a BENCHMARKS_TO_RUN

# Default to running all benchmarks if no arguments provided
if [[ $# -eq 0 ]]; then
    RUN_ALL=1
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                exit 0
                ;;
            --list|-l)
                get_available_benchmarks
                list_benchmarks
                exit 0
                ;;
            --all)
                RUN_ALL=1
                shift
                ;;
            --no-perf-mode)
                NO_PERF_MODE=1
                shift
                ;;
            --allow-turbo)
                ALLOW_TURBO=1
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                BENCHMARKS_TO_RUN+=("$1")
                shift
                ;;
        esac
    done
fi

# Get available benchmarks
get_available_benchmarks

# Determine which benchmarks to run
if [[ $RUN_ALL -eq 1 ]]; then
    if [[ ${#AVAILABLE_BENCHMARKS[@]} -eq 0 ]]; then
        print_error "No benchmarks found in $BENCHMARK_DIR"
        exit 1
    fi
    BENCHMARKS_TO_RUN=("${AVAILABLE_BENCHMARKS[@]}")
    print_info "Running all available benchmarks"
elif [[ ${#BENCHMARKS_TO_RUN[@]} -eq 0 ]]; then
    print_error "No benchmarks specified"
    usage
    exit 1
fi

# Verify all requested benchmarks exist
for benchmark in "${BENCHMARKS_TO_RUN[@]}"; do
    if [[ ! -x "$BENCHMARK_DIR/$benchmark" ]]; then
        print_error "Benchmark not found: $benchmark"
        print_info ""
        list_benchmarks
        exit 1
    fi
done

print_section "DSQuant Benchmark Runner"
print_info "Benchmarks to run: ${BENCHMARKS_TO_RUN[*]}"

# Set CPU to performance mode unless disabled
if [[ $NO_PERF_MODE -eq 0 ]]; then
    set_performance_mode || print_warning "Continuing without performance mode..."
else
    print_info "Skipping CPU performance mode optimization"
fi

# Run benchmarks
FAILED_BENCHMARKS=()
for benchmark in "${BENCHMARKS_TO_RUN[@]}"; do
    if ! run_benchmark "$benchmark"; then
        FAILED_BENCHMARKS+=("$benchmark")
    fi
done

# Summary
print_section "Benchmark Summary"
total_count=${#BENCHMARKS_TO_RUN[@]}
failed_count=${#FAILED_BENCHMARKS[@]}
success_count=$((total_count - failed_count))

print_info "Total: $total_count | Success: $success_count | Failed: $failed_count"

if [[ $failed_count -gt 0 ]]; then
    print_error "Failed benchmarks:"
    for benchmark in "${FAILED_BENCHMARKS[@]}"; do
        echo "  - $benchmark"
    done
    exit 1
fi

print_info "All benchmarks completed successfully!"
exit 0
