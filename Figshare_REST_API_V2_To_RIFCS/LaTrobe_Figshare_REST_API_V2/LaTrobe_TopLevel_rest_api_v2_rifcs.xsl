<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="xsl">
    <xsl:import href="Figshare_REST_API_V2_RIFCS"/>
    
    <xsl:param name="global_originatingSource" select="'La Trobe University'"/>
    <xsl:param name="global_baseURI" select="'http://figshare.com'"/> <!-- Set to prod even though sometimes we will run this against test - used to construct author url -->
    <xsl:param name="global_group" select="'La Trobe University'"/>
    <xsl:param name="global_key_source_prefix" select="'oai:figshare.com:article/'"/> <!-- mocking this up so that the keys end up the same even though we aren't getting from oai-pmh anymore -->
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:apply-templates select="datasets/dataset" mode="registry_object"/>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="custom_fields[contains(name, 'Contributor nameIdentifier') and contains(value, 'ror')]" mode="collection_custom_handling">
        <xsl:message select="concat('Handling custom fields where name is [Contributor nameIdentifier]', $global_group)"/>
        <relatedInfo type="party">
            <identifier type="ror">
               <xsl:value-of select="value"/>
            </identifier>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="custom_fields" mode="collection_custom_handling">
        <xsl:message select="concat('Handling custom fields where name is not [Contributor nameIdentifier] ', $global_group)"></xsl:message>
    </xsl:template>    
    
</xsl:stylesheet>

