#!/bin/bash
#
# Merge TAU traces in current directory
# and convert merge trace to slog2 format.
#
# Copyright (C) 2016 Bryzgalov Peter @ RIKEN AICS

echo "Calling tau_merge..."
tau_treemerge.pl
echo "Converting merge trace to SLOG2 format..."
traceconv.sh tau
echo "Done."
