# Localized date widgets.

use strict;
use vars qw($MW);

use File::Basename qw(basename);
use File::Glob qw(bsd_glob);
use POSIX;
use Tk;
use Tk::Date;
use Tk::Pane;

sub localized_date {
    my($demo) = @_;
    my $demo_widget = $MW->WidgetDemo
      (
       -name             => $demo,
       -text             => 'Localized date widgets.',
       -title            => 'Localized date widgets',
       -iconname         => 'Loc. date widgets',
      );
    $demo_widget->geometry("640x400+10+10");

    my $mw = $demo_widget->Top;   # get geometry master

    my $p = $mw->Scrolled("Pane",
			  -scrollbars => "osoe",
			  -sticky => "ne",
			  -gridded => 'y',
			 )->pack(qw(-fill both -expand 1));

    my $msg = $mw->Message(-text => "Loading locales.\n\nThis may take some time for computing locales and rendering fonts.")
	->place(-x => 0, -y => 0, -relwidth => 1, -relheight => 1);
    $msg->update;

    my $row = 0;
    for my $localedir ('/usr/share/locale') {
	my @locales = grep { -d } bsd_glob("$localedir/*");
	for my $locale (@locales) {
	    $locale = basename $locale;
	    POSIX::setlocale(POSIX::LC_TIME(), $locale);
	    my $got_locale = POSIX::setlocale(POSIX::LC_TIME());
	    next if $locale ne $got_locale;
	    undef $Tk::Date::weekdays;
	    undef $Tk::Date::monthnames;
	    $p->Label(-text => $got_locale)->grid(-row => $row, -column => 0, -sticky => 'e');
	    $p->Date(-datefmt => "%A, %4y-%m-%2d",
		     -fields  => 'date',
		     -monthmenu => 1,
		     -value   => 'now',
		    )->grid(-row => $row, -column => 1, -sticky => 'e');
	    $row++;
	    #our $x;last if $x++>10;
	}
    }

    $msg->destroy;
}

return 1 if caller();

require WidgetDemo;

$MW = new MainWindow;
$MW->geometry("+0+0");
$MW->Button(-text => 'Close',
	    -command => sub { $MW->destroy })->pack;
localized_date('localized_date');
MainLoop;

__END__
