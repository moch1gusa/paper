#!/bin/bash
set +v
echo "*************************************************"
echo "***     Assigning parameters using ACPYPE     ***"
echo "*************************************************"
set -v
which acpype.py
RES=$?
set +v
if [ $RES -ne 0 ]; then
  echo "Error : acpype.py was not found. Install and set PATH."
  sleep 5
  exit 1
fi
set -v
acpype.py -d -o gmx -i MOL01.mol2  -c user -f 
set +v
if [ ! -f MOL01.acpype/MOL01_GMX.gro ]; then
  echo "Error : Failed to run acpype."
  sleep 5
  exit 1
fi
set -v
sed -i.bak -e "s/ MOL /MOL01/g" MOL01.acpype/MOL01_GMX.itp
cp MOL01.acpype/MOL01_GMX.itp MOL01.itp
