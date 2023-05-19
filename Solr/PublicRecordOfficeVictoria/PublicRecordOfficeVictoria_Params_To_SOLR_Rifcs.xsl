<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
    xmlns:solr="http://wiki.apache.org/solr/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    
    <xsl:strip-space elements="*" />

    <xsl:import href="PROV_SOLR_To_RIFCS_Series.xsl"/>
    <xsl:import href="PROV_SOLR_To_RIFCS_Agency.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Public Record Office Victoria'"/>
    <xsl:param name="global_group" select="'Public Record Office Victoria'"/>
    <xsl:param name="global_acronym" select="'PROV'"/>
    <xsl:param name="global_publisherName" select="'Public Record Office Victoria'"/>
    <xsl:param name="global_baseURI" select="'https://prov.vic.gov.au/archive'"/>
    <xsl:param name="global_path" select="''"/>
    
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
        <xsl:apply-templates select="metadata/solr:doc[contains(lower-case(solr:str[@name='category']), 'series')]" mode="collection">
            <xsl:with-param name="metadata_datestamp" select="header/datestamp"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="metadata/solr:doc[contains(lower-case(solr:str[@name='category']), 'agency')]" mode="party">
            <xsl:with-param name="metadata_datestamp" select="header/datestamp"/>
        </xsl:apply-templates>
    </xsl:template>
    
    
 </xsl:stylesheet>
    
