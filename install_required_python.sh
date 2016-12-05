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
#     ./install_required_python.sh
#
# To change the version of Python that will be downloaded, just modify the
# Python variables for major, minor, and revision for the version that is
# needed.
#
# This script also creates a virtual environment, because anytime I need
# a specific version of Python, its always because its going to for a 
# preexisting project.

PYTHON_MAJOR="3"
PYTHON_MINOR="3"
PYTHON_REVISION="5"

# This is only needed to be set for release candidates. For all others
# this should be an empty string.
PYTHON_RC_NUMBER=""

VERSION="${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_REVISION}"

PYTHON_NAME="Python-${VERSION}${PYTHON_RC_NUMBER}"

PROJECT_DIR=`pwd`
DIRECTORY_FOR_VENV="${PROJECT_DIR}/venv"
WORKING_DIRECTORY="${PROJECT_DIR}/WORK_TEMP"
PYTHON_BINARY="${DIRECTORY_FOR_VENV}/bin/python"


python_install_location="${HOME}/PythonVersions/${VERSION}${PYTHON_RC_NUMBER}"

echo "Installing Python Version: $PYTHON_NAME"


download_python()
{

	curl --fail -O "https://www.python.org/ftp/python/$VERSION/$PYTHON_NAME.tgz"

	# Handle the situation where we get a 404 not found error because the 
	# version of python that was asked for does not exist
	if [ $? -ne 0 ]
		then
			echo "This is not a version of Python"
			exit
	fi

}


compile_python()
{
	# install dependencies
	sudo apt-get install build-essential
	sudo apt-get install libssl-dev openssl libsqlite3-dev

	# compile python
	tar -xzvf "$PYTHON_NAME.tgz"
	cd $PYTHON_NAME
	./configure --prefix="${python_install_location}"

	make
	sudo make install
	cd ../
 }


# This is only needed for versions of Python less than 3.4 and 2.7.9,
# but adding it covers the use case for other versions of python 3
# and will always update pip. 
pip_manual_install() 
{

	curl -O https://bootstrap.pypa.io/get-pip.py
	
	sudo ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} ./get-pip.py
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

			echo "Using virtualenv because venv is not builtin to ${PYTHON_NAME}"
			sudo ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip install ${venv}
	fi


	# make virtualenv
	${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m ${venv} ${venv_args} "${DIRECTORY_FOR_VENV}"


	# Print Virtual Environemnt info if there is a folder that it could be in
	if [ -d "${DIRECTORY_FOR_VENV}" ]
		then
			source venv/bin/activate
			ls
			
			echo "Version of Virtual Environment:"
			python --version
	else
		echo "Virtual Environment was not created"
	fi
}


main()
{
	mkdir -p "${WORKING_DIRECTORY}"
	cd "${WORKING_DIRECTORY}"

	# Only download and compile if its not already installed
	if [ ! -d ${python_install_location} ]
		then

			download_python

			compile_python

	else
		echo "${PYTHON_NAME} already installed... skipping installation"
	fi

	pip_manual_install

	cd "${PROJECT_DIR}"
	create_virtual_environment

}


main
