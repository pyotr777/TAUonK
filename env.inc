PKG=/opt/aics/TAU
TAUDIR=$(PKG)/tau-2.24.1
TAU_ARCH=sparc64fx
TAU=$(TAUDIR)/$(TAU_ARCH)/lib
TAUROOTDIR=$(TAUDIR)
CC=$(TAUDIR)/$(TAU_ARCH)/bin/tau_cc.sh
CXX=$(TAUDIR)/$(TAU_ARCH)/bin/tau_cxx.sh
F90=$(TAUDIR)/$(TAU_ARCH)/bin/tau_f90.sh
