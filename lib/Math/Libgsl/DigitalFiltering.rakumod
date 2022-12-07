unit class Math::Libgsl::DigitalFiltering:ver<0.0.1>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Vector;
use Math::Libgsl::Vector::Int32;
use Math::Libgsl::Raw::DigitalFiltering;

class Gaussian {
  has gsl_filter_gaussian_workspace $.ws;

  multi method new(Int $size!) { self.bless(:$size) }
  multi method new(Int :$size!) { self.bless(:$size) }

  submethod BUILD(Int :$size!) { $!ws = gsl_filter_gaussian_alloc($size) }
  submethod DESTROY { gsl_filter_gaussian_free($!ws) }

  method filter(Num() $alpha!, Math::Libgsl::Vector $x!, Int :$order = 0, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Bool :$inplace? --> Math::Libgsl::Vector) {
    my Math::Libgsl::Vector $y;
    with $inplace {
      $y := $x;
    } else {
      $y .= new: $x.vector.size;
    }
    my num64 $α = $alpha;
    my $ret = gsl_filter_gaussian($endtype, $α, $order, $x.vector, $y.vector, $!ws);
    fail X::Libgsl.new: errno => $ret, error => "Can't filter data" if $ret ≠ GSL_SUCCESS;
    return $y;
  }

  method kernel(Num() $alpha!, Int $size, Int :$order = 0, Int :$normalize = 0 --> Math::Libgsl::Vector) {
    my Math::Libgsl::Vector $kernel .= new: $size;
    my num64 $α = $alpha;
    my $ret = gsl_filter_gaussian_kernel($α, $order, $normalize, $kernel.vector);
    fail X::Libgsl.new: errno => $ret, error => "Can't create a gaussian kernel" if $ret ≠ GSL_SUCCESS;
    return $kernel;
  }
}

class Median {
  has gsl_filter_median_workspace $.ws;

  multi method new(Int $size!) { self.bless(:$size) }
  multi method new(Int :$size!) { self.bless(:$size) }

  submethod BUILD(Int :$size!) { $!ws = gsl_filter_median_alloc($size) }
  submethod DESTROY { gsl_filter_median_free($!ws) }

  method filter(Math::Libgsl::Vector $x!, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Bool :$inplace? --> Math::Libgsl::Vector) {
    my Math::Libgsl::Vector $y;
    with $inplace {
      $y := $x;
    } else {
      $y .= new: $x.vector.size;
    }
    my $ret = gsl_filter_median($endtype, $x.vector, $y.vector, $!ws);
    fail X::Libgsl.new: errno => $ret, error => "Can't filter data" if $ret ≠ GSL_SUCCESS;
    return $y;
  }
}

class RMedian {
  has gsl_filter_rmedian_workspace $.ws;

  multi method new(Int $size!) { self.bless(:$size) }
  multi method new(Int :$size!) { self.bless(:$size) }

  submethod BUILD(Int :$size!) { $!ws = gsl_filter_rmedian_alloc($size) }
  submethod DESTROY { gsl_filter_rmedian_free($!ws) }

  method filter(Math::Libgsl::Vector $x!, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Bool :$inplace? --> Math::Libgsl::Vector) {
    my Math::Libgsl::Vector $y;
    with $inplace {
      $y := $x;
    } else {
      $y .= new: $x.vector.size;
    }
    my $ret = gsl_filter_rmedian($endtype, $x.vector, $y.vector, $!ws);
    fail X::Libgsl.new: errno => $ret, error => "Can't filter data" if $ret ≠ GSL_SUCCESS;
    return $y;
  }
}

class Impulse {
  has gsl_filter_impulse_workspace $.ws;

  multi method new(Int $size!) { self.bless(:$size) }
  multi method new(Int :$size!) { self.bless(:$size) }

  submethod BUILD(Int :$size!) { $!ws = gsl_filter_impulse_alloc($size) }
  submethod DESTROY { gsl_filter_impulse_free($!ws) }

