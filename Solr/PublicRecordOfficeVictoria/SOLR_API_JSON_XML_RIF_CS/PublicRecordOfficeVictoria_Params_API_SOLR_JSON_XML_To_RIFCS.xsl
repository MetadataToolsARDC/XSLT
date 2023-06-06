<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:solr="http://wiki.apache.org/solr/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    
    <!-- xpath-default-namespace="http://www.openarchives.org/OAI/2.0/" -->
    
    <xsl:strip-space elements="*" />

    <xsl:import href="PROV_SOLR_API_JSON_XML_To_RIFCS_Series.xsl"/>
    <!--xsl:import href="PROV_SOLR_To_RIFCS_Agency.xsl"/-->
    
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
            
            
            <xsl:for-each select="distinct-values(//response/docs/category)">
                <xsl:message select="concat('category: ', .)"/>
            </xsl:for-each>
            <xsl:message select="concat('Total: ', count(//response/docs))"/>
            <xsl:message select="concat('Total series: ', count(//response/docs[category='Series']))"/>
            <xsl:message select="concat('Total series: ', count(//response/docs[category='relatedEntity']))"/>
            <xsl:apply-templates select="//response/docs[contains(lower-case(category), 'series')]" mode="collection"/>
            
        </registryObjects>
    </xsl:template>
    
   
 </xsl:stylesheet>
    
