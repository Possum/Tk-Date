# -*- perl -*-

package Bundle::Tk-Date;

$VERSION = sprintf("%d.%02d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/);

1;

__END__

=head1 NAME

Bundle::Tk-Date - A bundle to install all dependencies of Tk-Date

=head1 SYNOPSIS

 perl -MCPAN -e 'install Bundle::Tk-Date'

=head1 CONTENTS

Tk::NumEntryPlain 0.02 - Entry widget for integer numbers

Tk::FireButton 0.01    - For up/down buttons

POSIX                  - for strftime and mktime

Bundle::Tk             - :-)

Tk::Date               - This module itself

=head1 DESCRIPTION

This bundle defines all required modules for Tk::Date.

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

=cut
