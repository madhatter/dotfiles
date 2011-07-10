# Print realname of everyone who join to channels
# for irssi 0.7.99 by Timo Sirainen

use Irssi 20011207;
use strict;

# v0.71 changes
#  - a bit safer now with using "redirect last"
# v0.7 changes
#  - pretty much a rewrite - shouldn't break anymore
# v0.62 changes
#  - upgraded redirection to work with latest CVS irssi - lot easier
#    to handle it this time :)
# v0.61 changes
#  - forgot to reset %chan_list..
# v0.6 changes
#  - works now properly when a nick joins to multiple channels
# v0.5 changes
#  - Use "message join" so we won't ask realname for ignored people

Irssi::theme_register([
  'join_realname', '{channick_hilight $0} is {hilight $1}',
]);

my $whois_queue_length_before_abort = 10; # max. whois queue length before we should abort the whois queries for next few seconds (people are probably joining behind a netsplit)
my $whois_abort_seconds = 10; # wait for 10 secs when there's been too many joins

my %servers;

my %whois_waiting;
my %whois_queue;
my %aborted;
my %chan_list;

sub sig_connected {
  my $server = shift;
  $servers{$server->{tag}} = {
    abort_time => 0,  # if join event is received before this, abort
    waiting => 0,     # waiting reply for WHOIS request
    queue => [],      # whois queue
    nicks => {}       # nick => [ #chan1, #chan2, .. ]
  };
}

sub sig_disconnected {
  my $server = shift;
  delete $servers{$server->{tag}};
}

sub msg_join {
  my ($server, $channame, $nick, $host) = @_;
  $channame =~ s/^://;
  my $rec = $servers{$server->{tag}};

  # don't whois people who netjoin back
  return if ($server->netsplit_find($nick, $host));

  return if (time < $rec->{abort_time});
  $rec->{abort_time} = 0;

  # check if the nick is already found from another channel
  foreach my $channel ($server->channels()) {
    my $nickrec = $channel->nick_find($nick);
    if ($nickrec && $nickrec->{realname}) {
      # this user already has a known realname - use it.
      $channel = $server->channel_find($channame);
      $channel->printformat(MSGLEVEL_CRAP, 'join_realname', $nick, $nickrec->{realname});
      return;
    }
  }

  # save channel to nick specific hash so we can later check which channels
  # it needs to print the realname
  my $nicks = $rec->{nicks};
  my $in_queue = $nicks->{$nick};

  my @list = ();
  @list = @{$nicks->{$nick}} if ($nicks->{$nick});

  push @list, $channame;
  $nicks->{$nick} = \@list;

  # don't send the WHOIS again if nick is already in queue
  return if ($in_queue);

  # add the nick to queue
  my @queue = @{$rec->{queue}};
  push @queue, $nick;
  if (scalar @queue >= $whois_queue_length_before_abort) {
    # too many whois requests in queue, abort
    $rec->{queue} = [];
    $rec->{abort_time} = time+$whois_abort_seconds;
    return;
  }
  $rec->{queue} = \@queue;

  # waiting for WHOIS reply..
  return if $rec->{waiting};

  request_whois($server, $rec);
}

sub request_whois {
  my ($server, $rec) = @_;
  my @queue = @{$rec->{queue}};
  return if (scalar @queue == 0);

  my @whois_nicks = splice(@queue, 0, $server->{max_whois_in_cmd});
  my $whois_query = join(',', @whois_nicks);

  # ignore all whois replies except the first line of the WHOIS reply
  my $redir_arg = $whois_query.' '.join(' ', @whois_nicks);
  $server->redirect_event("whois", 1, $redir_arg, 0, 
			  "redir autorealname_whois_last", {
			    "event 311" => "redir autorealname_whois",
			    "event 401" => "redir autorealname_whois_unknown",
			    "redirect last" => "redir autorealname_whois_last",
			    "" => "event empty" });

  $server->send_raw("WHOIS :$whois_query");
  $rec->{queue} = \@queue;
  $rec->{waiting} = 1;
}

sub event_whois {
  my ($server, $data) = @_;
  my ($num, $nick, $user, $host, $empty, $realname) = split(/ +/, $data, 6);
  $realname =~ s/^://;
  my $rec = $servers{$server->{tag}};

  my @channels = @{$rec->{nicks}->{$nick}};
  foreach my $channel (@channels) {
    my $chanrec = $server->channel_find($channel);
    if ($chanrec && $chanrec->nick_find($nick)) {
      $chanrec->printformat(MSGLEVEL_CRAP, 'join_realname', $nick, $realname);
    }
  }

  delete $rec->{nicks}->{$nick};
}

sub event_whois_unknown {
  my ($server, $data) = @_;
  my ($temp, $nick) = split(" ", $data);
  my $rec = $servers{$server->{tag}};

  delete $rec->{nicks}->{$nick};
}

sub event_whois_last {
  my $server = shift;
  my $rec = $servers{$server->{tag}};

  $rec->{waiting} = 0;
  request_whois($server, $rec);
}

foreach my $server (Irssi::servers()) {
  sig_connected($server);
}

Irssi::signal_add( {
        'server connected' => \&sig_connected,
	'server disconnected' => \&sig_disconnected,
	'message join' => \&msg_join,
	'redir autorealname_whois' => \&event_whois,
	'redir autorealname_whois_unknown' => \&event_whois_unknown,
	'redir autorealname_whois_last' => \&event_whois_last });
