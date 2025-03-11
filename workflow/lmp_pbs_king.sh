#!/bin/bash
#PBS -N conf0
#PBS -l select=1:ncpus=48:mpiprocs=48
#PBS -q cpu96cores_2024
#PBS -o outfile.txt
#PBS -e outfile.err

export OMP_NUM_THREADS=1
jobname=$PBS_JOBNAME
jobid=$PBS_JOBID
nodelist=$PBS_NODEFILE
num_procs=`cat ${PBS_NODEFILE} | wc -l`

module load lammps/2Aug23

echo "-----------------"
cat ${PBS_NODEFILE}

echo PBS_JOBNAME , $PBS_JOBNAME
echo PBS_JOBID , $PBS_JOBID
echo NCPUS , $NCPUS
echo PBS_NODEFILE , $PBS_NODEFILE
echo num_procs , $num_procs

echo "-----------------"
lmp=/usr/local/LAMMPS/bin/lmp_linux_intelmpi
cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR
# Liquid simulations

CURRENT_DIR=$(pwd)

for folder in "$CURRENT_DIR"/*/; do
	folder_name=$(basename "$folder")
	echo "Folder: $folder_name"
	cd "$folder_name" || continue
	echo "Running simulations..."
	mpirun --rsh=rsh -machinefile ${PBS_NODEFILE} -np $num_procs $lmp -in solution.in -log solution.log
	mpirun --rsh=rsh -machinefile ${PBS_NODEFILE} -np $num_procs $lmp -in solvent.in -log solvent.log
	mpirun --rsh=rsh -machinefile ${PBS_NODEFILE} -np $num_procs $lmp -in solute.in -log solute.log
	cd "$CURRENT_DIR"

done

# Return to the original directory
cd $PBS_O_WORKDIR
echo "All simulations completed."

