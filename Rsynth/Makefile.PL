use ExtUtils::MakeMaker;
use File::Basename;

my $audio = ".../Audio";
eval "require Audio::Data";
unless ($@)
 {
  $audio = dirname($INC{"Audio/Data.pm"});
 }
else
 {
  warn "_Need_ Audio::Data:$@"
 }

WriteMakefile(
  NAME => "Rsynth::Audio",
  MYEXTLIB => "librsynth.a",
  INC => "-I.. -I$audio",
  TYPEMAPS => ["typemap","$audio/typemap"],
  VERSION_FROM => "Audio.pm",
  PREREQ_PM => { 'Audio::Data' => 1.000 },
  PREREQ_FATAL => 1,
);
