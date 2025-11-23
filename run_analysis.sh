#!/bin/bash
#SBATCH --job-name=avian_genomics_pipeline
#SBATCH --account=project_2014413
#SBATCH --time=05:00:00
#SBATCH --partition=small
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --output=analysis_%j.out
#SBATCH --error=analysis_%j.err

# --- Dependencies ---
module load bedtools

echo "Starting Avian Comparative Genomics Analysis..."
echo "------------------------------------------------------------"

# --- Configuration ---
MAF_FILE="alinhamento_dos_genes_zebrafinch.maf"   # Input Alignment
GENE_MAP_FILE="genes_do_zebra_finch.bed"          # Input Gene Coordinates
SPECIES_LIST_FILE="species_list.txt"              # Output Species List
REF_GENOME_ID="GCF_048771995.1"                   # Reference ID (e.g., Zebra Finch)
REF_GENOME_PREFIX="GCF_048771995.1."              # Prefix in MAF

# Intermediate and Output Files
TMP_BLOCKS_FILE="present_blocks.bed"
TMP_INTERSECT_FILE="intersect_results.tmp"
FINAL_MATRIX_FILE="gene_presence_matrix.tsv"
AWK_MATRIX_BUILDER="matrix_builder.awk"

# --- Setup Temporary Workspace (for sorting large files) ---
TEMP_WORKSPACE="$(pwd)/matrix_temp_workspace"
rm -rf $TEMP_WORKSPACE
mkdir -p $TEMP_WORKSPACE
export TMPDIR=$TEMP_WORKSPACE
echo "Temporary workspace set to: $TEMP_WORKSPACE"

# Clean previous runs
rm -f $TMP_BLOCKS_FILE $TMP_INTERSECT_FILE $FINAL_MATRIX_FILE

# --- Step 1: Parse MAF and Extract Blocks ---
echo "Step 1: Extracting alignment blocks from MAF..."
awk -v REF_PREFIX="$REF_GENOME_PREFIX" -v REF_ID="$REF_GENOME_ID" '
BEGIN { FS=OFS="\t" }
/^a/ {
    process_previous_block()
    delete present_species
    current_ref_chrom = "NA"
}
/^s/ {
    full_name = $2
    # Logic: Check if line starts with reference prefix
    if (index(full_name, REF_PREFIX) == 1) {
        current_ref_chrom = full_name
        current_ref_start = $3
        current_ref_end = $3 + $4
    } else {
        # Extract species genome ID
        match(full_name, /^([^\.]+\.[^\.]+)\./, parts)
        genome_name = parts[1]
        if (genome_name != "" && genome_name != REF_ID) {
            present_species[genome_name] = 1
        }
    }
}
END { process_previous_block() }
function process_previous_block() {
    if (current_ref_chrom != "NA") {
        for (species_name in present_species) {
            print current_ref_chrom, current_ref_start, current_ref_end, species_name
        }
    }
}
' $MAF_FILE | sort -k1,1 -k2,2n > $TMP_BLOCKS_FILE

echo "Step 1 Complete."

# --- Step 2: Intersect Genes with Blocks ---
echo "Step 2: Intersecting Genes with Blocks (bedtools)..."
bedtools intersect -a $GENE_MAP_FILE -b $TMP_BLOCKS_FILE -wa -wb > $TMP_INTERSECT_FILE
echo "Step 2 Complete."

# --- Step 2.5: Ensure Species List Exists ---
echo "Step 2.5: Generating/Verifying species list..."
# Adjust input filename 'seqfile_final_cactus.txt' if necessary
if [ -f "seqfile_final_cactus.txt" ]; then
    awk '{print $1}' seqfile_final_cactus.txt | grep -v "$REF_GENOME_ID" > $SPECIES_LIST_FILE
fi

# --- Step 3: Build Matrix ---
echo "Step 3: Generating final count matrix..."
cut -f 4,8 $TMP_INTERSECT_FILE | awk -f $AWK_MATRIX_BUILDER > $FINAL_MATRIX_FILE
echo "Step 3 Complete."

# --- Cleanup ---
rm $TMP_BLOCKS_FILE $TMP_INTERSECT_FILE
rm -rf $TEMP_WORKSPACE

echo "------------------------------------------------------------"
echo "Analysis Finished. Output: $FINAL_MATRIX_FILE"
