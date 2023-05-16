<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:extRif="http://ands.org.au/standards/rif-cs/extendedRegistryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs extRif"
    version="2.0">
    
    <xsl:param name="global_baseLocationURL" select="'https://prov.vic.gov.au/archive/'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="registryObject/*/location/address/electronic/value">
        <value>
            <xsl:value-of select="concat($global_baseLocationURL, substring-after(replace(ancestor::registryObject/key, ' ', ''), 'PROV'))"/>
        </value>
    </xsl:template>
    
    <xsl:template match="registryObject/*/relatedInfo[@type='website']">
        <relatedInfo type="'website'">
            <identifier type="uri">
               <xsl:choose>
                   <!-- If we get something like:
                        http://www.access.prov.vic.gov.au/public/component/daPublicBaseContainer?component=daViewAgency&amp;breadcrumbPath=Home/Access%20the%20Collection/Browse%20The%20Collection/Agency%20Details&amp;entityId=5228
                    ... Replace it with something like https://prov.vic.gov.au/archive/VA5228  -->
                    <xsl:when test="contains(identifier, 'component=daViewAgency') and contains(identifier, 'entityId=')">
                        <xsl:value-of select="concat($global_baseLocationURL, 'VA', substring-after(identifier, 'entityId='))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="identifier"/>
                    </xsl:otherwise>
                </xsl:choose>
            </identifier>
        </relatedInfo>
    </xsl:template>
    
</xsl:stylesheet>
