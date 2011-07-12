package Getopt::Mini;
use strict;
use warnings;
use utf8::all;
 
our $VERSION = '0.01';
 
sub import {
    my $class = shift;
    my %args = @_;
    if( ! defined $args{norun} ) {
        getopt( arrays=>0, %args );
    } else {
        my $where = caller(0);
        no strict 'refs';
        *{ $where . '::getopt' } = \&getopt;
    }
    #unshift @ARGV, @barewords;
    return;
}

sub getopt_array {
    getopt( arrays=>1 , @_ );
}

sub getopt {
    my ( $last_opt, $last_done, %hash );
    my %opts;
    # get my own opts
    my @argv = @_ == 0 ? @ARGV 
      : do {
           %opts = @_; 
           die 'Missing parameter: getopt( argv=>\@ARGV )'
               unless ref $opts{argv} eq 'ARRAY';
           @{ delete $opts{argv} };
      };
    for my $opt (@argv) {
        if ( $opt =~ m/^-+(.+)/ ) {
            $last_opt = $1;
            $last_done=0;
            warn $last_opt;
            if( $last_opt =~ m/^(.*)\=(.*)$/ ) {
                push @{ $hash{$1} }, $2 ;
                $last_done= 1;
            } else {
                $hash{$last_opt} = [] unless ref $hash{$last_opt};
            }
        }
        else {
            #$opt = Encode::encode_utf8($opt) if Encode::is_utf8($opt);
            $last_opt ='' if !$opts{arrays} && ( $last_done || ! defined $last_opt );
            push @{ $hash{$last_opt} }, $opt; 
            $last_done = 1;
        }
    }
    # convert single option => scalar
    for( keys %hash ) {
        if( @{ $hash{$_} } == 0 ) {
            $hash{$_} = ();
        } elsif( @{ $hash{$_} } == 1 ) {
            $hash{$_} = $hash{$_}->[0]; 
        }
    }
    defined wantarray and return %hash;
    %ARGV = %hash;
}

sub getopt_validatex {
    my %args = @_;
    require Params::Validate;
    @_ = ( [%ARGV], \%args );
    goto \&Params::Validate::validate;
}

sub getopt_validate {
    my %args = @_;
    require Data::Validator;
    my $rule = Data::Validator->new( %args );
    @_ = ($rule, %ARGV );
    goto \&Data::Validator::validate;
}
 
1;
 
__END__

=pod 

=head1 NAME

Getopt::Mini - yet another yet-another Getopt module

=head1 SYNOPSIS

    use Getopt::Mini;
    say $ARGV{'flag'};

=head1 DESCRIPTION

This is yet another Getopt module, a very lightweight one. It's not declarative 
in any way, ie, it does not support specs, like L<Getopt::Long> does.

Actually, it can validate your parameters using the L<Data::Validator> syntax. 
But that's a hidden feature for now (you'll need to install L<Data::Validator> yourself). 

=head1 USAGE

    perl myprog.pl -h -f foo --f bar
    use Getopt::Mini;   # parses the @ARGV into %ARGV
    say YAML::Dump \%ARGV;
    ---
    h: ~
    f: 
      - foo
      - bar

Or you can just use a modular version:

    use Getopt::Mini norun=>1; # nothing happens

    getopt;   #  imports into %ARGV
    my %argv = getopt;   #  imports into %argv instead

=cut
