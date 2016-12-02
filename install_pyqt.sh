#!/bin/bash
# This script will install pyqt into a virtual environment.
#
# Instructions:
# 1. Download the needed versions of
#        Sip
#        PyQt
#        Qt
#    Note about Qt: the opensource version of Qt can be downloaded here:
#        http://download.qt.io/archive/qt/
#    Note about Sip and PyQt: Thse can be downloaded here:
#        https://www.riverbankcomputing.com/software/pyqt/download   
# 2. Once Downloaded, create a folder in the home directory called:
#        Qt<Major>.<Minor>.<Revision>_Download_Source
# 3. Move the downloaded files to the new folder. 
# 4. Adjust the Python Version in the script so that PyQt is installed
#    properly into the Virtual Environment
# 5. Adjust QT versions so the file names match appropriately
# 6. Run the script
# 
# Usage Example:
#     ./install_pyqt.sh


PYTHON_MAJOR="3"
PYTHON_MINOR="5"
PYTHON_REVISION="2"

PROJECT_DIR=`pwd`
DIRECTORY_FOR_VENV="${PROJECT_DIR}/venv"
WORKING_DIRECTORY="${PROJECT_DIR}/WORK_TEMP"

PYTHON_BINARY="${DIRECTORY_FOR_VENV}/bin/python"

QT_MAJOR="5"
QT_MINOR="7"
QT_REVISION="0"
QT_VERSION="${QT_MAJOR}.${QT_MINOR}.${QT_REVISION}"

# This is where everything was downloaded to. It could be the normal Downloads directory
QT_STAGING_DIR="${HOME}/Qt5.7_Source"

# This is the default location for installation by Qt
QT_INSTALL_DIR="${HOME}/Qt${QT_VERSION}"


SIP_HEADER_LOCATION="${DIRECTORY_FOR_VENV}/include"
SIP_BINARY_LOCATION="${DIRECTORY_FOR_VENV}/bin"


install_sip()
{
	local sip_version="sip-4.18.1"

	cp $QT_STAGING_DIR/$sip_version.tar.gz $WORKING_DIRECTORY
	tar -xvzf "$QT_STAGING_DIR/$sip_version.tar.gz"

	cd "$sip_version"
	$PYTHON_BINARY configure.py -d "${DIRECTORY_FOR_VENV}/lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/site-packages/" --incdir "${SIP_HEADER_LOCATION}" -b "${SIP_BINARY_LOCATION}"
	
	make
	sudo make install
	sudo make clean
	cd ../
}


install_pyqt()
{
	local pyqt_version="PyQt5_gpl-${QT_MAJOR}.${QT_MINOR}"
	
	cp "$QT_STAGING_DIR/$pyqt_version.tar.gz" "$WORKING_DIRECTORY"
	tar -xvzf "$pyqt_version.tar.gz"
	
	cd "$pyqt_version"
	${PYTHON_BINARY} configure.py --confirm-license --qmake "${QT_INSTALL_DIR}/${QT_MAJOR}.${QT_MINOR}/gcc_64/bin/qmake" --sip "$SIP_BINARY_LOCATION/sip" --sip-incdir "${SIP_HEADER_LOCATION}" --verbose
	
	make
	sudo make install
	sudo make clean

	cd ../
}


main()
{
	mkdir -p "$WORKING_DIRECTORY"
	cd "$WORKING_DIRECTORY"

	install_sip

	install_pyqt
}

main
