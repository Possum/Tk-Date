# -*- perl -*-

#
# $Id: Date.pm,v 1.23 1998/02/01 20:53:01 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1997, 1998 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

package Tk::Date;
use Tk::NumEntryPlain;
use Tk::FireButton;
use POSIX qw(strftime mktime);
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Tk::Frame);
Construct Tk::Widget 'Date';

$VERSION = '0.21';

my @monlen = (undef, 31, undef, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
my %choice = 
  ('today'     => ['Today',     sub { time() }],
   'now'       => ['Now',       sub { time() }],
   'yesterday' => ['Yesterday', sub { time()-86400 } ],
   'tomorrow'  => ['Tomorrow',  sub { time()+86400 } ],
   'reset'     => ['Reset',     'RESET'],
  );

sub Populate {
    my($w, $args) = @_;
    $w->SUPER::Populate($args);

    my $input = 1;
    if (exists $args->{-editable}) { $input = delete $args->{-editable} }
    my $fields = 'both';
    if (exists $args->{-fields}) { $fields = delete $args->{-fields} }
    if ($fields !~ /^(date|time|both)$/) {
	die "Invalid option for -fields: must be date, time or both";
    }
    my $choices        = delete $args->{-choices};
    if ($choices) {
	if (ref $choices ne 'ARRAY') {
	    $choices = [$choices];
	}
    } else {
	$choices = [];
    }
    my $from           = delete $args->{-from}; # XXX TODO
    my $to             = delete $args->{-to};   # XXX TODO
    $w->{Configure}{-varfmt}  = delete $args->{-varfmt} || 'unixtime';
    my $orient         = delete $args->{-orient} || 'v';
    if ($orient !~ /^(v|h)/) {
	die "Invalid option for -orient: must be horizontal or vertical";
    } else {
	$orient = $1;
    }

    $w->{IncFireButtons} = [];
    $w->{DecFireButtons} = [];
    $w->{NumEntries}     = [];

    if ($fields ne 'time') {
	my %range = ('d' => [1, 31],
		     'm' => [1, 12],
		    );
	my $dw = $w->Frame->pack(-side => 'left');
	$w->Advertise(dateframe => $dw);
	my @datefmt = _fmt_to_array(delete $args->{-datefmt} || "%2d.%2m.%4y");
	foreach (@datefmt) {
	    if ($_ =~ /^%(\d+)?(.)$/) {
		my($l, $k) = ($1, $2);
		if (!$input || $k eq 'A') {  # A = weekday
		    $w->{Sub}{$k} =
		      $dw->Label(($l ? (-width => $l) : ()),
				 -borderwidth => 0,
				)->pack(-side => 'left');
		} else {
		    $w->{Var}{$k} = undef;
		    my $dne = $w->{Sub}{$k} =
		      $dw->DateNumEntryPlain
			(-width => $l,
			 (exists $range{$k} ?
			  ((defined $range{$k}->[0]
			    ? (-minvalue => $range{$k}->[0]) : ()),
			   (defined $range{$k}->[1]
			    ? (-minvalue => $range{$k}->[1]) : ()),
			  ) : ()),
			 # XXX NumEntryPlain ist buggy
			 -textvariable => \$w->{Var}{$k},
			)->pack(-side => 'left');
		    push(@{$w->{NumEntries}}, $dne);
		}
		push(@{$dw->{Sub}}, $k);
		$w->{'len'}{$k} = $l;
	    } else {
		$dw->Label(-text => $_,
			   -borderwidth => 0,
			  )->pack(-side => 'left');
	    }
	}
	if ($input) {
	    my $f = $dw->Frame->pack(-side => 'left');
	    my $fb1 = $f->FireButton
	      (-command => sub { $w->firebutton_command($dw, +1, 'date') },
	      )->pack(-side => ($orient eq 'h' ? 'right' : 'top'));
	    push(@{$w->{IncFireButtons}}, $fb1);
	    my $fb2 = $f->FireButton
	      (-command => sub { $w->firebutton_command($dw, -1, 'date') },
	      )->pack(-side => ($orient eq 'h' ? 'right' : 'top'));
	    push(@{$w->{DecFireButtons}}, $fb2);
	}
    }

    if ($fields eq 'both') {
	$w->Label->pack(-side => 'left');
    }

    if ($fields ne 'date') {
	my %range = ('H' => [0, 23],
		     'M' => [0, 59],
		     'S' => [0, 59],
		    );
	my $tw = $w->Frame->pack(-side => 'left');
	$w->Advertise(timeframe => $tw);
	my @timefmt = _fmt_to_array(delete $args->{-timefmt} || "%2H:%2M:%2S");
	foreach (@timefmt) {
	    if ($_ =~ /^%(\d)?(.)$/) {
		my($l, $k) = ($1, $2);
		if (!$input) {
		    $w->{Sub}{$k} =
		      $tw->Label(-width => $l,
				 -borderwidth => 0,
				)->pack(-side => 'left');
		} else {
		    $w->{Var}{$k} = undef;
		    my $dne = $w->{Sub}{$k} =
		      $tw->DateNumEntryPlain
			(-width => $l,
			 (exists $range{$k} ?
			  ((defined $range{$k}->[0]
			    ? (-minvalue => $range{$k}->[0]) : ()),
			   (defined $range{$k}->[1]
			    ? (-minvalue => $range{$k}->[1]) : ()),
			  ) : ()),
			 -textvariable => \$w->{Var}{$k},
			)->pack(-side => 'left');
		    push(@{$w->{NumEntries}}, $dne);
		}
		push(@{$tw->{Sub}}, $k);
		$w->{'len'}{$k} = $l;
	    } else {
		$tw->Label(-text => $_,
			   -borderwidth => 0,
			  )->pack(-side => 'left');
	    }
	}
	if ($input) {
	    my $f = $tw->Frame->pack(-side => 'left');
	    my $fb1 = $f->FireButton
	      (-command => sub { $w->firebutton_command($tw, +1, 'time') },
	      )->pack(-side => ($orient eq 'h' ? 'right' : 'top'));
	    push(@{$w->{IncFireButtons}}, $fb1);
	    my $fb2 = $f->FireButton
	      (-command => sub { $w->firebutton_command($tw, -1, 'time') },
	      )->pack(-side => ($orient eq 'h' ? 'right' : 'top'));
	    push(@{$w->{DecFireButtons}}, $fb2);
	}
	
    }

    if (@$choices) {
	my $b;
	my %text2time;
	if (@$choices > 1) {
	    require Tk::Optionmenu;
	    $b = $w->Optionmenu(-relief => 'raised',
				-borderwidth => 2);
	} else {
	    $b = $w->Button;
	}
	$b->pack(-side => 'left');
	foreach (@$choices) {
	    my($text, $time);
	    if (ref $_ eq 'ARRAY') {
		$text = $_->[0];
		$time = $_->[1];
	    } elsif (exists $choice{$_}) {
		$text = $choice{$_}->[0];
		$time = $choice{$_}->[1];

	    } else {
		die "Unknown choice: $_";
	    }
	    $text2time{$text} = $time;

	    if (@$choices > 1) {
		$b->addOptions($text);
	    } else {
		$b->configure(-text => $text,
			      -command => sub {
				  if (ref $time eq 'CODE') {
				      $w->set_localtime(&$time);
				  } elsif ($time eq 'RESET') {
				      $w->reset;
				  } else {
				      $w->set_localtime($time);
				  }
				  if ($w->{Configure}{-command}) {
				      $w->{Configure}{-command}->($w);
				  }
			      });
	    }
	}
	if (@$choices > 1) {
	    $b->configure(-command => sub {
			      my $time = $text2time{$_[0]};
			      if (ref $time eq 'CODE') {
				  $w->set_localtime(&$time);
			      } elsif ($time eq 'RESET') {
				  $w->reset;
			      } else {
				  $w->set_localtime($time);
			      }
			      if ($w->{Configure}{-command}) {
				  $w->{Configure}{-command}->($w);
			      }
			  });
	}
    }

    $w->ConfigSpecs
      (-repeatinterval => ['METHOD', 'repeatInterval', 'RepeatInterval', 50],
       -repeatdelay    => ['METHOD', 'repeatDelay',    'RepeatDelay',    500],
       -bell           => ['METHOD', 'bell', 'Bell', undef],
       -decbitmap      => ['METHOD',      'decBitmap',  'DecBitmap',
		           $Tk::FireButton::DECBITMAP],
       -incbitmap      => ['METHOD',      'incBitmap',  'IncBitmap',
		           $Tk::FireButton::INCBITMAP],
       -background     => ['DESCENDANTS', 'background', 'Background', undef], 
       -foreground     => ['DESCENDANTS', 'foreground', 'Foreground', undef], 
       -precommand     => ['CALLBACK',    'preCommand', 'PreCommand', undef],
       -command        => ['CALLBACK',    'command',    'Command',    undef],
       -variable       => ['METHOD',      'variable',   'Variable',   undef],
       -varfmt         => ['PASSIVE',     'varFmt',     'VarFmt',  'unixtime'],
       -value          => ['METHOD',      'value',      'Value',      undef],
      );

    $w;
}

sub value {
    my($w, $value) = @_;
    my $varfmt = $w->{Configure}{-varfmt};
    my $var;
    if ($value eq 'now') {
	$w->set_localtime($value);
    } elsif ($varfmt eq 'unixtime') {
	tie $var, 'Tk::Date::UnixTime', $w, $value;
	untie $var;
    } elsif ($varfmt eq 'datehash') {
	tie $var, 'Tk::Date::DateHash', $w, $value;
	untie $var;
    } else {
	die;
    }
}

sub decbitmap {
    my $w = shift;
    $w->subwconfigure($w->{DecFireButtons}, '-bitmap', @_);
}
sub incbitmap {
    my $w = shift;
    $w->subwconfigure($w->{IncFireButtons}, '-bitmap', @_);
}
sub repeatinterval {
    my $w = shift;
    $w->subwconfigure([@{$w->{DecFireButtons}}, @{$w->{IncFireButtons}}],
		      '-repeatinterval', @_);
}
sub repeatdelay {
    my $w = shift;
    $w->subwconfigure([@{$w->{DecFireButtons}}, @{$w->{IncFireButtons}}],
		      '-repeatdelay', @_);
}
sub bell {
    my $w = shift;
    $w->subwconfigure($w->{NumEntries}, '-bell', @_);
}

sub subwconfigure {
    my($w, $subw, $key, $val) = @_;
    my @w = @$subw;
    if (@_ > 3) {
	foreach (@w) {
	    $_->configure($key => $val);
	}
    } else {
	if (@w) {
	    $w[0]->cget($key);
	} else {
	    undef;
	}
    }
}

sub variable {
    my($w, $varref) = @_;
    if (@_ > 1 and defined $varref) {
	my $varfmt = $w->{Configure}{-varfmt};
	if ($varfmt eq 'unixtime') {
	    tie $$varref, 'Tk::Date::UnixTime', $w, $$varref; # XXX
	} elsif ($varfmt eq 'datehash') {
	    tie $$varref, 'Tk::Date::DateHash', $w, $$varref;
	} else {
	    tie $$varref, $varfmt, $w, $$varref;
	}
	$w->{Configure}{-variable} = $varref;
#	$w->OnDestroy(sub { $w->DESTROY });
    } else {
	$w->{Configure}{-variable};
    }
}

# should be eliminated or renamed ... only "now" is still needed
sub set_localtime {
    my($w, $setdate) = @_;
    if (defined $setdate and $setdate eq 'now') {
	$setdate = time();
    }
    if (!defined $setdate or ref $setdate ne 'HASH') {
	my @t;
	if (defined $setdate) {
	    @t = localtime $setdate;
	} else {
	    @t = localtime;
	}
	$setdate = { 'S' => $t[0],
		     'M' => $t[1],
		     'H' => $t[2],
		     'd' => $t[3],
		     'm' => $t[4]+1,
		     'y' => $t[5]+1900,
		     'A' => $t[6]
		   };
    }

    foreach (qw(y m d H M S)) { # umgekehrte Reihenfolge!
	if (defined $setdate->{$_}) {
	    $w->set_date($_, $setdate->{$_});
	}
    }
}

sub reset {
    my $w = shift;
    foreach my $key (qw(A y m d H M S)) {
	my $sw = $w->{Sub}{$key};
	if (Tk::Exists($sw)) {
	    if ($key eq 'A' || $sw->isa('Tk::Label')) {
		$sw->configure(-text => '');
	    } else {
		$sw->delete(0, 'end');
		$sw->insert(0, '');
	    }
	}
    }
}

sub get {
    my($w, $fmt) = @_;
    $fmt = '%+' if !defined $fmt;
    my %date;
    foreach (qw(y m d H M S)) {
	$date{$_} = $w->get_date($_);
	if ($date{$_} eq '') { $date{$_} = 0 }
    }
    $date{'m'}--;
    $date{'y'}-=1900;
# XXX weekday should also be set
    strftime($fmt, @date{qw(S M H d m y)});
}

sub get_date {
    my($w, $key, $defined) = @_;
    my $sw = $w->{Sub}{$key};
    if (Tk::Exists($sw)) {
	if ($sw->isa('Tk::Entry')) {
	    my $r;
	    if (ref $w->{Var}{$key} eq 'SCALAR') {
		$r = $ {$w->{Var}{$key}}; # XXX NumEntryPlain ist buggy
	    } else {
		$r = $sw->get;
	    }
	    if (!defined $r or $r eq '') {
		$r = _now($key);
	    }
	    $r;
	} elsif ($sw->isa('Tk::Label')) {
	    $sw->cget(-text);
	}
    }
}

sub set_date {
    my($w, $key, $value) = @_;

    $value = 0 if !defined $value; # XXX ???

    if ($key eq 'd') {
	if ($value < 1) {
	    my $m = $w->set_date('m', $w->get_date('m')-1);
	    $value = _monlen($m, $w->get_date('y'));
	} else {
	    my $m = $w->get_date('m');
	    if ($value > _monlen($m, $w->get_date('y'))) {
		$value = 1;
		$w->set_date('m', $m+1);
	    }
	}
    } elsif ($key eq 'm') {
	if ($value < 1) {
	    $value = 12;
	    $w->set_date('y', $w->get_date('y')-1);
	} elsif ($value > 12) {
	    $value = 1;
	    $w->set_date('y', $w->get_date('y')+1);
	}
    } elsif ($key eq 'H') {
	if ($value < 0) {
	    $value = 23;
	    $w->set_date('d', $w->get_date('d')-1);
	} elsif ($value > 23) {
	    $value = 0;
	    $w->set_date('d', $w->get_date('d')+1);
	}
    } elsif ($key eq 'M') {
	if ($value < 0) {
	    $value = 59;
	    $w->set_date('H', $w->get_date('H')-1);
	} elsif ($value > 59) {
	    $value = 0;
	    $w->set_date('H', $w->get_date('H')+1);
	}
    } elsif ($key eq 'S') {
	if ($value < 0) {
	    $value = 59;
	    $w->set_date('M', $w->get_date('M')-1);
	} elsif ($value > 59) {
	    $value = 0;
	    $w->set_date('M', $w->get_date('M')+1);
	}
    }

    my $sw = $w->{Sub}{$key};
    if (Tk::Exists($sw)) {
	if ($key eq 'A') {
	    $sw->configure(-text => $value);
	} else {
	    my $v = sprintf("%0".$w->{'len'}{$key}."d", $value);
	    if ($sw->isa('Tk::Entry')) {
		$sw->delete(0, 'end');
		$sw->insert(0, $v);
	    } elsif ($sw->isa('Tk::Label')) {
		$sw->configure(-text => $v);
	    }
	}
    }

    if ($key eq 'd') {
	my $d = $w->get_date('d');
	if ($d eq '') { $d = 0 }
	my $m = $w->get_date('m');
	if ($m eq '') { $m = 0 }
	my $y = $w->get_date('y');
	if ($y eq '') { $y = 0 }
	# XXX make independent from mktime
	my $t = mktime(0,0,0, $d, $m-1, $y-1900);
	if (defined $t) {
	    $w->set_date('A', strftime "%A", localtime($t));
	}
    }

    $value;
}

sub _monlen {
    my($mon, $year) = @_;
    if ($mon != 2) {
	$monlen[$mon];
    } elsif ($year % 4 == 0 &&
	     (($year % 100 != 0) || ($year % 400 == 0))) {
	29;
    } else {
	28;
    }
}

sub _now {
    my($k) = @_;
    my @now = localtime;
    if    ($k eq 'y') { $now[5]+1900 }
    elsif ($k eq 'm') { $now[4]+1 }
    elsif ($k eq 'd') { $now[3] }
    elsif ($k eq 'H') { $now[2] }
    elsif ($k eq 'M') { $now[1] }
    elsif ($k eq 'S') { $now[0] }
    else { @now }
}

sub inc_date {
    my($w, $ww, $inc) = @_;
    my $current_focus = $w->focusCurrent;
    foreach (@{$ww->{Sub}}) {
	if ($current_focus eq $w->{Sub}{$_}) {
	    $w->set_date($_, $w->get_date($_, 1)+$inc);
	    return;
	}
    }
    if ($ww eq $w->{SubWidget}{'dateframe'}) {
	$w->set_date('d', $w->get_date('d', 1)+$inc);
    } else {
	$w->set_date('S', $w->get_date('S', 1)+$inc);
    }
}

sub firebutton_command {
    my($w, $cw, $inc, $type) = @_;
    if ($w->{Configure}{-precommand}) {
	return unless $w->{Configure}{-precommand}->($w, $type, $inc);
    }
    $w->inc_date($cw, $inc);
    if ($w->{Configure}{-command}) {
	$w->{Configure}{-command}->($w, $type, $inc);
    }
}

sub _fmt_to_array {
    my $fmt = shift;
    my @a = split(/(%\d*[dmyAHMS])/, $fmt);
    shift @a if $a[0] eq '';
    @a;
}

## XXX causes segmentation fault
sub _Destroyed {
    my $w = shift;
    if ($] >= 5.00452) {
	my $varref = $w->{Configure}{'-variable'};
warn "varref is $varref";
	if (defined $varref) {
warn "Untie $varref (val before $$varref)";
	    untie $$varref;
warn "val after: $$varref";
	}
    }
    $w->SUPER::DESTROY($w);
}

