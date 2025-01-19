import pandas as pd
import math

pr2_taxonomies = pd.read_csv("trophic_type_databases/pr2_version_5.0.0_taxonomy.tsv", sep = "\t")
mdb = pd.read_csv("trophic_type_databases/MDB_data.tsv", sep = "\t")

"""Identify mixo by taxo: may use this in different notebooks"""

### making sure these structures only created once

###format pr2 data
#nucleomorph and plastid entries are fine, seems like pr2 neive bayes classification may also include them.
pr2_mixo_species = pr2_taxonomies[["species", "mixoplankton"]].dropna()
#clean characters that could create false differences
pr2_mixo_species["species"] = pr2_mixo_species["species"].str.strip(";.")
pr2_mixo_species.columns = ["species", "MFT"]
                         
###format mdb data
#some of the species names have the wrong unicode char (u'\xa0') for a space, replace those
mdb_mixo_species = pd.DataFrame({
"species" : mdb["Species Name"].apply(lambda x: "_".join(x.replace(u'\xa0', u' ').split(" ")).strip(".") ),
"MFT" : mdb["MFT"].str.strip("*")
})
    
###concat data and remove overlaps: they have to be combined like this because index not checked by drop_duplicates
#move species name to index after that since it makes searching easier
combined_mixo_species = pd.concat([pr2_mixo_species, mdb_mixo_species], ignore_index=True).drop_duplicates()
combined_mixo_species = combined_mixo_species["MFT"].rename(index=combined_mixo_species["species"])

###frequency table of genus names
#throw out genera that don't pass threshold
#find majority MFT amogn species of passing genera
threshold = 0
#Assigns each genus the majority MFT among mixo species in that genus.
genus_majority_mft = None
def set_genus_match_threshold(new_t):
    genus_frequencies = pd.Series(combined_mixo_species.index).apply(lambda x: x.split("_")[0]).value_counts()
    genus_frequencies = genus_frequencies[genus_frequencies >= threshold] #only "threshold or greater" allowed
    genus_majority_mft = pd.Series(genus_frequencies.index, index = genus_frequencies.index).apply(
        lambda x: combined_mixo_species[combined_mixo_species.index.str.contains(f"{x}_")].value_counts().index[0]
    )
                                                                 
#first pass match species, second pass match genus? or 
###one pass: most specific name is either a genus or starts with one...
def identify_mixo_by_taxo(name):
    if name in combined_mixo_species.index:
        return(combined_mixo_species[name])
    
    #step into genus checks
    if(threshold > 0):
        if name in genus_majority_mft.index:
            return genus_majority_mft[name]
        #most specific name is neither a matching species name or matching genus name
        #could extract a matching genus name
        genus = name.split("_")[0]
        if genus in genus_majority_mft.index:
            return genus_majority_mft[genus]
    
    #no match
    return ""