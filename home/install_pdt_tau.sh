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
# (C) 2015 RIKEN AICS
# Created by Peter Bryzgalov

BASEDIR=$HOME/TAU
PDT_DIR=$BASEDIR/pdt-3.21
TAU_DIR=$BASEDIR/tau-2.25
SCOREP_VER="1.4.2"
SCOREPDIR=$BASEDIR/scorep/$SCOREP_VER

binutils="binutils-2.23.2.tar.gz"

function install_tau {
    echo "***************"
    echo "* Install PDT *"
    echo "***************"

    if [[ ! -d "$BASEDIR" ]]; then 
        mkdir -p "$BASEDIR"
    fi
    cd $BASEDIR
    if [[ ! -a pdt_lite.tgz ]]; then
        curl -OL http://tau.uoregon.edu/pdt_lite.tgz
    fi
    tar -xzvf pdt_lite.tgz

    if [[ ! -d $PDT_DIR ]]; then
        mkdir -p $PDT_DIR
    fi
    cd pdtoolkit-3.21
    ./configure -prefix=$PDT_DIR
    gmake
    gmake install

    export PATH=$PATH:$PDT_DIR/x86_64/bin
    cd ..

    echo "***************"
    echo "* Install TAU *"
    echo "***************"

    if [[ ! -a tau.tgz ]]; then
        curl -OL http://tau.uoregon.edu/tau.tgz
    fi
    # Copy binutils if already downloaded
    if [[ -a "$binutils" ]]; then
        echo "Use downloaded binutils"
        mkdir -p "$TAU_DIR/external_dependencies"
        cp "$binutils" "$TAU_DIR/external_dependencies/$binutils"
    fi
    tar -xzvf tau.tgz -C $BASEDIR
    cd $TAU_DIR

    ./configure -pdt=$PDT_DIR -pdt_c++=g++ -arch=sparc64fx -prefix=$TAU_DIR  -c++=mpiFCCpx -cc=mpifccpx -fortran=mpifrtpx -mpi -bfd=download -iowrapper
    make install
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
    ./configure -pdt=$PDT_DIR -pdt_c++=g++ -arch=sparc64fx -c++=mpiFCCpx -cc=mpifccpx -fortran=mpifrtpx -mpi -bfd=download -iowrapper -scorep=$SCOREPDIR
    echo "no"
    export TAU_SCOREP=1
    cd $TAU_DIR
    make install
}

if [[ -n "$1" ]]; then
    if [[ "$1" == "-clean" ]]; then
        echo "*********************"
        echo "* Clean directories *"
        echo "*********************"
        rm -rf pdtoolkit-3.21
        rm -rf tau-2.25
        rm -rf $TAU_DIR
        rm -rf $PDT_DIR
        rm -rf $SCOREPDIR
        exit 0
    elif [[ "$1" == "x86" ]]; then
        cd $TAU_DIR
        ./configure -arch=x86_64
        make install
        exit 0
    elif [[ "$1" == "sparc64fx" ]]; then 
        cd $TAU_DIR
        ./configure -arch=sparc64fx
        make install
        exit 0
    elif [[ "$1" == "-install" ]]; then
        install_tau
        exit 0  
    elif [[ "$1" == "scorep" ]]; then
        install_tau_scorep
        exit 0  
    fi
fi

echo "Options:"
echo "  -install      install PDT and TAU for sparc64fx architecture"
echo "  -clean        clean installation directories"
echo "  x86           configure TAU for x86_64 architecture"
echo "  sparc64fx     configure TAU for sparc64fx architecture"
echo "  scorep        instll ScoreP and configure TAU to use Score-P"