######################################################################

package Tk::Date::NumEntryPlain;
use vars qw(@ISA);
@ISA = qw(Tk::NumEntryPlain);
Construct Tk::Widget 'DateNumEntryPlain';

sub value { }

sub incdec {
    my($e, $inc, $i) = @_;
    my $val = $e->get;

    # XXX $inc == 0 -> range check
    if (defined $inc and $inc != 0) {
	my $dw = $e->parent->parent; # XXX dangerous
	my $fw = $e->parent;
	$dw->inc_date($fw, $inc);
    }
}

######################################################################

package Tk::Date::UnixTime;
#use Carp qw(cluck);

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
#    cluck "STORE @_";
    my($self, $value) = @_;
    my(@t) = localtime $value;
    my $setdate = { 'S' => $t[0],
		    'M' => $t[1],
		    'H' => $t[2],
		    'd' => $t[3],
		    'm' => $t[4]+1,
		    'y' => $t[5]+1900,
		    'A' => $t[6]
		  };
    foreach (qw(y m d H M S)) { # umgekehrte Reihenfolge!
	$self->{Widget}->set_date($_, $setdate->{$_});
    }
}

sub FETCH {
#    cluck "FETCH @_";
    my $self = shift;
    $self->{Widget}->get("%s");
}

######################################################################


