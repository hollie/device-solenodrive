#! /usr/bin/env perl

use strict;
use warnings;
use 5.012;
use autodie;
use Pod::Help qw(-h --help);
use Getopt::Std;
use Device::Solenodrive;
use Data::Dumper;

my %opts;

# Extract the power and area file options if they are passed.
getopt( 'dvbc', \%opts );

Pod::Help->help() if ( !defined $opts{d} && !defined $opts{h} && !defined $opts{c});

# Create the object
my $soleno = Device::Solenodrive->new(
    device   => $opts{d},
    verbose  => $opts{v} || 0,
    baudrate => $opts{b} || 57600
);

# Connect to the target device over the specified connection
$soleno->connect_target();

$soleno->set("05051A2C", $opts{c});

sleep(1);

$soleno->disconnect_target();


# ABSTRACT: Control software for Solenodrive devices over RS485
# PODNAME: solenoctrl.pl

=head1 DESCRIPTION

This scripts implements the control protocol to Solenodrive hardware. Solenodrive is an 8 channel solenoid controller with RS485 interface

=head1 SYNOPSYS

Usage:
solenoctrl.pl -d <device> -c <channel>

Where C<device> is either a serial port or a TCP socket (format host:portnumber).

When using a serial port, the default baudrate used is 57600 bps. To override, pass
the parameter 'b' with the required baudrate when invoking the script.

C<channel> is the channel to set.

Optionally, a parameter -v <verboselevel> can be passed to modify the verbosity
of the Device::Solenodrive module. Defaults to '0', set to '3' for useful
debugging.

=cut