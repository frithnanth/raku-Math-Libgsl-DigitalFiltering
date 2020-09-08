#!/usr/bin/env raku

use Math::Libgsl::Constants;
use Math::Libgsl::Vector;
use Math::Libgsl::Random;
use Math::Libgsl::RandomDistribution;
use Math::Libgsl::DigitalFiltering;

my constant $N = 1000; # length of time series
my constant $K = 7;    # window size
my constant $f = 5;    # frequency of square wave in Hz
my Math::Libgsl::Vector $t .= new: $N; # time
my Math::Libgsl::Vector $x .= new: $N; # input vector
my Math::Libgsl::Random $r .= new;
my Math::Libgsl::DigitalFiltering::Median  $median  .= new: $K;
my Math::Libgsl::DigitalFiltering::RMedian $rmedian .= new: $K;

# generate input signal
for ^$N -> $i {
  my $ti = $i / ($N - 1);
  my $tmp = sin(2 * π * $f * $ti);
  $t[$i] = $ti;
  $x[$i] = ($tmp ≥ 0 ?? 1 !! -1) + gaussian($r, .1);
}

my $y-median  = $median.filter:  $x, :endtype(GSL_FILTER_END_PADVALUE);
my $y-rmedian = $rmedian.filter: $x, :endtype(GSL_FILTER_END_PADVALUE);

# print results
printf "%f %f %f %f\n", $t[$_], $x[$_], $y-median[$_], $y-rmedian[$_] for ^$N;
