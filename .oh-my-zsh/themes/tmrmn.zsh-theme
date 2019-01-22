# check session type
local session_type='local'
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  session_type='remote'
# many other tests omitted
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) session_type='remote';;
  esac
fi

# colors
local c_reset='%F{008}'
local c_user='%F{007}'
local c_host='%F{015}'
local c_path='%F{006}' #%F{166}
local c_path_no='%F{001}'
local c_git_clean='%F{002}' #%F{002}
local c_git_staged='%F{027}' #%F{012}%F{004}
local c_git_unstaged='%F{003}'
local c_branch_name='%F{008}' #%%F{236}
local c_alien='%F{005}'

# get directory info
function collapse_pwd () {
    if [[ -w $(pwd) ]]; then
      pwd_color="%{$c_path%}"
    else
      pwd_color="%{$c_path_no%}"
    fi
    echo $pwd_color${PWD/#$HOME/⌂}
}

# get user if different from default
function get_user() {
  if [ $USER != $default_username ]; then echo "%{$c_user%}%n "; else echo ""; fi
}

# get host name if remote session
function get_host() {
  # session_type='remote'
  if [ $session_type = 'remote' ]; then echo "%{$c_reset%}at %{$c_host%}%M "; fi
}

# Git info.
function parse_git_prompt ()
{
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
        ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
        # echo "${ref#refs/heads/}"
        #GIT_NAME=`git config --get remote.origin.url 2>/dev/null`
        GIT_NAME=`git config --get remote.origin.url | sed 's/.*\///' | sed 's/\.git//' 2>/dev/null`
        if [ ${#GIT_BRANCH} -eq 40 ]; then
            GIT_BRANCH="(no branch)"
        fi
        STATUS=`git status --porcelain 2>/dev/null`
        if [ -z "$STATUS" ]; then
            git_color="%{$c_git_clean%}"
        else
            echo -e "$STATUS" | grep -q '^ [A-Z\?]'
            if [ $? -eq 0 ]; then
                git_color="%{$c_git_unstaged%}"
            else
                git_color="%{$c_git_staged%}"
            fi
        fi
        echo "%{$c_reset%} on $git_color${ref#refs/heads/}$c_reset""±$c_branch_name$GIT_NAME$c_reset"
    fi
}

local curuser='$(get_user)'
local curdir='$(collapse_pwd)'
local gitinfo='$(parse_git_prompt)'

# Prompt format: \n # USER at MACHINE in DIRECTORY on git:BRANCH STATE [TIME] \n $
PROMPT="
%{$c_reset%}\
${curuser}\
$(get_host)\
%{$c_reset%}in \
${collapse_pwd}\
${curdir}\
${gitinfo}
%{$c_reset%}do %{$reset_color%}"
