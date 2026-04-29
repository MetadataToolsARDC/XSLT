<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:custom="http://custom.nowhere.yet">
    
    <xsl:import href="OAI_DC_To_Rifcs_LITE.xsl"/>
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Charles Darwin University'"/>
    <xsl:param name="global_group" select="'Charles Darwin University'"/>
    <xsl:param name="global_acronym" select="'CDU'"/>
    <xsl:param name="global_publisherName" select="'Charles Darwin University'"/>
    <xsl:param name="global_baseURI" select="'https://researchers.cdu.edu.au'"/>
    <xsl:param name="global_path" select="'/en/datasets/'"/>
    
    
    <!-- https://researchers.cdu.edu.au/en/datasets/508b3394-fe4f-44c3-825e-2dea803ccb6b -->
    
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:message select="concat('name(OAI-PMH): ', name(OAI-PMH))"/>
            <xsl:message select="concat('num record element: ', count(OAI-PMH/ListRecords/record))"/>
            
            <xsl:for-each select="OAI-PMH/ListRecords/record">
                <xsl:choose>
                    <xsl:when test="
                        custom:sequenceContains(header/setSpec, 'dataset') or
                        custom:sequenceContains(header/setSpec, 'software')">
                    
                        <xsl:apply-templates select="."/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="'Record skipped - not in required set'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="record">
       <xsl:variable name="metadataID">
            <xsl:choose>
                <xsl:when test="id"></xsl:when>
                <xsl:when test="contains(header/identifier, ':')">
                    <xsl:variable name="index" select="count(tokenize(header/identifier, ':'))"/>
                    <xsl:value-of select="normalize-space(tokenize(header/identifier, ':')[$index])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(header/identifier)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="boolean(string-length($metadataID))">
                <xsl:apply-templates select="metadata/oai_dc:dc" mode="collection">
                    <xsl:with-param name="metadataID" select="$metadataID"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'ERROR - Cannot create record where header identifier is missing'"/>
            </xsl:otherwise>
        </xsl:choose>
                
    </xsl:template>
    
    <!-- Override for CDU -->
    
    <xsl:template match="dct:license" mode="collection_rights_license">
        <rights>
            <licence>
               <xsl:if test="string-length(normalize-space(substring-after(.,'/dk/atira/pure/dataset/documentlicenses/'))) > 0">
                   <xsl:attribute name="type">
                    <xsl:value-of select="substring-before(substring-after(normalize-space(.), '/dk/atira/pure/dataset/documentlicenses/'), ';')"/>
                   </xsl:attribute>
               </xsl:if>
                
               <xsl:choose>
                   <xsl:when test="string-length(substring-after(.,'name=')) > 0">
                       <xsl:value-of select="normalize-space(substring-after(.,'name='))"/>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="normalize-space(.)"/>
                   </xsl:otherwise>
               </xsl:choose>
            </licence>
        </rights>
    </xsl:template>
    
    <!-- Override for CDU - map raid to related even though provided as if identifier of this record -->
    
    <xsl:template match="dc:identifier" mode="collection_identifier_raid">
        <relatedInfo type="activity">
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:choose>
                    <xsl:when test="starts-with(. , '10.')">
                        <xsl:value-of select="concat('http://raid.org/', .)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </identifier>    
            <relation type="isOutputOf"/>
        </relatedInfo>
    </xsl:template>
    
    
    <xsl:template match="dc:creator | dc:contributor" mode="collection_relatedInfo">
        <relatedInfo type="party">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(substring-after(.,'id_orcid'))) > 0">
                    <identifier type="'orcid'">
                        <xsl:value-of select="normalize-space(substring-after(.,'id_orcid'))"/>
                    </identifier>
                </xsl:when>
                <xsl:when test="string-length(normalize-space(substring-after(.,'id_ror'))) > 0">
                    <identifier type="'orcid'">
                        <xsl:value-of select="normalize-space(substring-after(.,'id_ror'))"/>
                    </identifier>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="collection_relatedInfo_identifier_fromName"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <title>
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(substring-before(.,'; id_orcid'))) > 0">
                        <xsl:value-of select="substring-before(normalize-space(.), '; id_orcid')"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space(substring-before(.,'; id_ror'))) > 0">
                        <xsl:value-of select="substring-before(normalize-space(.), '; id_ror')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </title>
            <relation>
                <xsl:choose>
                    <xsl:when test="local-name() = 'creator'">
                        <xsl:attribute name="type">
                            <xsl:text>hasCollector</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:text>hasAssociationWith</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </relation> 
        </relatedInfo>
    </xsl:template>
    
    <!-- Override for CDU -->
    
    <xsl:template match="dc:description" mode="collection_description_full">
        
        <xsl:variable name="position" select="count(preceding-sibling::dc:description) + 1"/>
        
        <xsl:choose>
            <xsl:when test="$position = 1">
                <name type="alternative">
                    <namePart>
                        <xsl:value-of select="normalize-space(.)"/>
                    </namePart>
                </name>
                <description type="brief">
                    <xsl:value-of select="normalize-space(.)"/>
                </description>
            </xsl:when>
            <xsl:when test="$position = 2">
                <description type="full">
                    <xsl:value-of select="normalize-space(.)"/>
                </description>
            </xsl:when>
            <xsl:when test="$position = 3">
                <description type="notes">
                    <xsl:value-of select="normalize-space(.)"/>
                </description>
            </xsl:when>
            <xsl:when test="$position = 4">
                <description type="notes">
                    <xsl:value-of select="normalize-space(.)"/>
                </description>
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
   
    
    <!-- Override for CDU -->
    
    <xsl:template match="dc:rights" mode="collection_rights_rightsStatement">
        <rights>
            <xsl:choose>
                 <xsl:when test="contains(lower-case(.), 'openaccess')">
                    <accessRights type="open"/>
                </xsl:when>
                <xsl:when test="contains(lower-case(.), 'closedcccess')">
                    <accessRights type="restricted"/>
                </xsl:when>
                <xsl:when test="contains(lower-case(.), 'embargoedaccess')">
                    <accessRights type="restricted"/>
                </xsl:when>
                
            </xsl:choose>
            
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>

        
    </xsl:template>
    
    
    
</xsl:stylesheet>

