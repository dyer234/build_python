# A script to compile python on ubuntu.
# It downloads the source directly from the python website and saves it to
# a working directory. The working directory can be deleted after the script
# was successful.
#
# By default, Python is installed to: /usr/local/bin, /usr/local/include, etc
# This is overridden by adding the --prefix to .configure. So that the 
# version is stored in a directory called PythonVersions inside the user Home
# directory. To change this location back to default, just modify this 
# --prefix variable to /usr/local.
#
# Usage:
#     ./install_python.sh
#
#     .install_python.sh --major 3 --minor 5 --revision 2
#
#     ./install_python.sh --major 3 --minor 6 --revision 0 --rc rc1	
#
# To change the version of Python that will be downloaded, just modify the
# Python variables for major, minor, and revision for the version that is
# needed.
#
# This script also creates a virtual environment, because anytime I need
# a specific version of Python, its always because its going to for a 
# preexisting project.
    
PYTHON_MAJOR="3"
PYTHON_MINOR="5"
PYTHON_REVISION="2"

# This is only needed to be set for release candidates. For all others
# this should be an empty string.
PYTHON_RC_NUMBER=""

# Handle any command line arguments
while [[ $# -gt 1 ]]
do
	key="$1"
	case $key in
		--major)
		PYTHON_MAJOR="$2"
		shift # past argument
		;;
		--minor)
		PYTHON_MINOR="$2"
		shift # past argument
		;;
		--revision)
		PYTHON_REVISION="$2"
		shift # past argument
		;;	
		--rc)
		PYTHON_RC_NUMBER="$2"
		shift # past argument
		;;	     
		*)
		# unknown option
		;;
	esac
	shift # past argument or value
done


VERSION="${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_REVISION}"

PYTHON_NAME="Python-${VERSION}${PYTHON_RC_NUMBER}"

PROJECT_DIR=`pwd`
DIRECTORY_FOR_VENV="${PROJECT_DIR}/venv"
WORKING_DIRECTORY="${PROJECT_DIR}/WORK_TEMP"
PYTHON_BINARY="${DIRECTORY_FOR_VENV}/bin/python"


python_install_location="/opt/PythonVersions/${VERSION}${PYTHON_RC_NUMBER}"

HIGHLIGHT='\033[0;36m'
NO_HIGHLIGHT='\033[0m' # No Color

echo -e $HIGHLIGHT"Installing Python Version: $PYTHON_NAME$NO_HIGHLIGHT"


install_dependencies()
{
    # install dependencies
    sudo apt-get install -y curl build-essential libssl-dev openssl \
                            libsqlite3-dev tcl-dev
}


download_python()
{
    curl --fail -O "https://www.python.org/ftp/python/$VERSION/$PYTHON_NAME.tgz"

    # Handle the situation where we get a 404 not found error because the 
    # version of python that was asked for does not exist
    if [ $? -ne 0 ]
        then
            echo -e $HIGHLIGHT"This is not a version of Python"$NO_HIGHLIGHT
            exit
    fi
}


compile_python()
{
    # compile python
    tar -xzvf "$PYTHON_NAME.tgz"
    cd $PYTHON_NAME
    ./configure --prefix="${python_install_location}"

    make
    sudo make install
    cd ../
 }


# This checks if there is a file called pip or pip3 inside the new python
# installation directory, if it is missing then pip is manually downloaded
# and installed.
pip_manual_install() 
{
    if [ -f "${python_install_location}/bin/pip" -o -f "${python_install_location}/bin/pip3" ]
        then
            sudo -H ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip install --upgrade pip			
    else
            curl -O https://bootstrap.pypa.io/get-pip.py
            sudo -H ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} ./get-pip.py
    fi
}


create_virtual_environment()
{
    sudo rm -rf ~/.cache/pip

    local venv="venv"
    local venv_args="--copies"

    # The venv module is only availabe in python3.3 and above, for anything 
    # else we need to use the virtualenv module. This always requires pip 
    # installing virtualenv into the custom python interpreter.
    if [ $PYTHON_MAJOR = "2" -o $PYTHON_MAJOR -eq "3" -a $PYTHON_MINOR -lt "4" ]
        then
            venv="virtualenv"
            venv_args="--always-copy"

            echo -e $HIGHLIGHT"Using virtualenv because venv is not builtin to ${PYTHON_NAME}"$NO_HIGHLIGHT
            sudo -H ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip install ${venv}
    fi


    # make virtualenv
    ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m ${venv} ${venv_args} "${DIRECTORY_FOR_VENV}"


    # Print Virtual Environemnt info if there is a folder that it could be in
    if [ -d "${DIRECTORY_FOR_VENV}" ]
        then
            source venv/bin/activate
            ls

            echo -e $HIGHLIGHT"Version of Virtual Environment:"
            python --version
            echo -e $NO_HIGHLIGHT
    else
        echo -e $HIGHLIGHT"Virtual Environment was not created"$NO_HIGHLIGHT
    fi
}


main()
{
    mkdir -p "${WORKING_DIRECTORY}"
    cd "${WORKING_DIRECTORY}"

    # Only download and compile if its not already installed
    if [ ! -d ${python_install_location} ]
        then
            install_dependencies

            download_python

            compile_python

    else
        echo -e $HIGHLIGHT"${PYTHON_NAME} already installed... skipping installation"$NO_HIGHLIGHT
    fi

    pip_manual_install

    cd "${PROJECT_DIR}"
    create_virtual_environment
}


main
