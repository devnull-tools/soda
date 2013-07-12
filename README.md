# soda

SODA is a simple platform to help writing and executing tasks in shell script.

## How It Works

SODA works by loading any scripts in a specific directory and calling a function
passed by the command line. Only functions exposes through the builtin **task** function
may be called.

## How To Install

Just clone the git repo and place the *soda* file in your path (a symlinks works well to).
After that, ensure you have a **$SODA_DIR** pointing to the place you clone the repo and you're
done.

## How To Use

Create a *~/.soda* directory with the following structure:

* _scripts_ - directory to put the scripts organized by namespaces
* _resources_ - directory to put resources (available through the
**$SODA_RESOURCES** variable)
* _options_ - directory to put custom options using the pattern ${option_name}.conf
(you can load the option using the **--options** parameter)

Inside *scripts*, any function in any script present in *scripts/common* will be
loaded and may be called through `soda`:

    task "git-open" "Creates a new branch off master"
    git_open() {
      local branch="$1"
      if [[ -z "$branch" ]]; then
        input "Name your branch" branch work
      fi
      git checkout -b "$branch"
    }

    $ soda git-open work

This will call the *git_open* function passing *work* as the arguments. By convention, you
may call a function with underscores replacing them by hyphens. To execute the task without
arguments, just use `soda git-open`.

To see the program usage, type `$ soda` or `$ soda --help`

## Task Namespaces

The namespaces are single directories in _scripts_. By default, the *common* and *soda* namespaces
are always imported. You can include other namespaces using the **import** function.

Namespaces are useful if you have a set of scripts that you should use only on specific cases. (It
also keeps your scripts organized.)

    # Example: script inside ~/.soda/scripts/git

    task "push" "Push local commits into the repository"

    push() {
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

You can call any task in *git* namespace using a **"."**:

    $ soda git.push

The **"."** indicates that namespace is the first part and task is the second part.

## Task Parameters

If you need to pass a set of parameters, you can use --OPTION_NAME in case of a boolean option or
--OPTION_NAME=OPTION_VALUE. The parameterss will be translated replacing hyphens with underscores
(but ignoring the prefix **--**).

      $ soda --my-option=test

      # script
      if [[ -n "$my_option" ]]; then
        # some code
      fi

To register a parameter in the program usage, use the *parameter* function (for more details, see
the documentation bellow). The registered parameters will also be available for bash completion.

## Events

You can subscribe and publish events in SODA using **when** and **broadcast** builtin functions.

    when finish say_goodbye
    say_goodbye() {
      echo "Goodbye, $1!"
    }

    broadcast finish "$USER"

The builtin events are:

* **start** - before the task execution
* **finish** - after the task execution
* **fail** *(exit code)* - when a command fails to execute

## Bash Completion

SODA supports bash completion by importing all namespaces and searching for defined parameters
and tasks. To enable bash completion, use the file **soda-bash-completion** (you can source it,
copy to */etc/bash_completion.d/*, ...). The default bash completion proposes tasks and parameters.

    $ soda he[TAB]
    $ soda help

To customize the options for a given task, use a function named ${TASK}_bash_completion:

    my_task_bash_completion() {
      echo "foo"
      echo "bar"
    }

    $ soda my-task f[TAB]
    $ soda my-task foo

If a parameter is passed after the task declaration in command line, the suggestions will be only
the parameters for the task namespace.

    # namespace my-namespace

    option "option" "My custom option"
    task "my-task" "My task"
    my_task() {
      :
    }

    $ soda my-namespace.my-task --[TAB]
    $ soda my-namespace.my-task --option

It is important to remember that logs and event broadcasting are disabled while SODA is in bash
completion mode.

## Configuration

You can configure SODA through a **~/.soda/soda.conf** file. The supported properties are:

* **LOG_FILE** - The log file  (defaults to *$SODA_DIR/log/soda.log*)
* **SODA_FUNCTION_NAME_LENGTH** - The max length to format the function name in the help usage
* **SODA_FUNCTION_ARGS_LENGTH** - The max length to format the function parameters in the help usage
* **SODA_PARAMETER_LENGTH** - The max length to format the parameter name in the help usage
* **SODA_PARAMETER_NAMESPACE_LENGTH** - The max length to format the parameter namespace in the help
usage
* **SODA_NAMESPACE_DELIMITER** - The namespace delimiter (defaults to **.**). Changing this also
affects the bash completion
* **SODA_TASK_BASH_COMPLETION_SUFFIX** - The suffix to build the function for custom bash completion
(defaults to *_bash_completion*)

## Logging

To log something, just call the **log** function passing the category and message (optionally, you
can pass a color for showing in console). There are some aliases for calling log with a predefined
category:

* **log_debug** - uses the DEBUG category
* **log_info** - uses the INFO category
* **log_notice** - uses the NOTICE category
* **log_warn** - uses the WARN category
* **log_error** - uses the ERROR category
* **log_fatal** - uses the FATAL category

### Custom logging

If you want to use another log system (a *syslog* or another) just define a **log** function.

    log() {
      local category="$1"
      local message="$2"
      logger -s -t "$category" "$message"
    }

## Builtin functions

The builtin functions are present in *scripts/soda* dir and the *scripts/core.sh*, the
most significant are listed below:

### task (function_name, description)

Register the given function as a task and enables invoking it. You may pass the function
args in *$function_name*.

### parameter (parameter_name, [default_value], description)

Register the given parameter and returns indicating if the parameter was given. You may
pass the parameter args in *$parameter_name*. The parameter value is accessible through
the variable $parameter_name (with hyphens replaced by underscores). To expose a value
based parameter use the syntax PARAMETER=VALUE. To expose a parameter with optional value
use the syntax PARAMETER[=VALUE].

    parameter "help" "Prints this help message" && {
      usage
    }

    parameter "backup[=EXTENSION]" "bak" "Indicates the extension for file backup" && {
      additional_parameters="$additional_parameters --extension=$backup"
    }

### import (namespace)

Loads all scripts in the scripts/$namespace directory relative to ${SODA_USER_DIR} or ${SODA_DIR}.

If a namespace was already imported, then it will not be imported again.

### invoke (description, function_name)

Invokes the given function based on user choice.

If there is a variable named exactly like the function, its value will be used instead of
asking user.

### ask (question)

Asks user about something and indicates if the answer is **yes** or **no**.

    ask "Push commits?" && {
      git push
    }

### check (description)

Checks if the previous command returned successfully and logs the result using the given
description.

### execute (description, command, [*args])

Executes a command and checks if it was sucessfull. The output will be redirected to
$LAST_COMMAND_LOG_FILE.

    execute "Pushing commits" git push

### input (description, variable, [default_value])

Asks the user to input a value. The value will be stored in the indicated
variable. If the variable name is in upper case and is already set, the prompt
will not be shown.

    input "Server address" "SERVER" "localhost"
    input "User name" "USER_NAME" "$(whoami)"

    scp file $USER_NAME@$SERVER:/tmp/.

### choose (description, variable, *options)

Asks user to choose a value from a list of options and stores the 0-based index
of the selected value and the label in the $variable_label var. If the variable name
is in upper case and is already set, the prompt will not be shown.

    choose "Server Type" "SERVER_TYPE" "Production" "Development"

    echo "$SERVER_TYPE: $SERVER_TYPE_label"

## Examples

Check out the **examples** dir for a simple set of tasks that may help you.
