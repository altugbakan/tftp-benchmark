#!/bin/bash

# Define the TFTP server IP address and the file transfer directory
SERVER_IP="127.0.0.1"

# Define the file sizes in kilobytes
FILE_SIZES=(200 400 600 800 1000)

# Define the block sizes in bytes
BLOCK_SIZES=(512 1024 1428 2048 4096 8192)

# Create a CSV file if it does not exist to store the transfer times
CSV_FILE="test_results.csv"

# Get the test name from user
if [ -z "$1" ]
  then
    echo "No test name supplied"
    exit 1
fi

# Set the test name
NAME=$1

if [ ! -f "$CSV_FILE" ]; then
  echo "name,file_size_kb,block_size_bytes,transfer_type,transfer_time_seconds" >> $CSV_FILE
fi

# Loop through the file sizes and generate a random file of each size
for SIZE in "${FILE_SIZES[@]}"
do

  # Loop through the block sizes and time the transfers for each block size
  for BLOCK_SIZE in "${BLOCK_SIZES[@]}"
  do
    # Generate a random file name
    FILENAME=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10 ; echo '')
    
    # Generate a random file of the specified size
    dd if=/dev/urandom of=$FILENAME bs=1024 count=$SIZE status=none
    
    # Send the file to the TFTP server and time the transfer
    echo "Sending $FILENAME to TFTP server..."
    START=$(date +%s.%N)
    atftp --option "blksize $BLOCK_SIZE" --put --local-file $FILENAME $SERVER_IP 2> /dev/null
    END=$(date +%s.%N)
    TRANSFER_TIME=$(echo "$END - $START" | bc)
    echo "Send time: $TRANSFER_TIME seconds for $SIZE kB"
    echo "$NAME,$SIZE,$BLOCK_SIZE,put,$TRANSFER_TIME" >> $CSV_FILE
    
    # Get the file back from the TFTP server and time the transfer
    echo "Getting $FILENAME back from TFTP server..."
    START=$(date +%s.%N)
    atftp --option "blksize $BLOCK_SIZE" --get --remote-file $FILENAME $SERVER_IP 2> /dev/null
    END=$(date +%s.%N)
    TRANSFER_TIME=$(echo "$END - $START" | bc)
    echo "Receive time: $TRANSFER_TIME seconds for $SIZE kB"
    echo "$NAME,$SIZE,$BLOCK_SIZE,get,$TRANSFER_TIME" >> $CSV_FILE
    
    # Remove the local copy of the file
    rm $FILENAME
  done

done
