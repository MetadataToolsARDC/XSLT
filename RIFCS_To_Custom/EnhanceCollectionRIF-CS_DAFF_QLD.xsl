<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:extRif="http://ands.org.au/standards/rif-cs/extendedRegistryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs custom extRif"
    version="2.0">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_debug" select="false()"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/rights/accessRights">
       <accessRights type="{@type}" rightsUri="{@rightUri}">
            <xsl:value-of select="text()"/>
        </accessRights>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/citationInfo/citationMetadata/date">
        <date type="{@type}">
            <xsl:value-of select="text()"/>
        </date>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/relatedInfo/relation[(count(@type) = 0) or (string-length(@type) = 0)]">
        <xsl:if test="string-length(text()) > 0">
            <relation type="{text()}"/>
        </xsl:if>
    </xsl:template>
    
        
  
    
</xsl:stylesheet>
