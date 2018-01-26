#!/usr/bin/perl
# Copyright 2010 Ankur Sinha 
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
# Fn : rtorrentQM.pl

# This program aims to act as a queue manager to be used with rtorrent

# Standard includes
use strict;
use warnings;

use Cwd;
use Getopt::Long;
use POSIX qw(setsid);
use File::Copy;
use Time::localtime;

# globals
my ($pid) = 0;
my ($workingDir) = $ENV{HOME} . "/.local/share/rtorrentQM/";
my ($refresh) = "60";
my ($logFn) = $workingDir . "rtorrentQM.log";
my ($logFh);
my ($pidFh);
my ($numberOfDownloads) = "2";
my ($sourceDir) = $ENV{HOME} . "/dump/QMtests/rtorrent_loading/";
my (@srcFnList) = "";
# when it's empty, it's length will be 1
$srcFnList[0] = "dummy";
my ($destDir) = $ENV{HOME} . "/dump/QMtests/rtorrent_watch/";
my ($currentlyDownloadingDir) = $ENV{HOME} . "/dump/QMtests/rtorrent_sessions/";
my ($move) = "1";
my ($userConfFn) = $ENV{HOME} . "/.config/rtorrentQM/rtorrentQM.conf";
my ($systemConfFn) ="/etc/rtorrentQM.conf";
my ($pidFn) = $workingDir . "pid";
my ($currentDLCount) = "0";

my ($usage) = "rtorrentQM: A queue manager for rtorrent
Copyright 2011 Ankur Sinha <ankursinha\@fedorproject.org>
Usage:
-s, --state
	Print current running instance's state.

-w DIR, --workdir=DIR
	Working dir for application (default: $workingDir).

-l LOGFILE, --log=LOGFILE
	Fn to print logs to (default: $logFn).

-k, --kill
	Kill current running instance.

-c CONFFILE, --config=CONFFILE
	Path to configuration file (default: $userConfFn).

-s SOURCEDIR, --sourcedir=SOURCEDIR
	Path to dir containing torrent files (default: $sourceDir).

-d DESTDIR, --destdir=DESTDIR
	Path to dir to which files will be moved (default: $destDir).

-r CURRENTLYDOWNLOADINGDIR, --rtorrentSessions CURRENTLYDOWNLOADINGDIR
	Path to the rtorrent SESSIONS dir (default: $currentlyDownloadingDir).

-n NUM, --number=NUMBER
	The number of simultaneous downloads (default: $numberOfDownloads).
	This option can also be used to update the value while the script is running.

-m, --move
	Copy file or move (default: move).

-i NUM, --refresh=NUMBER
	Refresh interval in seconds (default: $refresh).

-o, --order
	Reorder torrents list.
";

# subs
sub orderFns
{
}

sub printUsage
{
	print $usage;
}

sub incCount
{
	$numberOfDownloads += 1;
	print $logFh "Received SIGHUP, incrementing number of simultaneous dls\n";
	print $logFh "Value now is $numberOfDownloads\n";

}
sub decCount
{
	$numberOfDownloads -= 1;
	print $logFh "Received SIGQUIT, decrementing number of simultaneous dls\n";
	print $logFh "Value now is $numberOfDownloads\n";

}

