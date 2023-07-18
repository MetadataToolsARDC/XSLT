<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rif="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:oai="http://www.openarchives.org/OAI/2.0/" version="2.0">
    
    <xsl:variable name="trove_url" select="'http://api.trove.nla.gov.au'"/>
    <xsl:variable name="api_key" select="'&amp;key=6pq1vkvq9hbljnv6'"/>
    <xsl:variable name="searchparams" select="'/result?zone=article&amp;include=workversions&amp;q=au-research%2Fgrants%2Fnhmrc&amp;n=100&amp;s=0'"/>

    
    <xsl:template match='/'>
        <xsl:variable name="trove_response" select="document(concat($trove_url,$searchparams, $api_key))"/>
        <xsl:element name="troveGrants">
            <xsl:apply-templates select="zone"/>
            <xsl:for-each select="$trove_response">
            <xsl:apply-templates select="response"/>
            <xsl:apply-templates select="response/zone/records" mode="nextRequest"/>
        </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="records" mode="nextRequest">
        <xsl:choose>
            <xsl:when test="@next != ''">
                <xsl:message>Getting next document<xsl:value-of select="@next"/></xsl:message>
                <xsl:variable name="trove_response" select="document(concat($trove_url,@next, $api_key))"/>
                <xsl:message><xsl:value-of select="concat($trove_url,@next)"/></xsl:message>
                <xsl:for-each select="$trove_response">
                    <xsl:apply-templates select="response"/>
                    <xsl:apply-templates select="response/zone/records" mode="nextRequest"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>no more records</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="/response">
        <xsl:apply-templates select="zone"/>
    </xsl:template>
    
    <xsl:template match="zone[records/@n !=0]">
        <xsl:message><xsl:text>zone is </xsl:text><xsl:value-of select="@name"/><xsl:value-of select="records/@n"/></xsl:message>
        <xsl:apply-templates select="records/work"/>
    </xsl:template>
    
    <xsl:template match="work">
        <xsl:message><xsl:text>work is </xsl:text><xsl:value-of select="title"/></xsl:message>
        <xsl:apply-templates select="version/record/metadata"/>
    </xsl:template>
    
    <xsl:template match="metadata">
        <xsl:message><xsl:text>Metadata for </xsl:text><xsl:value-of select=".//title"/></xsl:message>
        <xsl:variable name="title" select=".//title"/>
        <xsl:variable name="identifier" select=".//identifier[contains(text(),'http://')]"/>
        <xsl:variable name="bibnotes" select=".//bibliographicCitation"/>
        <xsl:variable name="notes" select=".//description"/>
        <xsl:for-each select=".//relation[contains(text(),'au-research/grants')]">
            <xsl:text>&#xA;</xsl:text>
            <xsl:element name="grantPubInfo">
                <xsl:text>&#xA;</xsl:text>
                <xsl:element name="grantKey"><xsl:value-of select="replace(normalize-space(.),'NHMRC','nhmrc')"/></xsl:element>
                <xsl:text>&#xA;</xsl:text>
                <xsl:element name="relatedInfo">
                    <xsl:attribute name="type"><xsl:text>publication</xsl:text></xsl:attribute> 
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="title"><xsl:value-of select="$title"/></xsl:element>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="identifier">
                        <xsl:attribute name="type"><xsl:text>URI</xsl:text></xsl:attribute>
                        <xsl:value-of select="$identifier[position()=1]"/>
                    </xsl:element>
                </xsl:element>
                <xsl:text>&#xA;</xsl:text>
            </xsl:element>
            <xsl:text>&#xA;</xsl:text>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="*"/>
      
</xsl:stylesheet>