<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dcrifcsFunc="http://dcrifcsFunc.nowhere.yet"
    xpath-default-namespace="http://datacite.org/schema/kernel-4"
    exclude-result-prefixes="xsl custom fn xs xsi dcrifcsFunc">
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'DataCite'"/>
    <xsl:param name="global_group" select="'DataCite'"/>
    <xsl:param name="global_acronym" select="'DataCite'"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <!--xsl:param name="global_baseURI" select="''"/-->
    <!--xsl:param name="global_path" select="''"/-->
      
    

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        
        <xsl:apply-templates select="resource" mode="datacite_4_to_rifcs_collection">
            <xsl:with-param name="dateAccessioned"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="//resource/contributors/contributor" mode="datacite_4_to_rifcs_party">
            <xsl:with-param name="dateAccessioned"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="//resource/creators/creator" mode="datacite_4_to_rifcs_party">
            <xsl:with-param name="dateAccessioned"/>
        </xsl:apply-templates>
            
    </xsl:template>
    
  
    <xsl:template match="*" mode="datacite_4_to_rifcs_collection">
        <xsl:param name="dateAccessioned"/>
        
        <xsl:message select="'datacite_4_to_rifcs_collection'"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            
            <key>
                <xsl:value-of select="substring(string-join(for $n in fn:reverse(fn:string-to-codepoints(identifier[@identifierType = 'DOI'])) return string($n), ''), 0, 50)"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            
            <xsl:variable name="class">
                <xsl:choose>
                    <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'service')) = true()">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'website')) = true()">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'model')) = true()">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'collection'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:element name="{$class}">
                
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'dataset')) = true()">
                        <xsl:value-of select="'dataset'"/>
                    </xsl:when>
                    <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'text')) = true()">
                        <xsl:value-of select="'publication'"/>
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
                    <xsl:when test="boolean(custom:sequenceContains(resourceType/@resourceTypeGeneral, 'model')) = true()">
                        <xsl:value-of select="'generate'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'collection'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:attribute name="dateAccessioned" select="$dateAccessioned"/>
                
                <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]" mode="collection_extract_DOI_identifier"/>  
                
                <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]" mode="collection_extract_DOI_location"/>  
                
                <xsl:apply-templates select="identifier[string-length(.) > 0]" mode="identifier"/>
                
                <xsl:apply-templates select="identifier[(@identifierType != 'DOI') and (string-length(.) > 0)]" mode="collection_location_doi"/>
                
                <!-- if no doi, use handle as location -->
                <xsl:if test="count(identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]) = 0">
                    <xsl:apply-templates select="identifier[contains(lower-case(@identifierType),'handle')]" mode="collection_location_handle"/>
                    
                </xsl:if>
                
                <!--xsl:apply-templates select="../../oai:header/oai:identifier[contains(.,'oai:eprints.utas.edu.au:')]" mode="collection_location_nodoi"/-->
                
                <xsl:apply-templates select="titles/title[string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="dc:identifier.orcid" mode="collection_relatedInfo"/ -->
                
                <xsl:apply-templates select="relatedIdentifiers/relatedIdentifier" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="creators/creator[string-length(.) > 0]" mode="collection_relatedObject"/>
               
                <xsl:apply-templates select="contributors/contributor[string-length(.) > 0]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="subjects/subject" mode="collection_subject"/>
                
                <xsl:apply-templates select="geoLocations/geoLocation/geoLocationPlace[string-length(.) > 0]" mode="collection_spatial_coverage"/>
                
                <xsl:apply-templates select="dates/date[string-length(.) > 0]" mode="collection_dates"/>
                
                <xsl:apply-templates select="rightsList/rights[string-length(.) > 0]" mode="collection_rights"/>
                
                <xsl:call-template name="rightsStatement"/>
                
                <xsl:choose>
                    <xsl:when test="count(descriptions/description[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="descriptions/description[string-length(.) > 0]" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(titles/title[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="titles/title[string-length(.) > 0]" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
               
               
                <xsl:apply-templates select="dates/date[(@dateType='Collected') and (string-length(.) > 0)]" mode="collection_dates_coverage"/>  
                
                <!--xsl:apply-templates select="dc:source[string-length(.) > 0]" mode="collection_citation_info"/-->  
                
                <!--xsl:apply-templates select="dcterms:bibliographicCitation[string-length(.) > 0]" mode="collection_citation_info"/-->  
                
                <xsl:apply-templates select="." mode="collection_citationInfo_citationMetadata"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    
     <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="identifier" mode="collection_extract_DOI_identifier">
        <!-- override to extract identifier from full citation, custom per provider -->
    </xsl:template>  
    
    <xsl:template match="identifier" mode="collection_extract_DOI_location">
        <!-- override to extract location from full citation, custom per provider -->
    </xsl:template>
    
       
    <xsl:template match="*[contains(lower-case(name()), 'identifier')]" mode="identifier">
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
    
    <xsl:template match="identifier[@xsi:type ='dcterms:URI']" mode="collection_location_if_no_DOI">
        <!--override if required-->
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
    
    <xsl:template match="identifier" mode="collection_location_handle">
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
    
    <!--xsl:template match="oai:identifier" mode="collection_location_nodoi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path, '/', substring-after(.,'oai:eprints.utas.edu.au:'))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template-->
    
    <xsl:template match="title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="relatedIdentifier" mode="collection_relatedInfo">
        <relatedInfo>
            <xsl:apply-templates select="." mode="identifier"/>
            <relation type="{@relationType}"/>
        </relatedInfo>
    </xsl:template>
    
   <!--xsl:template match="dc:identifier.orcid" mode="collection_relatedInfo">
        <xsl:message select="concat('orcidId : ', .)"/>
                            
        <relatedInfo type='party'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template-->
    
   
    
    <xsl:template match="creator" mode="collection_relatedObject">
            <relatedObject>
                <key>
                    <xsl:value-of select="dcrifcsFunc:formatKey(dcrifcsFunc:formatName(.))"/> 
                </key>
                <relation type="hasCollector"/>
            </relatedObject>
    </xsl:template>
    
    <xsl:template match="contributor" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="dcrifcsFunc:formatKey(dcrifcsFunc:formatName(.))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="date" mode="collection_dates">
        <dates type="{@dateType}">
            <date type="dateFrom" dateFormat="{@xsi:type}">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>

    
    <xsl:template match="subject" mode="collection_subject">
        <xsl:if test="string-length(.) > 0">
            <subject type="local">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:if>
    </xsl:template>
   
    <xsl:template match="geoLocationPlace" mode="collection_spatial_coverage">
        <coverage>
            <spatial type='text'>
                <xsl:value-of select='normalize-space(.)'/>
            </spatial>
        </coverage>
    </xsl:template>
   
    <xsl:template name="rightsStatement">
        <!-- override with rights statement for all in olac_dc if required -->
    </xsl:template>
   
    <xsl:template match="rights" mode="collection_rights">
        <rights>
            <rightsStatement rightsUri="{@rightsURI}">
                <xsl:value-of select="."/>
            </rightsStatement>
        </rights>
        
        <xsl:if test="contains(lower-case(.), 'open access')">
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
           
        
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
    <xsl:template match="title" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="date" mode="collection_dates_coverage">
        <coverage>
            <temporal>
                <xsl:analyze-string select="translate(translate(., ']', ''), '[', '')" regex="[\d]+[?]*[-]*[\d]*">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="contains(regex-group(0), '-')">
                                <date type="dateFrom" dateFormat="W3CDTF">
                                    <xsl:value-of select="substring-before(regex-group(0), '-')"/>
                                    <!--xsl:message select="concat('from: ', substring-before(regex-group(0), '-'))"/-->
                                </date>
                                <date type="dateTo" dateFormat="W3CDTF">
                                    <xsl:value-of select="substring-after(regex-group(0), '-')"/>
                                    <!--xsl:message select="concat('to: ', substring-after(regex-group(0), '-'))"/-->
                                </date>
                            </xsl:when>
                            <xsl:otherwise>
                                <date type="dateFrom" dateFormat="W3CDTF">
                                    <xsl:value-of select="regex-group(0)"/>
                                    <!--xsl:message select="concat('match: ', regex-group(0))"/-->
                                </date> 
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </temporal>
        </coverage>
    </xsl:template>  
    
    <xsl:template match="resource" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(identifier[(@identifierType = 'DOI') and (string-length() > 0)]) > 0">
                        <xsl:apply-templates select="identifier[(@identifierType = 'DOI')][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(identfier[(string-length() > 0)]) > 0">
                        <xsl:apply-templates select="identifier[(string-length() > 0)][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'URL') and (string-length() > 0)]) > 0">
                        <xsl:apply-templates select="alternateIdentifier[(@alternateIdentifierType = 'URL')][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'PURL') and (string-length() > 0)]) > 0">
                        <xsl:apply-templates select="alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(alternateIdentifier[(string-length() > 0)]) > 0">
                        <xsl:apply-templates select="alternateIdentifier[(string-length() > 0)][1]" mode="identifier"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:for-each select="creators/creator/creatorName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <xsl:for-each select="contributors/contributor/contributorName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <title>
                    <xsl:value-of select="string-join(titles/title, ', ')"/>
                </title>
                
                <!--version></version-->
                <!--placePublished></placePublished-->
                <publisher>
                    <xsl:value-of select="publisher"/>
                </publisher>
                <date type="publicationDate">
                    <xsl:value-of select="publicationYear"/>
                </date>
                <url>
                    <xsl:choose>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'URL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'URL')][1]"/>
                        </xsl:when>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'PURL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]"/>
                        </xsl:when>
                    </xsl:choose>
                </url>
            </citationMetadata>
        </citationInfo>
        
    </xsl:template>
    
    <xsl:template match="contributorName | creatorName" mode="citationMetadata_contributor">
        <contributor>
            <namePart type="family">
                <xsl:choose>
                    <xsl:when test="contains(., ',')">
                        <xsl:value-of select="normalize-space(substring-before(.,','))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </namePart>
            <namePart type="given">
                <xsl:if test="contains(., ',')">
                    <xsl:value-of select="normalize-space(substring-after(.,','))"/>
                </xsl:if>
            </namePart>
        </contributor>
    </xsl:template>
    
    <xsl:template match="creator" mode="datacite_4_to_rifcs_party">
        
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(.) > 0)">
            
                   <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="dcrifcsFunc:formatKey(dcrifcsFunc:formatName(creatorName))"/> 
                        </key>
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                             <name type="primary">
                                 <namePart>
                                     <xsl:value-of select="dcrifcsFunc:formatName(normalize-space(creatorName))"/>
                                 </namePart>   
                             </name>
                         </party>
                     </registryObject>
                   </xsl:if>
                </xsl:if>
        </xsl:template>
    
    <xsl:template match="contributor" mode="datacite_4_to_rifcs_party">
        <xsl:param name="dateAccessioned"/>
        
        
        <xsl:variable name="name" select="normalize-space(.)"/>
        
        <xsl:if test="(string-length(.) > 0)">
            
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <registryObject group="{$global_group}">
                    <key>
                        <xsl:value-of select="dcrifcsFunc:formatKey(dcrifcsFunc:formatName(.))"/> 
                    </key>
                    <originatingSource>
                        <xsl:value-of select="$global_originatingSource"/>
                    </originatingSource>
                    
                    <party>
                        <xsl:attribute name="type" select="'person'"/>
                        
                        <xsl:attribute name="dateAccessioned" select="$dateAccessioned"/>
                        
                        <name type="primary">
                            <namePart>
                                <xsl:value-of select="dcrifcsFunc:formatName(normalize-space(.))"/>
                            </namePart>   
                        </name>
                    </party>
                </registryObject>
            </xsl:if>
        </xsl:if>
    </xsl:template>
                   
    <xsl:function name="dcrifcsFunc:formatName">
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
    
    <xsl:function name="dcrifcsFunc:formatKey">
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
    