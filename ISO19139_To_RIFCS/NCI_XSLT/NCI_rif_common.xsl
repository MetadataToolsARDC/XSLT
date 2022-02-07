<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts custom customGMD">
    
   
    <xsl:template match="gmd:resourceSpecificUsage" mode="registryObject_relatedInfo_sourceMetadata">
        <xsl:for-each select="gmd:MD_Usage">
            <xsl:if test="string-length(gmd:nci_source_id) > 0">
                <relatedInfo type="collection">
                    <identifier type="global">
                        <xsl:value-of select="gmd:nci_source_id"/>
                    </identifier>
                    <relation type="isDerivedFrom">
                        <xsl:if test="string-length(gmd:nci_source_provider) > 0">
                            <description>
                                <xsl:value-of select="concat('Source resource link from ', gmd:nci_source_provider)"/>
                            </description>
                        </xsl:if>
                        <xsl:if test="string-length(gmd:nci_data_link) > 0">
                            <url>
                                <xsl:value-of select="gmd:nci_data_link"/>
                            </url>
                        </xsl:if>
                    </relation>
                    <xsl:if test="string-length(gmd:nci_source_provider) > 0">
                        <title>
                            <xsl:value-of select="concat('Resource provided by ', gmd:nci_source_provider)"/>
                        </title>
                    </xsl:if>
                </relatedInfo>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>