package Tk::Date::DateHash;

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
    foreach (qw(y m d H M S)) { # umgekehrte Reihenfolge!
	$self->{Widget}->set_date($_, $value->{$_});
    }
}

sub FETCH {
    my $self = shift;
    my $datehash = {};
    foreach (qw(y m d H M S)) {
	$datehash->{$_} = $self->{Widget}->get_date($_);
    }
    $datehash;
}

######################################################################

1;

__END__

=head1 NAME

Tk::Date - a date/time widget for perl/Tk

=head1 SYNOPSIS

    use Tk::Date;
    $date_widget = $top->Date->pack;
    $date_widget->get("%x %X");

=head1 DESCRIPTION

Tk::Date implements a date/time widget. There are three ways to input
a date:

=over 4

=item * Using the keyboard to input the digits and the tab key or the mouse
pointer to move focus between fields.

=item * Using up and down cursor keys to increment/decrement the date.

=item * Selecting up and down arrow buttons will increment or decrement
the value of the active field.

=back

=head2 The Date/Time Format

Unlike Java, Perl does not have a date/time object. However, it is
possible to use the unix time (seconds since epoch, that is 1st
January 1970) as a replacement. This is limited, since on most
architectures, the valid range is between 14th December 1901 and 19th
January 2038. For other dates, it is possible to use a hash notation:

    { y => year,
      m => month,
      d => day,
      H => hour,
      M => minute,
      S => second }

