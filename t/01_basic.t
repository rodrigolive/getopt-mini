use strict;
use warnings;

use Test::More;

use Getopt::Mini norun=>1;

{
    my %args = getopt( argv=>[ '-d', '99' ] );
    is $args{d}, 99, 'first arg';
}

done_testing;
