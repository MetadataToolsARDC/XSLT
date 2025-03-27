<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:datacite_kernel_4="http://datacite.org/schema/kernel-4"
    exclude-result-prefixes="xsl custom oai fn xs xsi">
    
    <xsl:import href="DataCite_Kernel4_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of Southern Queensland'"/>
    <xsl:param name="global_group" select="'University of Southern Queensland'"/>
    <xsl:param name="global_acronym" select="'UniSQ'"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_project_identifier_strings" select="'raid'" as="xs:string*"/>
    <xsl:param name="global_create_and_relate_party_missing_identifier" select="true()"/>
    <xsl:param name="global_create_and_relate_activity_missing_identifier" select="false()"/>
    

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
  
    <xsl:template match="oai:record">
        <!-- astrix below to apply to any version of oai_datacite, 
            but switch later on datacita schema itself where necessary -->
        <xsl:variable name="recordID_stub">
            <xsl:choose>
                <xsl:when test="contains(oai:header/oai:identifier, ':') and not(fn:ends-with(oai:header/oai:identifier, ':'))">
                    <xsl:value-of select="fn:tokenize(oai:header/oai:identifier, ':')[last()]"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message select="concat('name: ', fn:namespace-uri(oai:metadata/*:oai_datacite/*:payload/*:resource))"/>
        <xsl:apply-templates select="oai:metadata/*:oai_datacite/*:payload/datacite_kernel_4:resource" mode="datacite_4_to_rifcs_collection">
            <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            <xsl:with-param name="dateModified" select="oai:header/oai:datestamp"/>
            <xsl:with-param name="recordIdentifier" select="$recordID_stub"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="//oai:metadata/*:oai_datacite/*:payload/datacite_kernel_4:resource/datacite_kernel_4:contributors/datacite_kernel_4:contributor" mode="datacite_4_to_rifcs_party">
            <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            <!--xsl:with-param name="dateModified" select="oai:header/oai:datestamp"/-->
        </xsl:apply-templates>
        
        <xsl:apply-templates select="//oai:metadata/*:oai_datacite/*:payload/datacite_kernel_4:resource/datacite_kernel_4:creators/datacite_kernel_4:creator" mode="datacite_4_to_rifcs_party">
            <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            <!--xsl:with-param name="dateModified" select="oai:header/oai:datestamp"/-->
        </xsl:apply-templates>
        
    </xsl:template>
    
   
    
</xsl:stylesheet>
    