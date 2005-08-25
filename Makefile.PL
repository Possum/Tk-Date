use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	  => 'Tk::Date',
   'VERSION_FROM' => 'Date.pm', # finds $VERSION
   'dist' => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},
   'PM' => {'Date.pm'   => '$(INST_LIB)/Tk/Date.pm',
            'demos/date.pl' => ($] >= 5.005
				? '$(INST_ARCHLIB)'
				: '$(INST_LIB)') . '/Tk/demos/widtrib/date.pl',
	   },
   'MAN3PODS' => {'Date.pm'   => '$(INST_MAN3DIR)/Tk::Date.$(MAN3EXT)',
		 },
   'PREREQ_PM' => {'Tk'                => 402.002,
		   'Tk::NumEntryPlain' => 0.02,
		   'Tk::NumEntry'      => 1.08,
		   'Tk::FireButton'    => 0.05,
		  },
);

sub MY::postamble {
    my $postamble = '
demo :: pure_all
	$(FULLPERL) -w -I$(SITELIBEXP)/Tk/demos/widget_lib -I$(SITEARCHEXP)/Tk/demos/widget_lib -Mblib demos/date.pl

';

    if (defined $ENV{USER} && $ENV{USER} eq 'eserte' && $^O =~ /bsd/i && -f "../../perl.release.mk") {
	$postamble .= <<'EOF';

.include "../../perl.release.mk"
.include "../../perl.cvs.mk"

EOF
    }

    $postamble;
}
