#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: noprereq.t,v 1.2 2001/08/08 09:15:50 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use Tk;
use Tk::Date;

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "# tests only work with installed Test module\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

BEGIN { plan tests => 6 }

# simulate not having some prereq widgets
$Tk::Date::has_numentryplain = 0;
$Tk::Date::has_numentry      = 0;

$^W = 0;

my $top = new MainWindow;

my $d1 = $top->Date->pack;
ok(ref $d1, "Tk::Date");
my $d2 = $top->Date(-allarrows => 1)->pack;
ok(ref $d2, "Tk::Date");
ok($d2->cget(-allarrows), undef);
my $d3 = $top->Date(-monthmenu => 1)->pack;
ok(ref $d3, "Tk::Date");
ok(!!$d3->cget(-monthmenu), !!$Tk::VERSION >= 800.023);
my $d4 = $top->Date(-readonly => 1)->pack;
ok(ref $d4, "Tk::Date");

#MainLoop;

__END__
