<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:custom="http://nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
    <xsl:param name="entitySeparator" select="'*'"/>
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    
    <xsl:param name="RDA_Record_PID" select="'https://researchdata.edu.au/view/?key='"/>
    
    <xsl:param name="output_key" select="true()" as="xs:boolean"/>
    <xsl:param name="output_name" select="true()" as="xs:boolean"/>
    <xsl:param name="output_publisher" select="true()" as="xs:boolean"/>
    <xsl:param name="output_location" select="true()" as="xs:boolean"/>
    <xsl:param name="output_relatedInfo" select="false()" as="xs:boolean"/>
    <xsl:param name="output_relatedInfo_blob" select="true()" as="xs:boolean"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()[ancestor::field and not(self::text())]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="/">
        
        <xsl:call-template name="columnHeaders"/>
        <xsl:apply-templates select="//registryObject"/>
        
       
    </xsl:template>
    
    <xsl:template name="columnHeaders">
        
        <xsl:if test="$output_key">
            <xsl:call-template name="columnHeaders_key"/>
        </xsl:if>
        
        <xsl:if test="$output_name">
            <xsl:call-template name="columnHeaders_name"/>
        </xsl:if>
        
        <xsl:if test="$output_publisher">
            <xsl:call-template name="columnHeaders_publisher"/>
        </xsl:if>
        
        <xsl:if test="$output_location">
            <xsl:call-template name="columnHeaders_location"/>
        </xsl:if>
        
        <xsl:if test="$output_relatedInfo">
            <xsl:call-template name="columnHeaders_relatedInfo"/>
        </xsl:if>
        
        <xsl:if test="$output_relatedInfo_blob">
            <xsl:call-template name="columnHeaders_relatedInfo_blob"/>
        </xsl:if>
        
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    <xsl:template match="registryObject">
        
        <xsl:if test="$output_key">
            <xsl:apply-templates select="." mode="output_key"/>
        </xsl:if>
        
        <xsl:if test="$output_name">
            <xsl:apply-templates select="." mode="output_name"/>
        </xsl:if>
        
        <xsl:if test="$output_publisher">
            <xsl:apply-templates select="." mode="output_publisher"/>
        </xsl:if>
        
        <xsl:if test="$output_location">
            <xsl:apply-templates select="." mode="output_location"/>
        </xsl:if>
        
        <xsl:if test="$output_relatedInfo">
            <xsl:apply-templates select="./*/*:relatedInfo" mode="output_relatedInfo"/>
        </xsl:if>
        
        <xsl:if test="$output_relatedInfo_blob">
            <xsl:apply-templates select="collection | service | activity" mode="output_relatedInfo_blob"/>
        </xsl:if>
        
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    <xsl:template name="columnHeaders_key">
        
        <xsl:text>key</xsl:text><xsl:value-of select="$columnSeparator"/>
   
    </xsl:template>
    
    <xsl:template name="columnHeaders_name">
        
        <xsl:text>name</xsl:text><xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template name="columnHeaders_publisher">
        
        <xsl:text>publisher</xsl:text><xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template name="columnHeaders_location">
        
        <xsl:text>location</xsl:text><xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template name="columnHeaders_relatedInfo">
        
        <xsl:text>type</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>title</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>identifier</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>relation</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>url_dataset_description</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>url_dataset</xsl:text><xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template name="columnHeaders_relatedInfo_blob">
        
        <xsl:text>relatedInfoBlob</xsl:text><xsl:value-of select="$columnSeparator"/>
    
    </xsl:template>
    
    <xsl:template match="registryObject" mode="output_key">
        
        <!--	column: key  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat($RDA_Record_PID, key)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
  </xsl:template>
    
    <xsl:template match="registryObject" mode="output_name">
        
        <!--	column: name  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="*/name[@type='primary']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template match="registryObject" mode="output_publisher">
        
        <!--	column: publisher  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(*/citationInfo/citationMetadata/publisher)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template match="registryObject" mode="output_location">
        
        <!--	column: location  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(*/location/address/electronic/value)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    
    <xsl:template match="relatedInfo" mode="output_relatedInfo">
       
        <!--	column: type  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: title  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(title)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="identifier"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: relation -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="relation/@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: url_description -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(relation/description)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: url_dataset -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(relation/url)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
    <xsl:template match="collection | activity | service" mode="output_relatedInfo_blob">
        
        <!--	column: relatedInfoBlob  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:apply-templates select="relatedInfo" mode="output_relatedInfo_string"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        
        
    </xsl:template>
    
    <xsl:template match="relatedInfo" mode="output_relatedInfo_string">
        
        <!--	column: type  -->
        <xsl:value-of select="@type"/>
        <xsl:value-of select="$valueSeparator"/>
      
        <!--	column: title  -->
        <xsl:value-of select="normalize-space(title)"/>
        <xsl:value-of select="$valueSeparator"/>
        
        <!--	column: identifier  -->
        <xsl:value-of select="identifier"/>
        <xsl:value-of select="$valueSeparator"/>
        
        <!--	column: relation -->
        <xsl:value-of select="relation/@type"/>
        <xsl:value-of select="$valueSeparator"/>
        
        <!--	column: url_description -->
        <xsl:value-of select="normalize-space(relation/description)"/>
        <xsl:value-of select="$valueSeparator"/>
        
        <!--	column: url_dataset -->
        <xsl:value-of select="normalize-space(relation/url)"/>
        <xsl:value-of select="$valueSeparator"/>
        
        <xsl:value-of select="$entitySeparator"/>
        
    </xsl:template>
    
</xsl:stylesheet>
