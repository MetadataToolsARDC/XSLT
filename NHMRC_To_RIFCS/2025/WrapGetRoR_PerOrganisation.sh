#!/bin/bash

INPUT_XML="/home/melanie/git/XSLT/NHMRC_To_RIFCS/2025/Summary-of-result-2025-app-round-27072025.xml"
XSLT="/home/melanie/git/XSLT/NHMRC_To_RIFCS/CORE/ExtractKeys/nhmrc_extract_institutional_keys_RoR.xsl"
OUTPUT_XML="/home/melanie/git/XSLT/NHMRC_To_RIFCS/2025/nhmrc_admin_institutions_ror_id_2025_AfterParticipatingInstitutionsIncluded.xml"

SAXON_JAR="/home/melanie/git/private_scripts-as-required/SaxonHE12-8J/saxon-he-12.8.jar"
XMLRESOLVER_JAR="/home/melanie/git/private_scripts-as-required/SaxonHE12-8J/lib/xmlresolver-5.3.3.jar"

TMP_XML="tmp.xml"


# Create file that will contains each organisation name, with a RoR if found by the XSLT that is called
echo '<?xml version="1.0" encoding="UTF-8"?><institutions>' > "$OUTPUT_XML"

# Get distinct organisations - Participating_Institutions contains organisation names pipe delimited
xmllint --xpath '//row/Admin_Institution | //row/Administering_Institution | //row/Participating_Institutions' "$INPUT_XML" \
  | sed 's/|/\n/g' \
  | sed 's/<[^>]*>//g' \
  | sed '/^\s*$/d' \
  | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
  | sort -u > organisations.txt

# Per each distinct organisation name in organisations.txt
while IFS= read -r org; do
    echo "Processing organisation: $org"

    # Skip empty lines
    [[ -z "$org" ]] && continue

    # Create minimal XML for this organisation
    echo "<root><row><Admin_Institution>${org}</Admin_Institution></row></root>" > "$TMP_XML"

    # Run Saxon-PE on the single organisation XML
    java -cp "$SAXON_JAR:$XMLRESOLVER_JAR" net.sf.saxon.Transform \
         -s:"$TMP_XML" \
         -xsl:"$XSLT" \
         -o:"$TMP_XML.out" \
         -t

    # Append <institution> elements to OUTPUT_XML
    xmllint --xpath '//institution' "$TMP_XML.out" >> "$OUTPUT_XML"

    # Sleep 6 seconds to respect API rate limit
    sleep 6

done < organisations.txt

# Close root
echo '</institutions>' >> "$OUTPUT_XML"

# Cleanup
#rm "$TMP_XML" "$TMP_XML.out" organisations.txt

echo "Processing complete. Output written to $OUTPUT_XML"