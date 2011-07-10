# Display "nick@address #channel" in XTerm title
# for irssi 0.7.98 by Timo Sirainen

use Irssi;
use IO::Handle;

sub xterm_topic {
	my $text = shift;

	STDERR->autoflush(1);
	print STDERR "\033]0;$text\007";
}

sub refresh_topic {
	my $server = Irssi::active_server();
	my $item = Irssi::active_win()->{active};

        my $title;
	if (!$server) {
                $title = "not connected";
	} else {
		$title = $server->{nick}."@".$server->{address};
		$title .= " ".$item->{name} if ($item);
	}
	xterm_topic($title);
}

Irssi::signal_add('window changed', 'refresh_topic');
Irssi::signal_add('window item changed', 'refresh_topic');
Irssi::signal_add('window server changed', 'refresh_topic');
Irssi::signal_add('server nick changed', 'refresh_topic');
