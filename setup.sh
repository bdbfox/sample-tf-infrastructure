#!/bin/bash

ROOT=`pwd`

echo "## Installing Homebrew"
if [ "$(uname)" == "Darwin" ]; then
  # check if homebrew is installed
  if brew --version > /dev/null; then
    echo "### Homebrew is installed"
  else
    echo "### Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
fi

echo "## Installing Terraform"
if terraform --version > /dev/null; then
  echo "### ...Terraform $(terraform --version) is installed. Updating..."
  brew upgrade terraform
else
  echo "### ...Installing Terraform..."
  brew update
  brew install terraform
fi

echo "## Installing Terragrunt"
if terragrunt --version > /dev/null; then
  echo "### ...Terragrunt $(terragrunt --version) is installed. Updating..."
  brew upgrade terragrunt
else
  echo "### ...Installing Terragrunt..."
  brew update
  brew install terragrunt
fi

echo "## Setup complete"
