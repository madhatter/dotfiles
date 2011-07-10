#!/usr/bin/perl -w

# friends.pl
my $friends_version = "20011126/v0.99l";

# Maintains list of people you know, with opping, voicing,
# inviting, key giving and limit raising features.
# Entries can be optionally password-protected.
# Original version by Erkki Seppälä <flux@inside.org> 2001
# Fixed for new Irssi version by Timo Sirainen
# Fixes by Jakub Jankowski <shasta@irc.pl>

#
# USAGE:
#
# /ADDFRIEND <hostmask> <flags> <chanspec> [password]
#  - adds friend to your friendlist
#   hostmask: nick!user@host.domain (wildcards are allowed)
#      flags: - a (auto)
#             - o (op)
#             - O (delayed op)
#             - v (voice)
#             - V (delayed voice)
#             - i (invite)
#             - k (key)
#             - l (limit)
#   chanspec: #channel1,#channel2,#channel3
#              OR:
#             * (stands for any channel)
#   password: optional password string
#
# AutoOpping-Mini-Howto:
#  - for instant auto-op use something like:
#     /addfriend *!user@host.domain ao #channel1,#channel2
#  - for delayed auto-op use:
#     /addfriend *!user@host.domain aO #channel1,#channel2
#
# /SET friends_delay_min <int>
#  - sets minimum delay value
#
# /SET friends_delay_max <int>
#  - sets maximum delay value
#
# /DELFRIEND <number>
#  - deletes friend at 'number' position from your friendlist
#
# /LOADFRIENDS
#  - loads friends from file
#
# /SAVEFRIENDS
#  - saves friends to file
#
# /LISTFRIENDS [#channel | number]
#  - lists your friends for #channel if specified
#    or shows friend no. 'number'. Lists all friends
#    if invoked without params
#
# /FINDFRIENDS
#  - lists friends online (on channels you're sitting on)
#
# /ISFRIEND <nick>
#  - performs an USERHOST query on given nick and matches
#    the result against your friendlist
#
# /CHFLAGS <mask|number|#chan> <flags_spec>
#  - alters flags for user specified by mask, number or chan.
#    flags_spec can be: +a, +ov, -k, -l+i, +a-o+v, or similar.
#
# /CHPASS <mask|number|#chan> [newpassword]
#  - changes password for user specified by mask, number or chan.
#    If newpassword is not specified, deletes the password.
#

#
# TODO list (before releasing 1.0)
# ('d' means 'partially done')
#  - channel matching should use globMatcher too
#  - clean up the code [hi, flux :P]
#  - remove all possible bugs [hi, cras && flux :P~]
#  - re-think our flag system
#  d add some kind of documentation [and move history there, it grew too big]
#  D use themes instead of hardcoded messages formatting (i hope it's ok)
#  D make use of $friends_allowed_flags everywhere
#  D add random-delay code [hi, flux :>]

#
# BUGS (known):
#  - one can have both 'o' and 'O' flags, it results in double-opping
#    (same for v/V)
#  - flag system STILL isn't perfect :/
#

use Irssi;
use Irssi::Irc;
use strict;

# do you want to process CTCP queries?
my $friends_want_ctcp = 1;

# which flags do you want to use? (case *sensitive*)
my $friends_allowed_flags = "aoOvVikl";

# path to friends list
my $friends_file = "$ENV{HOME}/.irssi/friends";

# turn it on only when necessary
my $friends_debug = 0;

# registering themes
Irssi::theme_register([
	'friends_flags', '%C$*%n',
	'friends_loaded', 'Loaded {hilight $0} friends from $1',
	'friends_saved', 'Saved {hilight $0} friends to $1',
	'friends_checking', 'Checking took {hilight $0} secs',
	'friends_notenoughargs', 'Not enough arguments. Usage: $0',
	'friends_badparams', 'Bad arguments. Usage: $0',
	'friends_chflagexec', 'Executing %c$0%n for {hilight $1}',
	'friends_currentflags', 'Current flags for {hilight $1} are: %c$0%n',
	'friends_chpassexec', 'Altered password for {hilight $0}',
	'friends_line', '{nick $1}[$0] {hilight $2} with flags %c$3%n on: $4 $5',
	'friends_empty', 'Your friendlist is empty. Add items with /ADDFRIEND',
	'friends_friendlist', 'Friendlist ($0):',
	'friends_findfriends', 'Online friends on channel {hilight $0}:',
	'friends_added', 'Added {hilight $0} to friendlist',
	'friends_removed', 'Removed {hilight $0} from friendlist',
	'friends_nosuch', 'No such friend',
	'friends_ctcprequest', '$0 asks for {hilight $1} on {hilight $2}',
	'friends_ctcppass', 'Password for {hilight $0} altered by $1',
	'friends_endof', 'End of $0 $1',
	'friends_notafriend', '{nick $0} does not look like any of your friends'
]);

