<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://wiki.apache.org/solr/"
    exclude-result-prefixes="xsl murFunc custom oai fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
      
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="doc"  mode="party">
        <xsl:param name="metadata_datestamp"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <!-- Generate key from doi if there is one (this means key will stay the same in future harvests even if harvest api or source xml changes form-->
            <xsl:apply-templates select="str[@name='citation']" mode="party_key"/>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="party">
                
                <xsl:attribute name="type">
                    <xsl:value-of select="'group'"/>
                </xsl:attribute>
                
                <xsl:apply-templates select="$metadata_datestamp" mode="date_modified"/>
                
                <xsl:apply-templates select="str[@name='identifier.PROV_ACM.id']" mode="party_identifier"/>
                
                <xsl:apply-templates select="str[@name='series_id']" mode="party_identifier"/>
                
                <xsl:apply-templates select="str[@name='citation'][1]" mode="party_location_url"/>
                
                <xsl:apply-templates select="str[@name='title']" mode="party_name"/>
                
                <xsl:apply-templates select="str[@name='description']" mode="party_description_full"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="*" mode="party_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="str" mode="party_key">
        <key>
            <xsl:value-of select="concat($global_acronym, ' ', normalize-space(.))"/>
        </key>
    </xsl:template>
    
    <xsl:template match="str" mode="party_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="str" mode="party_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, '/', replace(., ' ', ''))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="str" mode="party_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="str" mode="party_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="reference_number" mode="party_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
  
    
 </xsl:stylesheet>
    