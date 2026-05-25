<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="schemadotorg2rif_updated"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--xsl:import href="schemadotorg2rif.xsl"/-->
    <xsl:import href="schemadotorg2rif_updated.xsl"/>
    
    <xsl:param name="originatingSource" select="'RAiD AU'"/>
    <xsl:variable name="group" select="'RAiD AU'"/>
    <xsl:param name="groupAcronym" select="'RAiD_AU'"/> 
    <xsl:param name="prefixKeyWithGroup" select="false()"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    
    <xsl:template match="alternateName">
        <xsl:element name="name">
            <xsl:attribute name="type">
                <xsl:text>alternative</xsl:text>
            </xsl:attribute>
            <xsl:element name="namePart">
                <xsl:choose>
                    <xsl:when test="contains(., 'localhost:8080')">
                        <xsl:value-of select="replace(normalize-space(.), 'localhost:8080', 'raid.org')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template name="resultFromXPATH" as="node()*">
        <xsl:param name="xpathString" as="xs:string"/>
        
        <xsl:message select="concat('RAiD top level resultFromXPATH:', $xpathString)"/>
        
        <xsl:variable name="resultNodes" as="node()*">
            <xsl:evaluate xpath="$xpathString" as="node()*" context-item="."/>
        </xsl:variable>
        
        <xsl:for-each select="$resultNodes">
            
            <xsl:if test="(string-length(url) > 0) or ((string-length(value) > 0) and not(ends-with(value, ':')))">
                
                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:variable name="sourceType" select="normalize-space(propertyID)"/>
                        <xsl:choose>
                            <xsl:when test="string-length($sourceType) > 0">
                                <xsl:choose>
                                    <xsl:when test="contains($sourceType, '/')">
                                        <xsl:variable name="index" select="count(tokenize($sourceType, '/'))" as="xs:integer"/>
                                        <xsl:value-of select="tokenize($sourceType, '/')[$index]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$sourceType"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="string-length(url) > 0">
                            <xsl:apply-templates select="url/text()"/>
                        </xsl:when>
                        <xsl:when test="(string-length(value) > 0) and not(ends-with(value, ':'))">
                            <xsl:choose>
                                <xsl:when test="contains(value, 'localhost:8080')">
                                    <xsl:value-of select="replace(normalize-space(value), 'localhost:8080', 'raid.org')"/>
                                </xsl:when>
                                 <xsl:otherwise>
                                     <xsl:value-of select="normalize-space(value)"/>
                                 </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
