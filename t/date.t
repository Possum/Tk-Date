# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use Tk;
use Tk::Date;
use strict;
use vars qw($loaded);

BEGIN { $| = 1; $^W = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
$loaded = 1;
my $ok = 1;
print "ok " . $ok++ . "\n";

BEGIN {

    package Tk::Date::MyDate;
    # a custom date format: YYYYMMDD

    sub TIESCALAR {
	my($class, $w, $init) = @_;
	my $self = {};
	$self->{Widget} = $w;
	bless $self, $class;
	if (defined $init) {
	    $self->STORE($init);
	}
	$self;
    }

    sub STORE {
	my($self, $value) = @_;
#	warn "STORE: $value";
	my($y, $m, $d) = (substr($value, 0, 4),
			  substr($value, 4, 2),
			  substr($value, 6, 2));
	$self->{Widget}->set_date('y', $y);
	$self->{Widget}->set_date('m', $m);
	$self->{Widget}->set_date('d', $d);
    }

    sub FETCH {
	my $self = shift;
	my $value = sprintf("%04d%02d%02d",
			    $self->{Widget}->get_date('y'),
			    $self->{Widget}->get_date('m'),
			    $self->{Widget}->get_date('d'),
			   );
#	warn "FETCH: $value";
	$value;
    }

}

my $top = new MainWindow;
$top->geometry("+0+0");

my $dw = $top->Date->pack;
print ((ref $dw ne 'Tk::Date' ? "not " : "") . "ok " . $ok++ . "\n");

$dw->configure(-value => 'now');
my $now1 = $dw->get("%s");
my $now2 = time;
my $delta = abs($now2-$now1);
print (($delta > 2 ? "not " : "") . "ok " . $ok++ . "\n");

my $var2;
my $dw2 = $top->Date(-varfmt => 'unixtime',
		     -variable => \$var2,
		     -value => 'now',
		    )->pack;
$now2 = time;
$delta = abs($now2-$var2);
print (($delta > 2 ? "not " : "") . "ok " . $ok++ . "\n");

eval { require POSIX };
if ($@) {
    print "ok " . $ok++ . " # skip\n";
} else {
    eval {
	my $var3 = {};
	my $dw3 = $top->Date(-varfmt => 'datehash',
			     -variable => $var3,
			     -value => 'now',
			    )->pack;
	$now1 = POSIX::mktime(@{$var3}{qw(S M H d)},
			      $var3->{'m'}-1, $var3->{'y'}-1900
			     );
	$now2 = time;
	$delta = abs($now2-$now1);
    };
    print (($delta > 2 || $@ ? "not " : "") . "ok " . $ok++ . "\n");
}

my $var4;
my $dw4 = $top->Date(-varfmt => 'Tk::Date::MyDate',
		     -variable => \$var4,
		     -value => 'now',
		    )->pack;
my(@now) = localtime;
my $nowstring = sprintf("%04d%02d%02d", $now[5]+1900, $now[4]+1, $now[3]);
print (($nowstring ne $var4 ? "not " : "" . "ok ") . $ok++ . "\n");
