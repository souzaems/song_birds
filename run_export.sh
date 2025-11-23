#!/bin/bash
#SBATCH --job-name=export_clusters
#SBATCH --account=project_2014413
#SBATCH --time=00:15:00
#SBATCH --partition=small
#SBATCH --mem=8G
#SBATCH --output=export_%j.out
#SBATCH --error=export_%j.err

module load r-env

echo "Exporting Gene Clusters..."
Rscript export_clusters.R
echo "Done."
