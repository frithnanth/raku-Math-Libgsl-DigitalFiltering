#!/usr/bin/env raku

use Math::Libgsl::Constants;
use Math::Libgsl::Vector;
use Math::Libgsl::Random;
use Math::Libgsl::RandomDistribution;
use Math::Libgsl::DigitalFiltering;

my constant $N = 1000; # length of time series
my constant $K = 51;   # window size
my constant $α = 3;    # Gaussian kernel has +/- 3 standard deviations
my Math::Libgsl::Vector $x .= new: $N; # input vector
my Math::Libgsl::Random $r .= new;
my Math::Libgsl::DigitalFiltering::Gaussian $gauss .= new: $K;

# generate input signal
$x[$_] = ($_ > $N / 2 ?? .5 !! 0) + gaussian($r, .1) for ^$N;

# apply filters
my $y   = $gauss.filter: $α, $x, :order(0), :endtype(GSL_FILTER_END_PADVALUE);
my $dy  = $gauss.filter: $α, $x, :order(1), :endtype(GSL_FILTER_END_PADVALUE);
my $d2y = $gauss.filter: $α, $x, :order(2), :endtype(GSL_FILTER_END_PADVALUE);

# print results
for ^$N -> $i {
  my $dxi;
  if $i == 0 {
    $dxi = $x[$i + 1] - $x[$i];
  } elsif $i == $N - 1 {
    $dxi = $x[$i] - $x[$i - 1];
  } else {
    $dxi = .5 * ($x[$i + 1] - $x[$i - 1]);
  }
  printf "%.12e %.12e %.12e %.12e %.12e\n", $x[$i], $y[$i], $dxi, $dy[$i], $d2y[$i];
}
