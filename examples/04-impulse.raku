#!/usr/bin/env raku

use Math::Libgsl::Constants;
use Math::Libgsl::Vector;
use Math::Libgsl::Random;
use Math::Libgsl::RandomDistribution;
use Math::Libgsl::DigitalFiltering;

my constant $N = 1000; # length of time series
my constant $K = 25;   # window size
my constant $t = 4;    # number of scale factors for outlier detection
my Math::Libgsl::Vector $x .= new: $N; # input vector
my Math::Libgsl::Random $r .= new;
my Math::Libgsl::DigitalFiltering::Impulse $impulse .= new: $K;

# generate input signal
for ^$N -> $i {
  my $xi = 10 * sin(2 * π * $i / $N);
  my $ei = gaussian($r, 2);
  my $u = $r.get-uniform;
  my $outlier = $u < .01 ?? 15 * $ei.sign !! 0;
  $x[$i] = $xi + $ei + $outlier;
}

my ($xmedian, $xsigma, $noutlier, $ioutlier, $y) = $impulse.filter: $x, $t, :endtype(GSL_FILTER_END_TRUNCATE), :scaletype(GSL_FILTER_SCALE_QN);

# print results
printf "%u %f %f %f %f %d\n", $_, $x[$_], $y[$_], $xmedian[$_] + $t * $xsigma[$_], $xmedian[$_] - $t * $xsigma[$_], $ioutlier[$_] for ^$N;
