#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <stdint.h>
#include <math.h>



/* if this is set store results in an array to be able to compute the median
 * otherwise only compute the average */
#define COMPUTE_MEDIAN 1

#if COMPUTE_MEDIAN
	#define BEGIN_MICROBENCHMARKS() \
		uint64_t retval, t0, t1;	\
		uint64_t *results = malloc( REPS * sizeof(uint64_t));
#else
	#define BEGIN_MICROBENCHMARKS() \
		uint64_t min, max, sum, t0, t1, diff, retval;
#endif

#if COMPUTE_MEDIAN
	#define FINALIZE_MICROBENCHMARKS() \
		free(results);
#else
	#define FINALIZE_MICROBENCHMARKS()
#endif

#if COMPUTE_MEDIAN
	#define BENCHMARK(stmt, runs, out_stats_ptr, p)	\
		for(int i = 0; i < runs; i++) {											\
			t0 = BENCH_START();													\
			stmt;																\
			t1 = BENCH_END();													\
			results[i] = t1 - t0;												\
		}																		\
		do_statistics(results, runs, out_stats_ptr, p);
#else
	#define BENCHMARK(stmt, runs, out_stats_ptr)								\
		min = (uint64_t) -1;													\
		max = 0;																\
		sum = 0;																\
		for(int i = 0; i < runs; i++) {											\
			t0 = BENCH_START();													\
			stmt;																\
			t1 = BENCH_END();													\
			diff = t1 - t0;														\
			if (diff < min) min = diff;											\
			if (diff > max) max = diff;											\
			sum += diff;														\
		}																		\
		(out_stats_ptr)->num_measurements = runs;								\
		(out_stats_ptr)->min = min;												\
		(out_stats_ptr)->max = max;												\
		(out_stats_ptr)->average = sum / (runs);
#endif

static inline int cmp_int(const void *x, const void *y)
{
    uint64_t a = *((uint64_t*) x);
    uint64_t b = *((uint64_t*) y);
    if (a < b) {
        return -1;
    } else if (a > b) {
        return 1;
    } else {
        return 0;
    }
}

struct statistics {
	uint64_t num_measurements;
	uint64_t min;
	uint64_t max;
#if COMPUTE_MEDIAN
	uint64_t median;
	double average;
	double sdev;
	double p_interval;
	uint64_t interval_start;
	uint64_t interval_end;
#else
	uint64_t average;
#endif
};

#if COMPUTE_MEDIAN
void do_statistics(uint64_t *measurements, uint64_t n, struct statistics *out_stats, double p_interval) {
	qsort(measurements, n, sizeof(uint64_t), &cmp_int);
	uint64_t min = (uint64_t) -1;
	uint64_t max = 0;
	uint64_t sum = 0;
	for (size_t i = 0; i < n; ++i) {
		size_t x = measurements[i];
		sum += x;
		if (x < min) {
			min = x;
		}
		if (x > max) {
			max = x;
		}
	}
	double avg = ((double) sum) / n;
	double var = 0;
	for (size_t i = 0; i < n; ++i) {
		size_t x = measurements[i];
		var += (x - avg) * (x - avg);
	}
	var /= (n - 1);
	out_stats->num_measurements = n;
	out_stats->min = min;
	out_stats->max = max;
	if (n % 2) {
		out_stats->median = measurements[n / 2];
	} else {
		out_stats->median = (measurements[n / 2] + measurements[n / 2 - 1]) / 2;
	}
	out_stats->average = avg;
	out_stats->sdev = sqrt(var);
	if (p_interval > 0.0 && p_interval < 1.0) {
		out_stats->p_interval = p_interval;
		double q = (1.0 - p_interval) / 2;
		int low_idx = (int) (q * n) - 1;
		if (low_idx < 0) {
			low_idx = 0;
		}
		int high_idx = (int) ((1.0 - q) * n) - 1;
		if (high_idx < 0) {
			high_idx = 0;
		}
		out_stats->interval_start = measurements[low_idx];
		out_stats->interval_end = measurements[high_idx];
	} else {
		out_stats->p_interval = -1;
		out_stats->interval_start = 0;
		out_stats->interval_end = 0;
	}
}
#endif