# Do we really need those two?
Irssi::print("friends.pl $friends_version");
my $friends_file_version;

# Initialize vars
my @friends = ();

# does not use unixTimeOfExpiration because clock might be adjusted
# this makes this O(n) operation - but it should be light
# consists of { left=>secondsLeft, server=>$server, nicks=>[ nicks ], channel=>"#channel", operation=>"op|voice" }
my @operationQueue = ();
my $timerHandle = undef;
my $delay_min = 1;
my $delay_max = 5;

# addOperation($server, "#channel", "op|voice", timeout, "nick1", "nick2" ..)
# adds a delayed operation
sub addOperation {
	my ($server, $channel, $operation, $timeout, @nicks) = @_;

	push @operationQueue,
	{
		server=>$server,
		left=>$timeout,
		nicks=>[ @nicks ],
		channel=>$channel,
		operation=>$operation
	};

	if (!defined $timerHandle) {
		$timerHandle = Irssi::timeout_add(1000, 'timerHandler', 0);
	}
}

# handles delay timer
sub timerHandler {
	my @ops = ();

	# splice out expired timeouts. if they are expired, move them to
	# local ops-queue. this allows creating new operations to the queue
	# in the operation. (we're not (yet) doing that)
	for (my $c = 0; $c < @operationQueue;) {
		if ($operationQueue[$c]->{left} <= 0) {
			push(@ops, splice(@operationQueue, $c, 1));
		} else {
			++$c;
		}
	}

	for (my $c = 0; $c < @ops; ++$c) {
		my $op = $ops[$c];
		my $channel = $op->{server}->channel_find($op->{channel});

		# check if $channel is still active (you might've parted)
		if ($channel) {
			my @operationNicks = ();
			foreach my $nickStr (@{$op->{nicks}}) {
				my $nick = $channel->nick_find($nickStr);
				# check if there's still such nick (it might've quit/parted)
				if ($nick) {
					# because of a happy coincidence (irssi structures and
					# commands are the same) we can do this:
					if (!$nick->{$op->{operation}}) {
						push(@operationNicks, $nick->{nick});
					}
				}
			}
			# final stage: issue desired command if we're a chanop
			if ($channel->{chanop}) {
				$channel->command($op->{operation}." ".join(" ", @operationNicks));
			}
		}
	}

	# decrement timeouts.
	for (my $c = 0; $c < @operationQueue; ++$c) {
		--$operationQueue[$c]->{left};
	}

	# if operation queue is empty, remove timer.
	if (!@operationQueue) {
		Irssi::timeout_remove($timerHandle);
		$timerHandle = undef;
	}
}

# glob matching
sub globMatcher ($$) {
	my ($what, $regex) = @_;
	$regex =~ s/\\/\\\\/g;
	$regex =~ s/\./\./g;
	$regex =~ s/\*/\.\*/g;
	$regex =~ s/\!/\\\!/g;
	$regex =~ s/\?/\.\?/g;
	$regex =~ s/\^/\\\^/g;

	my $matches = $what =~ /^$regex$/i;

	return $matches;
}

# friends_crypt($what)
# returns crypt()ed $what, using random salt
sub friends_crypt {
	my ($plain) = @_;
	my $crypted = crypt("$plain", (join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64]));
	return $crypted;
}

# loading friends from file
sub load_friends {
	if (-e $friends_file) {
		@friends = ();
		# I want to get rid of this:
		# Irssi::print("Loading friends from $friends_file");
		local *F;
		open(F, "<$friends_file");
		local $/ = "\n";
		while (<F>) {
			chop;
			# ignoring comments
			if (/^\#/) {
				# version checking
				# (do we need this?)
				if (/^\# version = ([^\/]+)/) {
					$friends_file_version = $1;
				}
				next;
			}
			my $newFriend = new_friend(split("%"));
			if ($newFriend->{hostmask} ne "") {
				push(@friends, $newFriend);
			} else {
				Irssi::print("Skipping $newFriend (bad hostmask?)");
			}
		}
		close(F);
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_loaded', scalar(@friends), $friends_file);
	} else {
		Irssi::print("Cannot load $friends_file");
	}
}

