# export_clusters.R
library(pheatmap)

input_file <- "gene_presence_matrix.tsv"
output_file <- "gene_clusters.tsv"
NUMBER_OF_CLUSTERS <- 8  # Adjust based on visual inspection of heatmap

# Read and Process Data
data <- read.csv(input_file, sep="\t", header=TRUE, row.names=1, check.names=FALSE)
data_binary <- (data > 0) + 0

# Run Clustering (Silent)
heatmap_results <- pheatmap(
  data_binary,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  silent = TRUE
)

# Cut the Tree
gene_clusters <- cutree(heatmap_results$tree_row, k = NUMBER_OF_CLUSTERS)

# Format Output
cluster_df <- data.frame(
  Gene_Name = names(gene_clusters),
  Cluster_ID = gene_clusters
)
cluster_df <- cluster_df[order(cluster_df$Cluster_ID, cluster_df$Gene_Name),]

# Save
write.table(cluster_df, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
print(paste("Clusters saved to:", output_file))
