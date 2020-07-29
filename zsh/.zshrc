#! /bin/bash

# ------- MAC -------
# Turn off mouse accel, also called "pointer precision"
defaults write .GlobalPreferences com.apple.mouse.scaling -1
# Make MAC Finder show files that begin with "." by default
# You can use:  CMD + SHIFT + .   to enable this temporarily instead if you want
defaults write com.apple.finder AppleShowAllFiles YES


# ------- VARIABLES -------
# Make your history command show timestamps
export HISTTIMEFORMAT="%Y-%m-%d %T "

# OCI CLI Vars
# These are helpful so you don't have to constantly look them up
# Replace the contents with your own of the following:
export USER_OCID="ocid1.user.oc1..aaaaaaaayfxwatk5pcuazrm6hq32th37pflbtlqxe7ngvrp7onxufwlzsetq"
export USER_FINGERPRINT="58:f0:a3:21:2b:da:32:2a:3a:4b:58:7a:9c:77:f0:fc"
export USER_PRIVATE_KEY="/Users/michahuy/.oci/michahuy_private_key.pem"
# This is the same for you
export OCI_AUTH_TENANCY="ocid1.tenancy.oc1..aaaaaaaagkbzgg6lpzrf47xzy4rjoxg4de6ncfiq2rncmjiujvy2hjgxvziq"

