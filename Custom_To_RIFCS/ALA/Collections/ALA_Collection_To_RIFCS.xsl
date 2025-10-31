<xsl:stylesheet 
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:local="http://local/function" 
    exclude-result-prefixes="xs math local xsi"
    version="3.0">
    
    <xsl:param name="global_group" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_acronym" select="'ALA'"/>
    <xsl:param name="global_originatingSource" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_prefixURL" select="'https://collections.ala.org.au/public/show/'"/>
    <xsl:param name="global_prefixKey" select="'ala.org.au/'"/>
    <xsl:param name="serverUrl"/>
    <xsl:param name="dateCreated" />
    <xsl:param name="lastModified" />
    
    <xsl:variable name="rifcsVersion" select="1.6"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*" />
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:variable name="key" as="xs:string">
                <xsl:value-of select="map/string[@key='uid']"/>
            </xsl:variable>
            <xsl:apply-templates select="/*" mode="process">
                <xsl:with-param name="key" select="$key"/>
            </xsl:apply-templates>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="map" mode="process">
        <xsl:param name="key"/>
        <xsl:message select="concat('ALA source has children count:', has-children(.))"/>
        
        <registryObject group="$global_group">
            
            <key>
                <xsl:value-of select="$key"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            
            <collection type="collection">
                
                <identifier type="url">
                    <xsl:value-of select="concat($global_prefixURL, $key)"/>
                </identifier>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="string[@key='name']"/>
                    </namePart>
                </name>
                
                <description type="brief">
                    <xsl:value-of select="string[@key='pubDescription']"/>
                </description>
                
            </collection>
            
        </registryObject>
    </xsl:template>
    
   
    
    
</xsl:stylesheet>    