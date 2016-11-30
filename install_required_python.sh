# A simple script to compile python on ubuntu.
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
PYTHON_MINOR="5"
PYTHON_REVISION="2"

VERSION="$PYTHON_MAJOR.$PYTHON_MINOR.$PYTHON_REVISION"

PYTHON_NAME="Python-$VERSION"

PROJECT_DIR=`pwd`
DIRECTORY_FOR_VENV="${PROJECT_DIR}/venv"
WORKING_DIRECTORY="${PROJECT_DIR}/WORK_TEMP"
PYTHON_BINARY="${DIRECTORY_FOR_VENV}/bin/python"


python_install_location="${HOME}/PythonVersions"

echo "Installing Python Version:"
echo $PYTHON_NAME
echo ""


download_python()
{
	curl -O "https://www.python.org/ftp/python/$VERSION/$PYTHON_NAME.tgz"
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
# and will always update pip. Also using virtualenv may be considered
# less than ideal because venv is built into 3.4 and greater, but I 
# prefer the full the copy of the python interpreter instead of the 
# the symlinks and this is the most portable across versions
pip_manual_install() 
{

	curl -O https://bootstrap.pypa.io/get-pip.py
	
	sudo ${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} ./get-pip.py

}


create_virtual_environment()
{
	sudo rm -rf ~/.cache/pip

	# make virtualenv
	${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m venv --copies "${DIRECTORY_FOR_VENV}"

	source venv/bin/activate
	ls
	python --version
}


# this was only installed to be able to create the virtual environment.
# Now that the Virtual environment is set up, the custom python 
# interpreter it was created from can be deleted because we used
# the virtualenv option to --always-copy
remove_custom_python_version() {

	sudo rm -rf ${python_install_location} 
}


main()
{
	mkdir -p "${WORKING_DIRECTORY}"
	cd "${WORKING_DIRECTORY}"

	download_python

	compile_python

	pip_manual_install

	cd "${PROJECT_DIR}"
	create_virtual_environment

	#remove_custom_python_version
}


main