  method filter(Math::Libgsl::Vector $x!, Num() $tuning, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Int :$scaletype = GSL_FILTER_SCALE_MAD, Bool :$inplace? --> List) {
    my Math::Libgsl::Vector $y;
    with $inplace {
      $y := $x;
    } else {
      $y .= new: $x.vector.size;
    }
    my Math::Libgsl::Vector        $xmedian  .= new: $x.vector.size;
    my Math::Libgsl::Vector        $xsigma   .= new: $x.vector.size;
    my Math::Libgsl::Vector::Int32 $ioutlier .= new: $x.vector.size;
    my num64 $t = $tuning;
    my size_t $noutlier;
    my $ret = gsl_filter_impulse($endtype, $scaletype, $t, $x.vector, $y.vector, $xmedian.vector, $xsigma.vector, $noutlier, $ioutlier.vector, $!ws);
    fail X::Libgsl.new: errno => $ret, error => "Can't filter data" if $ret ≠ GSL_SUCCESS;
    return $xmedian, $xsigma, $noutlier, $ioutlier, $y;
  }
}

=begin pod

![Impulse filter](examples/04-impulse.svg)

=head1 NAME

Math::Libgsl::DigitalFiltering -  An interface to libgsl, the Gnu Scientific Library - Digital Filtering

=head1 SYNOPSIS

=begin code :lang<raku>

use Math::Libgsl::Vector;
use Math::Libgsl::DigitalFiltering;

my constant $N = 1000;
my constant $K = 21;
my Math::Libgsl::Vector $x .= new: :size($N);
$x.scanf('data.dat');
my Math::Libgsl::DigitalFiltering::Gaussian $gauss .= new: :size($K);
my $y = $gauss.filter(2.5, $x);

=end code

=head1 DESCRIPTION

Math::Libgsl::DigitalFiltering is an interface to the Digital Filtering functions of libgsl, the Gnu Scientific Library.

This module exports four classes:

=item Math::Libgsl::DigitalFiltering::Gaussian
=item Math::Libgsl::DigitalFiltering::Median
=item Math::Libgsl::DigitalFiltering::RMedian
=item Math::Libgsl::DigitalFiltering::Impulse

each encapsulates the methods and the buffers needed to create and use the filter on the data stored in a Math::Libgsl::Vector object.

=head2 Math::Libgsl::DigitalFiltering::Gaussian

This class encapsulate a Gaussian filter.

=head3 multi method new(Int $size!)
=head3 multi method new(Int :$size!)

The constructor accepts one simple or named argument: the kernel size.

=head3 filter(Num() $alpha!, Math::Libgsl::Vector $x!, Int :$order = 0, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Bool :$inplace? --> Math::Libgsl::Vector)

This method applies a Gaussian filter parameterized by B<$alpha> to the input vector B<$x>.
The optional named argument B<:$order> specifies the derivative order, with C<0> corresponding to a Gaussian, C<1> corresponding to a first derivative Gaussian, and so on.
The optional named argument B<:$endtype> specifies how the signal end points are handled. The symbolic names for this argument are listed in the Math::Libgsl::Constants module as follows:

=item B<GSL_MOVSTAT_END_PADZERO>: inserts zeros into the window near the signal end points
=item B<GSL_MOVSTAT_END_PADVALUE>: pads the window with the first and last sample in the input signal
=item B<GSL_MOVSTAT_END_TRUNCATE>: no padding is performed: the windows are truncated as the end points are approached

The boolean named argument B<:$inplace> directs the method to apply the filter in-place.
This method returns the filter output as a B<Math::Libgsl::Vector> object.

=head3 kernel(Num() $alpha!, Int $size, Int :$order = 0, Int :$normalize = 0 --> Math::Libgsl::Vector)

