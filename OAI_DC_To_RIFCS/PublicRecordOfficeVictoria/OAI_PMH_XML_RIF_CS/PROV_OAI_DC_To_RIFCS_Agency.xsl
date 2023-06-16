<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xsl murFunc custom oai fn xs xsi dcterms">
	
	<xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
      
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="oai_dc:dc"  mode="party">
        
        <registryObject group="{$global_group}">
            
            <xsl:apply-templates select="dcterms:bibliographicCitation" mode="party_key"/>
            
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            
            <party>
                <xsl:attribute name="type" select="'group'"/>
                
                <xsl:attribute name="dateModified">
                    <xsl:value-of select="ancestor::oai:record/oai:header/oai:datestamp"/>
                </xsl:attribute>
                
                <!-- Do not map handles yet - until PROV advises to do so -->
                <xsl:apply-templates select="identifier.uri[not(contains(text(), 'hdl.handle'))]" mode="party_identifier"/>
                <xsl:apply-templates select="dcterms:bibliographicCitation" mode="party_identifier"/>
                
                <xsl:choose>
                    <xsl:when test="count(dcterms:bibliographicCitation) > 0">
                        <xsl:apply-templates select="dcterms:bibliographicCitation" mode="party_location_url"/>
                    </xsl:when>
                    <xsl:when test="count(identifier.uri) > 0">
                        <xsl:apply-templates select="identifier.uri" mode="party_location_url"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:apply-templates select="title" mode="party_name"/>
                
                <xsl:choose>
                    <xsl:when test="count(description) > 0">
                        <xsl:apply-templates select="description" mode="party_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(title) > 0">
                        <xsl:apply-templates select="title" mode="party_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="party_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="coverage.temporal" mode="party_coverage_temporal"/>
                
            </party>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="party_key">
        <key>
            <xsl:value-of select="concat($global_acronym, ' ', normalize-space(.))"/>
        </key>
    </xsl:template>
    
    <xsl:template match="identifier.uri" mode="party_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="party_identifier">
        <identifier type="uri">
            <xsl:value-of select="concat($global_baseURI, $global_path, replace(., ' ', ''))"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="identifier.uri" mode="party_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="party_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path, replace(., ' ', ''))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    
    
    <xsl:template match="title" mode="party_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="description" mode="party_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="title" mode="party_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template name="party_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="coverage.temporal" mode="party_coverage_temporal">
        <coverage>
            <temporal>
                <text><xsl:value-of select="normalize-space(.)"/></text>
            </temporal>
        </coverage>
    </xsl:template>
    
    
  
    
 </xsl:stylesheet>
    