

set -e
set -x

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
