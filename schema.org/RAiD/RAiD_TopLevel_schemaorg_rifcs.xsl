<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--xsl:import href="schemadotorg2rif.xsl"/-->
    <xsl:import href="schemadotorg2rif_updated.xsl"/>
    
    <xsl:param name="originatingSource" select="'RAiD AU'"/>
    <xsl:variable name="group" select="'RAiD AU'"/>
    <xsl:param name="groupAcronym" select="'RAiD_AU'"/> 
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

</xsl:stylesheet>
