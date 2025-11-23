# plot_heatmap.R
library(pheatmap)

# --- Configuration ---
input_file <- "gene_presence_matrix.tsv"
map_file <- "species_list.txt"     # File mapping GenomeID -> CommonName
output_file <- "heatmap_annotated.png"

# 1. Read Translation Map
# Assumes format: CommonName <tab> GenomeID
map_data <- read.csv(map_file, sep="\t", header=FALSE, stringsAsFactors=FALSE)
# Create dictionary: GenomeID -> CommonName
translation_map <- setNames(map_data$V1, map_data$V2)

# 2. Read Data
data <- read.csv(input_file, sep="\t", header=TRUE, row.names=1, check.names=FALSE)
# Convert to Binary (Presence/Absence)
data_binary <- (data > 0) + 0

# 3. Translate Column Names
current_colnames <- colnames(data_binary)
new_labels <- c()

for (id in current_colnames) {
  if (id %in% names(translation_map)) {
    new_labels <- c(new_labels, translation_map[[id]])
  } else {
    new_labels <- c(new_labels, id)
  }
}

# 4. Generate Heatmap
png(output_file, width=15, height=20, units="in", res=300)

pheatmap(
  data_binary,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = TRUE,
  labels_col = new_labels, # Apply new names
  color = c("white", "black"),
  legend = FALSE,
  fontsize_col = 10
)

dev.off()
print(paste("Plot saved to:", output_file))
