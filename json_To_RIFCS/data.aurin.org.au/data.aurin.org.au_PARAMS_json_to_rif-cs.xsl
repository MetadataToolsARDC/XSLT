<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    <!-- stylesheet to convert data.aurin.gov.au xml (transformed from json with python script) to RIF-CS -->
    <xsl:import href="CKAN_json_to_rif-cs.xsl"/>

    <xsl:strip-space elements="*"/>
    <xsl:param name="global_originatingSource" select="'http://data.aurin.org.au'"/>
    <xsl:param name="global_baseURI" select="'http://data.aurin.org.au/'"/>
    <xsl:param name="global_dataset_path" select="'dataset/'"/>
    <xsl:param name="global_organization_path" select="'organization/'"/>
    <xsl:param name="global_acronym" select="'AURIN'"/>
    <xsl:param name="global_group" select="'Australian Urban Research Infrastructure Network (AURIN)'"/>
    <xsl:param name="global_contributor" select="'data.aurin.org.au'"/>
    <xsl:param name="global_publisherName" select="'data.aurin.org.au'"/>
    <xsl:param name="global_publisherPlace" select="'Australia'"/>
    <xsl:param name="global_includeDownloadLinks" select="false()"/>
    
    <xsl:template match="/">
        <!-- include all records except those with scopecode 'Document'-->
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//result/results" mode="all"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="results"  mode="extras">
        <xsl:message select="'Template extras override in top-level custom xslt'"/>
        <xsl:for-each select="extras">
            <xsl:message select="concat('Found extra: ', key)"/>
            <xsl:apply-templates select=".[contains(lower-case(key), 'spatial')]" mode="spatial"/>
            <xsl:apply-templates select=".[contains(lower-case(key), 'coordinate ref. system')]" mode="CRS"/>
            <xsl:apply-templates select=".[contains(lower-case(key), 'copyright notice')]" mode="copyright"/>
            <xsl:apply-templates select=".[contains(lower-case(key), 'access level')]" mode="access_rights"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="extras" mode="spatial">
        <xsl:for-each select="value">
            <xsl:call-template name="spatial_coordinates"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="extras" mode="CRS">
        <xsl:for-each select="value">
        <coverage>
            <spatial type="text">
                <xsl:value-of select="."/>
            </spatial>
        </coverage>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="extras" mode="copyright">
        <xsl:for-each select="value">
            <rights>
                <rightsStatement>
                    <xsl:value-of select="."/>
                </rightsStatement>
            </rights>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="extras" mode="access_rights">
        <xsl:for-each select="value">
            <xsl:choose>
                <xsl:when test="contains(lower-case(.), 'open')">
                    <rights>
                        <accessRights>
                            <xsl:attribute name="type">
                                <xsl:text>open</xsl:text>
                            </xsl:attribute>
                        </accessRights>
                    </rights>
                </xsl:when>
                <xsl:when test="contains(lower-case(.), 'restricted')">
                    <rights>
                        <accessRights>
                            <xsl:attribute name="type">
                                <xsl:text>restricted</xsl:text>
                            </xsl:attribute>
                        </accessRights>
                    </rights>
                </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
    </xsl:template>
        

    
</xsl:stylesheet>
