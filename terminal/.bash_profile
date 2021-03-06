export http_proxy=http://www-proxy-adcq7-new.us.oracle.com:80
export https_proxy=http://www-proxy-adcq7-new.us.oracle.com:80
export no_proxy='localhost,127.0.0.1,.oracle.com,.oraclecorp.com,.grungy.us'
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
   if [ -f $(brew --prefix)/etc/bash_completion ]; then
   source $(brew --prefix)/etc/bash_completion
   fi
   if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
   __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
   source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
   fi
export M3_HOME="/usr/local/Cellar/maven/3.6.3_1"
export M3=$M3_HOME/bin
export PATH=$M3:$PATH
export BASH_SILENCE_DEPRECATION_WARNING=1

#pic-tools
source /Users/michahuy/tools/pic-tools/scripts/*.env

#fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#ssh fix yubifix 
alias yubifix='pkill -9 ssh-agent;pkill -9 ssh-pkcs11-helper;ssh-add -e /usr/local/lib/opensc-pkcs11.so;ssh-add -k -s /usr/local/lib/opensc-pkcs11.so; ssh-add -l'
export PATH=/Users/michahuy/bin:$PATH
# Yubikey handler
reload-ssh() {
   ssh-add -e /usr/local/lib/opensc-pkcs11.so >> /dev/null
   if [ $? -gt 0 ]; then
       echo "Failed to remove previous card"
   fi
   ssh-add -s /usr/local/lib/opensc-pkcs11.so
}

#ls
alias ls='ls -a'
#cdb
alias cdb='cd ..' 


[[ -e "/Users/michahuy/lib/oracle-cli/lib/python3.7/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/Users/michahuy/lib/oracle-cli/lib/python3.7/site-packages/oci_cli/bin/oci_autocomplete.sh"

[[ -e "/Users/michahuy/lib/oracle-cli/lib/python3.8/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/Users/michahuy/lib/oracle-cli/lib/python3.8/site-packages/oci_cli/bin/oci_autocomplete.sh"
