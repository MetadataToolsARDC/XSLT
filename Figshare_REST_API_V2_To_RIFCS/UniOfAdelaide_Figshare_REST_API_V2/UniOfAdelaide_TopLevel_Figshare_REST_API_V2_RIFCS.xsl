<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="xsl xs">
    <xsl:import href="Figshare_REST_API_V2_RIFCS.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of Adelaide Figshare'"/>
    <xsl:param name="global_baseURI" select="'http://figshare.com'"/> <!-- Set to prod even though sometimes we will run this against test - used to construct author url -->
    <xsl:param name="global_group" select="'The University of Adelaide'"/>
    <xsl:param name="global_key_source_prefix" select="'oai:figshare.com:article/'"/> <!-- mocking this up so that the keys end up the same even though we aren't getting from oai-pmh anymore -->
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:apply-templates select="datasets/dataset" mode="registry_object"/>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="custom_fields[contains(lower-case(name), 'contributor') and contains(value, 'ror.org')]" mode="collection_custom_handling">
        <xsl:message select="'Handling custom fields where: name contains [contributor]; AND value contains ror.org - University of Adelaide Figshare'"/>
        <relatedInfo type="party">
            <identifier type="ror">
                <xsl:value-of select="value"/>
            </identifier>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="custom_fields[not(contains(lower-case(name), 'contributor')) or not(contains(value, 'ror.org'))]" mode="collection_custom_handling">
        <xsl:message select="'No handling in place for custom fields where: name does not contain [contributor]; OR value does not contain [ror.org] - University of Adelaide Figshare'"></xsl:message>
    </xsl:template>   
    
</xsl:stylesheet>

