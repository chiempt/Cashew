#!/bin/bash
# Wrapper script to remove -G flag from Flutter build process for Xcode 26 compatibility

# Remove -G flag from all compiler-related environment variables
export CC="${CC/-G / }"
export CXX="${CXX/-G / }"
export CFLAGS="${CFLAGS/-G / }"
export CXXFLAGS="${CXXFLAGS/-G / }"
export LDFLAGS="${LDFLAGS/-G / }"
export OTHER_CFLAGS="${OTHER_CFLAGS/-G / }"
export OTHER_CPLUSPLUSFLAGS="${OTHER_CPLUSPLUSFLAGS/-G / }"

# Execute original command
exec "$@"