void print_stats(struct statistics *stats, const char *str) {

#if COMPUTE_MEDIAN
	uint64_t avg = (uint64_t) stats->average;
	// fomat: description min max median average sdev
	printf("%16s %8ld \t %8ld \t %8ld \t %8ld \t %8ld \t %8ld\n",
        str, stats->min, stats->max, stats->median, avg, stats->interval_start, stats->interval_end);
#else
	// fomat: description min max average
	printf("%16s %4ld \t %8ld \t %4ld\n",
        str, stats->min, stats->max, stats->average);
#endif
}

/* uk_print apparently can't print floating point numbers, so use this instead
 * simply print the integers a.x */
void fraction_to_dec(double d, int digits, int64_t *out_a, uint64_t *out_x) {
    double frac = d - ((int64_t) d);
    if (frac < 0) {
	frac = -frac;
    }
    uint64_t res = 0;
    for (int i = 0; i < digits; ++i) {
        frac *= 10;
        res = (res * 10) + ((uint64_t) frac);
        frac -= (uint64_t) frac;
    }
    *out_a = (int64_t) d;
    *out_x = res;
}


// bench_start returns a timestamp for use to measure the start of a benchmark
// run.
__attribute__ ((always_inline)) static inline uint64_t bench_start(void)
{
  unsigned  cycles_low, cycles_high;
  asm volatile( "CPUID\n\t" // serialize
                "RDTSC\n\t" // read clock
                "MOV %%edx, %0\n\t"
                "MOV %%eax, %1\n\t"
                : "=r" (cycles_high), "=r" (cycles_low)
                :: "%rax", "%rbx", "%rcx", "%rdx" );
  return ((uint64_t) cycles_high << 32) | cycles_low;
}

// bench_end returns a timestamp for use to measure the end of a benchmark run.
__attribute__ ((always_inline)) static inline uint64_t bench_end(void)
{
  unsigned  cycles_low, cycles_high;
  asm volatile( "RDTSCP\n\t" // read clock + serialize
                "MOV %%edx, %0\n\t"
                "MOV %%eax, %1\n\t"
                "CPUID\n\t" // serialize -- but outside clock region!
                : "=r" (cycles_high), "=r" (cycles_low)
                :: "%rax", "%rbx", "%rcx", "%rdx" );
  return ((uint64_t) cycles_high << 32) | cycles_low;
}


// read TSC without any serialization
static inline __attribute__ ((always_inline)) uint64_t readtsc()
{
  unsigned  cycles_low, cycles_high;
	asm volatile(
	"RDTSC				\n"
    "MOV %%edx, %0		\n"
    "MOV %%eax, %1		\n"
    : "=r" (cycles_high), "=r" (cycles_low)
	:
	: "%rax", "%rbx", "%rcx", "%rdx"
	);
  	return ((uint64_t) cycles_high << 32) | cycles_low;
}

#define SERIALIZE_NONE 0
#define SERIALIZE_RDTSC 1
#define SERIALIZE_FULL 2

#define SERIALIZE SERIALIZE_RDTSC

#if ((SERIALIZE) == (SERIALIZE_FULL))
	#define BENCH_START() bench_start()
	#define BENCH_END() bench_end()
#elif ((SERIALIZE) == (SERIALIZE_RDTSC))
	#define BENCH_START() bench_start()
	#define BENCH_END() readtsc()
#elif ((SERIALIZE) == (SERIALIZE_NONE))
	#define BENCH_START() readtsc()
	#define BENCH_END() readtsc()
#endif /* SERIALIZE_RDTSC */

#define REPS 100000

int fcall_1r(int arg1) {
	return arg1;
}

int main() {
	BEGIN_MICROBENCHMARKS()
	
	double p = 0.95; // error interval
	
	struct statistics rdtsc_overhead;
	BENCHMARK(asm volatile(""), REPS, &rdtsc_overhead, p)
	
	struct statistics stats_fcall_1r;
	BENCHMARK(fcall_1r(1), REPS, &stats_fcall_1r, p)

	struct statistics stats_syscall;
	BENCHMARK(syscall(1000), REPS, &stats_syscall, p)


	printf("#%16s %8s\t%8s\t%8s\t%8s\t%8s\t%8s\n", "name", "min", "max", "median", "average", "istart", "iend");
	print_stats(&rdtsc_overhead, "rdtsc_overhead");
	print_stats(&stats_fcall_1r, "fcall_1r");
	print_stats(&stats_syscall, "syscall");


	FINALIZE_MICROBENCHMARKS()
	return 0;
}
