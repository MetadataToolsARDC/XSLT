<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <xsl:import href="eml-to-rifcs.xsl"/>

  <xsl:variable name="rifcsVersion" select="1.3"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

  <xsl:template name="citationMetadataVersion">
    <xsl:param name="revid"/>
    <xsl:element name="edition">
      <xsl:value-of select="$revid"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:apply-imports/>
  </xsl:template>
  
</xsl:stylesheet>