The abbreviations are derivated by the format letters of strftime.
Note that year is the full year (1998 instead of 98) and month is the
real month number, as opposed to the output of localtime().

In this document, the first method will be referred as B<unixtime> and
the second method as B<datehash>.

=head1 STANDARD OPTIONS

=over 4

Tk::Date descends from Frame and inherits all of its options.

=item -orient

Specified orientation of the increment and decrements buttons. May be
vertical (default) or horizontal.

=back

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item -bell

Specifies a boolean value. If true then a bell will ring if the user
attempts to enter an illegal character (e.g. a non-digit).

=item -choices

Creates an additional choice button. The argument to I<-choices> must be one
of C<now>, C<today>, C<yesterday> or C<tomorrow>, or an array with a
combination of those. If only one is used, only a simple button is created,
otherwise an optionmenu.

Examples:

	-choices => 'now'
	-choices => ['today', 'yesterday', 'tomorrow']

It is possible to specify user-defined values. User-defined values
should be defined as array elements with two elements. The first element
is the label for the button or optionmenu entry. The second element
specifies the time associated with this value. It may be either a date
hash (missing values are set to the current date) or a subroutine which
calculates unix seconds.

Here are two examples. The first defines an additional optionmenu
entry for this year's christmas and the second defines an entry for
the day before yesterday.

	-choices => ['today',
                     ['christmas' => { 'm' => 12, 'd' => 25}]
                    ]
        -choices => ['today',
		     'yesterday',
                     ['the day before yesterday' => sub { time()-86400*2 }]
                    ]

