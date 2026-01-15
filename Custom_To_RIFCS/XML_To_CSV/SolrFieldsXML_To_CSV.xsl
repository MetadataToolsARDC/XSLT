<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >
    
    <xsl:param name="columnSeparator" select="'|'" />
    <xsl:param name="rowSeparator" select="'&#xA;'" />
    
    <xsl:template match="/">
        <xsl:call-template name="columnHeaders"/>
        <xsl:apply-templates select="response/arr/lst" />
    </xsl:template>
    
    <xsl:template match="lst">
        <xsl:value-of select="str[@name='name']"/><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="str[@name='type']"/><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="bool[@name='docValues']"/><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="bool[@name='multiValued']"/><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="bool[@name='indexed']"/><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="bool[@name='stored']"/><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="$rowSeparator" />
    </xsl:template>
    
    <xsl:template name="columnHeaders">
        
        <xsl:text>name</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>type</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>docValues</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>multiValued</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>indexed</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>stored</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:value-of select="$rowSeparator" />
    </xsl:template>
    
    
</xsl:stylesheet>
