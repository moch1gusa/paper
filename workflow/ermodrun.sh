#!/bin/sh

#################################
# User-specific settings
#################################

MPICOMM="mpirun -np 16"
LMPBIN="lmp_mpi"
ERMOD_INSTALL_PATH="/home/yomogita/link_to_work02/yomogita/ermod"
#ERMOD_INSTALL_PATH="/work02/yomogita/ermod"
FLEXIBLE="True" # of "False"

#################################
# Check ERmod
#################################

which $ERMOD_INSTALL_PATH/bin/ermod || exit 1

#################################
# MD simulations using LAMMPS
#################################

#$MPICOMM $LMPBIN -in solution.in | tee solution.log
#$MPICOMM $LMPBIN -in solvent.in  | tee solvent.log
#$MPICOMM $LMPBIN -in solute.in   | tee solute.log

#################################
# Free energy calculation using ERmod
#################################

rm -fr soln refs

echo C5NH11 | ${ERMOD_INSTALL_PATH}/share/ermod/tools/LAMMPS/gen_structure \
    --data solution.data || exit 1

cd soln

${ERMOD_INSTALL_PATH}/share/ermod/tools/LAMMPS/gen_input \
    --traj  ../solution.xtc \
    --log   ../solution.log \
    --input ../solution.in || exit 1

${MPICOMM} ${ERMOD_INSTALL_PATH}/bin/ermod || exit 1

cd ../refs

if [ $FLEXIBLE = "True" ]; then
    ${ERMOD_INSTALL_PATH}/share/ermod/tools/LAMMPS/gen_input \
	--traj  ../solvent.xtc \
	--log   ../solvent.log \
	--input ../solvent.in \
	--flexible ../solute.xtc || exit 1
else
    ${ERMOD_INSTALL_PATH}/share/ermod/tools/LAMMPS/gen_input \
	--traj  ../solvent.xtc \
	--log   ../solvent.log \
	--input ../solvent.in \
	--rigid ../solute.data || exit 1
fi

${MPICOMM} ${ERMOD_INSTALL_PATH}/bin/ermod || exit 1

cd ..

${ERMOD_INSTALL_PATH}/bin/slvfe | tee slvfe.log

