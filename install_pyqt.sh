
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




install_qt()
{
	echo "Make sure QT is installed"
}


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

	#install_qt

	install_sip

	install_pyqt
}

main
