# vim: filetype=sh
autoload colors
colors

# for git information in the prompt
git_status_count() {
  if [ -z $1 ]; then
    echo $(git status --porcelain | wc -l)
  else
    echo $(git status --porcelain | grep -E "^$1" | wc -l)
  fi
}

git_untracked_count() {
  count=$(git_status_count "\?\?")
  if [ $count -eq 0 ]; then return; fi
  echo " %{$fg_bold[yellow]%}?%{$fg_no_bold[black]%}:%{$reset_color$fg[yellow]%}$count%{$reset_color%}"
}

git_modified_count() {
  count=$(git_status_count "^\sM")
  if [ $count -eq 0 ]; then return; fi
  echo " %{$fg_bold[red]%}M%{$fg_no_bold[black]%}:%{$reset_color$fg[red]%}$count%{$reset_color%}"
}

git_staged_count() {
  count=$(git_status_count "[A|M|D|C]\s")
  if [ $count -eq 0 ]; then return; fi
  echo " %{$fg_bold[green]%}S%{$fg_no_bold[black]%}:%{$reset_color$fg[green]%}$count%{$reset_color%}"
}

git_branch() {
  branch=$(git symbolic-ref HEAD --short --quiet 2> /dev/null)
  if [ -z $branch ]; then
    echo "%{$fg[yellow]%}$(git rev-parse --short HEAD)%{$reset_color%}"
  else
    if [[ $branch == "master" || $branch == "main" ]]; then
      echo "%{$fg[green]%}$branch%{$reset_color%}"
    else
      echo "%{$fg[red]%}$branch%{$reset_color%}"
    fi
  fi
}

git_remote_difference() {
  branch=$(git symbolic-ref HEAD --short --quiet)
  if [ -z $branch ]; then return; fi

  remote=$(git config branch.$branch.remote)
  ahead_by=$(git log --oneline $remote/$branch..HEAD 2> /dev/null | wc -l)
  behind_by=$(git log --oneline HEAD..$remote/$branch 2> /dev/null | wc -l)

  output=""
  if [ $ahead_by -gt 0 ]; then output="$output%{$fg_bold[white]%}↑%{$reset_color%}$ahead_by"; fi
  if [ $behind_by -gt 0 ]; then output="$output%{$fg_bold[white]%}↓%{$reset_color%}$behind_by"; fi

  echo $output
}

git_user() {
  user=$(git config user.name)
  if [ -z $user ]; then
    echo "%{$fg_bold[red]%}no user%{$fg[bright-black]%}@%{$reset_color%}"
  else
    echo "$user%{$fg[bright-black]%}@%{$reset_color%}"
  fi
}

git_prompt_info() {
  if git rev-parse --is-inside-work-tree >& /dev/null; then
	  info="$(git_user)$(git_branch)$(git_remote_difference)"
	  if [ $(git_status_count) -gt 0 ]; then
	    info="$info$(git_staged_count)$(git_modified_count)$(git_untracked_count)"
	  fi
	  print "$info "
  else
	return
  fi
}

# for mercurial information in the prompt
hg_status_count() {
	if [ -z $1 ]; then
		echo $(hg status | wc -l)
	else
		echo $(hg status | grep -E "^$1" | wc -l)
	fi
}

hg_untracked_count() {
	count=$(hg_status_count "\?")
	if [ $count -eq 0 ]; then return; fi
	echo " %{$fg_bold[yellow]%}?%{$fg_no_bold[black]%}:%{$reset_color$fg[yellow]%}$count%{$reset_color%}"
}

# the differentiation between modified and staged changes might be
# not too useful as mercurial stages everything but new files by default.
#hg_modified_count() {
#  count=$(hg_status_count "^M\s")
#  if [ $count -eq 0 ]; then return; fi
#  echo " %{$fg_bold[red]%}M%{$fg_no_bold[black]%}:%{$reset_color$fg[red]%}$count%{$reset_color%}"
#}

hg_staged_count() {
  count=$(hg_status_count "[A|M|R|C]\s")
  if [ $count -eq 0 ]; then return; fi
  echo " %{$fg_bold[green]%}S%{$fg_no_bold[black]%}:%{$reset_color$fg[green]%}$count%{$reset_color%}"
}

hg_branch() {
	branch=$(hg branch)
	if [ -z $branch ]; then
		return
	else
		echo "%{$fg[green]%}$branch%{$reset_color%}"
	fi
}

hg_remote_difference() {
  branch=$(hg branch)
  if [ -z $branch ]; then return; fi

  ahead_by=$(hg outgoing | grep changeset: | wc -l)
  behind_by=$(hg incoming | grep changeset: | wc -l)

  output=""
  if [ $ahead_by -gt 0 ]; then output="$output%{$fg_bold[white]%}↑%{$reset_color%}$ahead_by"; fi
  if [ $behind_by -gt 0 ]; then output="$output%{$fg_bold[white]%}↓%{$reset_color%}$behind_by"; fi

  echo $output
}

hg_user() {
	user=$(hg showconfig ui.username)
	if [ -z $user ]; then
		echo "%{$fg_bold[red]%}no user%{$fg[black]%}@%{$reset_color%}"
	  else
		echo "$user%{$fg[black]%}@%{$reset_color%}"
	fi
}

hg_prompt_info() {
	#if [[ ! -d .hg ]]; then return; fi
	if ! HG_ROOT=$(hg root) 2> /dev/null; then return; fi
	#info="$(hg_user)$(hg_branch)$(hg_remote_difference)"
	info="$(hg_user)$(hg_branch)"
	if [ $(hg_status_count) -gt 0 ]; then
		#info="$info$(hg_untracked_count)$(hg_modified_count)$(hg_staged_count)"
		info="$info$(hg_untracked_count)$(hg_staged_count)"
	fi
	print "$info "
}

date_info() {
	info="$(date +%H:%M.%S)"
	echo "[%{$fg[white]%}$info] "
}

# build my prompt
export PROMPT='$(date_info)%{$fg[blue]%}%~%{$reset_color%} $(hg_prompt_info)$(git_prompt_info)%{$fg[magenta]%}$%{$reset_color%} '
