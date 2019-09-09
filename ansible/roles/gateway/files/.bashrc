# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

export EC2_INI_PATH=/root/data-sandbox/ansible/ec2.ini_for_gateway
export ANSIBLE_HOSTS=/root/data-sandbox/ansible/ec2.py