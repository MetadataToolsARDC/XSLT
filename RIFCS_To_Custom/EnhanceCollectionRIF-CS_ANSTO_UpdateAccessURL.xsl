<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs fn"
    version="2.0">
    
    <xsl:param name="global_baseLocationURL" select="'https://neutron.ansto.gov.au/Bragg/proposal/ProposalView.jsp?id='"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/location/address/electronic[@type='url']/value">
        <xsl:variable name="id_formatted" select="ancestor::collection/identifier" as="xs:string"/>
        <xsl:variable name="url" select="concat($global_baseLocationURL, $id_formatted)"/>
        <!--xsl:message select="concat('Text available at ', $url, ' - ', fn:unparsed-text-available($url))"></xsl:message-->
        <!--xsl:message select="concat('Applying modified url ', $url)"></xsl:message-->
        <value>
            <xsl:value-of select="$url"/>
        </value>
    </xsl:template>
    
</xsl:stylesheet>