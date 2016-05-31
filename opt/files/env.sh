export PKG="$HOME/TAU"
export TAUDIR="$PKG/tau-2.25"
export TAU_ARCH="sparc64fx"
export TAU="$TAUDIR/$TAU_ARCH/lib"
export PATH="$PATH:$TAUDIR/$TAU_ARCH/bin:$TAUDIR/x86_64/bin"
# Score-P
export PATH="$PATH:$PKG/scorep/1.4.2/bin"
export TAU_MAKEFILE="$TAU/Makefile.tau-mpi-pdt-fujitsu"
