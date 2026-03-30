<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xsl murFunc custom dc oai oai_dc dct fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
      
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="*:OAI-PMH/*/*:record"/>
            
        </registryObjects>
    </xsl:template>
    
  
    <xsl:template match="record">
        <xsl:message select="concat('num oai_dc:dc dataset element: ', count(metadata/oai_dc:dc[contains(lower-case(dc:type), 'dataset')]))"/>
        <xsl:message select="concat('num oai_dc:dc collection element: ', count(metadata/oai_dc:dc[contains(lower-case(dc:type), 'collection')]))"/>
        <xsl:apply-templates select="metadata/oai_dc:dc[contains(lower-case(dc:type), 'dataset')]" mode="collection"/>
        <xsl:apply-templates select="metadata/oai_dc:dc[contains(lower-case(dc:type), 'collection')]" mode="collection"/>
        
    </xsl:template>
    
    <xsl:template match="*" mode="collection">
        <xsl:param name="metadataID" as="xs:string"/>
        
        <xsl:variable name="class" select="'collection'"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            
            <key>
                <xsl:value-of select="concat($global_acronym, '/', $metadataID)"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="boolean(custom:sequenceContains(dc:type[1], 'dataset')) = true()">
                            <xsl:value-of select="'dataset'"/>
                        </xsl:when>
                         <xsl:when test="boolean(custom:sequenceContains(dc:type[1], 'software')) = true()">
                            <xsl:value-of select="'software'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'collection'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="../../oai:header/oai:datestamp" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="dct:bibliographicCitation[string-length(.) > 0]" mode="collection_extract_DOI_identifier"/>  
                
                <xsl:apply-templates select="dct:bibliographicCitation[string-length(.) > 0]" mode="collection_extract_DOI_location"/>  
                
                <xsl:apply-templates select="dc:identifier[starts-with(normalize-space(.),'10.') or (contains(.,'doi') and starts-with(normalize-space(.),'http'))]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="dc:identifier[count(@type) = 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="dc:identifier[starts-with(normalize-space(.),'10.') or (contains(.,'doi') and starts-with(normalize-space(.),'http'))]" mode="collection_location_doi"/>
                
                <!-- if no doi, use handle as location -->
                <xsl:if test="count(dc:identifier[starts-with(normalize-space(.),'10.') or (contains(.,'doi') and starts-with(normalize-space(.),'http'))]) = 0">
                    <xsl:choose>
                        <xsl:when test="count(dc:identifier[contains(.,'handle.net')]) > 0">
                            <xsl:apply-templates select="dc:identifier[contains(.,'handle.net')]" mode="collection_location_handle"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="collection_location_metadataID">
                                <xsl:with-param name="metadataID" select="$metadataID"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                
                <!--xsl:apply-templates select="../../oai:header/oai:identifier[contains(.,'oai:eprints.utas.edu.au:')]" mode="collection_location_nodoi"/-->
                
                <xsl:apply-templates select="dc:title[string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="dc:identifier.orcid" mode="collection_relatedInfo"/ -->
                
                <xsl:apply-templates select="dc:identifier[not(@*) or not(string-length(@*))][1]" mode="collection_relatedInfo"/>
                
                
                
                <xsl:apply-templates select="dc:creator[string-length(.) > 0]" mode="collection_relatedInfo"/>
               
                <xsl:apply-templates select="dc:contributor[string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="dc:subject" mode="collection_subject"/>
                
                <xsl:apply-templates select="dc:coverage[string-length(.) > 0]" mode="collection_spatial_coverage"/>
                
                <xsl:apply-templates select="dct:created[string-length(.) > 0]" mode="collection_dates_created"/>
                
                <xsl:apply-templates select="dct:available[string-length(.) > 0]" mode="collection_dates_available"/>
                
                <xsl:apply-templates select="dc:rights[string-length(.) > 0]" mode="collection_rights_rightsStatement"/>
                
                <xsl:apply-templates select="dct:license[string-length(.) > 0]" mode="collection_rights_license"/>
                
                <xsl:call-template name="rightsStatement"/>
                
                <xsl:choose>
                    <xsl:when test="count(dc:description[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="dc:description[string-length(.) > 0]" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(dc:title[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="dc:title[string-length(.) > 0]" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
               
               
                <xsl:apply-templates select="dct:temporal[string-length(.) > 0]" mode="collection_dates_coverage"/>  
                
                
                <xsl:choose>
                    <xsl:when test="count(dct:bibliographicCitation[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="dct:bibliographicCitation[string-length(.) > 0]" mode="collection_citation_info"/>  
                        
                    </xsl:when>
                    <xsl:when test="count(dc:source[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="dc:source[string-length(.) > 0]" mode="collection_citation_info"/>  
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="collection_citation_info_metadata"/>  
                    </xsl:otherwise>
                </xsl:choose>
                
               
                
               
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    
     <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="oai:datestamp" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="dct:bibliographicCitation" mode="collection_extract_DOI_identifier">
        <!-- override to extract identifier from full citation, custom per provider -->
    </xsl:template>  
    
    <xsl:template match="dct:bibliographicCitation" mode="collection_extract_DOI_location">
        <!-- override to extract location from full citation, custom per provider -->
    </xsl:template>
    
       
    <xsl:template match="dc:identifier" mode="collection_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="dc:identifier[@xsi:type ='dct:URI']" mode="collection_location_if_no_DOI">
        <!--override if required-->
    </xsl:template>
    
     <xsl:template match="dc:identifier" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(normalize-space(.) , '10.')">
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
    
    <xsl:template match="dc:identifier" mode="collection_location_handle">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="normalize-space(.)"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template name="collection_location_metadataID">
        <xsl:param name="metadataID"/>
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path, $metadataID)"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="dc:title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
   <xsl:template match="dc:identifier.orcid" mode="collection_relatedInfo">
        <xsl:message select="concat('orcidId : ', .)"/>
                            
        <relatedInfo type='party'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="dc:identifier" mode="collection_relatedInfo">
        <!-- Override this -->
    </xsl:template>
    
    <xsl:template match="dc:creator | dc:contributor" mode="collection_relatedInfo">
            <relatedInfo type="party">
                <xsl:apply-templates select="." mode="collection_relatedInfo_identifier_fromName"/>
                <title>
                    <xsl:value-of select="normalize-space(.)"/>
                </title>
                <relation type="hasCollector"/>
            </relatedInfo>
    </xsl:template>
    
    <xsl:template match="dc:creator | dc:contributor" mode="collection_relatedInfo_identifier_fromName">
        <identifier type="local">
            <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
        </identifier>
    </xsl:template>
    
    
    
    <xsl:template match="dct:available" mode="collection_dates_available">
        <dates type="dc.available">
            <xsl:call-template name="parseDates">
                <xsl:with-param name="inputDate" select="normalize-space(.)"/>
                <xsl:with-param name="inputFormat" select="@xsi:type"></xsl:with-param>
            </xsl:call-template>
        </dates>
    </xsl:template>


    <xsl:template match="dct:created" mode="collection_dates_created">
        <dates type="dc.created">
            <xsl:call-template name="parseDates">
                <xsl:with-param name="inputDate" select="normalize-space(.)"/>
                <xsl:with-param name="inputFormat" select="@xsi:type"></xsl:with-param>
            </xsl:call-template>
        </dates>
    </xsl:template>
    
    
    <xsl:template match="dc:subject" mode="collection_subject">
        <xsl:if test="string-length(.) > 0">
            <subject type="local">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:if>
    </xsl:template>
   
    <xsl:template match="dc:coverage" mode="collection_spatial_coverage">
        <coverage>
            <spatial type='text'>
                <xsl:value-of select='normalize-space(.)'/>
            </spatial>
        </coverage>
    </xsl:template>
   
    <xsl:template name="rightsStatement">
        <!-- override with rights statement for all in olac_dc if required -->
    </xsl:template>
   
    <xsl:template match="dc:rights" mode="collection_rights_rightsStatement">
        <xsl:if test="contains(lower-case(.), 'open')">
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
        
            
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>

    </xsl:template>
    
    <xsl:template match="dct:license" mode="collection_rights_license">
        <rights>
            <licence>
                <xsl:value-of select="fn:normalize-space(.)"/>
            </licence>
        </rights>
    </xsl:template>
    
    <xsl:template name="collection_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="dc:description" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="dc:title" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="dct:temporal" mode="collection_dates_coverage">
        <coverage>
            <temporal>
                <xsl:call-template name="parseDates">
                    <xsl:with-param name="inputDate" select="normalize-space(.)"/>
                    <xsl:with-param name="inputFormat" select="'W3CDTF'"></xsl:with-param>
                </xsl:call-template>
            </temporal>
        </coverage>
    </xsl:template>  
    
    
    <xsl:template name="parseDates">
        <xsl:param name="inputDate"/>
        <xsl:param name="inputFormat"/>
        
        <xsl:variable name="format">
            <xsl:choose>
                <xsl:when test="fn:string-length($inputFormat) = 0">
                    <xsl:value-of select="'W3CDTF'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$inputFormat"/>
                </xsl:otherwise>
            </xsl:choose> 
        </xsl:variable>
       
        <xsl:analyze-string select="translate(translate($inputDate, ']', ''), '[', '')" regex="[\d\-?/]+">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="contains(regex-group(0), '/')">
                        <date type="dateFrom" dateFormat="{$format}">
                            <xsl:value-of select="substring-before(regex-group(0), '/')"/>
                            <!--xsl:message select="concat('from: ', substring-before(regex-group(0), '/'))"/-->
                        </date>
                        <date type="dateTo" dateFormat="{$format}">
                            <xsl:value-of select="substring-after(regex-group(0), '/')"/>
                            <!--xsl:message select="concat('to: ', substring-after(regex-group(0), '/'))"/-->
                        </date>
                    </xsl:when>
                    <xsl:otherwise>
                        <date type="dateFrom" dateFormat="{$format}">
                            <xsl:value-of select="regex-group(0)"/>
                            <!--xsl:message select="concat('match: ', regex-group(0))"/-->
                        </date> 
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="*" mode="collection_citation_info_metadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(dc:identifier[starts-with(normalize-space(.),'10.') or (contains(.,'doi') and starts-with(normalize-space(.),'http'))]) > 0">
                        <xsl:apply-templates select="dc:identifier[starts-with(normalize-space(.),'10.') or (contains(.,'doi') and starts-with(normalize-space(.),'http'))]" mode="collection_identifier"/>
                    </xsl:when>
                    <xsl:when test="count(dc:identifier[count(@type) = 0])">
                        <xsl:apply-templates select="dc:identifier[count(@type) = 0]" mode="collection_identifier"/>    
                    </xsl:when>
                </xsl:choose>

                <xsl:apply-templates select="dc:creator" mode="collection_citation_info_metadata_contributor"/>
                    
                <xsl:apply-templates select="dc:publisher" mode="collection_citation_info_metadata_publisher"/>
                
                <xsl:apply-templates select="dct:available" mode="collection_citation_info_metadata_date"/>
 
                 
            </citationMetadata>
        </citationInfo>
    </xsl:template>
    
    <xsl:template match="dc:publisher" mode="collection_citation_info_metadata_publisher">
        <publisher>
            <xsl:value-of select="fn:normalize-space(.)"/>
        </publisher>
    </xsl:template>
        
    <xsl:template match="dct:available" mode="collection_citation_info_metadata_date">
        <date type="available">
            <xsl:value-of select="fn:normalize-space(.)"/>
        </date>
    </xsl:template>
    
   
    <date type="date">1999</date>
    
    <xsl:template match="dc:creator" mode="collection_citation_info_metadata_contributor">
        <xsl:variable name="rawName" select="normalize-space(replace(., ';.*', ''))"/>
        
        <contributor>
            <namePart type="family"><xsl:value-of select="$rawName"/></namePart>
            <!-- Commenting out the following because we have organisations with commas sometimes so need to do this another way
             <xsl:choose>
                 <xsl:when test="contains($rawName, ',')">
                     <namePart type="family"><xsl:value-of select="normalize-space(substring-before($rawName, ','))"/></namePart>
                     <namePart type="given"><xsl:value-of select="normalize-space(substring-after($rawName, ','))"/></namePart>
                 </xsl:when>
                 
                 <xsl:when test="contains($rawName, ' ')">
                     <namePart type="given"><xsl:value-of select="replace($rawName, '^(.*)\s+.*$', '$1')"/></namePart>
                     <namePart type="family"><xsl:value-of select="replace($rawName, '^.*\s+(.*)$', '$1')"/></namePart>
                 </xsl:when>
                 
                 <xsl:otherwise>
                     <namePart type="family"><xsl:value-of select="$rawName"/></namePart>
                 </xsl:otherwise>
             </xsl:choose>
             -->
        </contributor>
    </xsl:template>
    
  
    
    <xsl:template match="dc:source | dct:bibliographicCitation" mode="collection_citation_info">
        <citationInfo>
           <fullCitation>
                <xsl:value-of select="normalize-space(.)"/>
            </fullCitation>
        </citationInfo>
    </xsl:template>  
             
     <xsl:template match="*" mode="party">
        
        <xsl:for-each select="dc:creator | dc:contributor">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(.) > 0)">
            
                   <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                        </key>
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                             <name type="primary">
                                 <namePart>
                                     <xsl:value-of select="murFunc:formatName(normalize-space(.))"/>
                                 </namePart>   
                             </name>
                         </party>
                     </registryObject>
                   </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:template>
                   
    <xsl:function name="murFunc:formatName">
        <xsl:param name="name"/>
        
        <xsl:variable name="namePart_sequence" as="xs:string*">
            <xsl:analyze-string select="$name" regex="[A-Za-z()-]+">
                <xsl:matching-substring>
                    <xsl:if test="regex-group(0) != '-'">
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:if>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($namePart_sequence) = 0">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="orderedNamePart_sequence" as="xs:string*">
                    <!--  we are going to presume that we have surnames first - otherwise, it's not possible to determine by being
                            prior to a comma because we get:  "surname, firstname, 1924-" sort of thing -->
                    <!-- all names except surname -->
                    <xsl:for-each select="$namePart_sequence">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="$namePart_sequence[1]"/>
                </xsl:variable>
                <xsl:message select="concat('formatName returning: ', string-join(for $i in $orderedNamePart_sequence return $i, ' '))"/>
                <xsl:value-of select="string-join(for $i in $orderedNamePart_sequence return $i, ' ')"/>
    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="murFunc:formatKey">
        <xsl:param name="input"/>
        <xsl:variable name="raw" select="translate(normalize-space($input), ' ', '')"/>
        <xsl:variable name="temp">
            <xsl:choose>
                <xsl:when test="substring($raw, string-length($raw), 1) = '.'">
                    <xsl:value-of select="substring($raw, 0, string-length($raw))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$raw"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($global_acronym, '/', $temp)"/>
    </xsl:function>
    
</xsl:stylesheet>
    