#!/usr/bin/perl
use strict;
use warnings;

# For POSIX with strftime that dies
use lib 't/inc';

use Test::More;
use Tk;

BEGIN {
    if ( eval { require Date::Format } ) {
        plan tests => 1;
    }
    else {
        plan skip_all => 'Date::Format not installed';
    }
}

my $top = MainWindow->new;
my $date = $top->Date;
ok eval { $date->get('%Y-%m-%d %H:%M:%S') }, "Get with Date::Format succeed.";
