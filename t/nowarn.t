#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: nowarn.t,v 1.1 2002/01/10 20:51:26 eserte Exp $
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

BEGIN { plan tests => 1 }

my $mw = tkinit;

my $date=$mw->Date(
	-datefmt => "%2m/%2d/%4y",
	-timefmt => "%2H:%2M:%2S",
	-editable=>0,
	-value=>'now')->pack;

my $timer;
$timer = $date->repeat(1000, [sub {
				  if (Tk::Exists($date)) {
				      $date->configure(-value => 'now');
				  } else {
				      $timer->cancel;
				  }
			      }]);
$mw->update;
ok(1);

__END__
