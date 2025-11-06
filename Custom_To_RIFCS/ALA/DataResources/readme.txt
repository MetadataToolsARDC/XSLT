https://biocache.ala.org.au/ws/occurrences/facets?q=*:*&facets=dataResourceUid&count=true&lookup=true&flimit=10000 has 1414 results - these are DataResources that contain one or more record/s.  This aligns with https://collections.ala.org.au/datasets#filters=resourceType%3Arecords (however, some of these have zero records as the UI cannot be filtered further by number of records). 

[
  {
    "fieldName": "dataResourceUid",
    "fieldResult": [
      {
        "label": "eBird Australia",
        "i18nCode": "dataResourceUid.dr2009",
        "count": 50500900,
        "fq": "dataResourceUid:\"dr2009\""
      },
      {
        "label": "NSW BioNet Atlas",
        "i18nCode": "dataResourceUid.dr368",
        "count": 14530682,
        "fq": "dataResourceUid:\"dr368\""
      },

You can use the count value from biocache call above, for each metadata entry, to include record total per dataResource (RIF-CS Collection).  Then get additional metadata per each call:  

Per each, json can be retrieved as https://collections.ala.org.au/ws/dataResource/dr23206 or eml at https://collections.ala.org.au/ws/eml/dr23206

Using EML for RDA currently

Can relate Party with relatedInfo, using uri (with “ws/institution” replaced with “public/show”) - i.e. https://collections.ala.org.au/public/show/in92 - identifier and name:
Can related to DataResource with relatedInfo, using uri (with “ws/dataResource” replaced with “public/show”) as - i.e. https://collections.ala.org.au/public/show/dr2153 - identifier, and name

-----

The difference between the two top-level XSLTS:
$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_DataResources_PARSE.xsl can run no matter what the input XML - it gets all keys itself from the URL in global_allKeysURL
$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_AllDataResources.xsl needs input XML to work - it gets all keys from the input XML, e.g from XML $HOME/git/XSLT/docs/ALA/DataResourceKeys.xml

--- 


Requires input from https://biocache.ala.org.au/ws/occurrences/facets?q=*:*&facets=dataResourceUid&count=true&lookup=true&flimit=10000 converted to XML (stored locally as example in $HOME/git/XSLT/docs/ALA/DataResourceKeys.xml)

On the RDA Harvester, use the top-level XSLT $HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_AllDataResources.xsl which will process every key that the 
harvester has retrieved from json, then converted to xml, with format as shown in $HOME/git/XSLT/docs/ALA/DataResourceKeys.xml
It passes the key to ALA_DataResource_To_RIFCS.xsl template with mode="process" to transform the dataset metadata to rif-cs

Test the above locally like so from directory $HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources

java -cp $HOME/OxygenXMLEditor/lib/xmlresolver-5.2.1.jar:$HOME/git/private_scripts-as-required/SaxonHE12-8J/saxon-he-12.8.jar net.sf.saxon.Transform -xsl:file:$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_AllDataResources.xsl -s:file:$HOME/git/XSLT/docs/ALA/DataResourceKeys.xml -o:out.xml

---

When running locally and you want it to receive all current keys from ALA, use:
$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_DataResources_PARSE.xsl
It passes the key to ALA_DataResource_To_RIFCS.xsl template with mode="process" to transform the dataset metadata to rif-cs

Test the above locally like so from directory $HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources

java -cp $HOME/OxygenXMLEditor/lib/xmlresolver-5.2.1.jar:$HOME/git/private_scripts-as-required/SaxonHE12-8J/saxon-he-12.8.jar net.sf.saxon.Transform -xsl:file:$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_DataResources_PARSE.xsl -s:file:$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/Untitled.xml -o:out.xml

---

When running locally and you just want to crosswalk one file like $HOME/git/XSLT/docs/ALA/dr23206_eml.xml, use 
$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_DataResource_To_RIFCS.xsl directly (with no top-level call).

