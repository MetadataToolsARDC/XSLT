https://collections.ala.org.au/ws/collection.json
[
  {
    "name": "Allan Herbarium",
    "uri": "https://collections.ala.org.au/ws/collection/co214",
    "uid": "co214"
  },
  {
    "name": "American Museum of Natural History Palaeontology Collections",
    "uri": "https://collections.ala.org.au/ws/collection/co229",
    "uid": "co229"
  },
  {

Per each, json can be retrieved as https://collections.ala.org.au/ws/collection/co214

-----

Requires input from https://collections.ala.org.au/ws/collection.json converted to XML (stored locally as example in $HOME/git/XSLT/docs/ALA/CollectionKeys.xml)

On the RDA Harvester, use the top-level XSLT $HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_AllCollections.xsl which will process every key that the 
harvester has retrieved from json, then converted to xml, with format as shown in $HOME/git/XSLT/docs/ALA/CollectionKeys.xml
It passes the key to ALA_DataResource_To_RIFCS.xsl template with mode="process" to transform the dataset metadata to rif-cs

Test the above locally like so from directory $HOME/git/XSLT/Custom_To_RIFCS/ALA/Collections

java -cp $HOME/OxygenXMLEditor/lib/xmlresolver-5.2.1.jar:$HOME/git/private_scripts-as-required/SaxonHE12-8J/saxon-he-12.8.jar net.sf.saxon.Transform -xsl:file:$HOME/git/XSLT/Custom_To_RIFCS/ALA/DataResources/ALA_AllCollections.xsl -s:file:$HOME/git/XSLT/docs/ALA/CollectionKeys.xml -o:out.xml

---

When running locally and you just want to crosswalk one file like ~git/projects/ALA/202510/CollectionExamples/co214.xml, use 
$HOME/git/XSLT/Custom_To_RIFCS/ALA/Collections/ALA_Collection_To_RIFCS.xsl directly (with no top-level call).

---

