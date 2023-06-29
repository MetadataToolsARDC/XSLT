<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xsl murFunc custom oai fn xs xsi dcterms">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
      
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    
    
    <xsl:template match="oai_dc:dc"  mode="collection">
        
        <xsl:variable name="class">
            <xsl:value-of select="'collection'"/>
        </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            
            <xsl:apply-templates select="dcterms:bibliographicCitation" mode="collection_key"/>
            
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="collection">
                
                <xsl:attribute name="type">
                    <xsl:value-of select="'collection'"/>
                </xsl:attribute>
                
                <xsl:attribute name="dateModified">
                    <xsl:value-of select="ancestor::oai:record/oai:header/oai:datestamp"/>
                </xsl:attribute>
                
                <!-- Do not map handles yet - until PROV advises to do so -->
                <xsl:apply-templates select="identifier.uri[not(contains(text(), 'hdl.handle'))]" mode="collection_identifier"/>
                <xsl:apply-templates select="dcterms:bibliographicCitation" mode="collection_identifier"/>
                
                <xsl:choose>
                    <xsl:when test="count(dcterms:bibliographicCitation) > 0">
                        <xsl:apply-templates select="dcterms:bibliographicCitation" mode="collection_location_url"/>
                    </xsl:when>
                    <xsl:when test="count(identifier.uri) > 0">
                        <xsl:apply-templates select="identifier.uri" mode="collection_location_url"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:apply-templates select="." mode="collection_name"/>
                
                <xsl:apply-templates select="subject" mode="collection_subject"/>
                
                <!-- Default subject required by PROV -->
                <subject type="anzsrc-for" termIdentifier="http://purl.org/au-research/vocabulary/anzsrc-for/2008/2103">2103</subject>
                
                <!-- Default coverage (Victoria, Australia) required by PROV -->
                <coverage>
                    <spatial type="kmlPolyCoords">141.000000,-34.000000 142.919336,-34.145604 144.582129,-35.659230 147.742627,-35.873175 150.024219,-37.529041 150.200000,-39.200000 141.000000,-39.200000 141.000000,-34.000000 141.000000,-34.000000</spatial>
                </coverage>
                
                <xsl:choose>
                    <xsl:when test="count(description) > 0">
                        <xsl:apply-templates select="description" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(title) > 0">
                        <xsl:apply-templates select="title" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="coverage.temporal" mode="collection_coverage_temporal"/>
                
                <xsl:apply-templates select="rights.accessRights" mode="collection_rights_access"/>
                
                <xsl:apply-templates select="creator[starts-with(text(), 'PROV VA')]" mode="collection_relatedObject_agency"/>
                
                <xsl:apply-templates select="." mode="collection_citationInfo_citationMetadata"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_key">
        <key>
            <xsl:value-of select="concat($global_acronym, ' ', normalize-space(.))"/>
        </key>
    </xsl:template>
    
    
    <xsl:template match="*" mode="date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="identifier.uri" mode="collection_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_identifier">
        <identifier type="uri">
            <xsl:value-of select="concat($global_baseURI, $global_path, replace(., ' ', ''))"/>
        </identifier>    
    </xsl:template>
    
    
    
    <xsl:template match="identifier.uri" mode="collection_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path, replace(., ' ', ''))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="concat(dcterms:bibliographicCitation, ' ', title)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="subject" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="description" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="title" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template name="collection_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="coverage.temporal" mode="collection_coverage_temporal">
        <coverage>
            <temporal>
                <text><xsl:value-of select="normalize-space(.)"/></text>
            </temporal>
        </coverage>
    </xsl:template>
    
    <xsl:template match="rights.accessRights" mode="collection_rights_access">
        <rights>
            <accessRights>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="(lower-case(.) = 'open')">
                            <xsl:text>open</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'closed')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>other</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
                <xsl:value-of select="."/>
            </accessRights>
        </rights>
    </xsl:template>
    
    <xsl:template match="creator" mode="collection_relatedObject_agency">
        <relatedObject>
            <key>
                <xsl:choose>
                    <xsl:when test="matches(., '[\d]+')">
                        <xsl:analyze-string select="normalize-space(.)" regex="[\d]+\s">
                            <xsl:matching-substring>
                                <xsl:value-of select="normalize-space(concat('PROV VA ', regex-group(0)))"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <!-- Do not map handles yet - until PROV advises to do so -->
                    <xsl:when test="count(identifier.uri[not(contains(text(), 'hdl.handle'))]) > 0">
                        <xsl:apply-templates select="identifier.uri[not(contains(text(), 'hdl.handle'))]" mode="collection_identifier"/>
                    </xsl:when>
                    <xsl:when test="count(dcterms:bibliographicCitation) > 0">
                        <xsl:apply-templates select="dcterms:bibliographicCitation" mode="collection_identifier"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:for-each select="creator">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <title>
                    <xsl:value-of select="concat(dcterms:bibliographicCitation, ' ', title)"/>
                </title>
                
                <!--version></version-->
                <!--placePublished></placePublished-->
                <publisher>
                    <xsl:value-of select="normalize-space(string-join(publisher, ', '))"/>
                </publisher>
                <!--date type="publicationDate">
                    <xsl:value-of select="publicationYear"/>
                </date-->
                <!--url>
                    <xsl:choose>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'URL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'URL')][1]"/>
                        </xsl:when>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'PURL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]"/>
                        </xsl:when>
                    </xsl:choose>
                </url-->
            </citationMetadata>
        </citationInfo>
        
    </xsl:template>
    
    <xsl:template match="creator" mode="citationMetadata_contributor">
        <contributor>
            <namePart type="family">
                <xsl:analyze-string select="." regex="PROV VA [\d]+ ">
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </namePart>
            
        </contributor>
    </xsl:template>
    
</xsl:stylesheet>
    