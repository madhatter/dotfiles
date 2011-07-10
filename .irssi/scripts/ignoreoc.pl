#!/usr/bin/perl -w
use Irssi;
use vars qw($VERSION %IRSSI);
$VERSION = "0.3";
%IRSSI = (
    authors     => "Erkki Seppälä",
    contact     => "flux\@inside.org",
    name        => "Ignore-OC",
    description => "Ignore messages from people not on your channels." .
		   "Now people you msg are added to bypass-list.",
    license     => "Public Domain",
    url         => "http://xulfad.inside.org/~flux/software/irssi/",
    changed     => "Sun Jan 27 19:07:00 CET 2002"
);

my %bypass = ();

sub cmd_message_private {
  my ($server, $message, $nick, $address) = @_;
  my $channel;

  if ($message =~ m/oc:/i ||
      exists $bypass{$nick}) {
    return 1;
  }

  foreach $channel (Irssi::active_server()->channels()) {
    foreach my $other ($channel->nicks()) {
      if ($other->{nick} eq $nick) {
        return 1;
      }
    }
  }

  Irssi::active_server()->command("^NOTICE $nick You're not on any channel I'm on, thus, due to spambots, your message was ignored. Prefix your message with 'OC:' to bypass the ignore.");
  Irssi::signal_stop();
}

sub cmd_message_own_private {
  my ($server, $message, $nick, $address) = @_;
  $bypass{$nick} = 1;
}

Irssi::signal_add("message private", "cmd_message_private");
Irssi::signal_add("message own_private", "cmd_message_own_private");
