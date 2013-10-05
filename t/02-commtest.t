#!/usr/bin/perl
#
# Copyright (C) 2013 by Lieven Hollevoet

# This test runs the communication test.

use strict;

use Test::More;
use Test::Requires qw/Test::SharedFork/;
use Test::SharedFork;
use IO::Select;
use IO::Socket::INET;

BEGIN { use_ok('Device::Solenodrive'); }

my $debug_mult = 10
    ; # Set this to a big number for longer timeouts when interactively debugging.

my $tcp = IO::Socket::INET->new(
    Listen    => 5,
    Proto     => 'tcp',
    LocalAddr => '127.0.0.1',
    LocalPort => 0
) or plan skip_all => "Failed to open TCP server on loopback address: $!";
my $tcp_port = $tcp->sockport;

my $pid = fork();

# Make a TCP test server in a spearate thread and connect to it with the bootloader from the parent thread
if ( $pid == 0 ) {

    # child
    my $sel = IO::Select->new($tcp);
    $sel->can_read( 10 * $debug_mult ) or die;
    my $client = $tcp->accept;
    ok $client, 'client accepted';
    $sel = IO::Select->new($client);
    $sel->can_read( 10 * $debug_mult ) or die;
    my ($buf, $bytes, $resp);

    # Handle enumeration request
    $bytes = sysread $client, $buf, 2048;
    is $bytes, 5, 'sync packet length';
    is $buf, "\x0F\x00\x00\x00\x04", "Got bootloader info request";
    $resp = "\x0F\x00\x00\x05\x05\x01\xFF\x84\x01\x02\x03\x00\x31\x42\x04";
    syswrite $client, $resp, length($resp);

}
elsif ($pid) {

    #parent
    my $soleno = Device::Solenodrive->new(
        device   => '127.0.0.1' . ":" . $tcp_port,
        verbose  => 3
    );
    ok $soleno, 'object created';

    # Connect to controller
    $soleno->connect_target();

    #is ($soleno->program, 1, 'Programming over TCP done');
    waitpid $pid, 0;
    done_testing();
}
else {
    die $!;
}
