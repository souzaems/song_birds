#!/bin/bash
#SBATCH --job-name=plot_heatmap
#SBATCH --account=project_2014413
#SBATCH --time=00:20:00
#SBATCH --partition=small
#SBATCH --mem=8G
#SBATCH --output=plot_%j.out
#SBATCH --error=plot_%j.err

module load r-env

echo "Generating Heatmap..."
Rscript plot_heatmap.R
echo "Done."
