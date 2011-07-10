# /binary huora
# tuolostaa k.o. ikkunaan huora:n sijaan 01101001 ....

use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

$VERSION = "1.0";
%IRSSI = (
        authors     => "Riku Voipio",
        contact     => "riku.voipio\@iki.fi",
        name        => "binary",
        description => "adds /binary command that converts what you type into 2-base string representation",
        license     => "GPLv2",
        url         => "http://nchip.ukkosenjyly.mine.nu/irssiscripts/",
    );


sub cmd_binary {
	$_=join(" ",$_[0]);
	$_=reverse;
	my (@r);
	$r[0]="/say";
	while ($a = chop($_)) {
	        push (@r,unpack ("B*", $a));}
			
	my $window = Irssi::active_win();
	$window->command(join (" ",@r));
}
#this is borken - need2fix
sub cmd_unbinary {
	my (@x)=$_[0];
	my (@r);
		 
	$r[0]="/say";
	while (my($a)=shift @x){
		push(@r, pack ("B*",$a));
	}
	my $window = Irssi::active_win();
	$window->command(join (" ",@r));
	
}
Irssi::command_bind('binary', 'cmd_binary');
#Irssi::command_bind('unbinary', 'cmd_unbinary');
Irssi::print("binary obfuscator vanity script by nchip loaded");
