#!/usr/bin/env raku

use Math::Libgsl::Constants;
use Math::Libgsl::Vector;
use Math::Libgsl::Random;
use Math::Libgsl::RandomDistribution;
use Math::Libgsl::DigitalFiltering;

my constant $N = 500;  # length of time series
my constant $K = 51;   # windows size
my @alpha = .5, 3, 10; # alpha values
my Math::Libgsl::Vector $x .= new: $N; # input vector
my Math::Libgsl::Random $r .= new;
my Math::Libgsl::DigitalFiltering::Gaussian $gauss .= new: $K;

# generate input signal
for ^$N -> $i {
  state $sum += gaussian($r, 1);
  $x[$i] = $sum;
}

# compute kernels without normalization
my $k1 = $gauss.kernel(@alpha[0], $K);
my $k2 = $gauss.kernel(@alpha[1], $K);
my $k3 = $gauss.kernel(@alpha[2], $K);

# apply filters
my $y1 = $gauss.filter(@alpha[0], $x, :endtype(GSL_FILTER_END_PADVALUE));
my $y2 = $gauss.filter(@alpha[1], $x, :endtype(GSL_FILTER_END_PADVALUE));
my $y3 = $gauss.filter(@alpha[2], $x, :endtype(GSL_FILTER_END_PADVALUE));

# print kernels
printf "%e %e %e\n", $k1[$_], $k2[$_], $k3[$_] for ^$K;
print "\n\n";

# print filter results
printf "%.12e %.12e %.12e %.12e\n", $x[$_], $y1[$_], $y2[$_], $y3[$_] for ^$N;
