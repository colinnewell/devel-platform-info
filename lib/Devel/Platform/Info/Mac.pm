package Devel::Platform::Info::Mac;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.01';


#-------------------------------------------------------------------------------

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;

    return $self;
}


#-------------------------------------------------------------------------------

sub get_info {
    my $self = shift;
    $self->{info}{osname} = 'Mac';
    
    my $uname_s = $self->command('uname -s');
    if ($uname_s =~ /Darwin/i) {
        $self->{info}{oslabel} = 'OS X';
        
        my $productversion = $self->command('sw_vers -productVersion');
        if ($productversion =~ /(\d+)\.(\d+)\.(\d+)/) {
            my ($major, $minor, $release) = ($1, $2, $3);
            my $versions = macos_versions();
            if (my $codename = $versions->{"$major.$minor"}) {
                $self->{info}{codename} = $codename;
                $self->{info}{osvers}  = "$major.$minor.$release";
            }
        }
    }
    
    if (my $arch = $self->command('uname -p')) {
        chomp $arch;
        $self->{info}{archname} = $arch;
        $self->{info}{is32bit}  = $arch !~ /_(64)$/ ? 1 : 0;
        $self->{info}{is64bit}  = $arch =~ /_(64)$/ ? 1 : 0;
    }
    
    if (my $unamev = $self->command('uname -v')) {
        chomp $unamev;
        $self->{info}{kernel} = $unamev;
    }
    
    $self->command('uname -a');
    
    return $self->{info};
}


#-------------------------------------------------------------------------------

sub command {
    my $self    = shift;
    my $command = shift;
    my $result  = `$command`;
    
    $self->{info}{source} .= $command;
    $self->{info}{source} .= "\n";
    $self->{info}{source} .= $result;    
    $self->{info}{source} .= "\n";
    
    chomp $result;
    return $result;  
}

#-------------------------------------------------------------------------------

sub macos_versions {
    return {
        '10.0' => 'Cheetah',
        '10.1' => 'Puma',
        '10.2' => 'Jaguar',
        '10.3' => 'Panther',
        '10.4' => 'Tiger',
        '10.5' => 'Leopard',
        '10.6' => 'Snow Leopard',
    };
}


#-------------------------------------------------------------------------------

1;

__END__

=head1 NAME

Devel::Platform::Info::Mac - Retrieve common platform metadata

=head1 SYNOPSIS

  use Devel::Platform::Info::Mac;
  my $info = Devel::Platform::Info::Mac->new();
  my $data = $info->get_info();

=head1 DESCRIPTION

This module is a driver to determine platform metadata regarding the Mac
operating system. It should be called indirectly via it's parent 
Devel::Platform::Info

=head1 INTERFACE

=head2 The Constructor

=over

=item * new

Simply constructs the object.

=back

=head2 Methods

=over 4

=item * get_info

Returns a hash reference to the Mac platform metadata.

Returns the following keys:

  source
  archname
  osname
  osvers
  oslabel
  codename
  kernel
  is32bit
  is64bit

=back

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties, that is not explained within the POD
documentation, please send bug reports and patches to the RT Queue (see below).

RT Queue -
http://rt.cpan.org/Public/Dist/Display.html?Name=Devel-Platform-Info

=head1 AUTHORS

  Barbie (BARBIE) <barbie@cpan.org>
  Brian McCauley (NOBULL) <nobull67@gmail.com>
  Colin Newell http://colinnewell.wordpress.com/
  Jon 'JJ' Allen (JONALLEN) <jj@jonallen.info>

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2010 Birmingham Perl Mongers

  This module is free software; you can redistribute it and/or
  modify it under the Artistic License 2.0.

=cut