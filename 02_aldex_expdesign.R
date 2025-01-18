#Preprocessing notebook
#Not going to try this with full set anymore, clearly produces too much data
#and leads to errors. 
#chase et al 2024 does the following:
#1) only shallow water samples. (445 total)
#2) shallow water samples split into 3 clusters by a SOM operating on 
#temp, salinity, and dissolved nitrogen (sum NO3 and NH3, nitrate and ammonia)

#1) Import sample metadata: there should be a row for every sample (558 total)
env.metadata <- read.csv2(
  "NCOG_sample_log_RNA_metadata.tsv", 
  sep = "\t")

#can see that sample set splits into 1/4, 1/2, 1/4 by depth. 
#keep the surface samples only
print(table(env.metadata$depth_category))
shallow.metadata <- env.metadata[(env.metadata$depth_category == "Surface"),]

#2) selecting by depth already rules out over half the samples. any further
#and i won't have enough samples in each group for a convincing t test? 
#just split on temperature.

#quantiles <- quantile(env.metadata$T_degC, probs=c(0.33,0.66))
assign.factor <- function(temp) {
  if (temp < median(shallow.metadata$T_degC)) {
    return ("A")
  }
  "B" #returns last evaluated expression
}

design.frame <- data.frame(
    conditions = sapply(shallow.metadata$T_degC, FUN = assign.factor),
    row.names = shallow.metadata$sample_number #recognizable sample IDs
)

#write.csv2 hardcodes semicolon for sep
write.csv2(design.frame, "02_shallow_split_temp.tsv", quote = FALSE)
