https://spatial.ala.org.au/ws/layers
[
  {
    "enabled": true,
    "source": "WorldClim",
    "keywords": "",
    "licence_notes": "CC BY-SA 4.0",
    "maxlongitude": 180.0,
    "metadatapath": "https://www.worldclim.org/data/worldclim21.html",
    "minlongitude": -180.0,
    "environmentalvalueunits": "mm",
    "environmentalvaluemin": "",
    "licence_link": "https://creativecommons.org/licenses/by-sa/4.0/",
    "displaypath": "https://spatial.ala.org.au/geoserver/gwc/service/wms?service=WMS&version=1.1.0&request=GetMap&layers=ALA:worldclim21_bio19&format=image/png&styles=",
    "dt_added": 1620632788642,
    "displayname": "WorldClim 2.1: Precipitation - coldest quarter",
    "classification2": "Precipitation",
    "mddatest": "2020-01",
    "description": "Precipitation of Coldest Quarter",
    "datalang": "eng",
    "name": "worldclim21_bio19",
    "respparty_role": "Custodian",
    "type": "Environmental",
    "domain": "Terrestrial",
    "source_link": "https://www.worldclim.org/data/worldclim21.html",
    "maxlatitude": 90.0,
    "classification1": "Climate",
    "path_orig": "layer/worldclim21_bio19",
    "environmentalvaluemax": "",
    "citation_date": "2017",
    "minlatitude": -90.0,
    "notes": "This is WorldClim version 2.1 climate data for 1970-2000. This version was released in January 2020.\r\n\r\nFick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315. https://rmets.onlinelibrary.wiley.com/doi/abs/10.1002/joc.5086",
    "licence_level": "1",
    "id": 10996
  },
  ...

Json for each spatial later records is embedded in that first call above.  

-----

Requires input from https://spatial.ala.org.au/ws/layers converted to XML (stored locally as example in $HOME/git/XSLT/docs/ALA/SpatialLayerRecords.xml)

On the RDA Harvester, use file:/home/melanie/git/XSLT/Custom_To_RIFCS/ALA/Spatial/ALA_SpatialLayer_To_RIFCS.xsl to generate rif-cs per each spatial layer.  

Test the above locally like so from directory $HOME/git/XSLT/Custom_To_RIFCS/ALA/Collections

java -cp $HOME/OxygenXMLEditor/lib/xmlresolver-5.2.1.jar:$HOME/git/private_scripts-as-required/SaxonHE12-8J/saxon-he-12.8.jar net.sf.saxon.Transform -xsl:file:$HOME/git/XSLT/Custom_To_RIFCS/ALA/Spatial/ALA_SpatialLayer_To_RIFCS.xsl -s:file:$HOME/git/XSLT/docs/ALA/SpatialLayerRecords.xml -o:out.xml

---

