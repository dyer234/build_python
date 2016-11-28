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


create_virtual_environment()
{
	# make virtualenv
	${python_install_location}/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} -m venv "${DIRECTORY_FOR_VENV}"
	cd "${PROJECT_DIR}"
	source venv/bin/activate
	ls
	python --version
	pip install --upgrade pip
}


main()
{
	mkdir -p "${WORKING_DIRECTORY}"
	cd "${WORKING_DIRECTORY}"

	download_python

	compile_python

	create_virtual_environment
}


main
