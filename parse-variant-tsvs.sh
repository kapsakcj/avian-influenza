#!/bin/bash
# Curtis Kapsak, started 2025-01-02

# USAGE:
# ./parse-variant-tsvs.sh <input_directory> <output_file>
# example: ./parse-variant-tsvs.sh /path/to/directory/of/variantsTSVs/ /path/to/output.tsv

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

# kill script if any command fails or if any variable is not set or if any pipe fails
set -eou pipefail

# take in first argument as the directory to search for *.tsv files
# take in second argument as the output file name
INPUT_DIR=$1

# set output filename
OUTPUT_FILE=$2

# create the output file with the headers
echo -e "entity:h5n1_flu_specimen_id\tha_variants\tmp_variants\tna_variants\tns_variants\tnp_variants\tpb1_variants\tpb2_variants\tpa_variants" > $OUTPUT_FILE

# get list of all unique SRR accessions from the input directory of TSV files
SRR_LIST=$(ls ${INPUT_DIR} | cut -d '_' -f 1 | sort -u)

# loop through all *.tsv files in the input directory
for SRR in ${SRR_LIST}; do
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
    for SEGMENT in HA MP NA NS NP PB1 PB2 PA; do
      if [ $(wc -l ${INPUT_DIR}/${SRR}_${SEGMENT}_variants.tsv | cut -d ' ' -f1) -eq 1 ]; then
        echo "${INPUT_DIR}/${SRR}_${SEGMENT}_variants.tsv does not contain any variants"
        continue
      else
        echo "Parsing ${SRR}_${SEGMENT} segment"
        export ${SEGMENT}_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${SRR}_${SEGMENT}_variants.tsv | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # tail to remove header, awk to grab columns 17, 20, 19, format to "<column17><column20><column19>", sed to remove trailing comma
        # HA_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${HA_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # MP_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${MP_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # NA_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${NA_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # NS_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${NS_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # NP_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${NP_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # PB1_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${PB1_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # PB2_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${PB2_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        # PA_VARIANT_LIST=$(tail -n +2 ${INPUT_DIR}/${PA_FILE} | awk -F'\t' '{printf "%s%s%s,", $17, $20, $19}' | sed 's/,$//')
        
      fi
    done
  # now that each segment has been parsed, write to the output file
  echo "finished parsing each segment variant TSV file, appending $SRR variants to output file..."
  echo -e "$SRR\t$HA_VARIANT_LIST\t$MP_VARIANT_LIST\t$NA_VARIANT_LIST\t$NS_VARIANT_LIST\t$NP_VARIANT_LIST\t$PB1_VARIANT_LIST\t$PB2_VARIANT_LIST\t$PA_VARIANT_LIST" >> $OUTPUT_FILE

  echo "done parsing all segments for ${SRR}, continuing to next SRR..."

done
echo "DONE! Output file is located at $OUTPUT_FILE"