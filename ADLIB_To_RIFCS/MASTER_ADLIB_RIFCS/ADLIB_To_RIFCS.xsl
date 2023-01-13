<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
    exclude-result-prefixes="xsl murFunc custom dc oai fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
    <xsl:param name="global_path_organisations" select="''"/>
      
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(OAI-PMH): ', name(OAI-PMH))"/>
            <xsl:message select="concat('num record element: ', count(OAI-PMH/ListRecords/record))"/>
            <xsl:apply-templates select="OAI-PMH/ListRecords/record"/>
            
        </registryObjects>
    </xsl:template>
    
  
    <xsl:template match="record">
        <xsl:apply-templates select="metadata/record" mode="collection"/>
     </xsl:template>
    
    <xsl:template match="record"  mode="collection">
        <xsl:variable name="class">
            <!--xsl:choose>
                <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'dataset')) = true()">
                    <xsl:value-of select="'collection'"/>
                </xsl:when>
                <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'software')) = true()">
                    <xsl:value-of select="'collection'"/>
                </xsl:when>
                <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'service')) = true()">
                    <xsl:value-of select="'service'"/>
                </xsl:when>
                <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'website')) = true()">
                    <xsl:value-of select="'service'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'collection'"/>
                </xsl:otherwise>
            </xsl:choose-->
            <xsl:value-of select="'collection'"/>
        </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <!-- Generate key from doi if there is one (this means key will stay the same in future harvests even if harvest api or source xml changes form-->
            <xsl:choose>
                <xsl:when test="count(identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]) > 0">
                    <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]" mode="collection_key"/>
                </xsl:when>
                <xsl:when test="count(@priref) > 0">
                    <xsl:apply-templates select="@priref" mode="collection_key"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="ancestor::record/header/identifier" mode="collection_key"/>
                </xsl:otherwise>
            </xsl:choose>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <!--xsl:choose>
                        <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'dataset')) = true()">
                            <xsl:value-of select="'dataset'"/>
                        </xsl:when>
                        <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'software')) = true()">
                            <xsl:value-of select="'software'"/>
                        </xsl:when>
                        <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'service')) = true()">
                            <xsl:value-of select="'report'"/>
                        </xsl:when>
                        <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'website')) = true()">
                            <xsl:value-of select="'report'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'collection'"/>
                        </xsl:otherwise>
                    </xsl:choose-->
                    <xsl:value-of select="'collection'"/>
                </xsl:attribute>
             
                <xsl:apply-templates select="@modification" mode="collection_date_modified"/>
                
                <!--xsl:apply-templates select="identifier" mode="collection_identifier"/-->
                
                <xsl:apply-templates select="@priref[boolean(string-length(.))][1]" mode="collection_identifier"/>
               
                <xsl:choose>
                    <xsl:when test="count(identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]) > 0">
                        <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]" mode="collection_location_doi"/>
                    </xsl:when>
                    <xsl:when test="count(@priref[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="@priref[boolean(string-length(.))][1]" mode="collection_location_url"/>
                    </xsl:when>
                </xsl:choose>
               
                <xsl:apply-templates select="Title[boolean(string-length(.))]" mode="collection_name"/>
                
                <xsl:choose>
                    <xsl:when test="count(Description/description[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="Description/description[boolean(string-length(.))]" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(Title[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="Title[boolean(string-length(.))]" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="Access_Directions[boolean(string-length(.))]" mode="collection_rights_access"/>
                <xsl:apply-templates select="item_control_status[boolean(string-length(.))]" mode="collection_rights_access"/>
                
                <xsl:apply-templates select="control.agency" mode="relatedInfo_agency"/>
                <xsl:apply-templates select="Create.Agency" mode="relatedInfo_agency"/>
                <xsl:apply-templates select="Part_of" mode="relatedInfo_partOf"/>
                
                
                <xsl:apply-templates select="Production_date" mode="collection_date"/>
                
                <xsl:apply-templates select="Production_date" mode="collection_coverage_temporal"/>
                
                <xsl:apply-templates select="." mode="collection_citationInfo_citationMetadata"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="identifier" mode="collection_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', substring(string-join(for $n in fn:reverse(fn:string-to-codepoints(.)) return string($n), ''), 0, 50))"/>
        </key>
    </xsl:template>
   
   
    <xsl:template match="@priref" mode="collection_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', .)"/>
        </key>
    </xsl:template>
    
    
    <xsl:template match="@modification" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="datestamp" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="identifier" mode="collection_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
   <xsl:template match="identifier" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="@priref" mode="collection_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path, normalize-space(.))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="@priref" mode="collection_identifier">
        <identifier type="uri">
            <xsl:value-of select="concat($global_baseURI, $global_path, normalize-space(.))"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="Title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="control.agency" mode="relatedInfo_agency">
        <relatedInfo type="party">
            <identifier type="uri">
                <xsl:value-of select="concat($global_baseURI, $global_path_organisations, series.agency.control.no.lref)"/>
            </identifier>
            <relation type="isManagedBy"/>
            <title>
                <xsl:value-of select="concat(series.agency.control.name, ' [', series.agency.control.no, ']')"/>
            </title>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="Create.Agency" mode="relatedInfo_agency">
        <relatedInfo type="party">
            <identifier type="uri">
                <xsl:value-of select="concat($global_baseURI, $global_path_organisations, series.agency.create.no.lref)"/>
            </identifier>
            <relation type="hasCollector"/>
            <title>
                <xsl:value-of select="concat(normalize-space(agency.name), ' [', series.agency.create.no, ']')"/>
            </title>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="Part_of" mode="relatedInfo_partOf">
        <relatedInfo type="{lower-case(part_of.description_level)}">
            <identifier type="uri">
                <xsl:value-of select="concat($global_baseURI, $global_path, part_of_reference.lref)"/>
            </identifier>
            <relation type="isPartOf"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="Production_date" mode="collection_date">
        <dates type="dc.created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="production.date.start"/>
            </date>
            <date type="dateTo" dateFormat="W3CDTF">
                <xsl:value-of select="production.date.end"/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="Production_date" mode="collection_coverage_temporal">
        
        <coverage>
            <temporal>
                <date type="dateFrom" dateFormat="W3CDTF">
                    <xsl:value-of select="content_start_date"/>
                </date>
                <date type="dateTo" dateFormat="W3CDTF">
                    <xsl:value-of select="content_end_date"/>
                </date>
            </temporal>
        </coverage>
        
    </xsl:template>
  
    <xsl:template match="Access_Directions" mode="collection_rights_access">
        <rights>
            <accessRights>
                <!--xsl:attribute name="rightsUri">
                    <xsl:value-of select="@rightsURI"/>
                </xsl:attribute-->
                <!--xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="(lower-case(.) = 'open access')">
                            <xsl:text>open</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'embargoed access')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'restricted access')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'metadata only access')">
                            <xsl:text>conditional</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute-->
                <xsl:for-each select="./*">
                    <xsl:value-of select="concat(substring-after(name(.), 'series_access_'), ': [',.,'] ')"/>
                </xsl:for-each>
                
            </accessRights>
        </rights>
        
    </xsl:template>
    
    <xsl:template match="item_control_status" mode="collection_rights_access">
        <rights>
            <accessRights>
                <xsl:value-of select="normalize-space(.)"/>
            </accessRights>
        </rights>
    </xsl:template>
    
    <xsl:template match="rights" mode="collection_rights">
        <rights>
            <accessRights>
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="@rightsURI"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="(lower-case(.) = 'open access')">
                            <xsl:text>open</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'embargoed access')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'restricted access')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'metadata only access')">
                            <xsl:text>conditional</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                
                <xsl:value-of select="."/>
            </accessRights>
        </rights>
        
    </xsl:template>
    
    <xsl:template name="collection_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="description" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="Title" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
  
     <xsl:template match="record" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]) > 0">
                        <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]" mode="collection_identifier"/>
                    </xsl:when>
                    <xsl:when test="count(@priref[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="@priref[boolean(string-length(.))][1]" mode="collection_identifier"/>
                    </xsl:when>
                </xsl:choose>
                            
                <xsl:for-each select="creators/creator/creatorName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <xsl:for-each select="Create.Agency[boolean(string-length(agency.name))]">
                    <xsl:apply-templates select="agency.name" mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <title>
                    <xsl:value-of select="normalize-space(string-join(Title, ' - '))"/>
                </title>
                
                <!--version></version-->
                <!--placePublished></placePublished-->
                <publisher>
                    <xsl:value-of select="normalize-space(string-join(control.agency/series.agency.control.name, ', '))"/>
                </publisher>
                <date type="publicationDate">
                    <xsl:value-of select="publicationYear"/>
                </date>
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
    
    <xsl:template match="agency.name" mode="citationMetadata_contributor">
        <contributor>
            <namePart type="family">
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
         </contributor>
    </xsl:template>
    
             
     
   </xsl:stylesheet>
    