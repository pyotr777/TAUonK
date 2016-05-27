#!/bin/bash -e 
# Installs PDT and TAU into $HOME directory.
#
# For K/FX10 architecture run:
# ./install_pdt_tau.sh -install
# On login nodes create files for x86_64 architecture:
# ./install_pdt_tau.sh x86
#
# Use -clean flag for removing (old) installation directores and files before install 
#
# (C) 2015-2016 RIKEN AICS
# Created by Peter Bryzgalov

echo "TAU on K installation script v1.0"

CURDIR="$(pwd)"
TARFILES_DIR="files"
EDITED_DIR="edited"
BASEDIR="$HOME/TAU"
PDT_VER="3.22"
TAU_VER="2.25.1"
PDT_DIR="$BASEDIR/pdt-$PDT_VER"
TAU_DIR="$BASEDIR/tau-$TAU_VER"
SCOREP_VER="1.4.2"
SCOREPDIR="$BASEDIR/scorep/$SCOREP_VER"
OPARI="/opt/aics/tw20/scorep/REL-1.4.2"
PDT_DISTR_TAR="pdtoolkit-$PDT_VER.tar.gz"
TAU_DISTR_TAR="tau-$TAU_VER.tar.gz"
BINUTIL_DISTR_TAR="binutils-2.23.2.tar.gz"

CONFIGURE_OPTIONS_sparc="-pdt=$PDT_DIR -pdt_c++=g++ -arch=sparc64fx -prefix=$TAU_DIR  -c++=mpiFCCpx -cc=mpifccpx -fortran=mpifrtpx -mpi -bfd=download -iowrapper -TRACE"
CONFIGURE_OPTIONS_x8664="-pdt=$PDT_DIR -pdt_c++=g++ -arch=x86_64 -prefix=$TAU_DIR -bfd=download -iowrapper -TRACE"

function install_pdt {
    echo "********************"
    echo "* Install PDT $PDT_VER "
    echo "********************"

    if [[ ! -d "$BASEDIR" ]]; then 
        mkdir -p "$BASEDIR"
    fi
    cd $BASEDIR
    # Use downloaded files if exist
    if [[ -f "$CURDIR/$TARFILES_DIR/$PDT_DISTR_TAR" ]]; then
        echo "Using downloaded file $CURDIR/$TARFILES_DIR/$PDT_DISTR_TAR"
        cp $CURDIR/$TARFILES_DIR/$PDT_DISTR_TAR $BASEDIR/
    fi
    if [[ ! -f "$BASEDIR/$PDT_DISTR_TAR" ]]; then
        echo "Downloading PDT $PDT_VER to $(pwd)"
        wget https://www.cs.uoregon.edu/research/tau/pdt_releases/$PDT_DISTR_TAR
    fi
    tar -xzf $PDT_DISTR_TAR
    if [[ ! -d $PDT_DIR ]]; then
        mkdir -p $PDT_DIR
    fi
    cd pdtoolkit-$PDT_VER
    pwd
    ./configure -prefix=$PDT_DIR
    gmake
    gmake install

    export PATH=$PATH:$PDT_DIR/x86_64/bin
    cd $CURDIR
}


