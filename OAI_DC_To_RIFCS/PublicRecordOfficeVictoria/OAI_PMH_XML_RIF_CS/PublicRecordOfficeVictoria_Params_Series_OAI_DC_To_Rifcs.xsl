<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:import href="PROV_OAI_DC_To_RIFCS_Series.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'https://prov.vic.gov.au'"/>
    <xsl:param name="global_group" select="'Public Record Office Victoria'"/>
    <xsl:param name="global_acronym" select="'PROV'"/>
    <xsl:param name="global_publisherName" select="'Public Record Office Victoria'"/>
    <xsl:param name="global_baseURI" select="'https://prov.vic.gov.au'"/>
    <xsl:param name="global_path" select="'/archive/'"/>
    
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:message select="concat('name(OAI-PMH): ', name(OAI-PMH))"/>
            <xsl:message select="concat('num record element: ', count(OAI-PMH/ListRecords/record))"/>
            <xsl:apply-templates select="OAI-PMH/ListRecords/record"/>
            
        </registryObjects>
    </xsl:template>
    
    
    <xsl:template match="record">
        <xsl:apply-templates select="metadata/oai_dc:dc[contains(lower-case(dc:type), 'collection')]" mode="collection"/>
        
    </xsl:template>
    
    
 </xsl:stylesheet>
    
