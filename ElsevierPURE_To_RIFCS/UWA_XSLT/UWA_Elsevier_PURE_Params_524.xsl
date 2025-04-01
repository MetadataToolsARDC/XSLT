<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="xs xsl">
    
    <xsl:import href="Elsevier_PURE_API524_rifcs.xsl"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'University of Western Australia'"/>
    <xsl:param name="global_baseURI" select="'research-repository.uwa.edu.au'"/>
    <xsl:param name="global_path" select="'/en/'"/>
    <xsl:param name="global_acronym" select="'UWA_PURE'"/>
    <xsl:param name="global_group" select="'The University of Western Australia'"/>
    <xsl:param name="global_publisherName" select="'University of Western Australia'"/>
    <xsl:param name="global_validateWorkflow" select="true()"/>
    
    <!--Override for Equipment UWA -->
    
    <xsl:template match="equipment" mode="object_linkHandler">
        <xsl:apply-templates select="webAddresses/webAddress" mode="equipment_relatedInfo"/>
    </xsl:template>
   
    <!-- Unique to this xsl - not an override -->
    <xsl:template match="webAddress" mode="equipment_relatedInfo">
        <xsl:choose>
            <xsl:when test="contains(lower-case(type/term/text) , 'doi')">
                <identifier type="doi">
                    <xsl:apply-templates select="value/text/text()"/>
                </identifier>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="object_relatedInfo"/> <!-- Calls default in core -->
            </xsl:otherwise>
        </xsl:choose>           
    </xsl:template>
    
  
 
</xsl:stylesheet>