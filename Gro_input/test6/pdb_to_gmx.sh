cat > packmol_input.inp <<EOF
tolerance 2.0
filetype pdb

output solution.pdb

structure solute.pdb
  number 1
  inside box 0. 0. 0. 50. 50. 50.
end structure

structure solvent.pdb
  number 1000
  inside box 0. 0. 0. 50. 50. 50.
end structure
EOF

packmol < packmol_input.inp

# 3. Convert the solute and solvent PDB files to MOL2 format using Antechamber

# Convert solute (solute.pdb) to MOL2 format with BCC charges
antechamber -i solute.pdb -fi pdb -o solute.mol2 -fo mol2 -c bcc -nc 0 -s 2

# Convert solvent (solvent.pdb) to MOL2 format with BCC charges
antechamber -i solvent.pdb -fi pdb -o solvent.mol2 -fo mol2 -c bcc -nc 0 -s 2

echo "MOL2 files for solute and solvent generated."
echo "Packmol box generated as box.pdb"

# 4. Use ACPYPE to generate GROMACS files from MOL2 files

# Convert solute (solute.mol2) to GROMACS topology and coordinate files
acpype -i solute.mol2 -o gmx

# Convert solvent (solvent.mol2) to GROMACS topology and coordinate files
acpype -i solvent.mol2 -o gmx

# The GROMACS files (solute_GMX.gro, solute_GMX.top, solvent_GMX.gro, solvent_GMX.top) will be generated in the respective directories
echo "MOL2 files for solute and solvent generated."
echo "Packmol box generated as box.pdb"
echo "GROMACS files generated using ACPYPE."
