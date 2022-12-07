use v6;

unit module Math::Libgsl::Raw::DigitalFiltering:ver<0.0.2>:auth<zef:FRITH>;

use Math::Libgsl::Raw::Matrix :ALL;
use Math::Libgsl::Raw::Matrix::Int32 :ALL;
use Math::Libgsl::Raw::MovingWindow;
use NativeCall;

sub LIB {
  run('/sbin/ldconfig', '-p', :chomp, :out)
    .out
    .slurp(:close)
    .split("\n")
    .grep(/^ \s+ libgsl\.so\. \d+ /)
    .sort
    .head
    .comb(/\S+/)
    .head;
}

class gsl_filter_gaussian_workspace is repr('CStruct') is export {
  has size_t  $.K;
  has CArray[num64] $.kernel;
  has gsl_movstat_workspace $.movstat_workspace;
}

class gsl_filter_median_workspace is repr('CStruct') is export {
  has gsl_movstat_workspace $.movstat_workspace;
}

class gsl_filter_rmedian_workspace is repr('CStruct') is export {
  has size_t                $.H;
  has size_t                $.K;
  has Pointer[void]         $.state;
  has CArray[num64]         $.window;
  has gsl_movstat_accum     $.minmaxacc;
  has gsl_movstat_workspace $.movstat_workspace;
}

class gsl_filter_impulse_workspace is repr('CStruct') is export {
  has gsl_movstat_workspace $.movstat_workspace;
}

sub gsl_filter_gaussian_alloc(size_t $K --> gsl_filter_gaussian_workspace) is native(LIB) is export { * }
sub gsl_filter_gaussian_free(gsl_filter_gaussian_workspace $w) is native(LIB) is export { * }
sub gsl_filter_gaussian(int32 $endtype, num64 $alpha, size_t $order, gsl_vector $x, gsl_vector $y, gsl_filter_gaussian_workspace $w --> int32) is native(LIB) is export { * }
sub gsl_filter_gaussian_kernel(num64 $alpha, size_t $order, int32 $normalize, gsl_vector $kernel --> int32) is native(LIB) is export { * }
sub gsl_filter_median_alloc(size_t $K --> gsl_filter_median_workspace) is native(LIB) is export { * }
sub gsl_filter_median_free(gsl_filter_median_workspace $w) is native(LIB) is export { * }
sub gsl_filter_median(int32 $endtype, gsl_vector $x, gsl_vector $y, gsl_filter_median_workspace $w --> int32) is native(LIB) is export { * }
sub gsl_filter_rmedian_alloc(size_t $K --> gsl_filter_rmedian_workspace) is native(LIB) is export { * }
sub gsl_filter_rmedian_free(gsl_filter_rmedian_workspace $w) is native(LIB) is export { * }
sub gsl_filter_rmedian(int32 $endtype, gsl_vector $x, gsl_vector $y, gsl_filter_rmedian_workspace $w --> int32) is native(LIB) is export { * }
sub gsl_filter_impulse_alloc(size_t $K --> gsl_filter_impulse_workspace) is native(LIB) is export { * }
sub gsl_filter_impulse_free(gsl_filter_impulse_workspace $w) is native(LIB) is export { * }
sub gsl_filter_impulse(int32 $endtype, int32 $scale_type, num64 $t, gsl_vector $x, gsl_vector $y,
      gsl_vector $xmedian, gsl_vector $xsigma, size_t $noutlier is rw, gsl_vector_int $ioutlier,
      gsl_filter_impulse_workspace $w --> int32) is native(LIB) is export { * }