This method constructs a Gaussian kernel parameterized by B<$alpha>, of size B<$size>.
The optional named argument B<:$order> specifies the derivative order.
The optional named argument B<:$normalize> specifies if the kernel is to be normalized to sum to one on output.
This method returns the filter output as a B<Math::Libgsl::Vector> object.

=head2 Math::Libgsl::DigitalFiltering::Median

This class encapsulate a Median filter.

=head3 multi method new(Int $size!)
=head3 multi method new(Int :$size!)

The constructor accepts one simple or named argument: the kernel size.

=head3 filter(Math::Libgsl::Vector $x!, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Bool :$inplace? --> Math::Libgsl::Vector)

This method applies a Median filter to the input vector B<$x>.
The optional named argument B<:$endtype> specifies how the signal end points are handled.
The optional boolean named argument B<:$inplace> directs the method to apply the filter in-place.
This method returns the filter output as a B<Math::Libgsl::Vector> object.

=head2 Math::Libgsl::DigitalFiltering::RMedian

This class encapsulate a recursive Median filter.

=head3 multi method new(Int $size!)
=head3 multi method new(Int :$size!)

The constructor accepts one simple or named argument: the kernel size.

=head3 filter(Math::Libgsl::Vector $x!, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Bool :$inplace? --> Math::Libgsl::Vector)

This method applies a Median filter to the input vector B<$x>.
The optional named argument B<:$endtype> specifies how the signal end points are handled.
The optional boolean named argument B<:$inplace> directs the method to apply the filter in-place.
This method returns the filter output as a B<Math::Libgsl::Vector> object.

=head2 Math::Libgsl::DigitalFiltering::Impulse

This class encapsulate an Impulse detection filter.

=head3 multi method new(Int $size!)
=head3 multi method new(Int :$size!)

The constructor accepts one simple or named argument: the kernel size.

=head3 filter(Math::Libgsl::Vector $x!, Num() $tuning, Int :$endtype = GSL_MOVSTAT_END_PADZERO, Int :$scaletype = GSL_FILTER_SCALE_MAD, Bool :$inplace? --> List)

This method applies an Impulse filter to the input vector B<$x>, using the tuning parameter B<$tuning>.
The optional named argument B<:$endtype> specifies how the signal end points are handled.
The optional named argument B<:$scaletype> specifies how the scale estimate Sₙ of the window is calculated. The symbolic names for this argument are listed in the Math::Libgsl::Constants module as follows:

=item B<GSL_FILTER_SCALE_MAD>: specifies the median absolute deviation (MAD) scale estimate
=item B<GSL_FILTER_SCALE_IQR>: specifies the interquartile range (IQR) scale estimate
=item B<GSL_FILTER_SCALE_SN>: specifies the so-called Sₙ statistic
=item B<GSL_FILTER_SCALE_QN>: specifies the so-called Qₙ statistic

The optional boolean named argument B<:$inplace> directs the method to apply the filter in-place.
This method returns a List of values:

=item the window medians, as a B<Math::Libgsl::Vector> object
=item the window Sₙ, as a B<Math::Libgsl::Vector> object
=item the number of outliers as an Int
=item the location of the outliers as a B<Math::Libgsl::Vector::Int32> object

=head1 C Library Documentation

For more details on libgsl see L<https://www.gnu.org/software/gsl/>.
The excellent C Library manual is available here L<https://www.gnu.org/software/gsl/doc/html/index.html>, or here L<https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf> in PDF format.

=head1 Prerequisites

This module requires the libgsl library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux and Ubuntu 20.04+

=begin code
sudo apt install libgsl23 libgsl-dev libgslcblas0
=end code

That command will install libgslcblas0 as well, since it's used by the GSL.

=head2 Ubuntu 18.04

libgsl23 and libgslcblas0 have a missing symbol on Ubuntu 18.04.
I solved the issue installing the Debian Buster version of those three libraries:

=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb>

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::Libgsl::DigitalFiltering
=end code

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
