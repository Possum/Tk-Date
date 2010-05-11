#!/usr/bin/perl
use strict;
use warnings;
use Tk;

package Tk::Widget;
use strict;
use warnings;
sub eventGenerate2 {
    my $w = shift;
    my $e = shift;
    $w->eventGenerate($e, @_,
		      ($Tk::VERSION >= 800.016 ? (-warp => 1) : ()),
		     );
    if ($main::SLOW) {
	warn "Event: $e => $w\n";
	$w->update;
	sleep $main::SLOW;
    }
}

package main;
use strict;
use warnings;

use Test::More tests => 7;

#use Tk::widgets qw(Date);

my $top = MainWindow->new;
my $dw = $top->Date( -use_date_entry => 1 )->pack;
ok $dw;

$dw = $top->Date( -use_date_entry => 1, -value => 'now' )->pack;
ok $dw;

sleep 1;
my $time = time();
ok $dw->configure( -value => $time );
is $dw->get, $time;

$dw = $top->Date( -use_date_entry => 1 )->pack;
ok $dw;
$time = time();
ok $dw->configure( -value => $time );
is $dw->get, $time;
