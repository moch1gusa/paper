#!/bin/bash

export PATH=~/ermod/bin:$PATH
export PATH=~/ermod/share/ermod/tools/GROMACS/:$PATH

# Define the number of processors as a variable
NUM_PROCS=4

# Create a log file for output
LOGFILE="gromacs_run.log"

# Copy the topology file
cp etoh.top etohsolution.top | tee -a $LOGFILE

# Step 1: Solvate the system
gmx solvate -cp etoh.gro -box 3.2 3.2 3.2 -cs spc216.gro -maxsol 1000 -o solution.gro -p etohsolution.top | tee -a $LOGFILE

# Step 2: Energy minimization
gmx grompp -f min.mdp -c solution.gro -p etohsolution.top -o solution_min.tpr | tee -a $LOGFILE
gmx mdrun -s solution_min.tpr -o solution_min.trr -e solution_min.edr -g solution_min.log -c solution_min.gro | tee -a $LOGFILE

# Step 3: NVT equilibration
gmx grompp -f nvt.mdp -c solution_min.gro -p etohsolution.top -o solution_nvt.tpr | tee -a $LOGFILE
gmx mdrun -s solution_nvt.tpr -o solution_nvt.trr -x solution_nvt.xtc -e solution_nvt.edr -g solution_nvt.log -c solution_nvt.gro | tee -a $LOGFILE

# Step 4: NPT equilibration
gmx grompp -f npt.mdp -c solution_nvt.gro -p etohsolution.top -o solution_npt.tpr | tee -a $LOGFILE
gmx mdrun -s solution_npt.tpr -o solution_npt.trr -x solution_npt.xtc -e solution_npt.edr -g solution_npt.log -c solution_npt.gro -cpo solution_npt.cpt | tee -a $LOGFILE

# Step 5: Production run
gmx grompp -f solution_run.mdp -c solution_npt.gro -t solution_npt.cpt -e solution_npt.edr -p etohsolution.top -o solution_run.tpr | tee -a $LOGFILE
gmx mdrun -s solution_run.tpr -o solution_run.trr -x solution_run.xtc -e solution_run.edr -g solution_run.log -c solution_run.gro | tee -a $LOGFILE

# Solvent preparation (NVT & NPT equilibration)
gmx grompp -f nvt.mdp -c solvent.gro -p wat.top -o solvent_nvt.tpr | tee -a $LOGFILE
gmx mdrun -s solvent_nvt.tpr -o solvent_nvt.trr -x solvent_nvt.xtc -e solvent_nvt.edr -g solvent_nvt.log -c solvent_nvt.gro | tee -a $LOGFILE

gmx grompp -f npt.mdp -c solvent_nvt.gro -p wat.top -o solvent_npt.tpr | tee -a $LOGFILE
gmx mdrun -s solvent_npt.tpr -o solvent_npt.trr -x solvent_npt.xtc -e solvent_npt.edr -g solvent_npt.log -c solvent_npt.gro -cpo solvent_npt.cpt | tee -a $LOGFILE

gmx grompp -f solvent_run.mdp -c solvent_npt.gro -t solvent_npt.cpt -e solvent_npt.edr -p wat.top -o solvent_run.tpr | tee -a $LOGFILE
gmx mdrun -s solvent_run.tpr -o solvent_run.trr -x solvent_run.xtc -e solvent_run.edr -g solvent_run.log -c solvent_run.gro | tee -a $LOGFILE

# Solute preparation
gmx editconf -f etoh.gro -c -o etoh_box.gro -box 5.0 5.0 5.0 | tee -a $LOGFILE
gmx grompp -f solute_min.mdp -c etoh_box.gro -p etoh.top -o solute_min.tpr | tee -a $LOGFILE
gmx mdrun -s solute_min.tpr -o solute_min.trr -e solute_min.edr -g solute_min.log -c solute_min.gro | tee -a $LOGFILE

gmx grompp -f solute_eq.mdp -c solute_min.gro -p etoh.top -o solute_eq.tpr | tee -a $LOGFILE
gmx mdrun -s solute_eq.tpr -o solute_eq.trr -x solute_eq.xtc -e solute_eq.edr -g solute_eq.log -c solute_eq.gro | tee -a $LOGFILE

gmx grompp -f solute_run.mdp -c solute_eq.gro -e solute_eq.edr -p etoh.top -o solute_run.tpr | tee -a $LOGFILE
gmx mdrun -s solute_run.tpr -o solute_run.trr -x solute_run.xtc -e solute_run.edr -g solute_run.log -c solute_run.gro | tee -a $LOGFILE

# Handle periodic boundary conditions
gmx trjconv -s solute_run.tpr -f solute_run.xtc -center -pbc mol -o solute_run_pbc.xtc | tee -a $LOGFILE

# Generate input for ERDST
gen_structure --top etohsolution.top | tee -a $LOGFILE
cd soln
gen_input --traj ../solution_run.xtc --log ../solution_run.log | tee -a $LOGFILE
mpirun -np $NUM_PROCS erdst | tee -a $LOGFILE

cd ../refs
gen_input --traj ../solvent_run.xtc --log ../solvent_run.log --rigid ../etoh.gro | tee -a $LOGFILE
mpirun -np $NUM_PROCS erdst | tee -a $LOGFILE

cd ../
mpirun -np $NUM_PROCS slvfe | tee -a $LOGFILE

which $ERMOD_INSTALL_PATH/bin/ermod || exit 1