sub readConfig
{
	my ($confFn) = "";
	my ($confFh);
	my ($line) = "";
	my ($name) = "";
	my ($value) = "";

	if( -e $userConfFn )
	{
		$confFn = $userConfFn;
	}
	elsif( -e $systemConfFn )
	{
		$confFn = $systemConfFn;
	}
	else 
	# Do nothing, use hard coded defaults
	{
		print $logFh "No config file found, using hard coded defaults\n";
		return 0;
	}
	open $confFh, "<" , $confFn or die "Could not open $confFn - $!";

	#print $logFh "Found a config file at $confFn.. Parsing\n";

	while (my $line  = <$confFh>)
	{
		$name = "";
		$value = "";

		chomp($line);
		$line =~ s/^\s*//;			# remove whitespace at beginning of line
		$line =~ s/\s*$//;			# remove whitespace at end of line
		if ( !($line =~ m/^#/) && ($line ne "") )
		{
			($name,$value) = split(/=/,$line);
			$name =~ s/^\s*//;			# remove whitespace at beginning of line
			$name =~ s/\s*$//;			# remove whitespace at end of line
			$value =~ s/^\s*//;			# remove whitespace at beginning of line
			$value =~ s/\s*$//;			# remove whitespace at end of line

			if($name =~ m/work_dir/)
			{
				$workingDir = $value;
			}
			elsif ($name =~ m/number_of_downloads/)
			{
				$numberOfDownloads = $value;
			}
			elsif ($name =~ m/source_dir/)
			{
				$sourceDir = $value;
			}
			elsif ($name =~ m/destination_dir/)
			{
				$destDir = $value;
			}
			elsif ($name =~ m/currently_downloading_dir/)
			{
				$currentlyDownloadingDir = $value;
			}
			elsif ($name =~ m/refresh_interval/)
			{
				$refresh = $value;
			}
			else
			{
				print STDERR "found weird variable in conf file $name.\nIgnoring\n";
				# do nothing, unrecognized option!
			}
			#print $logFh "found .. $name -> $value\n";
		}

	}

	close($confFh);

}


sub getSourceFnsList
{
	if ( -d "$sourceDir" )
	{
		opendir(SRCDIR, "$sourceDir") or die $!;
	}
	else 
	{
		print $logFh "did not find a directory ..$sourceDir..\nCreating...";
		mkdir ("$sourceDir",0700) or die $!;
	}

	while (my $file = readdir(SRCDIR))
	{
		my ($present) = 0;

		next if ($file =~ m/^\./);
		if($file =~ m/\.torrent$/)
		{
			# check if already present
			if(@srcFnList != 0)
			{
				foreach (@srcFnList)
				{
					if( $_ eq $file)
					{
						$present = 1;
						last;
					}
				}
			}
			if ($present == 0)
			{
				push(@srcFnList,$file);
				print $logFh "Found new torrent file: $file\n";
			}
		}
	}
	closedir(SRCDIR);
	#print $logFh "list is @srcFnList\n";
}

sub getCurrentDLCount
{
	$currentDLCount = 0;

	opendir(DESTDIR, $currentlyDownloadingDir) or die $!;
	while (my $file = readdir(DESTDIR))
	{
		next if ($file =~ m/^\./);

		if($file =~ m/\.torrent$/)
		{
			$currentDLCount++;
		}
	}
	closedir(DESTDIR);
}

sub doJob
{
	print $$;
	# add my signal handlers

	# kill -2
	$SIG{'INT'} = 'killProcess';
	# kill -1
	$SIG{'HUP'} = 'incCount';
	# kill -3
	$SIG{'QUIT'} = 'decCount';

	readConfig();

	if ( -e $pidFn )
	{
		print STDERR "$pidFn already exists. Another instance must be running.\n";
		open $pidFh, "<" , $pidFn or die "Could not open $pidFn - $!";
		my ($oldPID) = <$pidFh>;
		print STDERR "PID file says $oldPID is running!\n";
		close($pidFh);
		exit 0;
	}

	daemonize();

	# main loop
	while(1)
	{
		getSourceFnsList();
		getCurrentDLCount();

		my ($topFn) = "";
		my ($srcFn) = "";
		my ($desFn) = "";

		if ($currentDLCount < $numberOfDownloads)
		{
			if(scalar (@srcFnList) != 1)
			{
				$topFn = pop(@srcFnList);
				$srcFn = "$sourceDir" . "$topFn";
				$desFn = "$destDir" . "$topFn";

				if( ! -d $destDir)
				{
					print $logFh "did not find a directory $destDir.\nCreating...";
					(mkdir ("$destDir",0700) or die $!);
				}
				move("$srcFn", "$desFn") or print $logFh "list is @srcFnList, src is $srcFn, dest is $desFn. error: $!" and die; 
				print $logFh "Moved $srcFn to $desFn\n";
			}
		}
		else
		{
			#print $logFh "Sessions dir full, not moving.\n";
		}
		sleep($refresh);
	}

}

sub printState
{
	open my $pidFh , "<" , $pidFn  or die "Could not open $pidFn - $!";
	my ($oldPID) = <$pidFh>;
	print "$oldPID\n";
	close($pidFh);
}

sub setState
{
	open my $pidFh, ">" , $pidFn or die "Could not open $pidFn - $!";
	print $pidFh $pid;
	close($pidFh);
}

sub killProcess
{
	close($logFh);
	unlink($pidFn) or die $!;
	exit 0;
}

sub daemonize
{
	# change to working dir. If it doesn't exist, create it.
	if (! -d $workingDir )
	{
		mkdir ("$workingDir",0700) or die $!;

		open $logFh,">>", $logFn or die "Could not open $logFn - $!";
		# make $logFh HOT : http://perl.plover.com/FAQs/Buffering.html
		select((select($logFh), $|=1)[0]);
		print $logFh "Did not find a directory $workingDir.\nCreated...";
	}
	else 
	{
		open $logFh,">>", $logFn or die "Could not open $logFn - $!";
		select((select($logFh), $|=1)[0]);

	}
	chdir("$workingDir") or die $!;

	open STDIN, '/dev/null'   or die "Can't read /dev/null: $!";
	open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
	#open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";
	defined($pid = fork) or die "Can't fork: $!";

	# make the parent process quit
	if($pid)
	{
		setState();
		close($logFh);
		exit 0;
	}
	setsid  or die "Can't start a new session: $!";
	umask 755;
}


doJob