# saving friends to file
sub save_friends {
	local *F;
	open(F, ">$friends_file") or die "Couldn't open $friends_file for writing";
	print(F "# version = $friends_version\n");
	for (my $idx = 0; $idx < @friends; ++$idx) {
		print(F join("%", $friends[$idx]->{hostmask}, $friends[$idx]->{flags},
					 join(",", get_friend_channels($friends[$idx])), 
					 $friends[$idx]->{password} . "\n"));
	}
	close(F);
	Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_saved', scalar(@friends), $friends_file);
}

sub get_friend_channels {
	return keys(%{$_[0]->{channels}});
}

# mask, flags, channel(s), password
sub new_friend {
	my $friend = {};
	$friend->{hostmask} = shift;
	$friend->{flags} = shift;
	my $chanstr = shift;
	$chanstr = lc($chanstr);
	$friend->{password} = shift;
	my @channels = split(",", $chanstr);
	foreach my $channel (@channels) {
		$friend->{channels}->{$channel} = 1;
	}
	return $friend;
}

# is_friend($channelName, $nick, $userhost)
# returns index of the friend or -1 if not a friend
sub is_friend {
	my ($channelName, $nick, $userhost) = @_;
	$channelName = lc($channelName);
	for (my $idx = 0; $idx < @friends; ++$idx) {
		if ((exists $friends[$idx]->{channels}->{$channelName} ||
			 exists $friends[$idx]->{channels}->{'*'}) &&
			globMatcher(($nick . "!" . $userhost), 
						$friends[$idx]->{hostmask})) {
			return $idx;
		}
	}
	return -1;
}

# friend_passwdok($idx, $pwd)
# returns 1 if password is ok, 0 if isn't
sub friends_passwdok {
	my ($idx, $pwd) = @_;
	if (crypt("$pwd", $friends[$idx]->{password}) eq $friends[$idx]->{password}) {
		return 1;
	}
	return 0;
}

# friend_has_flag($idx, $flag)
# return true if friend numbered $idx has $flag, false if hasn't
sub friend_has_flag {
	my ($idx, $flag) = @_;
	if ($friends_allowed_flags =~ /$flag/ &&
		$friends[$idx]->{flags} =~ /$flag/) {
		return 1;
	}
	return 0;
}

sub check_friends {
	my ($server, $channelName, @nicks) = @_;
	my $channel = $server->channel_find($channelName);
	my %opList = ();
	my %voiceList = ();

	my $min = Irssi::settings_get_int('friends_delay_min');
	my $max = Irssi::settings_get_int('friends_delay_max');

	# lazy man's sanity checks :-P
	$min = $delay_min if $min < 0;
	$max = $delay_max if $min > $max;

	foreach my $nick (@nicks) {
		if ((my $idx = is_friend($channelName, $nick->{nick}, $nick->{host})) > -1) {

			# skip this friend if he doesn't have +a
			# (here, we take care about +a'ed people ONLY)
			next if (!friend_has_flag($idx, "a"));

			# notice: password doesn't matter in this loop

			# add $nick to opList{0} if he has +o and isn't opped already
			if (friend_has_flag($idx, "o") && !($nick->{op})) {
				$opList{0}->{$nick->{nick}} = 1;
			}
			# add $nick to opList{delay} if he has +O and isn't opped already
			if (friend_has_flag($idx, "O") && !($nick->{op})) {
				$opList{int(rand ($max - $min)) + $min}->{$nick->{nick}} = 1;
			}
			# add $nick to voiceList{0} if he has +v and isn't voiced already
			if (friend_has_flag($idx, "v") && !($nick->{voice})) {
				$voiceList{0}->{$nick->{nick}} = 1;
			}
			# add $nick to voiceList{0} if he has +V and isn't voiced already
			if (friend_has_flag($idx, "V") && !($nick->{voice})) {
				$voiceList{int(rand ($max - $min)) + $min}->{$nick->{nick}} = 1;
			}
		}
	}

	# opping
	foreach my $delay (keys %opList) {
		addOperation($server, $channelName, "op", $delay, keys %{$opList{$delay}});
		# I'm gonna remove this in 1.0, but till then...
		if ($friends_debug) {
			Irssi::print("Debug: Going to op " . join(" ", keys %{$opList{$delay}}) . " in $delay seconds");
		}
	}

	# voicing
	foreach my $delay (keys %voiceList) {
		addOperation($server, $channelName, "voice", $delay, keys %{$voiceList{$delay}});
		# I'm gonna remove this in 1.0, but till then...
		if ($friends_debug) {
			Irssi::print("Debug: Going to voice " . join(" ", keys %{$voiceList{$delay}}) . " in $delay seconds");
		}
	}

	timerHandler();
}

