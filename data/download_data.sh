if [[ $1 -eq "" ]]; then
    echo "Please supply valid TSCC login address"
fi

TSCC_LOGIN=$1

#Download totalRNA orfhit table & annotations, as of Nov 24
scp ${TSCC_LOGIN}:/tscc/projects/ps-allenlab/archdata/zfussy/RAP_runs/NCOG_totalRNA/annotation_all.filtered.orfhits.tab totalRNA/

scp ${TSCC_LOGIN}:/tscc/projects/ps-allenlab/archdata/zfussy/RAP_runs/NCOG_totalRNA/annotations/NCOG-totalRNA-annotations.tsv.gz totalRNA/

#Download polyA orfhit table & annotations, as of Nov 24
scp ${TSCC_LOGIN}:/tscc/projects/ps-allenlab/archdata/zfussy/RAP_runs/NCOG_polyA/annotations/NCOG-polyA-annotations.tsv.gz polyA/

scp ${TSCC_LOGIN}:/tscc/projects/ps-allenlab/archdata/zfussy/RAP_runs/NCOG_polyA/annotation_042022/annotation_all.filtered.orfhits.tab polyA/
