<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="schemadotorg2rif_updated"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:import href="schemadotorg2rif_updated.xsl"/>
    
    <xsl:param name="originatingSource" select="'RAiD AU'"/>
    <xsl:variable name="group" select="'RAiD AU'"/>
    <xsl:param name="groupAcronym" select="'RAiD_AU'"/> 
    <xsl:param name="prefixKeyWithGroup" select="false()"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <!-- Some of the RAiDs don't have "Project" in their ResourceTypeGeneral yet,
        but we know we are dealing with RAiDs here, so let's just set this correctly
        even if we get nonsense-->
    
    <xsl:function name="local:getTypeAndSubType" as="xs:string*">
        <xsl:param name="sourceType"/>
        
        <xsl:choose>
            <xsl:when test="'project' = translate($sourceType, 'PROJECT', 'project')">
                <xsl:value-of select="'activity'"/>
                <xsl:value-of select="'project'"/>
            </xsl:when>
           <xsl:when test="'project' = translate($sourceType, 'RAID', 'raid')">
                <xsl:value-of select="'activity'"/>
                <xsl:value-of select="'project'"/>
            </xsl:when>
            <xsl:when test="'researchproject' = translate($sourceType, 'RESEARCHPROJECT', 'researchproject')">
                <xsl:value-of select="'activity'"/>
                <xsl:value-of select="'project'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'activity'"/>
                <xsl:value-of select="'project'"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    
   
</xsl:stylesheet>
