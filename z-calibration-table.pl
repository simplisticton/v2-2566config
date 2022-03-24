#!/usr/bin/perl

use List::Util qw( min max );
use Statistics::Basic qw(:all);
use Text::Table;
use Data::Dumper;
use strict;

my $CONFIG = '/home/pi/config/klicky-z-calibration.cfg';
my $LOGS = '/home/pi/logs/';

my $max_dev;
open IN,"<$CONFIG" or die "Can't open $CONFIG for reading: $!";
while (<IN>) {
	next unless /^max_deviation: (.*?)$/;
	$max_dev = $1;
}
if (!$max_dev) { 
	print STDERR "Couldn't detect max_deviation from $CONFIG, assuming 1.0\n"; 
	$max_dev = 1.0;
} else {
	print STDERR "Max deviation detected as $max_dev\n";
}

my $data_in = `grep ^Z-CALIBRATION $LOGS/klippy.log*`;

if (!$data_in) { die "Didn't get any Z-CALIBRATION data from $LOGS/klippy.log*. Are you sure you have Z-Calibration enabled and have set \$LOGS correctly?\n"; }

my @data = split /\n/,$data_in;

my $total = 0;
my $count = 0;
my %data;

my $sep = \'│';

my $tb = Text::Table->new($sep,' ',$sep,'Endstop',$sep,'Nozzle',$sep,'Switch',$sep,'Probe',$sep,'Offset',$sep);

foreach (@data) {
	#print "$_\n";
	$total++;
	my ($endstop, $nozzle, $switch, $probe, $offset) = $_ =~ /.*?ENDSTOP=(.*?) NOZZLE=(.*?) SWITCH=(.*?) PROBE=(.*?)\s.*?\sOFFSET=(.*?)$/;
	if (abs($offset) > $max_dev) { 
		print STDERR "Offset $offset ignored\n";
		next;
	}
	push @{$data{'endstop'}}, $endstop;
	push @{$data{'nozzle'}}, $nozzle;
	push @{$data{'switch'}}, $switch;
	push @{$data{'probe'}}, $probe;
	push @{$data{'offset'}}, $offset;
	$count++;
	$tb->load([$count,$endstop,$nozzle,$switch,$probe,$offset]);
}

$tb->load([' ',' ',' ',' ',' ',' ']);
$tb->load(["Min:",min(@{$data{'endstop'}}),min(@{$data{'nozzle'}}),min(@{$data{'switch'}}),min(@{$data{'probe'}}),min(@{$data{'offset'}})]);
$tb->load(["Max:",max(@{$data{'endstop'}}),max(@{$data{'nozzle'}}),max(@{$data{'switch'}}),max(@{$data{'probe'}}),max(@{$data{'offset'}})]);
$tb->load(["Median:",median(@{$data{'endstop'}}),median(@{$data{'nozzle'}}),median(@{$data{'switch'}}),median(@{$data{'probe'}}),median(@{$data{'offset'}})]);
$tb->load(["Mean:",mean(@{$data{'endstop'}}),mean(@{$data{'nozzle'}}),mean(@{$data{'switch'}}),mean(@{$data{'probe'}}),mean(@{$data{'offset'}})]);
$tb->load(["Variance:",variance(@{$data{'endstop'}}),variance(@{$data{'nozzle'}}),variance(@{$data{'switch'}}),variance(@{$data{'probe'}}),variance(@{$data{'offset'}})]);
$tb->load(["Std. Dev:",stddev(@{$data{'endstop'}}),stddev(@{$data{'nozzle'}}),stddev(@{$data{'switch'}}),stddev(@{$data{'probe'}}),stddev(@{$data{'offset'}})]);

$tb->rule('=');
#foreach ('endstop','nozzle','switch','probe','offset') { 
#	my @data = @{$data{$_}};
	#	print uc $_ . ": " . (join ", ", @data) . "\n";
	#printf("\tMin:      %-7.3f\n",min(@data));
	#printf("\tMax:      %-7.3f\n",max(@data));
	#printf("\tMedian:   %-7.3f\n",median(@data));
	#printf("\tMean      %-7.3f\n",mean(@data));
	#printf("\tVariance: %-7.3f\n",variance(@data));
	#printf("\tStd. Dev: %-7.3f\n",stddev(@data));
	#print "\n";
	#}

print $tb;

print STDERR "Used $count datapoints out of $total available.\n";

exit 0;

#logs/klippy.log:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.187 SWITCH=5.973 PROBE=7.312 --> OFFSET=-0.157791
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.367 SWITCH=5.809 PROBE=7.154 --> OFFSET=-0.372375
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.379 SWITCH=5.691 PROBE=7.037 --> OFFSET=-0.383231
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.424 SWITCH=5.723 PROBE=7.086 --> OFFSET=-0.409813
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.196 SWITCH=5.995 PROBE=7.330 --> OFFSET=-0.211359
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.201 SWITCH=5.968 PROBE=7.322 --> OFFSET=-0.197188
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.209 SWITCH=5.948 PROBE=7.249 --> OFFSET=-0.257403
#logs/klippy.log.2022-03-03:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.576 SWITCH=5.580 PROBE=6.876 --> OFFSET=-0.630047
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.169 SWITCH=5.997 PROBE=7.293 --> OFFSET=-0.222906
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-2.155 SWITCH=5.044 PROBE=6.359 --> OFFSET=-1.190234
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.636 SWITCH=5.570 PROBE=6.891 --> OFFSET=-0.665250
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.631 SWITCH=5.591 PROBE=6.904 --> OFFSET=-0.666919
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.111 SWITCH=6.072 PROBE=7.372 --> OFFSET=-0.160897
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.576 SWITCH=5.653 PROBE=6.953 --> OFFSET=-0.625656
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.245 SWITCH=5.940 PROBE=7.247 --> OFFSET=-0.287922
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.573 SWITCH=5.622 PROBE=6.931 --> OFFSET=-0.614328
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.424 SWITCH=5.713 PROBE=7.012 --> OFFSET=-0.475297
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.384 SWITCH=5.790 PROBE=7.103 --> OFFSET=-0.421016
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.220 SWITCH=5.912 PROBE=7.217 --> OFFSET=-0.265315
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.589 SWITCH=5.564 PROBE=6.860 --> OFFSET=-0.642334
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.176 SWITCH=5.998 PROBE=7.345 --> OFFSET=-0.138606
#logs/klippy.log.2022-03-04:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.117 SWITCH=6.010 PROBE=7.360 --> OFFSET=-0.077297
#logs/klippy.log.2022-03-06:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.221 SWITCH=5.873 PROBE=7.218 --> OFFSET=-0.186063
#logs/klippy.log.2022-03-06:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.416 SWITCH=5.760 PROBE=7.122 --> OFFSET=-0.364628
#logs/klippy.log.2022-03-07:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.242 SWITCH=5.933 PROBE=7.274 --> OFFSET=-0.210731
#logs/klippy.log.2022-03-07:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.177 SWITCH=6.026 PROBE=7.372 --> OFFSET=-0.140531
#logs/klippy.log.2022-03-07:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.230 SWITCH=5.968 PROBE=7.302 --> OFFSET=-0.206531
#logs/klippy.log.2022-03-07:Z-CALIBRATION: ENDSTOP=-1.090 NOZZLE=-1.275 SWITCH=5.884 PROBE=7.239 --> OFFSET=-0.230000
