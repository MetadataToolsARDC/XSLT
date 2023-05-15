<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:extRif="http://ands.org.au/standards/rif-cs/extendedRegistryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs custom extRif"
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
    
</xsl:stylesheet>
