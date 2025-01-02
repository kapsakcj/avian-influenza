#!/bin/bash
# Curtis Kapsak, started 2025-01-02

# requirements:
# csvkit (https://csvkit.readthedocs.io/en/latest/), install with 'pip install csvkit'

# parse through all *.tsv files in the variant directories and produce a single TSV file with the following columns:
# 'entity:h5n1_flu_specimen_id' which contains the SRR accession number from the TSV filename
# 'ha_variants'
# 'mp_variants'
# 'na_variants'
# 'ns_variants'
# 'np_variants'
# 'pb1_variants'
# 'pb2_variants'
# 'pa_variants'

# take in first argument as the directory to search for *.tsv files
# take in second argument as the output file name
INPUT_DIR=$1

# set output filename
OUTPUT_FILE=$2

# create the output file with the header
echo -e "entity:h5n1_flu_specimen_id\tha_variants\tmp_variants\tna_variants\tns_variants\tnp_variants\tpb1_variants\tpb2_variants\tpa_variants" > $OUTPUT_FILE

# loop through all *.tsv files in the input directory
for file in ${INPUT_DIR}/*_variants.tsv; do
    # get the SRR accession number from the filename
    SRR=$(basename $file | cut -d'_' -f1)
    # set file names for each segment per SRR accession number
    HA_FILE=${SRR}_HA_variants.tsv
    MP_FILE=${SRR}_MP_variants.tsv
    NA_FILE=${SRR}_NA_variants.tsv
    NS_FILE=${SRR}_NS_variants.tsv
    NP_FILE=${SRR}_NP_variants.tsv
    PB1_FILE=${SRR}_PB1_variants.tsv
    PB2_FILE=${SRR}_PB2_variants.tsv
    PA_FILE=${SRR}_PA_variants.tsv

    # check for TSV files that only have a header row and nothing else, if so echo "No variants for ${SRR}_<segment> segment" and continue to the next file
    if [ $(wc -l ${INPUT_DIR}/${HA_FILE} | cut -d' ' -f1) -eq 1 ]; then
        echo "No variants for ${SRR}_HA segment"
        continue
    else
        echo "Parsing ${SRR}_HA segment"
        HA_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${HA_FILE} | cut -f2 | tr '\n' ',')
    fi

    # for every non-header row in the each variants.tsv file, parse columns 2-4, format to "<column4><column3><column2>" and write it to the output file in a comma-separated list
    MP=$(tail -n +2 ${INPUT_DIR}/${MP_FILE} | cut -f2 | tr '\n' ',')
    HA=$(tail -n +2 ${INPUT_DIR}/${HA_FILE} | cut -f2 | tr '\n' ',')

    
    # write the variants to the output file
    echo -e "${SRR}\t${HA}\t${MP}\t${NA}\t${NS}\t${NP}\t${PB1}\t${PB2}\t${PA}" >> $OUTPUT_FILE
done