#!/bin/sh

# Initialize default values
BREAK_CONDITION="-t 50000"
OUTFILE="/opt/sp2bench/output/sp2b.ttl"

# Parse command-line arguments
while getopts "t:s:o:" opt; do
  case $opt in
    t)
      BREAK_CONDITION="-t $OPTARG"
      ;;
    s)
      BREAK_CONDITION="-s $OPTARG"
      ;;
    o)
      OUTFILE="/opt/sp2bench/output/$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if the sp2b_gen binary exists and is executable
if [ ! -x "./sp2b_gen" ]; then
  echo "Error: sp2b_gen binary not found or not executable."
  exit 1
fi

# Run the sp2b_gen binary with the specified break condition and output file
./sp2b_gen $BREAK_CONDITION $OUTFILE
