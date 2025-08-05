export PATH="$PATH:$HOME/dev/ops-cmd/lhotse_ops/files/ops_command/bin"
#export PATH="$PATH:$HOME/dev/lhotse-puppet/modules/lhotse_ops/files/ops_command/bin:$HOME/dev/lhotse-puppet/modules/lhotse_ops/files/scripts"

for a in p2:459940072735:465543055212 \
	ft1:054395779405:634353253303 \
	codelab:699194762178:0 \
	dv:316186851731:948404762416 \
	dv-dr:146430384206:176779409311; do
	#dv-dr:146430384206:093753516799; do
  profile_name=$(echo ${a} | cut -d: -f1)
  nl_account=$(echo ${a} | cut -d: -f2)
  l_account=$(echo ${a} | cut -d: -f3)


  alias swamp-${profile_name}-nonlive-admin="swamp -account ${nl_account} -mfa-device arn:aws:iam::027617375449:mfa/awarneck -target-profile ${profile_name}-nonlive-admin -target-role admin -renew" 
  alias swamp-${profile_name}-live-admin="swamp -account ${l_account} -mfa-device arn:aws:iam::027617375449:mfa/awarneck -target-profile ${profile_name}-live-admin -target-role admin -renew" 
  alias swamp-${profile_name}-nonlive-developer="swamp -account ${nl_account} -mfa-device arn:aws:iam::027617375449:mfa/awarneck -target-profile ${profile_name}-nonlive-developer -target-role developer -renew" 
  alias swamp-${profile_name}-live-developer="swamp -account ${l_account} -mfa-device arn:aws:iam::027617375449:mfa/awarneck -target-profile ${profile_name}-live-developer -target-role developer -renew" 
done

eval "$(/opt/homebrew/bin/brew shellenv)"

##
# Your previous /Users/Arvid.Warnecke/.zprofile file was backed up as /Users/Arvid.Warnecke/.zprofile.macports-saved_2022-05-18_at_08:22:07
##

# MacPorts Installer addition on 2022-05-18_at_08:22:07: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# MacPorts Installer addition on 2022-05-18_at_08:22:07: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

# Here are secrets located
source ~/.zprofile_otto