function install_tau {
    echo "**********************"
    echo "* Install TAU $TAU_VER "
    echo "**********************"
    cd $BASEDIR
    # Use downloaded files if exist
    if [[ -f "$CURDIR/$TARFILES_DIR/$BINUTIL_DISTR_TAR" ]]; then
        echo "Using downloaded file $CURDIR/$TARFILES_DIR/$BINUTIL_DISTR_TAR"
        cp $CURDIR/$TARFILES_DIR/$BINUTIL_DISTR_TAR $BASEDIR/
    fi
    if [[ -f "$CURDIR/$TARFILES_DIR/$TAU_DISTR_TAR" ]]; then
        echo "Using downloaded file $CURDIR/$TARFILES_DIR/$TAU_DISTR_TAR"
        cp $CURDIR/$TARFILES_DIR/$TAU_DISTR_TAR $BASEDIR/
    fi
    if [[ ! -f "$TAU_DISTR_TAR" ]]; then
        echo "Downloading $TAU_DISTR_TAR"
        wget "https://www.cs.uoregon.edu/research/tau/tau_releases/$TAU_DISTR_TAR"
    fi
    # Copy binutils if already downloaded
    if [[ -f "$BINUTIL_DISTR_TAR" ]]; then
        echo "Using downloaded binutils $BINUTIL_DISTR_TAR"
        mkdir -p "$TAU_DIR/external_dependencies"
        cp "$BINUTIL_DISTR_TAR" "$TAU_DIR/external_dependencies/$BINUTIL_DISTR_TAR"
    fi
    if [[ ! -d "$TAU_DIR" || ! -f "$TAU_DIR/configure" ]]; then
        echo "Extracting TAU distribution files into $TAU_DIR"
        tar -xzf "$TAU_DISTR_TAR" -C $BASEDIR
    fi
    # Copy edited files
    cp -R $CURDIR/$TARFILES_DIR/$EDITED_DIR/* $TAU_DIR/
    cd $TAU_DIR
    pwd
    echo "Configuring TAU with options $CONFIGURE_OPTIONS_sparc"
    ./configure $CONFIGURE_OPTIONS_sparc
    make install
    cd $CURDIR
}


function install_tau_scorep {
    echo "*******************"
    echo "* Install Score-P *"
    echo "*******************"
    
    if [[ ! -f "$TAU_DIR/configure" ]]; then
        echo "Install TAU with $0 -install"
        return
    fi

    cd $BASEDIR    
    TAR="scorep-$SCOREP_VER.tar.gz"
    WEB="http://www.vi-hps.org/upload/packages/scorep/$TAR"
    
    ## Check if Score-P already installed
    if [[ -x "$SCOREPDIR/bin/scorep" ]]; then
        echo "Score-P already installed in $SCOREPDIR"
    else
        if [ ! -f "$TAR" ]
            then
            wget $WEB
        fi
        mkdir -p $SCOREPDIR
        tar -xzf $TAR
        cd scorep-$SCOREP_VER
        ./configure --prefix=$SCOREPDIR --enable-static --disable-shared
        make
        make install
    fi

    echo "***************"
    echo "* Install TAU *"
    echo "***************"
    
    cd $TAU_DIR
    ./configure $CONFIGURE_OPTIONS_sparc -scorep=$SCOREPDIR
    echo "no"
    export TAU_SCOREP=1
    cd $TAU_DIR
    make install
    cd $CURDIR
}

function install_traceconv {
    cd $CURDIR
    files=(traceconvert.sh traceconv.sh)
    for filename in ${files[@]}; do
        if [ ! -f "$TAU_DIR/x86_64/bin/$filename" ]; then
            echo "Copying $filename to $TAU_DIR/x86_64/bin"
            if [ ! -f "./$filename" ]; then
                echo "File $filename not found!"
            else
                cp ./$filename $TAU_DIR/x86_64/bin/
            fi
        fi
    done
}

if [[ -n "$1" ]]; then
    if [[ "$1" == "clean" ]]; then
        echo "*********************"
        echo "* Clean directories *"
        echo "*********************"
        rm -rf $TAU_DIR
        rm -rf $PDT_DIR
        rm -rf $BASEDIR/pdtoolkit-$PDT_VER
        rm -rf $SCOREPDIR
        exit 0
    elif [[ "$1" == "x86" ]]; then
        cd $TAU_DIR
        ./configure $CONFIGURE_OPTIONS_x8664
        make install
        install_traceconv
        cd -
        exit 0
    elif [[ "$1" == "sparc64fx" ]]; then 
        cd $TAU_DIR
        ./configure -arch=sparc64fx
        make install
        cd -
        exit 0
    elif [[ "$1" == "install" ]]; then
        install_pdt
        install_tau
        exit 0  
    elif [[ "$1" == "tau" ]]; then
        export PATH=$PATH:$PDT_DIR/x86_64/bin
        install_tau
        exit 0
    elif [[ "$1" == "scorep" ]]; then
        install_tau_scorep
        exit 0
    elif [[ "$1" == "openmp" ]]; then
        cd $TAU_DIR
        ./configure -openmp -opari $CONFIGURE_OPTIONS_sparc
        #./configure -openmp -opari=$OPARI -bfd=download -pdt=$PDT_DIR -pdt_c++=g++ -prefix=$TAU_DIR -arch=sparc64fx -c++=mpiFCCpx -cc=mpifccpx -fortran=mpifrtpx -mpi -DISABLESHARED 
        make install
        cd -
    fi
fi

echo "Options:"
echo "  install      install PDT and TAU for sparc64fx architecture"
echo "  tau          install TAU for sparc64fx architecture (do not install PDT)"
echo "  clean        clean installation directories"
echo "  x86           configure TAU for x86_64 architecture"
echo "  sparc64fx     configure TAU for sparc64fx architecture"
echo "  scorep        install ScoreP and configure TAU to use Score-P"
echo "  openmp        configure TAU for using openMP and opari"