# Path to your oh-my-zsh installation.
export ZSH="/Users/michahuy/.oh-my-zsh"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=/Users/michahuy/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# pic-tools
source /Users/michahuy/tools/pic-tools/scripts/*.env

# fzf - command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ------- Aliases -------
# So when you make changes to your .bash_profile, they're reflected in your terminal after typing "sb"
alias sb="source ~/.bash_profile"
# Make grep use extend regular expression and default color
alias grep="egrep --color=auto -I"
# Enable color in LS
alias ls="ls -aG"
# ll is awesome -l == long format, -a == show directories that start with ".", -h == Show human readable sizes
alias ll="ls -lah -G"

# Get the full path to a file: EG "readlink ad2.r2.ini" Outputs: /Users/michahuy/git/operations/ad2.r2.ini
# GNU Readlink has to be installed before you can use this: brew install coreutils
alias readlink="greadlink -f "
# If you're on PF team, HIGHLY recommend you make an alias to CD to your operations directory
alias cdo="cd ~/workspace/operations"
# So find doesn't yell at you about permissions
alias find="sudo find"
# Opens .zshrc config file
alias zshconfig="vim ~/.zshrc"
# So you don't have to type ..
alias cdb="cd .."
# Takes you to home direcotry
alias cdh="cd ~"
# OC7 Barndoor
alias sshoc7='ssh -vtD 1081 barndoor7.ob.us-phoenix-1.oci.oraclecloud.com watch -n 90 date'
# YubiKey Fix
alias yk='pkill -9 ssh-agent;pkill -9 ssh-pkcs11-helper;ssh-add -s /usr/local/lib/opensc-pkcs11.so'

# ------- FUNCTIONS -------

# GIT
# Make adding all files, committing, and commit messaging easier
# Don't use this without a commit message in a real branch, we don't want commit messages that get merged to say
# "stuff".  You should try to always "gpush '<COMMIT MESSAGE>'" instead of "gpush".
function gpush() {
    git add -A
    if [[ -z $@ ]]; then
        git commit -m "Stuff"
    else
        git commit -m "$@"
    fi
    git push
}

# Merge Master in to your working branch more easily
function mergem() {
    branch=$(git rev-parse --abbrev-ref HEAD)
    git checkout master
    git pull
    git checkout $branch
    git merge master -m "Merge master in to $branch"
    unset branch
}

# Squash your commits in to one commit - again, try to always type "squish '<COMMIT MESSAGE>'" and not just "squish"
function squish() {
    if [[ -z "$1" ]];then
        git reset --soft $(git merge-base HEAD master) && git commit --reuse-message=HEAD@{1}
    else
        git reset --soft $(git merge-base HEAD master) && git commit --reuse-message=HEAD@{$1}
    fi
}

# Force the push up of your current branch to bitbucket.
# This is used when you create a new branch and it doesn't exist in bitbucket yet, as well as when you squish a branch
# and need to override previous commits.
function push() {
	git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD) --force
}

# Create a new git branch from current master
# Use this when you want to set up a Pull request for your code, then checkout the files you want to merge from your
# working branch in to this new one you just created.
function newb() {
    git checkout master
    if [[ $? -ne 0 ]]; then
        return
    fi
    git pull
    git checkout -b $1
    if [[ $? -ne 0 ]]; then
        echo -e "$red""New branch creation failed""$off"
        git checkout $1
    fi
}

# Get just the FILE NAMES of the files that are different between your branch and master
function gdiff() {
    if [[ -z $1 ]]; then
        git diff master --name-only
    else
        git diff $1 --name-only
    fi
}

# GENERAL
# Get the latest SSH configs
# This requires that you have your SSH config files set up the way I do, and that your "flamingotoolbox" is at the path
# shown.  Please adjust your paths accordingly, but this function is worth the time to set up properly.
# The purpose is 2 things:
# git pull in SecOps "ssh_configs" repo, get latest master
# git pull in the "flamingotoolbox" repo from PF
# Personally, I have each of these repos in a custom branch, and that's why "mergem" and "gpush/mergem" are used here,
# because I have small tweaks to the files that I use.
function refressh() {
    curr=`pwd`
    cd ~/.ssh/ssh_configs/
    echo "Doing" `pwd`
    mergem
    cd ~/git/flamingotoolbox/
    echo "Doing" `pwd`
    gpush
    mergem
    echo "" > ~/.ssh/known_hosts
    cd $curr
    unset curr
}

# Run a single command on a remote host without the "authorized users only" spam
function remote() {
    ip=$1
    shift
    ssh -q $ip $@ 2>/dev/null
    unset ip
}

# FOPS / LB specific
# All of these functions require that "fops" be runnable from anywhere - you can set up a symlink to fops with:
# ln -s <FULL PATH TO FOPS BINARY IN THE VENV> ~/bin/fops

# All commands require tunnel to be up

# Get information about an LB using fops and run it through JQ.  Pass any variables after the OCID to JQ.
# lbget <OCID>
# lbget <LAST SHA PART>
# lbget <OCID> '.hosts'
function lbget() {
    if [[ -z $1 ]]; then
        echo "No LBID supplied."
        return
    fi
    lb=$1
    shift
    if [[ "$lb" =~ ^[a-z0-9]+$ ]]; then
        reg=`tunnel -l |awk '/Curren.*Region/ {print $NF}' |tr -d ':'`
        if [[ -z $reg ]]; then
            echo "No active tunnel to reconstruct LB from?  Check tunnel."
            return
        elif [[ $reg == "us-ashburn-1" ]]; then
            reg="iad"
        elif [[ $reg == "us-phoenix-1" ]]; then
            reg="phx"
        fi
        lb="ocid1.loadbalancer.oc1.$reg.$lb"
        echo "Reconstructed LB to: $lb"
        # return
    fi
    unset args
    for arg in "$@"; do
        args="${args} '${arg}'"
    done
    # echo "fops lbs get $lb |jq $args"
    eval "fops lbs get $lb |jq $args"
}

# Get information about a specific host ocid from fops and run it through JQ
function fget() {
    if [[ -z $1 ]]; then
        echo "No Host OCID supplied."
        return
    fi
    ocid=$1
    shift
    unset args
    for arg in "$@"; do
        args="${args} '${arg}'"
    done
    # echo "fops lbs get $lb |jq $args"
    if [[ -z $ocid ]]; then
        eval "curl -s http://localhost:11000/v1/fleet/ |jq $args"
    else
        eval "curl -s http://localhost:11000/v1/fleet/ |jq '.[] |select(.id==\"$ocid\")' |jq $args"
    fi
}

# Get the sahpesplacementsv2 of a host OCID
function fsget() {
    fops profiles shapes placementsv2 get $1
}

# List hosts in the region and show their AD, OCID, whether they're marked for removal or not, and host type.
# VERY USEFUL IN PREPROD
function flist() {
    fops hosts list --limit 5000 | jq -r '.[] |"\(.availabilityDomain) \(.faultDomain) \(.hostName) \(.id) \(.markedForRemoval) \(.state) \(.hostType)"' | sort
}

# Get workrequest information from workrequest OCID
function wrget() {
    if [[ -z $1 ]]; then
        echo "No work request OCID supplied."
        return
    fi
    wr="$1"
    shift
    fops workrequests get $wr |jq $@
}

# Delete a TERMINATED HOST from fops, and its shapes placements
function nuke_from_fops() {
    if [[ -z $1 ]]; then
        echo -e "You need to give me a host to nuke."
        return
    fi
    if ! [[ `fops hosts get $1` ]]; then
        echo -e "fops hosts get $1   failed, check tunnel?"
        return
    fi
    if [[ $2 != "nocheck" ]]; then
        lbs=`fops lbs list_for_host $1`
        if [[ -n $lbs ]]; then
            echo -e $red"Can't delete $1, it still has LBs on it:"$off
            echo $lbs
            return
        fi
    fi

    echo -e "Marking host for removal..."
    fops hosts remove --mark $1 --why "Killing this host from fops"

    # Get shapes placements
    echo -e "Getting placements..."
    echo -e $cya"fops profiles shapes placements list |grep \": \\\"[0-9Mbpsicro\-]+$1[0-9\-]*\\\"\" |prep -p 'id\": \"(.*?)\"'"$off
    placements=(` fops profiles shapes placements list |grep ": \"[0-9Mbpsicro\-]+$1[0-9\-]*\"" |prep -p 'id": "(.*?)"'`)
    echo -e "Deleting placements..."
    for placement in ${placements[@]};do
        echo -e "fops profiles shapes placements delete $placement"
        fops profiles shapes placements delete $placement
        if [[ $? -ne 0 ]]; then
            echo -e $red"Something went wrong trying to delete $placement ."$off
            return
        fi
    done
    echo -e $cya"fops profiles shapes placementsv2 list |grep \": \\\"[0-9Mbpsicro\-]+$1[0-9\-]*\\\"\" |prep -p 'id\": \"(.*?)\"'"$off
    placements=(`fops profiles shapes placementsv2 list |grep ": \"[0-9Mbpsicro\-]+$1[0-9\-]*\"" |prep -p 'id": "(.*?)"'`)
    echo -e "Deleting placements..."
    for placement in ${placements[@]};do
        echo -e $cya"fops profiles shapes placementsv2 delete $placement"$off
        fops profiles shapes placementsv2 delete $placement
        if [[ $? -ne 0 ]]; then
            echo -e $red"Something went wrong trying to delete $placement ."$off
            return
        fi
    done
    echo -e "Deleting host:"
    fops hosts get $1
    echo -e "fops hosts delete $1"
    fops hosts delete $1
    if [[ $? -ne 0 ]]; then
        echo -e $red"Delete host failed."$off
    else
        echo -e $grn"Done."$off
    fi
}

# OCI CLI
# Update / install OCI CLI
function update_oci() {
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
}

# Get information about a host OCID from OCI CLI
# VERY USEFUL - set up your OCI CLI so that you can run this, I can't tell you how many times this has been a relief
# to run.
# cget <OCID> <REGION LONG>
# cget ocid1.instance.oc1.phx.anyhqljtyhrfuyycausbe5c6uvbhxrt42yvc7c7lfljqm2i3v24jhcjfme7a us-phoenix-1
function cget() {
    ocid="$1"
    shift
    reg="$1"
    shift
    oci compute instance get --instance-id $ocid --region $reg |jq $@
}

# List the VNICs on a host OCID and pipe it through JQ
# get_vnics <OCID> <REGION LONG>
# get_vnics ocid1.instance.oc1.phx.anyhqljtyhrfuyycausbe5c6uvbhxrt42yvc7c7lfljqm2i3v24jhcjfme7a us-phoenix-1
function get_vnics() {
    ocid="$1"
    shift
    reg="$1"
    shift
    oci compute instance list-vnics --instance-id $ocid --region $reg |jq $@
}

# Get information about a specific VNIC using the VNIC OCID
# vget <OCID> <REGION LONG>
# vget ocid1.vnic.oc1.phx.abyhqljtdndjunbmsal6roq37vtkxs4ze57yn3ku2zvegyuga6rmilkwo4rq us-phoenix-1
function vget() {
    ocid="$1"
    shift
    reg="$1"
    shift
    oci network vnic get --vnic-id $ocid --region $reg |jq $@
}

# PAWS
# This will write out the paws command that decommissions a host for you given only a host OCID
function scratch() {
    if [[ $(echo $1 |grep -i help) ]]; then
        echo "Decommission a given OCID.  Make sure you are tunneled in to the appropriate region."
        echo "Usage:"
        echo "  scratch <OCID> <REASON CODE or TEXT>"
        echo "Reason codes:"
        echo "  1: \"Decommission X5s to return to compute\""
        echo "  2: \"Decommission X7s to return to compute\""
        echo "  3: \"CM 200479 Decommission hosts with older partition scheme\""
        echo "  4: \"Decommission CasperV1 hosts for LBROadmap 226 CM-190345\""
        echo "  5: \"Hardware / technical problems with host\""
        return
    fi
    o=$1
    reason="I just feel like it"
    if [[ -n "$@" ]]; then
        if [[ $(echo $2 |grep '^[0-9]+$') ]]; then
            if [[ $2 -gt 5 ]] || [[ $2 -lt 1 ]]; then
                echo "Reason code must be an integer between 1 and 5."
                return
            elif [[ $2 -eq 1 ]]; then
                reason="Decommission X5s to return to compute"
            elif [[ $2 -eq 2 ]]; then
                reason="Decommission X7s to return to compute"
            elif [[ $2 -eq 3 ]]; then
                reason="CM 200479 Decommission hosts with older partition scheme"
            elif [[ $2 -eq 4 ]]; then
                reason="Decommission CasperV1 hosts for LBROadmap 226 CM-190345"
            elif [[ $2 -eq 5 ]]; then
                reason="Hardware / technical problems with host"
            fi
        elif [[ $(echo "$@" |wc -c) -lt 5 ]]; then
            echo "Reason text must be greater than 5 characters, or use a reason code."
            return
        else
            reason="$@"
        fi
    else
        echo "Specify a reason.  Type scratch help for help."
        return
    fi

    fops hosts get $o > .scratch_temp
    o=$(cat .scratch_temp |jq -r '.id')
    r=$(get_long_from_ocid $o)
    a=$(cat .scratch_temp |jq -r '.availabilityDomain' |cut -d\- -f3)
    a="ad$a"
    h=$(cat .scratch_temp |jq -r '.hostName')
    h=$(ssh -q $h "hostname" 2>/dev/null)
    rm -rf .scratch_temp

    echo "paws capacity decommission --host_id $o --region $r --availability_domain $a --host_name $h --why \"$reason\""
    # paws capacity decommission --host_id $o --region $r --availability_domain $a --host_name $h --why "$reason"
    echo
}