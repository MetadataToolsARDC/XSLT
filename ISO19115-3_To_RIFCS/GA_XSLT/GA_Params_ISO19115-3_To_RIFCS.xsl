<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0" 
    exclude-result-prefixes="xs xsi xsl mdb">
    
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Geoscience Australia'"/>
    <xsl:param name="global_acronym" select="'GA'"/>
    <xsl:param name="global_baseURI" select="'ecat.ga.gov.au'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/search?uuid='"/>
    <xsl:param name="global_group" select="'Geoscience Australia'"/>
    
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:apply-templates select="//mdb:MD_Metadata" mode="process"/>
        </registryObjects>
        
    </xsl:template>
    
</xsl:stylesheet>