sub event_modechange {
	my ($server, $data, $nick) = @_;
	my ($channel, $modeStr, $nickStr) = $data =~ /^([^ ]+) ([^ ]+) (.*)$/;
	my @nicks = split(" ", $nickStr);
	my $mode = undef;
	my $nickIndex = 0;
	my $myNick = $server->{nick};
	my $gotOpped = 0;

	for (my $c = 0; $c < length($modeStr); $c++) {
		if (substr($modeStr, $c, 1) eq "+") {
			$mode = "+";
		} elsif (substr($modeStr, $c, 1) eq "-") {
			$mode = "-";
		} elsif (substr($modeStr, $c, 1) eq "o") {
			if ($mode eq "+" && $nicks[$nickIndex++] eq $myNick) {
				$gotOpped = 1;
			}
		}
	}

	if ($gotOpped) {
		check_friends($server, $channel, $server->channel_find($channel)->nicks);
	}
}

sub event_massjoin {
	my ($channel, $nicksList) = @_;
	my @nicks = @{$nicksList};
	my $server = $channel->{'server'};
	my $channelName = $channel->{name};
	my $begin = time;

	check_friends($server, $channelName, @nicks);

	my $duration = time - $begin;
	if ($duration >= 2) {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_checking', $duration);
	}
}

# friends_exec_chflag($idx, $mode, $flag)
# executes flags altering (changes $friends[$idx]->{flags})
sub friends_exec_chflag {
	my ($idx, $mode, $flag) = @_;

	if ($mode eq "+") {
		if (!friend_has_flag($idx, $flag)) {
			$friends[$idx]->{flags} = $friends[$idx]->{flags} . $flag;
		}
	} elsif ($mode eq "-") {
		$friends[$idx]->{flags} =~ s/$flag//;
	}
}

# friends_chflags($idx, $string)
# parses the $string and calls friends_exec_chflags()
sub friends_chflags {
	my ($idx, $string) = @_;
	my $wasplus = 0;
	my $wasminus = 0;
	my $char;

	for (my $c = 0; $c < length($string); $c++) {
		$char = substr($string, $c, 1);
		if ($char eq "+") {
			$wasplus = 1;
			$wasminus = 0;
		} elsif ($char eq "-") {
			$wasplus = 0;
			$wasminus = 1;
		} else {
			if ($friends_allowed_flags =~ /$char/) {
				if ($wasplus && !$wasminus) {
					friends_exec_chflag($idx, '+', $char);
				} elsif (!$wasplus && $wasminus) {
					friends_exec_chflag($idx, '-', $char);
				}
			}
		}
	}
}

