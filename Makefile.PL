use strict;
use warnings;

use Getopt::Long qw/:config no_ignore_case/;
use ExtUtils::Embed ();

GetOptions(
    'with-libevent=s' => \my $libevent_path,
) or usage() && exit;

my ($cflags, $ldflags) = check_libevent($libevent_path);
my $out = process_makefile($cflags, $ldflags);
write_makefile($out);

####

sub check_libevent {
    my ($path) = @_;
    my @try = qw{ /usr /usr/local };
    unshift @try, $path if $path;
    for my $base (@try) {
        my ($cflags, $ldflags) = map { $base . $_ } qw{/include /lib};
        my $ret = compile_libevent($cflags, $ldflags);
        return ($cflags, $ldflags) if $ret;
    }
    return ("", ""); #system
}

sub process_makefile {
    my ($cflags, $ldflags) = @_;

    my $ccopts = ExtUtils::Embed::ccopts();
    my $ldopts = ExtUtils::Embed::ldopts();
    chomp $_ for ($ccopts, $ldopts);

    ## FIXME: ld: symbol(s) not found for architecture ppc
    $ldopts =~ s/ -arch ppc //g;

    $ldopts .= " -L$ldflags" if $ldflags;
    $ccopts .= " -L$cflags"  if $cflags;

    my $mm = do {undef $/; <DATA>};
    $mm =~ s/%%LDOPTS%%/$ldopts/g;
    $mm =~ s/%%CCOPTS%%/$ccopts/g;
    return $mm;
}


sub compile_libevent {
    my ($cflags, $ldflags) = @_;
    my $test_c = <<EOF;
#include <sys/time.h>
#include <sys/types.h>
#include <event.h>
int main () {
  event_init();
  return 0;
}
EOF
    my $conftest = 'conftest.c';
    if (-f $conftest) {
        chmod 0666, $conftest;
        unlink $conftest or warn "unlink $conftest: $!";
    }
    open my $mfh, '>', $conftest or die "open $conftest for write: $!";
    print $mfh $test_c;

    my $ret = 0;
    system "cc -c -I$cflags conftest.c";
    system "cc -o /dev/null conftest.o -L$ldflags -levent";
    $ret = $? == 0 ? 1 : 0;

    unlink qw/conftest.c conftest.o/;

    return $ret;
}

sub write_makefile {
    my ($mm) = @_;

    my $new = 'Makefile';
    my $old = 'Makefile.old';

    if (-f $old) {
        chmod 0666, $old;
        unlink $old or warn "unlink $old: $!";
    }
    if ( -f $new ) {
        chmod 0666, $old;
        unlink $old;
        rename $new, $old or warn "rename $new => $old: $!";
    }
    open my $mfh, '>', $new or die "open $new for write: $!";
    print $mfh $mm;;
}

sub usage {
    print <<EOF;

Usage:
    perl $0 [--with-libevent=/usr/local]

EOF
}

__DATA__
all: evpsgi

evpsgi: evpsgi.o
	${CC} -o evpsgi evpsgi.o %%LDOPTS%% -levent

evpsgi.o: evpsgi.c
	${CC} -c evpsgi.c -I. %%CCOPTS%%

clean:
	${RM} *.o evpsgi
