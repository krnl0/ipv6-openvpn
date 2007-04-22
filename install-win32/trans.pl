#!/usr/bin/perl

# This script translates a simple definition-based grammar
# to either C, sh, Javascript, or in (in = identity grammar, i.e.
# same grammar as input).
#
# Input grammar:
#   (1) comments having ';' or '#' as the first char in the line
#   (2) a blank line
#   (3) include "file"
#   (4) define foo bar
#   (5) define foo "bar"
#
# Environmental variables can be used to override a setting.
# The special value "null" causes the variable to be undefined.
# If an environmental value is bracketed, i.e [abc], the brackets
# will be converted to double quotes prior to output.

sub comment {
  my ($cmt) = @_;
  print "//$cmt\n" if ($mode =~ /^(c|js|h)$/);
  print "#$cmt\n" if ($mode =~ /^(sh|nsi|in)$/);
}

sub define {
  my ($name, $value) = @_;
  if ($mode eq "sh") {
    print "[ -z \"\$$name\" ] && export $name=$value\n";
    print "[ \"\$$name\" = \"$nulltag\" ] && unset $name\n";
  } else {
    if ($ENV{$name}) {
      $value = $ENV{$name};
      $value = "\"$1\"" if ($value =~ /\[(.*)\]$/);
    }
    if ($value ne $nulltag) {
      print "#define $name $value\n" if ($mode =~ /^(c|h)$/);
      print "!define $name $value\n" if ($mode eq "nsi");
      print "define $name $value\n" if ($mode eq "in");
      print "var $name=$value;\n" if ($mode eq "js");
    } else {
      print "//#undef $name\n" if ($mode =~ /^(c|h)$/);
      print "#!undef $name\n" if ($mode eq "nsi");
      print ";undef $name\n" if ($mode eq "in");
      print "//undef $name\n" if ($mode eq "js");
    }
  }
}

sub include_file {
  local $_;
  $include_file_level++;
  die "!include file nesting too deep" if ($include_file_level > $max_inc_depth);
  my ($parm) = @_;
  my $fn = "$incdir/$parm";
  local *IN;
  open(IN, "< $fn") or die "cannot open $fn";
    while (<IN>) {
      chomp;
      if (/^\s*$/) {
	print "\n";
      } elsif (/^[#;](.*)$/) {
	comment ($1);
      } elsif (/^define\s+(\w+)\s+(.+)$/) {
	define ($1, $2);
      } elsif (/^include\s+"(.+)"/) {
	include_file ($1);
      } else {
	die "can't parse this line: $_\n";
      }
    }
  $include_file_level--;
}

die "usage: trans <c|h|sh|js|nsi|in> [-I<dir>] [files ...]" if (@ARGV < 1);

($mode) = shift(@ARGV);
die "mode must be one of c, h, sh, js, nsi, or in" if !($mode =~ /^(c|h|sh|js|nsi|in)$/);

$nulltag = "null";
$max_inc_depth = 10;
$include_file_level = 0;
$incdir = ".";

comment(" This file was automatically generated by trans.pl");

while ($arg=shift(@ARGV)) {
  if ($arg =~ /^-/) {
    if ($arg =~ /^-I(.*)$/) {
      $incdir = $1;
    } else {
      die "unrecognized option: $arg";
    }
  } else {
    print "\n";
    include_file ($arg);
  }
}
