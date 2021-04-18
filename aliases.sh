################################################################################
# Aliases
################################################################################

alias ec2="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==\`Name\`].Value|[0],State.Name,PrivateIpAddress,PublicIpAddress]' --output text | column -t | sort -h"
alias a='aws'
alias av='aws-vault'

alias k='kubectl'
alias h='helm'

alias tf='terraform'
alias tfp='tf init && tf plan'
alias tfa='tf init && tf apply'
alias tfd='tf init && tf destroy'
alias tff='tf fmt'
alias tfg='tf graph'
alias tfo='tf output'
alias tfc='rm -rf .terraform && tf init'

alias chrome="/Applications/Google\\ \\Chrome.app/Contents/MacOS/Google\\ \\Chrome"

alias py='python'
alias py3='python3'

alias myip="curl http://ipecho.net/plain; echo"
alias top="htop"
alias histg="history | grep"
alias ping="gping"
alias dt='date -u +"%Y-%m-%dT%H:%M:%SZ"'


############################################################################
#                                                                          #
#               ------- Useful Docker Aliases --------                     #
#                                                                          #
#     # Installation :                                                     #
#     copy/paste these lines into your .bashrc or .zshrc file or just      #
#     type the following in your current shell to try it out:              #
#     wget -O - https://gist.githubusercontent.com/jgrodziski/9ed4a17709baad10dbcd4530b60dfcbb/raw/d84ef1741c59e7ab07fb055a70df1830584c6c18/docker-aliases.sh | bash
#                                                                          #
#     # Usage:                                                             #
#     daws <svc> <cmd> <opts> : aws cli in docker with <svc> <cmd> <opts>  #
#     dc             : docker-compose                                      #
#     dcu            : docker-compose up -d                                #
#     dcd            : docker-compose down                                 #
#     dcr            : docker-compose run                                  #
#     dex <container>: execute a bash shell inside the RUNNING <container> #
#     di <container> : docker inspect <container>                          #
#     dim            : docker images                                       #
#     dip            : IP addresses of all running containers              #
#     dl <container> : docker logs -f <container>                          #
#     dnames         : names of all running containers                     #
#     dps            : docker ps                                           #
#     dpsa           : docker ps -a                                        #
#     drmc           : remove all exited containers                        #
#     drmid          : remove all dangling images                          #
#     drun <image>   : execute a bash shell in NEW container from <image>  #
#     dsr <container>: stop then remove <container>                        #
#                                                                          #
############################################################################
alias daws=d-aws-cli-fn
alias dc=dc-fn
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcr=dcr-fn
alias dex=dex-fn
alias di=di-fn
alias dim="docker images"
alias dip=dip-fn
alias dl=dl-fn
alias dnames=dnames-fn
alias dps="docker ps"
alias dpsa="docker ps -a"
alias drmc=drmc-fn
alias drmid=drmid-fn
alias drun=drun-fn
alias dsp="docker system prune --all"
alias dsr=dsr-fn
