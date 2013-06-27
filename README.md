# soda

SODA is a simple platform to help writing and executing shell scripts.

# How It Works

SODA works by loading any scripts in a specific directory and calling a
function passed by the command line. Every function can be exposed to
the program help using the builtin **public** function.

# How To Use

Create a ~/.soda directory with the following structure:

* _scripts_ - directory to put the scripts organized by namespaces
* _resources_ - directory to put resources (available through the 
**$SODA_RESOURCES** variable)

Inside *scripts*, any function in any script present in *scripts/common* will be
loaded and may be called through `soda`:

    # script in scripts/common/oracle-grid.sh
    
    public "grid_pre_install" "Prepares the environment to install Oracle GRID"
    
    function grid_pre_install {
      message "Installing RPMs"

      yum install -y $SODA_RESOURCES/rpms/grid/*.rpm $SODA_RESOURCES/rpms/grid/ol$1/*.rpm

      execute "Creating group asmadmin" groupadd -g 504 asmadmin
      execute "Creating group asmdba" groupadd -g 506 asmdba
      execute "Creating group asmoper" groupadd -g 507 asmoper
      
      execute "Creating user grid" useradd -u 501 -g oinstall -G asmadmin,asmdba,asmoper grid
      execute "Adding groups for user oracle" usermod -u 502 -G dba,asmdba oracle
    }

    $ soda grid-pre-install 5

This will call the *grid_pre_install* function passing *5* as the arguments. By convention, you
may call a function with underscores replacing them by hyphens. The *message* and *execute* functions
ships with SODA and will be explained later.

# Namespaces

The namespaces are single directories in _scripts_. By default, the *common* namespace
is always included. You can include other namespaces using the **import** function.

Namespaces are useful if you have a set of scripts that you should use
only on specific cases.

    # script inside ~/.soda/scripts/common
    
    public install "Installs the given product"
    
    function install {
      import "install/$1" # loads the namespace that contains installation scripts
      shift
      begin_install $@
      finish_install $@
    }
    
    # script inside ~/.soda/scripts/install/something.sh
    
    function begin_install {
      # code here
    }
    
    function finish_install {
      # code here
    }

# Configuration

# Builtin functions

The builtin functions are present in *scripts/soda* dir and the *scripts/core.sh*, the
most significant are listed below:

## public (function_name, description, [*args])

Adds the given function to the help message. This is only a documentation feature and
does not affect anything.

## import (namespace)

Loads all scripts in the *scripts/namespace* directory. The scripts may be in
$SODA_USER_DIR or $SODA_DIR. If the scripts are present in the first directory,
the second one will not be used.

If a namespace was already imported, then it will not be imported again.

## invoke (description, function_name)

Invokes the given function based on user choice. Additionally, a pre_$function_name and
post_$function_name will be invoked if exists. The value of the user choice will be stored
in the $OPTIONS_FILE file.

If there is a variable named exactly like the function, its value will be used instead of
asking user.

## ask (question)

Asks user about something and indicates if the answer is **yes** or **no**.

    ask "Remove temporary directoryes?" && {
      rm -rf /tmp/my-temp-dir
    }
    
## check (description)

Checks if the previous command returned successfully and logs the result using the given
description.

## execute (description, command, [*args])

Executes a command and checks if it was sucessfull. The output will be redirected to
$LAST_COMMAND_LOG_FILE.

    execute "Installing GCC" yum install -y gcc

## require_reboot

Indicates that a reboot is required. SODA will ask to reboot before terminate.

## message (message)

Displays an information message and logs it in the $LOG_FILE

## debug (message)

Displays a debug message and logs it in the $LOG_FILE

## warn (message)

Displays a warn message and logs it in the $LOG_FILE

## error (message)

Displays en error message and logs it in the $LOG_FILE

## success (message)

Displays a successfull operation message and logs it in the $LOG_FILE

## fail (message)

Displays a failed operation message and logs it in the $LOG_FILE

## input (description, variable, [default_value])

Asks the user to input a value. The value will be stored in the indicated
variable. If there is a variable named as $variable, the input asking will
be skipped.

    input "Server address" "SERVER" "localhost"
    input "User name" "USER_NAME" "$(whoami)"
    
    scp file $USER_NAME@$SERVER:/tmp/.
    
# choose (description, variable, *options)
        
Asks user to choose a value from a list of options and stores the 0-based index
of the selected value. If there is a variable named as $2, the choice will be skipped.
