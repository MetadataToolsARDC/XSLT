<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:custom="http://custom.nowhere.yet">
    
    <xsl:import href="OAI_DC_To_Rifcs_LITE.xsl"/>
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Charles Darwin University'"/>
    <xsl:param name="global_group" select="'Charles Darwin University'"/>
    <xsl:param name="global_acronym" select="'CDU'"/>
    <xsl:param name="global_publisherName" select="'Charles Darwin University'"/>
    <xsl:param name="global_baseURI" select="'https://researchers.cdu.edu.au'"/>
    <xsl:param name="global_path" select="'/en/datasets/'"/>
    
    
    <!-- https://researchers.cdu.edu.au/en/datasets/508b3394-fe4f-44c3-825e-2dea803ccb6b -->
    
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:message select="concat('name(OAI-PMH): ', name(OAI-PMH))"/>
            <xsl:message select="concat('num record element: ', count(OAI-PMH/ListRecords/record))"/>
            
            <xsl:for-each select="OAI-PMH/ListRecords/record">
                <xsl:choose>
                    <xsl:when test="
                        custom:sequenceContains(header/setSpec, 'dataset') or
                        custom:sequenceContains(header/setSpec, 'software')">
                    
                        <xsl:apply-templates select="."/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="'Record skipped - not in required set'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="record">
       <xsl:variable name="metadataID">
            <xsl:choose>
                <xsl:when test="id"></xsl:when>
                <xsl:when test="contains(header/identifier, ':')">
                    <xsl:variable name="index" select="count(tokenize(header/identifier, ':'))"/>
                    <xsl:value-of select="normalize-space(tokenize(header/identifier, ':')[$index])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(header/identifier)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="boolean(string-length($metadataID))">
                <xsl:apply-templates select="metadata/oai_dc:dc" mode="collection">
                    <xsl:with-param name="metadataID" select="$metadataID"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'ERROR - Cannot create record where header identifier is missing'"/>
            </xsl:otherwise>
        </xsl:choose>
                
    </xsl:template>
    
    
</xsl:stylesheet>

