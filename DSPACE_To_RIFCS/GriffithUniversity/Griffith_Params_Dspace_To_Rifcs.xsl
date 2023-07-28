<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://www.lyncode.com/xoai" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:import href="DSPACE_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Griffith University'"/>
    <xsl:param name="global_group" select="'Griffith University'"/>
    <xsl:param name="global_acronym" select="'GU'"/>
    <xsl:param name="global_publisherName" select="'Griffith University'"/>
    <xsl:param name="global_baseURI" select="'https://research-repository.griffith.edu.au'"/>
    <xsl:param name="global_path" select="'/handle/10072/'"/>
    
    <!-- overrides -->
    <!--xsl:template match="dc:source" mode="collection_citation_info">
       
    </xsl:template-->  
    
</xsl:stylesheet>
    
