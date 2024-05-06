#!/usr/bin/env bash

# shellcheck source=../scripts/distro.sh
. scripts/distro.sh
# shellcheck source=../scripts/execs.sh
. scripts/execs.sh
# shellcheck source=../scripts/utils.sh
. scripts/utils.sh

# Remove 1Passowrd agent config from SSH config file
remove_op_agent_from_ssh() {
  sed -i '/IdentityAgent ~\\/\\.1password\\/agent\\.sock/d' /home/node/.ssh/config
}

symlink "$HOME/dotfiles/ssh/config" "$HOME/.ssh/config"

if [ $REMOTE_CONTAINERS ]
then
  echo "Running in remote containers"

  remove_op_agent_from_ssh  
else
  echo "Running locally"
fi
