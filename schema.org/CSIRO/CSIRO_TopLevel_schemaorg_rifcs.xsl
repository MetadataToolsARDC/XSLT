<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--xsl:import href="schemadotorg2rif.xsl"/-->
    <xsl:import href="schemadotorg2rif_updated.xsl"/>
    
    <xsl:param name="originatingSource" select="'Commonwealth Scientific and Industrial Research Organisation'"/>
    <xsl:param name="group" select="'Commonwealth Scientific and Industrial Research Organisation'"/>
    <!-- Usually we prefix keys with the contributor acronym, so that we can allow duplicate records 
        (i.e. from different contributors), but for CSIRO, don't use acronym as prefix to key because they 
        use their handle in key and we want to keep the same (so that view/access statistics transfer 
        from old records to new) and it won't be a blocker to duplicate records because an alternative
        contributor/aggregator will have a prefix and anyway won't use the CSIRO handle as the key value -->
    <xsl:param name="groupAcronym" select="''"/> 
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

</xsl:stylesheet>
