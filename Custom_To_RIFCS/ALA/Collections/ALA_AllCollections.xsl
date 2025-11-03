<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:local="http://local/function" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math local xsi fn"
    version="3.0">
    
    <xsl:param name="global_group" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_acronym" select="'ALA'"/>
    <xsl:param name="global_originatingSource" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_emlNamespace" select="'eml://ecoinformatics.org/eml-2.1.1'"/>
    <xsl:param name="global_prefixURL" select="'https://collections.ala.org.au/public/show/'"/>
    <xsl:param name="global_prefixKey" select="'ala.org.au/'"/>
    <xsl:param name="global_baseURI" select="'https://collections.ala.org.au'"/>
    <xsl:param name="global_path_collection_ws" select="'/ws/collection'"/>
    <xsl:param name="serverUrl"/>
    <xsl:param name="dateCreated" />
    <xsl:param name="lastModified" />
  
  <xsl:import href="ALA_Collection_To_RIFCS.xsl"/>
  
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*" />
  
    <xsl:template match="/">
      
      <xsl:message select="concat('Getting keys from context ', node-name(.))"/>
      
       <xsl:variable name="allKeys" as="xs:string*">
         <xsl:for-each select="datasets/dataset/uid[string-length(.) > 2]">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:variable> 
      
      
      <xsl:message select="concat('Key total: ', count($allKeys))"/>
      
      
      <!-- Batch the keys in groups of 200 -->
      <xsl:for-each-group select="$allKeys" group-adjacent="(position() - 1) idiv 5">
        <xsl:variable name="batch" select="current-group()"/>
        <xsl:variable name="ts" select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]T[H01][m01]')"/>
        <xsl:variable name="filename" select="concat($ts, '-', position(), '.xml')"/>
        
        <xsl:result-document href="{$filename}" method="xml" indent="yes">
          <registryObjects
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:for-each select="$batch">
              
              <xsl:variable name="fullURL" select="concat($global_baseURI, $global_path_collection_ws, '/', .)"/>
              
              <xsl:message select="concat('Loading collection metadata from: ', $fullURL)"/>
              
              <xsl:choose>
                <xsl:when test="fn:unparsed-text-available($fullURL)">
                  
                  <xsl:variable name="unparsedJson" select="fn:unparsed-text($fullURL)"/>
                  
                  <xsl:variable name="xmlDoc" select="fn:json-to-xml($unparsedJson)"/>
                  
                  <xsl:choose>
                    <xsl:when test="not(has-children($xmlDoc))">
                      <xsl:message select="'Doc is empty'"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:message select="concat('Transforming doc and writing rif-cs to ', $filename)"/>
                        <xsl:with-param name="key" select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
                  
                  
                </xsl:when>
                <xsl:otherwise>
                  <xsl:message select="concat('No doc available at: ', $fullURL)"/>
                </xsl:otherwise>
              </xsl:choose>
              
            </xsl:for-each>
            
            
          </registryObjects>
        </xsl:result-document>
      </xsl:for-each-group>
      
      <!-- Main output: combined registryObjects -->
      <registryObjects
        xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
        
        <!--xsl:for-each select="$allTempFiles">
                <xsl:copy-of select="/*"/>
            </xsl:for-each-->
        
      </registryObjects>
      
    </xsl:template>
    
</xsl:stylesheet>
