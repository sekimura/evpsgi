use strict;
use warnings;

use ExtUtils::Embed;
use Getopt::Long qw(:config bundling);

GetOptions(
    'libs'    => sub { cmd_libs() },
    'ldflags' => sub { cmd_ldflags() },
);

sub cmd_ldflags {
    my ($ldflags, undef) = _parse_ldopts();
    print $ldflags;
}

sub cmd_libs {
    my (undef, $libs) = _parse_ldopts();
    print $libs;
}

sub _parse_ldopts {
    my $ldopts = ExtUtils::Embed::ldopts();
    chomp $ldopts;
    my @items = split(/\s+/, $ldopts);
    my $ldflags = join(' ', grep {$_ !~ /^-l/} @items);
    my $libs    = join(' ', grep {$_ =~ /^-l/} @items);
    return ($ldflags, $libs);
}
