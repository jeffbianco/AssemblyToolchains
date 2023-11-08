#!/bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022
# Suggested by Jefferson Bianco
# Default values for options
GDB=false
OUTPUT_FILE=""
VERBOSE=false
BITS=false
QEMU=false
BREAK="_start"
RUN=false

# Function to display usage information
usage() {
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
    echo ""
    echo "-v | --verbose                Show some information about steps performed."
    echo "-g | --gdb                    Run gdb command on executable."
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
    echo "-o | --output <filename>      Output filename."
    exit 1
}

# Option handling using getopts
while getopts "gvo:64qrb:" opt; do
    case $opt in
        g)
            GDB=true
            ;;
        v)
            VERBOSE=true
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        64)
            BITS=true
            ;;
        q)
            QEMU=true
            ;;
        r)
            RUN=true
            ;;
        b)
            BREAK="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done