=item -command

Specifies a callback which is executed every time after an arrow
button is selected. The callback is called with the date widget as its
argument.

=item -decbitmap

Sets the bitmap for the decrease button. Defaults to FireButton's default
decrease bitmap.

=item -editable

If set to a false value, disables editing of the date widget. All entries
are converted to labels and there are no arrow buttons. Defaults to
true (widget is editable).

=item -fields

Specifies which fields are constructed: date, time or both. Defaults to both.

=item -incbitmap

Sets the bitmap for the increase button. Defaults to FireButton's default
increase bitmap.

=item -precommand

Specifies a callback which is executed every time when an arrow button
is selected and before actually execute the increment or decrement
command. The callback is called with following arguments: date widget,
type (either C<date> or C<time>) and increment (+1 or -1). If the
callback returns with a false value, the increment or decrement
command will not be executed.

=item -repeatinterval

Specifies the amount of time between invokations of the increment or
decrement. Defaults to 50 milliseconds.

=item -repeatdelay

Specifies the amount of time before the increment or decrement is first done 
after the Button-1 is pressed over the widget. Defaults to 500 milliseconds.

=item -value

Sets an initial value for the widget. The argument may be B<unixtime>,
B<datehash> or B<now> (for the current time).

=item -varfmt

Specifies the format of the I<-variable> or I<-value> argument. May be
B<unixtime> (default) or B<datehash>.

=item -variable

Ties the specified variable to the widget. (See Bugs)

=back

=head1 METHODS

The B<Date> widget supports the following non-standard method:

=over 4

=item B<get>([I<fmt>])

Gets the current value of the date widget. If I<fmt> is not given, the
returned value is in unix time (seconds since epoch), otherwise I<fmt> is
a format string which is fed to B<strftime>.

=back

=head1 BUGS/TODO

 - waiting for a real Date/Time object
 - tie interface (-variable) does not work if the date widget gets destroyed
   (see uncommented DESTROY)
 - get and set must use the tied variable, unless tieying does no work
   at all
 - -from/-to (limit) (or -minvalue, -maxvalue?)
 - range check (in DateNumEntryPlain::incdec)
 - am/pm
 - more intractive examples are needed for some design issues (how strong
   signal errors? ...)
 - Wochentag wird beim Hoch-/Runterzaehlen von m und y nicht aktualisiert

=head1 SEE ALSO

L<Tk>, L<Tk::NumEntryPlain>, L<Tk::FireButton>, L<POSIX>

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

=head1 COPYRIGHT

Copyright (c) 1997, 1998 Slaven Rezic. All rights reserved.
This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

