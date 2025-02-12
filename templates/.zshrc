# git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
ZSH_THEME="spaceship"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-z
)

# https://ohmyz.sh/
source ~/.oh-my-zsh/oh-my-zsh.sh

# TODO: move to separate file
read_env() {
  local filePath="${1:-.env}"

  if [ ! -f "$filePath" ]; then
    echo "missing ${filePath}"
    exit 1
  fi

  # echo "Reading $filePath"
  
  while read -r LINE; do
    # Remove leading and trailing whitespaces, and carriage return
    CLEANED_LINE=$(echo "$LINE" | awk '{$1=$1};1' | tr -d '\r')

    if [[ $CLEANED_LINE != '#'* ]] && [[ $CLEANED_LINE == *'='* ]]; then
      export "$CLEANED_LINE"
    fi
  done < "$filePath"
}

# -------------------------------- #
# Node Package Manager
# -------------------------------- #
# https://github.com/antfu/ni

alias nio="ni --prefer-offline"
alias s="nr start"
alias d="nr dev --no-fork"
alias play="nr play --no-fork"
alias b="nr build"
alias bw="nr build --watch"
alias t="nr test"
alias tu="nr test -u"
alias tw="nr test --watch"
alias w="nr watch"
alias p="nr play"
alias c="nr typecheck"
alias lint="nr lint"
alias lintf="nr lint --fix"
alias release="nr release"
alias re="nr release"

# -------------------------------- #
# Vercel
# -------------------------------- #

# Run vercel command with the token from the env file
# Example: vercel_cli deploy
vercel_cli() {
  # read env file
  local envFile=".env"
  read_env $envFile

  # get all arguments or 'deploy' as default
  local command="${@:-deploy}"

  # get the vercel token loaded from the env file
  local vercelToken="${VERCEL_TOKEN:-$VERCEL_TOKEN}"

  # check if the vercel token is set
  if [ -z "$vercelToken" ]; then
    echo "VERCEL_TOKEN is not set"
    exit 1
  fi

  # run the vercel command
  # printf "Running vercel command: $command"
  npx -y vercel@latest --token $vercelToken $command
}

alias v="vercel_cli"
alias vprod="vercel_cli deploy --prod"
alias vbuild="vercel_cli build"
alias vprebuilt="vercel_cli deploy --prebuilt"
alias vdev="vercel_cli dev"
alias vi="vercel_cli init"
alias vlogin="npx -y vercel@latest login"

# Deploy to custom domain
# Example: vcustom mydomain.com
# https://vercel.com/docs/cli/deploy#deploying-to-a-custom-domain
vcustom() {
  local envFile=".env"

  read_env $envFile

  local customDomain="${1:-$VERCEL_CUSTOM_DOMAIN}"

  printf "Deploying to custom domain $customDomain ..."

  # run command and save stdout and stderr to files
  vercel_cli deploy >.vercel/deployment-url.txt 2>.vercel/deployment-error.txt

  # check the exit code
  code=$?
  if [ $code -eq 0 ]; then
      printf "Deployment was successful"
      printf "Assigning custom domain $customDomain to deployment"
      # Now you can use the deployment url from stdout for the next step of your workflow
      deploymentUrl=`cat .vercel/deployment-url.txt`
      # run command and show output during the build
      vercel_cli alias $deploymentUrl $customDomain
  else
      # Handle the error
      errorMessage=`cat .vercel/deployment-error.txt`
      printf "There was an error: $errorMessage"
  fi
}

# -------------------------------- #
# Dev Containers
# -------------------------------- #

# function to apply devcontainer templates with argument for the url of template
apply_devcontainer_template() {
  local template="ghcr.io/dbarjs/devcontainer-templates/$1"

  echo "Applying devcontainer template from $template"

  npx @devcontainers/cli@latest templates apply -t "$template"
}

alias applytemplate="apply_devcontainer_template"

# ZSH
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true

# Command history
export HISTFILE=/commandhistory/.zsh_history 
