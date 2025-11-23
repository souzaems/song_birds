# matrix_builder.awk
BEGIN {
    FS="\t"
    # Load species list to define columns
    col_index = 1
    while ( (getline species < "species_list.txt") > 0 ) {
        col_order[col_index] = species
        species_index_map[species] = col_index
        col_index++
    }
    num_cols = col_index - 1
    
    # Print Header
    printf "Gene_Name"
    for (i = 1; i <= num_cols; i++) {
        printf "\t%s", col_order[i]
    }
    printf "\n"
}
{
    gene = $1
    species = $2
    genes[gene] = 1
    counts[gene, species]++
}
END {
    for (gene in genes) {
        printf "%s", gene
        for (i = 1; i <= num_cols; i++) {
            species = col_order[i]
            count = (counts[gene, species] > 0) ? counts[gene, species] : 0
            printf "\t%d", count
        }
        printf "\n"
    }
}
