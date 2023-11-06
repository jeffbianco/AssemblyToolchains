#!/bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

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

shift $((OPTIND-1)) # Shift past the parsed options
POSITIONAL_ARGS=("$@")

if [ "${#POSITIONAL_ARGS[@]}" -lt 1 ]; then
    usage
fi

INPUT_FILE="${POSITIONAL_ARGS[0]}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Specified file does not exist: $INPUT_FILE"
    exit 1
fi

# If OUTPUT_FILE is not specified, use the input file name without the extension
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${INPUT_FILE%.*}"
fi

if [ "$VERBOSE" = true ]; then
    echo "Arguments being set:"
    echo "	GDB = $GDB"
    echo "	RUN = $RUN"
    echo "	BREAK = $BREAK"
    echo "	QEMU = $QEMU"
    echo "Input File = $INPUT_FILE"
    echo "Output File = $OUTPUT_FILE"
    echo "Verbose = $VERBOSE"
    echo "64-bit mode = $BITS"
    echo ""
    echo "NASM started..."
fi

# Function to assemble and link code
assemble_and_link() {
    nasm_flags="-f elf"
    ld_flags="-m elf_i386"
    if [ "$BITS" = true ]; then
        nasm_flags="-f elf64"
        ld_flags="-m elf_x86_64"
    fi

    nasm $nasm_flags "$INPUT_FILE" -o "${OUTPUT_FILE}.o" && echo ""

    if [ "$VERBOSE" = true ]; then
        echo "NASM finished"
        echo "Linking ..."
    fi

    ld $ld_flags "${OUTPUT_FILE}.o" -o "$OUTPUT_FILE" && echo ""

    if [ "$VERBOSE" = true ]; then
        echo "Linking finished"
    fi
}

assemble_and_link

if [ "$QEMU" = true ]; then
    echo "Starting QEMU ..."
    echo ""
    qemu_command="qemu-i386"
    if [ "$BITS" = true ]; then
        qemu_command="qemu-x86_64"
    fi
    $qemu_command "$OUTPUT_FILE" && echo ""
    exit 0
fi

if [ "$GDB" = true ]; then
    gdb_params=()
    gdb_params+=(-ex "b $BREAK")

    if [ "$RUN" = true ]; then
        gdb_params+=(-ex "r")
    fi

    gdb "${gdb_params[@]}" "$OUTPUT_FILE"
fi
