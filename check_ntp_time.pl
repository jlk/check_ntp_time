#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------------------------------
#
# Program Name: check_ntp_time.pl
# Purpose:      Check if the server clock is in syncronization with the NTP server clock
# Date:         15/09/2011
# Author:       Antonio Fernando Evangelista
#
#--------------------------------------------------------------------------------------------------------------

use vars qw($opt_h $opt_H $opt_s $opt_c $opt_f $opt_u $opt_w $opt_C $opt_v %exit_codes);

#-----------------------------------------------------------------------------
# Show usage
#-----------------------------------------------------------------------------
sub usage() {
  print "\ncheck_ntp_time.pl v1.0 - Nagios Plugin\n\n";
  print "usage:\n";
  print " check_ntp_time.pl <-H ntpserver> <-w warnlevel> <-c critlevel>\n\n";
  print "options:\n";
  print " -H ntpserver   Hostname or IP address of the ntp server\n";
  print " -w seconds     Difference in seconds from the ntpserver clock and the server clock which the plugin will emit a warning alarm - Default = 150 seconds (above or below)\n";
  print " -c seconds     Difference in seconds from the ntpserver clock and the server clock which the plugin will emit a critical alarm - Default = 300 seconds (above or below)\n";
  print "\nCopyright (C) 2011 Antonio Fernando Evangelista <afevangelista\@uol.com.br>\n";
  print "check_ntp_time.pl comes with absolutely NO WARRANTY either implied or explicit\n";
  print "This program is licensed under the terms of the\n";
  print "GNU General Public License (check source code for details)\n";
  exit (0);
}

#-----------------------------------------------------------------------------
# Check execution parameters
#-----------------------------------------------------------------------------
sub init {

    getopts('c:w:H:h');

    if ($opt_h)
    {
	&usage;
	exit(0);
    }

    if (!$opt_w or $opt_w == 0)
    {
	$opt_w = 150;
    }

    if (!$opt_c or $opt_c == 0)
    {
	$opt_c = 300;
    }

    if ($opt_w >= $opt_c) {
      print "*** WARN level must be less than CRITICAL!\n";
      &usage;
    }
}

#-----------------------------------------------------------------------------
# Main Routine
#-----------------------------------------------------------------------------
use strict;
use Getopt::Std;
use Net::NTP;

my $ntpserver;

init();

my $warningpos = $opt_w;
my $warningneg = $opt_w * (-1);
my $criticalpos = $opt_c;
my $criticalneg = $opt_c * (-1);

if(!$opt_H)
{
    $ntpserver="172.16.4.253";
}
else
{
    $ntpserver=$opt_H;
}

# Check if NTP Server is alive
my $checkalive = 'ping ' . $ntpserver . ' -n 1 -m 2 | grep "packet loss" | awk ' . "'{print \$7}' | tr -d '%'";
my $hostalive = `$checkalive`;
if($hostalive>0)
{
    printf ("NTP CRITICAL: NTP Server %s is unreachable\n",$ntpserver);
    exit 2;
}


my %ntp = get_ntp_response("$ntpserver");
my $localtime=time();

my $offset =(($ntp{'Receive Timestamp'} - $ntp{'Originate Timestamp'}) + ($ntp{'Transmit Timestamp'} - $localtime) / 2);

     if($offset >=0 )
     {
         if ( $offset >= $criticalpos )
         {
             printf ("NTP CRITICAL: Offset %.6f secs|offset=%.6fs;%.6f;%.6f;\n", $offset, $offset, $warningpos, $criticalpos);
             exit 2;
         }
         elsif ( $offset >= $warningpos )
         {
             printf ("NTP WARNING: Offset %.6f secs|offset=%.6fs;%.6f;%.6f;\n", $offset, $offset, $warningpos, $criticalpos);
             exit 1;
         }
         else
         {
             printf ("NTP OK: Offset %.6f secs|offset=%.6fs;%.6f;%.6f;\n", $offset, $offset, $warningpos, $criticalpos);
             exit 0;
         }
     }

     if ( $offset <= $criticalneg )
     {
         printf ("NTP CRITICAL: Offset %.6f secs|offset=%.6fs;%.6f;%.6f;\n", $offset, $offset, $warningneg, $criticalneg);
         exit 2;
     }
     elsif ( $offset <= $warningneg )
     {
         printf ("NTP WARNING: Offset %.6f secs|offset=%.6fs;%.6f;%.6f;\n", $offset, $offset, $warningneg, $criticalneg);
         exit 1;
     }
     else
     {
         printf ("NTP OK: Offset %.6f secs|offset=%.6fs;%.6f;%.6f;\n", $offset, $offset, $warningneg, $criticalneg);
         exit 0;
     }

