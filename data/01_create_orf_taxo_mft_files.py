from helper_functions import identify_mixo_by_taxo
import os
import pandas as pd
TOTAL_TABLE = os.path.abspath("./totalRNA/annotation_all.filtered.orfhits.tab")
POLYA_TABLE = os.path.abspath("./polyA/annotation_all.filtered.orfhits.tab")
TOTAL_ANNOT = os.path.abspath("./totalRNA/NCOG-totalRNA-annotations.tsv")
POLYA_ANNOT = os.path.abspath("./polyA/NCOG-polyA-annotations.tsv")

#orf_taxo_mft tables for each dataset, can select spec groups later
def orf_taxo_mft(infile_path, outfile_path):
    with open(infile_path, "r") as infile:
        #skip column names
        infile.readline()
        with open(outfile_path, "w") as outfile:
            #add column names
            outfile.write("ORFID\tLPI_taxonomy\tmost_specific_name\tMFT\n")

            for line in infile.readlines():
                terms = line.split("\t")
                #print(terms)
                #quit(1)
                orfid = terms[0]
                assert(len(terms) == 19)
                taxonomy = terms[18].strip()
                if taxonomy == "":
                    continue
                most_specific_name = taxonomy.strip(";.").split(";")[-1]
                mft = identify_mixo_by_taxo(most_specific_name)
                outfile.write(f"{orfid}\t{taxonomy}\t{most_specific_name}\t{mft}\n")
       
orf_taxo_mft(POLYA_ANNOT, os.path.abspath("./polyA/orf_taxo_mft.tsv"))
print("PolyA Done")
orf_taxo_mft(TOTAL_ANNOT, os.path.abspath("./totalRNA/orf_taxo_mft.tsv"))