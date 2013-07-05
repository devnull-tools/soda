#!/bin/sh
#                            The MIT License
#
#        Copyright (c) 2013 Marcelo Guimaraes <ataxexe@gmail.com>
# ----------------------------------------------------------------------
# Permission  is hereby granted, free of charge, to any person obtaining
# a  copy  of  this  software  and  associated  documentation files (the
# "Software"),  to  deal  in the Software without restriction, including
# without  limitation  the  rights to use, copy, modify, merge, publish,
# distribute,  sublicense,  and/or  sell  copies of the Software, and to
# permit  persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The  above  copyright  notice  and  this  permission  notice  shall be
# included  in  all  copies  or  substantial  portions  of the Software.
#                        -----------------------
# THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY OF ANY KIND,
# EXPRESS  OR  IMPLIED,  INCLUDING  BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN  NO  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM,  DAMAGES  OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT  OR  OTHERWISE,  ARISING  FROM,  OUT OF OR IN CONNECTION WITH THE
# SOFTWARE   OR   THE   USE   OR   OTHER   DEALINGS  IN  THE  SOFTWARE.

# Example of a simple git workflow

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

function stash_work {
  git diff-files --quiet
  if [[ "$?" == 1 ]]; then
    message "Stashing changes"
    STASH=true
    git stash save
    if [[ $(git stash list | wc -l) == 0 ]]; then
      STASH_CLEAR=true
    fi
  fi
}

function unstash_work {
  if [[ $STASH ]]; then
    message "Applying stash"
    git stash apply
    if [[ $STASH_CLEAR ]]; then
      message "Clearing stash"
      git stash clear
    fi
  fi
}

task "update" "Pull new commits from the repository"
function update {
  stash_work
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
  unstash_work
}

task "push" "Push local commits into the repository"
function push {
  stash_work
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
  unstash_work
}

task "merge" "Merge commits into the master branch"
function merge {
  stash_work
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
  unstash_work
}

task "close" "Delete the current branch and switch back to master"
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

task "open" "Creates a new branch off master"
function open {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    input "Name your branch" branch work
  fi
  git checkout -b "$branch"
}

# Tests if the git is using svn

git_status="$(git status &> /dev/null)"

if [[ "$?" == 0 ]]; then
  if [[ $(git branch -a | grep -ie trunk) ]]; then
    message "Found git svn branch"

    function git_fetch {
      git svn fetch
    }

    function git_rebase {
      git svn rebase
    }

    function git_push {
      git svn dcommit
    }
  fi
fi
