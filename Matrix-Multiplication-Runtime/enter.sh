#!/bin/bash

#Execute c and cuda codes
Cmatrix=" gcc MatrixCPU.c -o results/out "
Gmatrix=" nvcc matrix_global.cu -o results/out -Wno-deprecated-gpu-targets "
Smatrix=" nvcc matrix_shared.cu -o results/out -Wno-deprecated-gpu-targets "
Gblock=" nvcc global_block.cu -o results/out -Wno-deprecated-gpu-targets "
#Sblock=" nvcc shared_block.cu -o results/out -Wno-deprecated-gpu-targets "


total_time=0


if [ -e "results/r1.dat" ] 
	then
		rm -rf "results/r1.dat" 
		touch "results/r1.dat"
	else
		touch "results/r1.dat"
	fi

if [ -e "results/r2.dat" ] 
	then
		rm -rf "results/r2.dat" 
		touch "results/r2.dat"
	else
		touch "results/r2.dat"
	fi

if [ -e "results/r3.dat" ] 
	then
		rm -rf "results/r3.dat" 
		touch "results/r3.dat"
	else
		touch "results/r3.dat"
	fi

if [ -e "results/r4.dat" ] 
	then
		rm -rf "results/r4.dat" 
		touch "results/r4.dat"
	else
		touch "results/r4.dat"
	fi			

SIZES=( 32 64 128 256 512 3024 )


echo "<----------------------generating datafile- r1.dat ----------------------->"

for i in "${SIZES[@]}"
	do
		:

		TIMES=($(seq 0  30))
		total="0"
		echo "N=$i"
		for (( j=0; j<=30 ; j++ ))
		do 
			:
			eval $Cmatrix
			resp=$(./results/out $i)
			total=$(bc <<< "scale=30; $total+$resp")
			echo "# Round=$j T=$resp"
		done
		avg=$(bc <<< "scale=30; $total/${#TIMES[@]}")
		printf "($i, $avg)\n" >> "results/r1.dat"
		echo "Time avg. = $avg"
	done






echo "<----------------------generating datafile- r2.dat ----------------------->"

for i in "${SIZES[@]}"
	do
		:

		TIMES=($(seq 0  30))
		total="0"
		echo "N=$i"
		for (( j=0; j<=30 ; j++ ))
		do 
			:
			eval $Gmatrix
			resp=$(./results/out $i)
			total=$(bc <<< "scale=30; $total+$resp")
			echo "# Round=$j T=$resp"
		done
		avg=$(bc <<< "scale=30; $total/${#TIMES[@]}")
		printf "($i, $avg)\n" >> "results/r2.dat"
		echo "Time avg. = $avg"
	done






echo "<----------------------generating datafile- r3.dat ----------------------->"

for i in "${SIZES[@]}"
	do
		:

		TIMES=($(seq 0  30))
		total="0"
		echo "N=$i"
		for (( j=0; j<=30 ; j++ ))
		do 
			:
			eval $Smatrix
			resp=$(./results/out $i)
			total=$(bc <<< "scale=30; $total+$resp")
			echo "# Round=$j T=$resp"
		done
		avg=$(bc <<< "scale=30; $total/${#TIMES[@]}")
		printf "($i, $avg)\n" >> "results/r3.dat"
		echo "Time avg. = $avg"
	done




BLOCK_SIZES=( 32 64 128 256 )


echo "<----------------------generating datafile- r4.dat ----------------------->"

 for i in "${BLOCK_SIZES[@]}"
	do
		:

		TIMES=($(seq 0  30))
		total="0"
		echo "N=$i"
		for (( j=0; j<=30 ; j++ ))
		do 
			:
			eval $Gblock
			resp=$(./results/out $i)
			total=$(bc <<< "scale=30; $total+$resp")
			echo "# Round=$j T=$resp"
		done
		avg=$(bc <<< "scale=30; $total/${#TIMES[@]}")
		printf "($i, $avg)\n" >> "results/r4.dat"
		echo "Time avg. = $avg"
	done





echo "<----------------------Written data to $outputfile ------------------------->"
clear
echo "<_______________________________FINISHED____________________________________>"

./final.sh
./final.sh

