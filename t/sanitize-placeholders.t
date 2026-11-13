use strict;
use warnings;

use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use Test::More;

my $script = File::Spec->catfile($Bin, '..', 'sanitize-placeholders.pl');
ok(-f $script, 'sanitizer script exists');

sub write_file {
    my ($path, $contents) = @_;
    open(my $fh, '>:raw', $path) or die "Cannot write $path: $!\n";
    print {$fh} $contents or die "Cannot write $path: $!\n";
    close($fh) or die "Cannot close $path: $!\n";
}

sub read_file {
    my ($path) = @_;
    open(my $fh, '<:raw', $path) or die "Cannot read $path: $!\n";
    local $/;
    my $contents = <$fh>;
    close($fh) or die "Cannot close $path: $!\n";
    return $contents;
}

sub run_sanitizer {
    my (@args) = @_;
    open(my $fh, '-|', $^X, $script, @args) or die "Cannot run sanitizer: $!\n";
    local $/;
    my $output = <$fh> // '';
    close($fh);
    my $status = $? >> 8;
    return ($status, $output);
}

my ($usage_status) = run_sanitizer();
isnt($usage_status, 0, 'missing arguments fail');

my $root = tempdir(CLEANUP => 1);
my $en_dir = File::Spec->catdir($root, 'en-US');
my $ru_dir = File::Spec->catdir($root, 'ru-RU');
make_path($en_dir, $ru_dir);

my $english = <<'XML';
<labels>
<label commandName="mismatch" devLabel="Create %1% and %2%" translation="" />
<label commandName="reordered" devLabel="Move %1% to %2%" translation="" />
<label commandName="formats" devLabel="Tokens %1% %% %s %d {user} %" translation="" />
<label commandName="blank-translation" devLabel="Open %1%" translation="" />
<label commandName="translation-wins" devLabel="Open %1%" translation="" />
</labels>
XML

my $russian = <<'XML';
<labels>
<label commandName="mismatch" devLabel="Create localized text" translation="Localized" />
<label commandName="reordered" devLabel="Move localized text" translation="%2% before %1% and %1%" />
<label commandName="formats" devLabel="Tokens localized" translation="%d %% {user} %s %1% %1% %" />
<label commandName="blank-translation" devLabel="Open" translation="" />
<label commandName="translation-wins" devLabel="Open %1%" translation="Open without token" />
<label commandName="unknown-command" devLabel="Localized" translation="Localized" />
</labels>
XML

my $en_file = File::Spec->catfile($en_dir, 'Strings.xml');
my $ru_file = File::Spec->catfile($ru_dir, 'Strings.xml');
my $unmatched_file = File::Spec->catfile($ru_dir, 'NoEnglishCounterpart.xml');
my $non_xml_file = File::Spec->catfile($ru_dir, 'ignored.txt');
write_file($en_file, $english);
write_file($ru_file, $russian);
write_file($unmatched_file, '<label commandName="untouched" devLabel="Local" translation="Local" />');
write_file($non_xml_file, '<label commandName="untouched" devLabel="Local" translation="Local" />');

my ($status, $output) = run_sanitizer($en_dir, $ru_dir);
is($status, 0, 'valid directories complete successfully');
like($output, qr/Strings\.xml: reset 3 string\(s\) to English/, 'reports the number of reset labels');
like($output, qr/Placeholder check: 3 string\(s\) reset to English/, 'reports the total number of resets');

my $updated = read_file($ru_file);
like(
    $updated,
    qr{<label commandName="mismatch" devLabel="Create %1% and %2%" translation="" />},
    'resets a translation with missing numbered placeholders to the English label',
);
like(
    $updated,
    qr{<label commandName="blank-translation" devLabel="Open %1%" translation="" />},
    'uses devLabel when the translation is empty',
);
like(
    $updated,
    qr{<label commandName="translation-wins" devLabel="Open %1%" translation="" />},
    'checks the effective translation instead of the Russian devLabel',
);
like(
    $updated,
    qr{<label commandName="reordered" devLabel="Move localized text" translation="%2% before %1% and %1%" />},
    'allows placeholder reordering and duplicate placeholders',
);
like(
    $updated,
    qr{<label commandName="formats" devLabel="Tokens localized" translation="%d %% \{user\} %s %1% %1% %" />},
    'matches numbered, printf, escaped-percent, named, and stray-percent tokens',
);
like(
    $updated,
    qr{<label commandName="unknown-command" devLabel="Localized" translation="Localized" />},
    'leaves labels without an English commandName match unchanged',
);
is(
    read_file($unmatched_file),
    '<label commandName="untouched" devLabel="Local" translation="Local" />',
    'leaves Russian XML untouched when no English counterpart file exists',
);
is(
    read_file($non_xml_file),
    '<label commandName="untouched" devLabel="Local" translation="Local" />',
    'ignores non-XML files',
);

my ($second_status, $second_output) = run_sanitizer($en_dir, $ru_dir);
is($second_status, 0, 'a second run completes successfully');
like($second_output, qr/Placeholder check: 0 string\(s\) reset to English/, 'a second run is idempotent');
is(read_file($ru_file), $updated, 'a second run does not change the already-sanitized file');

my ($missing_dir_status) = run_sanitizer($en_dir, File::Spec->catdir($root, 'missing'));
isnt($missing_dir_status, 0, 'missing input directories fail');

done_testing();
