package Rsynth::Elements;
use strict;
use Exporter;
use base 'Exporter';
use vars qw(@EXPORT %elem %parms @pNames @eNames);
@EXPORT = qw(read_elements write_elements %elem %parms @pNames @eNames);
use Getopt::Std;
use Sampa ();
my %opt;
getopts('c',\%opt);

my %fset;
my @fNames;

my $file = "Elements.def";

sub NULL () {undef}


sub read_elements
{
 $file = shift if @_;
 open(EL,$file) || die "Cannot read $file:$!";
 my $name;
 while(<EL>)
  {
   if (/^\{(".*",\s*.*),\s*(\/\*.*\*\/)?\s*$/)
    {
     my %args;
     my (@args) = split(/\s*,\s*/,$1);
     my @feat = split(/\|/,pop(@args));
     my %feat;
     foreach my $f (@feat)
      {
       next unless $f =~ /^[a-z]/i;
       $feat{$f} = 1;
       unless (exists $fset{$f})
        {
         push(@fNames,$f);
         $fset{$f} = 1;
        }
      }
     ($name,@args) = map(eval($_),@args);
     push(@args,\%feat);
     foreach my $parm (qw(rk du ud unicode sampa features))
      {
       $args{$parm}  = shift(@args);
       $parms{$parm} = $args{$parm};
      }
     $elem{$name} = {%args};
     push(@eNames,$name);
    }
   elsif (/^\s*\{\s*(.*?)\s*\},?\s*\/\*\s*(\w+)/)
    {
     my $parm = $2;
     my @val = split(/\s*,\s*/,$1);
     if ($parm =~ /^a/)
      {
       $val[0] = 0 if ($val[0] < 0);
       $val[0] = sprintf("%+6.1f",$val[0]);
      }
     unless (exists $parms{$parm})
      {
       $parms{$parm} = $val[0];
       push(@pNames,$parm);
      }
     $elem{$name}{$parm} = [@val];
    }
  }
 close(EL);
}

sub write_elements
{
 my $fh = shift;
 unless (ref $fh)
  {
   open(EL,">$fh") || die "Cannot open $fh:$!";
   $fh = \*EL;
  }
 my $save = select $fh;
 print $fh <<'END';
/*
    Copyright (c) 1994,2001-2003 Nick Ing-Simmons. All rights reserved.
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
    MA 02111-1307, USA

*/
END

 my @ename = @eNames;
 while (@ename)
  {
   my $name = shift(@ename);
   my @feat;
   my $sampa = $elem{$name}{sampa}; 
   if (defined $sampa)
    {
     if (exists $Sampa::unicode{$sampa})
      {
       $elem{$name}{unicode} = ord($Sampa::unicode{$sampa});
      }
     else
      {
       warn "No Unicode for $name [$sampa]\n";
       $elem{$name}{unicode} = ord($sampa);
      }  
    } 
   my @args = qw(rk du ud unicode);
   @args = @{$elem{$name}}{@args};
   foreach my $k (qw(sampa))
    {
     my $v = $elem{$name}{$k};
     if (defined $v)
      {
       $v =~ s#([\\"])#\\$1#g;
      }
     $v = (defined $v) ? qq["$v"] : 'NULL';
     push(@args,$v);
    }
   foreach my $f (@fNames)
    {
     push(@feat,$f) if $elem{$name}{'features'}{$f};
    }
   push(@args,(@feat) ? join('|',sort @feat) : 0);
   printf qq({"$name", %3d,%2d,%2d,0x%04X,%s,%s,\n {\n),@args;
   my @pname = @pNames;
   while (@pname)
    {
     my $parm = shift(@pname);
     my @vals = @{$elem{$name}{$parm}};
     printf "  {%6g,%4d,%3d,%3d,%3d}%s /* %-3s */\n",
       @vals,((@pname) ? ',' : ' '),$parm;
    }
    printf " }\n}%s\n",((@ename) ? ",\n" : ' ');
  }
 select $save;
}

1;
