from rdkit import Chem
from rdkit.Chem import AllChem
import os

def generate_pdb(smiles, output_filename):
    """Generates a PDB file from SMILES string with explicit hydrogens and optimized structure."""
    mol = Chem.MolFromSmiles(smiles)
    mol = Chem.AddHs(mol)  # Add explicit hydrogens
    AllChem.EmbedMolecule(mol)
    AllChem.UFFOptimizeMolecule(mol)  # Optimize structure using UFF
    with open(output_filename, "w") as f:
        f.write(Chem.MolToPDBBlock(mol))

# Define SMILES for solute and solvent
solute_smiles = 'C1CCNCC1'  # Replace with your solute SMILES (e.g., Piperidine)
solvent_smiles = 'CO'    # Replace with your solvent SMILES (e.g., Dichloromethane)

# Generate PDB files
generate_pdb(solute_smiles, "solute.pdb")
generate_pdb(solvent_smiles, "solvent.pdb")

print("PDB files for solute and solvent generated.")
