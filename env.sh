export PKG=/opt/aics/TAU
export TAUDIR=$PKG/tau-2.24.1
export TAU_ARCH=sparc64fx
export TAU=$TAUDIR/$TAU_ARCH/lib
export TAUROOTDIR=$TAUDIR
export PATH="$TAUDIR/$TAU_ARCH/bin:$TAUDIR/x86_64/bin:$PATH"
export TAU_MAKEFILE="$TAU/Makefile.tau-mpi-pdt-fujitsu"
