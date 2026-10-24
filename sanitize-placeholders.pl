#!/usr/bin/perl
# Guard against Fusion crashes caused by stale translations.
#
# Fusion formats many strings with boost::format (%1%, %2%, ...). If a translated
# string has a different set of placeholders than the English one shipped with the
# installed build, boost throws too_many_args / too_few_args and Fusion crashes
# (e.g. right after creating a new design). Autodesk adds/changes placeholders in
# updates, so a translation that was fine yesterday can crash tomorrow.
#
# For every ru-RU label whose placeholders do not match the installed en-US string,
# this script resets it to the current English text (translation="" + current
# devLabel), so Fusion shows English for that one string instead of crashing.
#
# Usage: perl sanitize-placeholders.pl <en-US dir> <ru-RU dir>   (edits ru-RU in place)

use strict;
use warnings;

my ($en_dir, $ru_dir) = @ARGV;
die "Usage: $0 <en-US dir> <ru-RU dir>\n" unless $en_dir && $ru_dir && -d $en_dir && -d $ru_dir;

sub slurp { my ($p) = @_; open(my $fh, '<:raw', $p) or die "$p: $!\n"; local $/; my $s = <$fh>; close $fh; $s }

# Unique set of formatting tokens: %N%, %%, printf-style %s/%d, {name}, stray %.
sub tokens {
    my ($s) = @_;
    my %t = map { $_ => 1 } ($s =~ /(%\d+%|%%|%[a-zA-Z]|\{\w+\}|%)/g);
    join(' ', sort keys %t);
}

sub attr { my ($tag, $name) = @_; $tag =~ /\s$name="([^"]*)"/ ? $1 : undef }

my $fixed = 0;
opendir(my $dh, $ru_dir) or die "$ru_dir: $!\n";
for my $file (sort grep { /\.xml$/ } readdir $dh) {
    my $en_path = "$en_dir/$file";
    next unless -f $en_path;

    my %en;
    for my $tag (slurp($en_path) =~ /(<label\s[^>]*?\/>)/g) {
        my $k = attr($tag, 'commandName');
        $en{$k} = attr($tag, 'devLabel') // '' if defined $k;
    }

    my $ru_path = "$ru_dir/$file";
    my $ru = slurp($ru_path);
    my $n = 0;
    $ru =~ s{(<label\s[^>]*?/>)}{
        my $tag = $1;
        my $k = attr($tag, 'commandName');
        my $tr = attr($tag, 'translation') // '';
        my $dev = attr($tag, 'devLabel') // '';
        my $effective = $tr ne '' ? $tr : $dev;
        if (defined $k && exists $en{$k} && tokens($effective) ne tokens($en{$k})) {
            $n++;
            qq{<label commandName="$k" devLabel="$en{$k}" translation="" />};
        } else {
            $tag;
        }
    }ge;

    if ($n) {
        open(my $out, '>:raw', $ru_path) or die "$ru_path: $!\n";
        print $out $ru;
        close $out;
        print "  $file: reset $n string(s) to English\n";
        $fixed += $n;
    }
}
closedir $dh;
print "Placeholder check: $fixed string(s) reset to English\n";
