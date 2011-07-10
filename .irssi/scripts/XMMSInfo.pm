# XMMSInfo.pm
# this should be in a separate file...
package XMMSInfo;

# should write docs...

use strict;
use POSIX;
use IO::File;
use MP3::Info;
use vars qw($PIPE $STATUS @ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw($STATUS);

$PIPE = '/tmp/xmms-info';
$STATUS = {
	-1	=> 'Fatal error',
	0	=> 'Not running',
	1	=> 'Stopped',
	2	=> 'Playing',
	3	=> 'Paused',
};

sub new {
	my($class) = shift;

	my($self) = {};
	bless($self, $class);

	$self->die("Try calling some methods first. \$obj->getInfo() is currently the only one available...");

	$self;
}

sub parseArgs {
	my($self) = shift;

	$#_ % 2 || return $self->die("Invalid number of arguments");
	for(my $i = 0; $i < $#_; $i += 2) {
		my($k, $v) = ($_[$i], $_[$i + 1]);
		$self->{Args}->{'.'.uc($k)} = $v;
	}

	1;
}

sub die {
	my($self) = shift;
	$self->setError(shift);
	$self->setStatus(-1);
	undef;
}

sub round {
	my($d) = shift;
	return $d unless $d =~ /^(\d+)\.(\d)/;
	$d = $1;
	$d++ if $2 >= 5;
	$d;
}

sub getInfo {
	my($self) = shift;

	$self->parseArgs(@_) || return;

	my($f) = $self->argPipe || $PIPE;
	-r $f || return $self->setStatus(0);
	my($fh) = IO::File->new($f) ||
		return $self->die("Can't open $f for reading: $!");

	while(<$fh>) {
		chomp;
		next unless /^(.+?): (.+)$/;
		if($1 eq 'Status') {
			$self->setStatus($2);
		} else {
			$self->{Info}->{'.'.uc($1)} = $2;
		}
	}
	$fh->close;

	return $self->die("Invalid input") unless $self->{Info}->{'.INFOPIPE PLUGIN VERSION'};

	my($t) = get_mp3tag($self->infoFile) || return $self->die("Can't read ID3 tag: ". $self->infoFile);
	my($i) = get_mp3info($self->infoFile) || return $self->die("Can't read MP3 info: ". $self->infoFile);

	my($k, $v);
	while(($k, $v) = (each(%$t), each(%$i))) {
		$self->{Info}->{'.'.$k} = $v;
	}

	$self->getStatus;
}

sub setStatus {
	my($self, $s) = @_;
	if($s =~ /^*\d+$/) {
		$self->{Status}->{'.STATUS'} = $s;
		$self->{Status}->{'.STATUSSTRING'} = $STATUS->{$s};
	} else {
		foreach my $k (keys %$STATUS) {
			my($v) = $STATUS->{$k};
			if($s eq $v) {
				$self->{Status}->{'.STATUS'} = $k;
				$self->{Status}->{'.STATUSSTRING'} = $s;
				return $self->getStatus;
			}
		}
		die "HELP";
	}

	$self->getStatus;
}

sub setError {
	shift->{Status}->{'.ERROR'} = pop;
}

sub getStatus {
	shift->{Status}->{'.STATUS'};
}

sub getStatusString {
	shift->{Status}->{'.STATUSSTRING'};
}

sub getError {
	shift->{Status}->{'.ERROR'};
}

sub isFatalError {
	shift->getStatus == -1;
}

sub isXmmsRunning {
	shift->getStatus > 0;
}

sub isPlaying {
	shift->getStatus == 2;
}

sub isPaused {
	shift->getStatus == 3;
}

sub isStopped {
	shift->getStatus == 1;
}

sub argPipe {
	shift->{Args}->{'.PIPE'};
}

sub infoPlayListItems {
	shift->{Info}->{'.TUNES IN PLAYLIST'};
}

sub infoCurrentItemInPlaylist {
	shift->{Info}->{'.CURRENTLY PLAYING'};
}

sub infoTimeNow {
	shift->{Info}->{'.POSITION'};
}

sub infoTimeTotal {
	shift->{Info}->{'.TIME'};
}

sub infoSecondsTotal {
	POSIX::ceil (shift->{Info}->{'.SECS'});
}

sub infoSecondsNow {
	my($self) = shift;
	my($s) = $self->infoTimeNow;
	die "HELP" unless $s =~ /^(\d+):(\d+)$/;
	$1 * 60 + $2;
}

sub infoMinutesTotal {
	shift->{Info}->{'.MM'};
}

sub infoMinutesNow {
	my($self) = shift;
	my($s) = $self->infoTimeNow;
	die "HELP" unless $s =~ /^(\d+):\d+$/;
	$1;
}

sub infoSecondsTotalLeftover {
	shift->{Info}->{'.SS'};
}

sub infoSecondsNowLeftover {
	my($self) = shift;
	$self->infoSecondsNow - ($self->infoMinutesNow * 60);
}

sub infouSecTotal {
	shift->{Info}->{'.USECTIME'};
}

sub infouSecNow {
	shift->{Info}->{'.USECPOSITION'};
}

sub infoPercentage {
	my($self) = shift;
	my($p) = ($self->infouSecNow / $self->infouSecTotal) * 100;
	round($p);
}

sub infoTitle {
	shift->{Info}->{'.TITLE'};
}

sub infoFile {
	shift->{Info}->{'.FILE'};
}

sub infoArtist {
	shift->{Info}->{'.ARTIST'};
}

sub infoAlbum {
	shift->{Info}->{'.ALBUM'};
}

sub infoYear {
	shift->{Info}->{'.YEAR'};
}

sub infoComment {
	shift->{Info}->{'.COMMENT'};
}

sub infoGenre {
	shift->{Info}->{'.GENRE'};
}

sub infoVersion {
	shift->{Info}->{'.VERSION'};
}

sub infoLayer {
	shift->{Info}->{'.LAYER'};
}

sub infoIsStereo {
	shift->{Info}->{'.STEREO'};
}

sub infoIsVbr {
	shift->{Info}->{'.VBR'};
}

sub infoBitrate {
	shift->{Info}->{'.BITRATE'};
}

sub infoFrequency {
	shift->{Info}->{'.FREQUENCY'};
}

sub infoSizeBytes {
	shift->{Info}->{'.SIZE'};
}

sub infoSize {
	shift->infoSizeBytes;
}

sub infoSizeKiloBytes {
	round(shift->infoSizeBytes / 1024);
}

sub infoSizeMegaBytes {
	round(shift->infoSizeKiloBytes / 1024);
}

sub infoIsCopyright {
	shift->{Info}->{'.COPYRIGHT'};
}

sub infoIsPadded {
	shift->{Info}->{'.PADDING'};
}

sub infoFrames {
	shift->{Info}->{'.FRAMES'};
}

sub infoFramesLength {
	shift->{Info}->{'.FRAMESLENGTH'};
}

sub infoVbrScale {
	shift->{Info}->{'.VBR_SCALE'};
}

1;

# EOF
