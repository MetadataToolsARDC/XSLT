<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs fn"
    version="2.0">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="relation[((count(@type) = 0) or (@type=''))]">
         <relation type="hasAssociationWith">
             <xsl:for-each select="child::*">
                 <xsl:copy-of select="."/>
             </xsl:for-each>
         </relation>
    </xsl:template>
    
    <xsl:template match="citationInfo/citationMetadata/date[(count(@dateFormat) > 0)]">
        <date>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="string-length(@type) > 0">
                        <xsl:value-of select="@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <text>publicationDate</text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:copy-of select="node()"/>
        </date>
    </xsl:template>
    
    <xsl:template match="citationInfo/citationMetadata/date[(count(@dateFormat) > 0)]">
        <date>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="string-length(@type) > 0">
                        <xsl:value-of select="@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <text>publicationDate</text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:copy-of select="node()"/>
        </date>
    </xsl:template>
    
    <xsl:template match="rights/accessRights[(count(@rightUri) > 0)]">
        <accessRights>
            <xsl:if test="string-length(@type) > 0">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length(@rightUri) > 0">
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="@rightUri"/>
                </xsl:attribute>
            </xsl:if>
        </accessRights>
    </xsl:template>
  
</xsl:stylesheet>