#!/bin/sh

function current_branch {
  echo "$(git branch | grep "*" | cut -d' ' -f2)"
}

function git_fetch {
  git fetch
}

function git_rebase {
  git rebase origin/master
}

function git_push {
  git push
}

public "update" "Pull new commits from the repository"
function update {
  local branch="$(current_branch)"
  if [[ ! "$branch" == "master" ]]; then
    message "Switching to master branch"
    git checkout master
    local switch=true
  fi
  git_fetch
  git_rebase
  if [[ $switch ]]; then
    message "Switching back to $branch branch"
    git checkout "$branch"
    message "Porting changes into $branch"
    git rebase master
  fi
}

public "push" "Push local commits into the repository"
function push {
  local branch="$(current_branch)"
  if [[ "$branch" == "master" ]]; then
    message "Pushing changes from master into server"
    git_push
  else
    message "Pushing changes from $branch into master"
    git checkout master
    git merge "$branch"
    message "Pushing changes from master into server"
    git_push
    message "Going back to $branch branch"
    git checkout "$branch"
    git rebase master
  fi
}

public "merge" "Merge commits into the master branch"
function merge {
  local branch="$(current_branch)"
  if [[ "$branch" == "master" ]]; then
    error "Already on master branch"
  else
    message "Pushing changes from $branch into master"
    git checkout master
    git merge "$branch"
    message "Going back to $branch branch"
    git checkout "$branch"
    git rebase master
  fi
}

public "close" "Delete the current branch and switch back to master"
function close {
  local branch="$(current_branch)"
  if [[ "$branch" == "master" ]]; then
    error "Cannot delete master branch"
  else
    message "Switching to master branch"
    git checkout master
    message "Deleting branch $branch"
    git branch -d "$branch"
  fi
}

public "open" "Creates a new branch off master"
function open {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    input "Name your branch" branch work
  fi
  git checkout -b "$branch"
}
