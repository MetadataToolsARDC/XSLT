<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xs xsi xsl mdb">
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'AuScope'"/>
    <xsl:param name="global_acronym" select="'AuScope'"/>
    <xsl:param name="global_baseURI" select="'portal.auscope.org'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/api/records/'"/>
    <xsl:param name="global_group" select="'AuScope'"/>
    
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