# handles /chflags <who> <what>
sub cmd_chflags {
	my ($who, $what) = split(" ", @_[0]);
	my $flagstr;
	my $usage = "/CHFLAGS <mask|num|chan> <+-flags>";

	# remove trailing space
	$what =~ s/\ $//g;

	# if not enough arguments
	if ($what eq "") {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_notenoughargs', $usage);
		return;
	}
	# if the 'flags' part doesn't start with + or -
	if ((substr($what, 0, 1) ne "+") && (substr($what, 0, 1) ne "-")) {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_badparams', $usage);
		return;
	}

	# changing flags for friends matching certain channel
	if ($who =~ /^[\!\&\#]/) {
		for (my $idx = 0; $idx < @friends; ++$idx) {
			if (exists $friends[$idx]->{channels}->{$who} ||
				exists $friends[$idx]->{channels}->{'*'}) {
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_chflagexec', $what, $friends[$idx]->{hostmask});
				friends_chflags($idx, $what);
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_currentflags', $friends[$idx]->{flags}, $friends[$idx]->{hostmask});
			}
		}
	# changing flags for friend number X
	} elsif ($who =~ /^[0-9,]+$/) {
		foreach my $idx (split(/,/, $who)) {
			if ($idx < @friends) {
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_chflagexec', $what, $friends[$idx]->{hostmask});
				friends_chflags($idx, $what);
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_currentflags', $friends[$idx]->{flags}, $friends[$idx]->{hostmask});
			}
		}
	# changing flags for friends matching certain hostmask
	} else {
		for (my $idx = 0; $idx < @friends; ++$idx) {
			if (globMatcher($friends[$idx]->{hostmask}, $who)) {
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_chflagexec', $what, $friends[$idx]->{hostmask});
				friends_chflags($idx, $what);
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_currentflags', $friends[$idx]->{flags}, $friends[$idx]->{hostmask});
			}
		}
	}
}

# handles /chpass <who> [newpass]
sub cmd_chpass {
	my ($who, $what) = split(" ", @_[0]);
	my $usage = "/CHPASS <mask|num|chan> [newpassword]";

	# remove trailing space
	$what =~ s/\ $//g;

	# if not enough arguments
	if ($who eq "") {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_notenoughargs', $usage);
		return;
	}

	# altering password for friends matching certain channel
	if ($who =~ /^[\!\&\#]/) {
		for (my $idx = 0; $idx < @friends; ++$idx) {
			if (exists $friends[$idx]->{channels}->{$who} ||
				exists $friends[$idx]->{channels}->{'*'}) {
				$friends[$idx]->{password} = friends_crypt("$what");
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_chpassexec', $friends[$idx]->{hostmask});
			}
		}
	# altering password for friend number X
	} elsif ($who =~ /^[0-9,]+$/) {
		foreach my $idx (split(/,/, $who)) {
			if ($idx < @friends) {
				$friends[$idx]->{password} = friends_crypt("$what");
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_chpassexec', $friends[$idx]->{hostmask});
			}
		}
	# altering password for friends matching certain hostmask
	} else {
		for (my $idx = 0; $idx < @friends; ++$idx) {
			if (globMatcher($friends[$idx]->{hostmask}, $who)) {
				$friends[$idx]->{password} = friends_crypt("$what");
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_chpassexec', $friends[$idx]->{hostmask});
			}
		}
	}
}

# listfriend($idx [, $nick])
# prints an info line about certain friend.
# if you want to improve the look of the script, you should change themes, probably.
sub listfriend {
	my ($idx, $nick) = @_;
	Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_line',
			$idx,
			($nick ? "$nick: " : ""),
			$friends[$idx]->{hostmask},
			($friends[$idx]->{flags} ? $friends[$idx]->{flags} : "[none]"),
			join(", ", get_friend_channels($friends[$idx])),
			($friends[$idx]->{password} ? " (password set)" : ""));
}

# handles /listfriends [what]
sub cmd_listfriends {
	if (@friends == 0) {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_empty');
	} else {
		my ($searchFor) = @_;
		# remove trailing space in case of tab-completing or something
		$searchFor =~ s/\ $//g;
		if ($searchFor =~ /^[\!\&\#]/) {
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_friendlist', "channel " . $searchFor);
			for (my $idx = 0; $idx < @friends; ++$idx) {
				if (exists $friends[$idx]->{channels}->{$searchFor}) {
					listfriend($idx);
				}
			}
		} elsif ($searchFor =~ /^[0-9,]+$/) {
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_friendlist', $searchFor);
			foreach my $idx (split(/,/, $searchFor)) {
				if ($idx < @friends) {
					listfriend($idx);
				}
			}
		} else {
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_friendlist', "all");
			for (my $idx = 0; $idx < @friends; ++$idx) {
				listfriend($idx);
			}
		}
	}
}

# handles /addfriend <hostmask> <flags> <chanspec> [password]
sub cmd_addfriend {
	my ($hostmask, $flags, $channels, $password) = split(" ", $_[0]);
	my $passwd;
	my $usage = "/ADDFRIEND <hostmask> <flags> <channel_spec> [password]";

	if ($channels) {
		# remove trailing space in case of tab-completing or something
		$channels =~ s/\ $//g;

		if ($password) {
			# remove trailing space in case of tab-completing or something
			$password =~ s/\ $//g;
			# encrypt the password
			$passwd = friends_crypt("$password");
		} else {
			$passwd = '';
		}

		# some might specify flags with `+' or `-' signs, so strip them
		$flags =~ s/[\+\-]//g;

		# don't let add entries with flags out of $friend_allowed_flags range
		foreach my $char (split("", $flags)) {
			$flags =~ s/$char//g if (!($friends_allowed_flags =~ /$char/));
		}

		# add friend!
		push(@friends, new_friend($hostmask, $flags, $channels, $passwd));
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_added', $hostmask);
	} else {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_notenoughargs', $usage);
	}
}

# handles /delfriend <num>
sub cmd_delfriend {
	my ($index) = split(" ", $_[0], 1);
	my $usage = "/DELFRIEND <number>";

	if ($index ne "") {
		my $friend = splice(@friends, $index, 1);
		if ($friend) {
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_removed', $friend->{hostmask});
		} else {
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_nosuch');
		}
	} else {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_notenoughargs', $usage);
	}
}

# handles /savefriends
sub cmd_savefriends {
	eval {
		save_friends();
	};
	if ($?) {
		Irssi::print("Save failed: $?");
	}
}

# handles /loadfriends
sub cmd_loadfriends {
	load_friends();
}

# handles /findfriends
sub cmd_findfriends {
	# this also goes out of here
	# Irssi::print("Friends online:");
	foreach my $channel (Irssi::channels()) {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_findfriends', $channel->{name});
		foreach my $nick ($channel->nicks()) {
			if ((my $idx = is_friend($channel->{name}, $nick->{nick}, $nick->{host})) > -1) {
				listfriend($idx, $nick->{nick});
			}
		}
	}
}

# handles ctcp requests
sub event_ctcpmsg {
	my ($server, $args, $sender, $userhost, $target) = @_;
	my $fec_sigstop = 0;

	# return, if ctcp is not for us
	my $myNick = $server->{nick};
	return if (lc($target) ne lc($myNick));

	# return, if we don't accept ctcp requests
	return if (!$friends_want_ctcp);

	my @cmdargs = split(" ", $args);

	my $command = uc($cmdargs[0]);

	my $channelName = $cmdargs[1];
	# remove trailing space in case of tab-completing or something
	$channelName =~ s/\ $//g;
	my $channel = $server->channel_find($channelName);

	my $password = $cmdargs[2];
	# remove trailing space in case of tab-completing or something
	$password =~ s/\ $//g;

	my $idx = is_friend($channelName, $sender, $userhost);

	# return, if the second side is not a friend of us
	# (except of the PASS command, one doesn't specify channel there
	#  so we can't check if [s]he's really a friend)
	if (($idx < 0) && ($command ne "PASS")) {
		return;
	}

	# /ctcp nick OP #channel password
	if ($command eq "OP" && $channelName && $channel) {
		if (friend_has_flag($idx, "[oO]") && friends_passwdok($idx, $password)) {
			# process allowed opping
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcprequest', $sender.'!'.$userhost, $command, $channelName);
			# op that begger!
			$channel->command("op $sender");
		}
		$fec_sigstop = 1;
	# /ctcp nick VOICE #channel password
	} elsif ($command eq "VOICE" && $channelName && $channel) {
		if (friend_has_flag($idx, "[vV]") && friends_passwdok($idx, $password)) {
			# process allowed voice
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcprequest', $sender.'!'.$userhost, $command, $channelName);
			# voice that begger!
			$channel->command("voice $sender");
		}
		$fec_sigstop = 1;
	# /ctcp nick INVITE #channel password
	} elsif ($command eq "INVITE" && $channelName && $channel) {
		if (friend_has_flag($idx, "i") && friends_passwdok($idx, $password)) {
			# process allowed invite
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcprequest', $sender.'!'.$userhost, $command, $channelName);
			# invite that begger!
			$channel->command("invite $sender");
		}
		$fec_sigstop = 1;
	# /ctcp nick KEY #channel password
	} elsif ($command eq "KEY" && $channelName && $channel) {
		if (friend_has_flag($idx, "k") && friends_passwdok($idx, $password)) {
			# process allowed key giving
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcprequest', $sender.'!'.$userhost, $command, $channelName);
			if ($channel->{key} ne '') {
				# give him/her a key!
				$server->command("NOTICE $sender Key for $channelName is: $channel->{key}");
			}
		}
		$fec_sigstop = 1;
	# /ctcp nick LIMIT #channel password
	} elsif ($command eq "LIMIT" && $channelName && $channel) {
		if (friend_has_flag($idx, "l") && friends_passwdok($idx, $password)) {
			# process allowed limit raising
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcprequest', $sender.'!'.$userhost, $command, $channelName);
			my @nicks = Irssi::Channel::nicks($channel);
			if ($channel->{limit} <= scalar(@nicks) && $channel->{limit}) {
				# raise the limit!
				$server->command("MODE $channelName +l " . (scalar(@nicks) + 1));
			}
		}
		$fec_sigstop = 1;
	# /ctcp nick PASS pass [newpass]
	} elsif ($command eq "PASS" && $channelName) {
		# if someone has password already set - we can only *change* it
		if ($friends[$idx]->{password} ne "") {
			# if cmdargs[1] is a valid password (current)
			# and cmdargs[2] contains something ...
			if (friends_passwdok($idx, $channelName) && $password) {
				# ... process allowed password change.
				# in this case, old password is in $channelName
				# and new password is in $password
				$friends[$idx]->{password} = friends_crypt("$password");
				Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcppass', $friends[$idx]->{hostmask}, $sender.'!'.$userhost);
				$server->command("NOTICE $sender Password changed to: $password");
			}
		# if $idx doesn't have a password, we will *set* it
		} else {
			# in this case, new password is in $channelName
			# and $password is unused
			$friends[$idx]->{password} = friends_crypt("$channelName");
			Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_ctcppass', $friends[$idx]->{hostmask}, $sender.'!'.$userhost);
			$server->command("NOTICE $sender Password set to: $channelName");
		}
		$fec_sigstop = 1;
	}

	# stop the signal if we processed the request
	Irssi::signal_stop() if ($fec_sigstop);
}

# handles /isfriend <nick>
# idea stolen from realname.pl
sub cmd_isfriend {
	my ($data, $server, $channel) = @_;

	$server->send_raw("USERHOST :$data");

	# redirect reply to event_isfriend_userhost()
	$server->redirect_event($data, 1,
				"event 302", "redir userhost_friends", -1);
}

sub event_isfriend_userhost {
	my ($mynick, $reply) = split(/ +/, $_[1]);
	my ($nick, $user, $host) = $reply =~ /^:(.*)=.(.*)@(.*)/;
	$nick =~ s/\*$//;
	my $friend_matched = 0;

	for (my $idx = 0; $idx < @friends; ++$idx) {
		if (globMatcher(($nick."!".$user."@".$host), $friends[$idx]->{hostmask})) {
			listfriend($idx, $nick);
			$friend_matched = 1;
		}
	}

	if ($friend_matched) {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_endof', "/isfriend", $nick);
	} else {
		Irssi::printformat(MSGLEVEL_CLIENTNOTICE, 'friends_notafriend', $nick);
	}
}

Irssi::settings_add_int("misc", "friends_delay_min", $delay_min);
Irssi::settings_add_int("misc", "friends_delay_max", $delay_max);
Irssi::command_bind("addfriend", "cmd_addfriend");
Irssi::command_bind("delfriend", "cmd_delfriend");
Irssi::command_bind("loadfriends", "cmd_loadfriends");
Irssi::command_bind("savefriends", "cmd_savefriends");
Irssi::command_bind("listfriends", "cmd_listfriends");
Irssi::command_bind("findfriends", "cmd_findfriends");
Irssi::command_bind("isfriend", "cmd_isfriend");
Irssi::command_bind("chflags", "cmd_chflags");
Irssi::command_bind("chpass", "cmd_chpass");
Irssi::signal_add_last("massjoin", "event_massjoin");
Irssi::signal_add_last("event mode", "event_modechange");
Irssi::signal_add("default ctcp msg", "event_ctcpmsg");
Irssi::signal_add("redir userhost_friends", "event_isfriend_userhost");

load_friends();

#
# History log:
#
# shasta@01/11/26: * check if $server->channel_find($channelName) returns
#                    anything while processing CTCP requests (thanks, netcat)
# shasta@01/11/21: * globmatcher fixes: more escaping (once again, Ascent wins
#                    the prize)
# shasta@01/11/20: * sensitivity fixes: nicknames and channel names are case
#                    insensitive anyway. Thanks Ascent for pointing out this
#                    bug
#                  * fixed changelog dates
# shasta@01/10/24: * _do_ friend-checking if you're not a chanop, you
#                    might get opped later ;) $channel->{chanop} checking
#                    moved to timerHandler(), just before sending op/voice
#                    command to server
#                  * Hello, themes, nice to meet you ;-) Most messages
#                    are now printed using themes -- you can customize
#                    them (not much, but always... ;)
#                  * Don't let people add entries with flags out of 
#                    $friend_allowed_flags range
#                  * use '$idx' everywhere ($friends[$idx]->{blah})
#   flux@01/10/24: * don't do friend-checking if you're not an operator
#                    instant opping should now be really instant (again)
# shasta@01/10/24: * instant opping is handled with addOperation()
#                    too, but with delay=0; moved delay calculation
#                    to check_friends()
# shasta@01/10/23: * /chflags bugfix: allow chflag even for friend
#                    number 0 ;)
#                  * same bugfix for /chpass
#                  * flags checking is case _sensitive_ now
#                  * merged with flux's delay code (does it work as
#                    it's supposed to?); changed fixed delay time
#                    to a random one; added two /SETtings for minimal
#                    and maximal delay time (/set friends_delay_min
#                    and /set friends_delay_max)
# shasta@01/10/22: * /isfriend fixes: print correct entries even
#                    if we're not joined to any channel; use better
#                    regexps; don't show '*' after ircoper's nick
# shasta@01/10/13: * save the bandwith! send USERHOST instead of
#                    WHOIS when doing /isfriend (thanks, cras)
#                  * friends_event_* -> event_* ("all scripts are
#                    in their own namespace anyway" - cras)
#                  * friends_globMatcher -> globMatcher
#                  * added few comments
# shasta@01/09/30: * password setting/changing via CTCP requests
#                  * /chpass added for altering friend's passwords
#                  * reverted: +a works with password set too
#                  * somewhere in the wild, a bug which allowed
#                    to auto-op a friend without +a but with #*,
#                    disappeared
#                  * minor fixes/improvements
# shasta@01/09/28: * /chflags added for altering friends' flags
# shasta@01/09/28: * added 'usage', moved history to the bottom
# shasta@01/09/28: * removed backward-compatibility code
# shasta@01/09/28: * password protected entries should work now
#                    crypted using system crypt() with random
#                    salt. +a flag works ONLY WITHOUT password
# shasta@01/09/28: * use comma to separate channels
# shasta@01/09/28: **** Moving towards 1.0 ****
# shasta@01/09/06: * another features: key asking/giving and
#                    limit raise requesting via CTCP (another
#                    flags for this feature: 'k' and 'l')
#   cras@01/08/25: * code cleanups in load_friends()
# shasta@01/08/19: * friends_globMatcher() bugfix: escape ^ chars
#                    when doing a match. thanks cras for pointing
#                    this bug out and suggesting a fix for it.
# shasta@01/08/18: * changed few function's names to reduce potential
#                    collisions
# shasta@01/08/18: * $version -> $friends_version
#                  * uh-oh. new line in config file (with friends.pl
#                    version number). this allows us to check if
#                    we are using a recent release, and thus - use
#                    the new 'a' (auto-) flag. with the new flag 
#                    system we op and voice automatically *only*
#                    if the friend has the 'a' flag specified.
#                    while saving an old friendlist to a file using
#                    the new script, all +o and +v entries will be
#                    written with +a flag.
# shasta@01/08/17: * redir whois -> redir whois_friends (thx cras)
# shasta@01/08/17: * enhanced the look of listfriend() output
#                  * added /isfriend nick for quick checking if
#                    nick is our friend
#                  * indented code with tabs instead of spaces
# shasta@01/08/16: * is_friend() bugfix: op all friends, even the
#                    first one ;)
#                  * is_friend() takes 3 arguments now, plain channel
#                    name, plain nickname and plain user@host
#                  * has_flags() added to simplify flags checking
#                  * CTCP requests are now processed. Syntax:
#                    /ctcp person_running_this_script command channel
#                    where command is one of OP, VOICE or INVITE.
#                    netcat asked for such feature :)
#                  * added flag 'i', allows asking for a INVITE
#                    through CTCP msgs.
#   flux@01/07/12: * reverted +1 - -1 -magic, uses alternate approach
# shasta@01/07/12: * /listfriends shows numbers from 1 to n. The code
#                    is *awful*, but it allows to check whether
#                    /delfriend was issued with, or without friend's
#                    number (and give appropriate "usage" message if
#                    without);
#                  * /listfriends [number] bugfix
#   flux@01/07/10: * added /findfriends for listing friends online
#                  * modified /listfriends to show friends on given
#                    channel or a given friend by number
#                  * function is_friend now checks if the given nick
#                    on a given channel is a friend
# shasta@01/07/03: * removed "Loading *!bla@bla.bla" text, it is
#                    annoying with a huge friendlist
#   flux@01/07/02: * added version-variable
#                  * removed final 'loaded'-text, who needs them
#                  * merged all fixes
#                  * changelog written :)
# shasta@01/07/01: * removed dead/unused code
# shasta@01/06/30: * don't op|voice already opped|voiced people
#                    (they could come from a netsplit with +o|+v)
# shasta@01/06/24: * added auto-voice support
# shasta@01/06/23: * added '*' as all-channels-matching character
#                    hostmask is matched correctly against '?' now
# shasta@01/06/20: * changed field separator from ':' to '%' because
#                    the former one didn't work with IPv6 hosts. It
#                    is done within ircd's config in a similar way
