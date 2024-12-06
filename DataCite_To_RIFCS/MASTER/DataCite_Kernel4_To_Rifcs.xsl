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
    
    <!-- All values of params below will be overriden in the case where an xsl imports this file, 
        then sets the param values itself, so the values below can be considered default values -->
    <xsl:param name="global_originatingSource" select="'DataCite'"/>
    <xsl:param name="global_group" select="'Health Data Australia Contributor Records'"/>
    <xsl:param name="global_acronym" select="'DataCite'"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_project_identifier_strings" select="'raid'" as="xs:string*"/>
    <xsl:param name="global_create_and_relate_party_missing_identifier" select="false()"/>
    <xsl:param name="global_create_and_relate_activity_missing_identifier" select="false()"/>
    <xsl:variable name="registry_identifier_normalise_api_url" select="'https://researchdata.edu.au/api/registry/myceliumservices/identifiers/normalise'"/>  
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <!-- don't create parties for NHMRC and ARC -->
    <xsl:variable name="ignorePartiesWithIdentifierList" select="'ROR.ORG/011KF5R70,10.13039/501100000925,10.13039/501100000923'"/>


    <xsl:template match="/">
        <xsl:message select="'DataCite_Kernel4_To_Rifcs'"/>
        
        <xsl:apply-templates select="resource" mode="datacite_4_to_rifcs_collection">
            <xsl:with-param name="originatingSource"/>
        </xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="resource" mode="resourceSubType">
        <xsl:choose>
            <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'dataset')]) > 0">
                <xsl:value-of select="'dataset'"/>
            </xsl:when>
            <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'text')]) > 0">
                <xsl:value-of select="'publication'"/>
            </xsl:when>
            <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'software')]) > 0">
                <xsl:value-of select="'software'"/>
            </xsl:when>
            <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'service')]) > 0">
               <xsl:value-of select="'report'"/>
            </xsl:when>
            <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'website')]) > 0">
                <xsl:value-of select="'report'"/>
            </xsl:when>
            <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'model')]) > 0">
                <xsl:value-of select="'generate'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'collection'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="resource" mode="datacite_4_to_rifcs_collection">
        <xsl:param name="originatingSource" as="xs:string*"/>
        
        <xsl:message select="'datacite_4_to_rifcs_collection'"/>
        
        <registryObject group="{$global_group}">
            <!-- HES-65 use the Publisher of the dataset for the group attribute -->
            <key>
                <xsl:value-of select="concat($global_acronym, '/', identifier[@identifierType = 'DOI'])"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <xsl:variable name="class">
                <xsl:choose>
                    <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'service')]) > 0">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'website')]) > 0">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:when test="count(resourceType[contains(lower-case(@resourceTypeGeneral), 'model')]) > 0">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'collection'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
           <xsl:element name="{$class}">
                
            <xsl:attribute name="type">
                <xsl:apply-templates select="." mode="resourceSubType"/>
            </xsl:attribute>
             
                <!--TODO xsl:apply-templates select="[boolean(string-length(.))]" mode="collection_date_modified"/-->
                
                <!-- TODO - xsl:attribute name="dateAccessioned" select=""/-->
                
                <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (boolean(string-length(.)))]" mode="collection_extract_DOI_identifier"/>  
                
                <xsl:apply-templates select="identifier[(@identifierType = 'DOI') and (boolean(string-length(.)))]" mode="collection_extract_DOI_location"/>  
                
                <xsl:apply-templates select="identifier[boolean(string-length(.))]" mode="identifier"/>
                
               <xsl:apply-templates select="identifier[('DOI' = @identifierType) and boolean(string-length(.))]" mode="collection_location_doi"/>
                
                <!-- if no doi, use handle as location -->
                <xsl:if test="count(identifier[(@identifierType = 'DOI') and (boolean(string-length(.)))]) = 0">
                    <xsl:apply-templates select="identifier[contains(lower-case(@identifierType),'handle')]" mode="collection_location_handle"/>
                    
                </xsl:if>
                
                <!--xsl:apply-templates select="../../oai:header/oai:identifier[contains(.,'oai:eprints.utas.edu.au:')]" mode="collection_location_nodoi"/-->
                
                <xsl:apply-templates select="titles/title[boolean(string-length(.))]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="dc:identifier.orcid" mode="collection_relatedInfo"/ -->
                
                <xsl:apply-templates select="relatedIdentifiers/relatedIdentifier" mode="collection_relatedInfo"/>
                
               <xsl:apply-templates select="relatedItems/relatedItem" mode="collection_relatedInfo"/>
               <!-- creator and contributor may have multiple nameIdentifier -->
               <xsl:apply-templates select="creators/creator[nameIdentifier/text() != '']" mode="collection_relatedInfo"/>
               <xsl:apply-templates select="contributors/contributor[boolean(string-length(nameIdentifier))]" mode="collection_relatedInfo"/>
               
               
               <xsl:apply-templates select="fundingReferences/fundingReference[boolean(string-length(funderIdentifier))]" mode="collection_relatedInfo_funder"/>
               
               <!--xsl:apply-templates select="fundingReferences/fundingReference[boolean(string-length(awardNumber)) or boolean(string-length(awardNumber/@awardURI))]"  mode="collection_relatedInfo_grant"/-->
               
               <xsl:if test="$global_create_and_relate_activity_missing_identifier">
                <xsl:apply-templates select="fundingReferences/fundingReference[boolean(string-length(awardTitle)) and (not(boolean(string-length(awardNumber))) and not(boolean(string-length(awardNumber/@awardURI))))]"  mode="collection_relatedObject_grant"/>
               </xsl:if>
               
               <xsl:if test="true() = $global_create_and_relate_party_missing_identifier">
                    <xsl:apply-templates select="creators/creator[not(boolean(string-length(nameIdentifier)))]" mode="collection_relatedObject"/>
                    <xsl:apply-templates select="contributors/contributor[boolean(string-length(nameIdentifier))]" mode="collection_relatedObject"/>
                   <xsl:apply-templates select="fundingReferences/fundingReference[boolean(string-length(funderIdentifier))]" mode="collection_relatedObject_funder"/>
               </xsl:if>
               
                <xsl:apply-templates select="subjects/subject" mode="collection_subject"/>
                
                <xsl:apply-templates select="geoLocations/geoLocation/geoLocationPlace[boolean(string-length(.))]" mode="collection_spatial_coverage"/>
                
                <xsl:apply-templates select="dates/date[boolean(string-length(.))]" mode="collection_dates"/>
                
                <xsl:apply-templates select="rightsList/rights[boolean(string-length(.))]" mode="collection_rights"/>
                
                <xsl:call-template name="rightsStatement"/>
                
                <xsl:choose>
                    <xsl:when test="count(descriptions/description[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="descriptions/description[boolean(string-length(.))]" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(titles/title[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="titles/title[boolean(string-length(.))]" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
               
               
                <xsl:apply-templates select="dates/date[(@dateType='Collected') and (boolean(string-length(.)))]" mode="collection_dates_coverage"/>  
                
                <!--xsl:apply-templates select="dc:source[boolean(string-length(.))]" mode="collection_citation_info"/-->  
                
                <!--xsl:apply-templates select="dcterms:bibliographicCitation[boolean(string-length(.))]" mode="collection_citation_info"/-->  
                
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
            <xsl:attribute name="type">
                <xsl:apply-templates select="." mode="related_item_type"/>
            </xsl:attribute>
            
            <xsl:apply-templates select="." mode="identifier"/>
            <xsl:apply-templates select="." mode="relation"/>
            
        </relatedInfo>
    </xsl:template>
    
    <!-- For relating grant that has an awardNumber or awardNumber/@awardURI -->
    <xsl:template match="fundingReference" mode="collection_relatedInfo_grant">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:text>activity</xsl:text> <!-- Change to 'grant' if required -->
            </xsl:attribute>
            
            <xsl:choose>
                <xsl:when test="
                    boolean(string-length(awardNumber/@awardURI)) and
                    boolean(string-length(awardNumber))">
                    <identifier type="{awardNumber/@awardURI}">
                        <xsl:value-of select="awardNumber"/>
                    </identifier>
                </xsl:when>
                <xsl:when test="boolean(string-length(awardNumber/@awardURI))">
                    <identifier type="{awardNumber/@awardURI}">
                        <xsl:value-of select="awardNumber/@awardURI"/>
                    </identifier>
                </xsl:when>
                <xsl:when test="boolean(string-length(awardNumber))">
                    <identifier type="{awardNumber}">
                        <xsl:value-of select="awardNumber"/>
                    </identifier>
                </xsl:when>
            </xsl:choose>
            
            <xsl:if test="boolean(string-length(awardTitle))">
                <title>
                  <xsl:value-of select="awardTitle"/>
                </title>
            </xsl:if>
            
            <!-- Currently using vocab term 'isOutputOf' to relate this Collection to the (grant) Activity, 
                 noting that the vocabs documentation specifies that 'isFundedBy' ought only be for where:
                - a Party is funded by a Party
                - a Party is funded by a (program) Activity
                - an Activity is funded by a (program) Activity -->
            <relation type="isOutputOf"/>
            
        </relatedInfo>
    </xsl:template>
    
    <!-- For creator who has no identifier - relate with relatedObject -->
    <xsl:template match="fundingReference" mode="collection_relatedObject_grant">
        <relatedObject>
            <key>
                <xsl:value-of select="dcrifcsFunc:formatKey(awardTitle)"/>
            </key>
            <relation type="isOutputOf"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="relatedItem" mode="collection_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:apply-templates select="." mode="related_item_type_core"/>
            </xsl:attribute>
              
            <xsl:apply-templates select="relatedItemIdentifier" mode="identifier"/>
            <xsl:apply-templates select="relatedItemIdentifier" mode="relation"/>
            <title>
                <xsl:value-of select="fn:string-join(titles/title, ' - ')"/>
            </title>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="relatedIdentifier | relatedItemIdentifier" mode="relation">
        <xsl:variable name="currentNode" select="." as="node()"/>
        <relation>
            <xsl:attribute name="type">
                <xsl:apply-templates select="." mode="relation_core"/>
            </xsl:attribute>
        </relation>
    </xsl:template>
    
    <xsl:template match="relatedIdentifier | relatedItemIdentifier" mode="relation_core">
        <xsl:variable name="currentNode" select="." as="node()"/>
        
        <xsl:variable name="inferredRelation" as="xs:string*">
            <xsl:for-each select="tokenize($global_project_identifier_strings, '\|')">
                <xsl:variable name="testString" select="." as="xs:string"/>
                <xsl:if test="boolean(string-length($testString))">
                    <xsl:if test="count($currentNode[contains(lower-case(.), $testString)])">
                        <xsl:text>isOutputOf</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="boolean(string-length($inferredRelation[1]))">
                <xsl:value-of select="$inferredRelation[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="boolean(string-length(@relationType))">
                        <xsl:value-of select="@relationType"/>
                    </xsl:when>
                    <xsl:when test="'relatedItemIdentifier' = local-name(.)">
                        <xsl:if test="boolean(string-length(parent::relatedItem/@relationType))">
                            <xsl:value-of select="parent::relatedItem/@relationType"/>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
               
            </xsl:otherwise>
        </xsl:choose>
        
      </xsl:template>
    
    <xsl:template match="relatedItem" mode="related_item_type_core">
        <xsl:choose>
            <xsl:when test="'studyregistration' = lower-case(@relatedItemType)">
                <xsl:text>activity</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="relatedItemIdentifier" mode="related_item_type"/>
                <xsl:value-of select="@relatedItemType"/> <!-- Add as last entry after any inferred -->
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="node()" mode="party_type_core">
        
        <xsl:choose>
            
            <!-- @nameType 'Personal' is default for nameType in DataCite, so only alter to group if 'Organizational' -->
            <xsl:when test="
                ('organizational' = lower-case(contributorName/@nameType)) or
                ('organizational' = lower-case(creatorName/@nameType)) or
                (nameIdentifier[lower-case(/@nameIdentifierScheme) = 'ror'])"> 
                <xsl:text>group</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>person</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    

    <xsl:template match="relatedIdentifier | relatedItemIdentifier" mode="related_item_type">
        <xsl:apply-templates select="." mode="related_item_type_core"/>
    </xsl:template>
    
    <xsl:template match="relatedIdentifier | relatedItemIdentifier" mode="related_item_type_core">
        <xsl:variable name="currentNode" select="." as="node()"/>
        <xsl:for-each select="tokenize($global_project_identifier_strings, '\|')">
            <xsl:variable name="testString" select="." as="xs:string"/>
            <xsl:if test="count($currentNode[contains(lower-case(.), $testString)])">
                <xsl:text>activity</xsl:text>
            </xsl:if>
        </xsl:for-each>
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
    
    <!-- For a creator who has a nameIdentifier -->
     <xsl:template match="creator" mode="collection_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="creatorName/@nameType = 'Organizational'">
                        <xsl:text>group</xsl:text>
                    </xsl:when>
                    <xsl:otherwise><xsl:text>party</xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <identifier>
                <xsl:variable name="selected-identifier">
                    <xsl:choose>
                        <xsl:when test="nameIdentifier[@nameIdentifierScheme = 'ORCID']/text() != ''">
                            <xsl:message><xsl:value-of select="nameIdentifirer[upper-case(@nameIdentifierScheme) = 'ORCID']/text()"/></xsl:message>
                            <xsl:value-of select="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ORCID']/text()"/>
                        </xsl:when>
                        <xsl:when test="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ROR']/text() != ''">
                            <xsl:value-of select="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ROR']/text()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="nameIdentifier[text() != ''][1]/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="selected-identifier-type">
                    <xsl:choose>
                        <xsl:when test="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ORCID']/text() != ''">
                            <xsl:text>ORCID</xsl:text>
                        </xsl:when>
                        <xsl:when test="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ROR']/text() != ''">
                            <xsl:text>ROR</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="nameIdentifier[text() != ''][1]/@nameIdentifierScheme"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:attribute name="type">
                    <xsl:value-of select="$selected-identifier-type"/>
                </xsl:attribute>
                <xsl:value-of select="$selected-identifier"/>
            </identifier>
            <title>
                <xsl:value-of select="dcrifcsFunc:formatName(creatorName)"/> 
            </title>
            <relation type="Creator"/>
        </relatedInfo>
    </xsl:template>
    
    <!-- For creator who has no identifier - relate with relatedObject -->
    <xsl:template match="creator" mode="collection_relatedObject">
        <relatedObject>
            <key>
               <xsl:value-of select="dcrifcsFunc:formatKey(creatorName)"/>
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <!-- For contributor who has a name identifier -->
    <xsl:template match="contributor" mode="collection_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="@contributorType = 'Distributor'">
                        <xsl:text>group</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>party</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="nameIdentifier/@nameIdentifierScheme"/>
                </xsl:attribute>
                <xsl:value-of select="nameIdentifier"/>
            </identifier>
            <title>
                <xsl:value-of select="dcrifcsFunc:formatName(contributorName)"/> 
            </title>
            <!-- HES-67 -->
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="@contributorType = 'Distributor'">
                            <xsl:text>isAvailableThrough</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>hasCollector</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </relatedInfo>
    </xsl:template>
    
    <!-- For contributor who has no identifier - relate with relatedObject -->
    <xsl:template match="contributor" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="dcrifcsFunc:formatKey(contributorName)"/>
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    
    <!-- For funder who has a name identifier -->
    <xsl:template match="fundingReference" mode="collection_relatedInfo_funder">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:text>group</xsl:text>
            </xsl:attribute>
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="funderIdentifier/@funderIdentifierType"/>
                </xsl:attribute>
                <xsl:value-of select="funderIdentifier"/>
            </identifier>
            <title>
                <xsl:value-of select="dcrifcsFunc:formatName(funderName)"/>
            </title>
            
            <!-- Currently using vocab term 'isEnrichedBy' to relate this Collection to the (funder) Party, 
                 noting that the vocabs documentation specifies that 'isFundedBy' ought only be for where:
                - a Party is funded by a Party
                - a Party is funded by a (program) Activity
                - an Activity is funded by a (program) Activity -->
            <relation type="isFundedBy"/>
        </relatedInfo>
    </xsl:template>
    
    <!-- For funder who has no identifier - relate with relatedObject -->
    <xsl:template match="fundingReference" mode="collection_relatedObject_funder">
        <relatedObject>
            <key>
                <xsl:value-of select="dcrifcsFunc:formatKey(funderName)"/>
            </key>
            <relation type="isFundedBy"/>
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
        <xsl:if test="boolean(string-length(.))">
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
        <description>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="@descriptionType = 'TechnicalInfo' and count(following-sibling::description[@descriptionType != 'TechnicalInfo']) + count(preceding-sibling::description[@descriptionType != 'TechnicalInfo']) > 0">
                        <xsl:text>note</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>full</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
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
                    <xsl:when test="count(identifier[(@identifierType = 'DOI') and boolean(string-length())]) > 0">
                        <xsl:apply-templates select="identifier[(@identifierType = 'DOI')][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(identfier[boolean(string-length())]) > 0">
                        <xsl:apply-templates select="identifier[boolean(string-length())][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'URL') and boolean(string-length())]) > 0">
                        <xsl:apply-templates select="alternateIdentifier[(@alternateIdentifierType = 'URL')][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'PURL') and boolean(string-length())]) > 0">
                        <xsl:apply-templates select="alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]" mode="identifier"/>
                    </xsl:when>
                    <xsl:when test="count(alternateIdentifier[boolean(string-length())]) > 0">
                        <xsl:apply-templates select="alternateIdentifier[boolean(string-length())][1]" mode="identifier"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:for-each select="creators/creator">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <xsl:for-each select="contributors/contributor">
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
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'URL') and boolean(string-length())]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'URL')][1]"/>
                        </xsl:when>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'PURL') and boolean(string-length())]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]"/>
                        </xsl:when>
                    </xsl:choose>
                </url>
            </citationMetadata>
        </citationInfo>
        
    </xsl:template>
    
    <xsl:template match="contributor" mode="citationMetadata_contributor">
        <contributor>
            <xsl:choose>
                <xsl:when test="'Organizational' = contributorName/@nameType">
                    <namePart type="family">
                        <xsl:value-of select="normalize-space(contributorName)"/>
                    </namePart>
                </xsl:when>
                <xsl:otherwise>
                    <namePart type="family">
                        <xsl:choose>
                            <xsl:when test="boolean(string-length(familyName))">
                                <xsl:value-of select="familyName"/>
                            </xsl:when>
                            <xsl:when test="contains(contributorName, ',')">
                                <xsl:value-of select="normalize-space(substring-before(contributorName,','))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(contributorName)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </namePart>
                    <namePart type="given">
                        <xsl:choose>
                            <xsl:when test="boolean(string-length(givenName))">
                                <xsl:value-of select="givenName"/>
                            </xsl:when>
                            <xsl:when test="contains(contributorName, ',')">
                                <xsl:value-of select="normalize-space(substring-after(contributorName,','))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(contributorName)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </namePart>
        
                </xsl:otherwise>
            </xsl:choose>
        </contributor>
    </xsl:template>
    
    <xsl:template match="creator" mode="citationMetadata_contributor">
        <contributor>
            <xsl:choose>
                <xsl:when test="'Organizational' = creatorName/@nameType">
                    <namePart type="family">
                        <xsl:value-of select="normalize-space(creatorName)"/>
                    </namePart>
                </xsl:when>
                <xsl:otherwise>
                    <namePart type="family">
                        <xsl:choose>
                            <xsl:when test="boolean(string-length(familyName))">
                                <xsl:value-of select="familyName"/>
                            </xsl:when>
                            <xsl:when test="contains(creatorName, ',')">
                                <xsl:value-of select="normalize-space(substring-before(creatorName,','))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(creatorName)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </namePart>
                    <namePart type="given">
                        <xsl:choose>
                            <xsl:when test="boolean(string-length(givenName))">
                                <xsl:value-of select="givenName"/>
                            </xsl:when>
                            <xsl:when test="contains(creatorName, ',')">
                                <xsl:value-of select="normalize-space(substring-after(creatorName,','))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(creatorName)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </namePart>
                    
                </xsl:otherwise>
            </xsl:choose>
        </contributor>
    </xsl:template>
    
    
    <!-- ***************************************** -->
    <!-- PARTY RECORDS -->
    
    <!-- https://jira.ardc.edu.au/browse/HES-33 -->
    
    <xsl:template match="creator" mode="datacite_4_to_rifcs_party">
        <xsl:param name="originatingSource" as="xs:string*"/>
        <xsl:variable name="selected-identifier">
            <xsl:choose>
                <xsl:when test="nameIdentifier[@nameIdentifierScheme = 'ORCID']/text() != ''">
                    <xsl:message><xsl:value-of select="nameIdentifirer[upper-case(@nameIdentifierScheme) = 'ORCID']/text()"/></xsl:message>
                    <xsl:value-of select="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ORCID']/text()"/>
                </xsl:when>
                <xsl:when test="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ROR']/text() != ''">
                    <xsl:value-of select="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ROR']/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>FISH<xsl:value-of select="nameIdentifier[text() != '']/text()"/></xsl:message>
                    <xsl:value-of select="nameIdentifier[text() != '']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="selected-identifier-type">
            <xsl:choose>
                <xsl:when test="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ORCID']/text() != ''">
                    <xsl:text>ORCID</xsl:text>
                </xsl:when>
                <xsl:when test="nameIdentifier[upper-case(@nameIdentifierScheme) = 'ROR']/text() != ''">
                    <xsl:text>ROR</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="nameIdentifier[text() != '']/@nameIdentifierScheme"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="url" select="concat($registry_identifier_normalise_api_url, '?identifier_value=', encode-for-uri($selected-identifier), '&amp;identifier_type=', encode-for-uri($selected-identifier-type))"/>
        <xsl:variable name="response" as="node()*">
            <xsl:if test="has-children($selected-identifier) and has-children($selected-identifier-type)">
                <xsl:copy-of select="document($url)"/>
            </xsl:if>
        </xsl:variable>
            
        <xsl:variable name="normalisedIdentifier">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'value']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="normalisedIdentifierType">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'type']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable> 
        <registryObject group="{$global_group}">
            <key>
                <xsl:choose>
                    <xsl:when test="string-length($normalisedIdentifier) &gt; 0">
                        <xsl:value-of select="concat($global_acronym, '/', $normalisedIdentifier)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dcrifcsFunc:formatKey(creatorName)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <party>
                <xsl:attribute name="type">
                    <xsl:apply-templates select="." mode="party_type_core"/>
                </xsl:attribute>
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(creatorName)"/>
                    </namePart>
                </name>
                <xsl:for-each select="nameIdentifier[text() != '']">
                    <identifier>
                        <xsl:attribute name="type" select="@nameIdentifierScheme"/>
                        <xsl:value-of select="normalize-space(text())"/>
                    </identifier>
                </xsl:for-each>
            </party>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="fundingReference" mode="datacite_4_to_rifcs_party">
        <xsl:param name="originatingSource" as="xs:string*"/>
        <xsl:variable name="url" select="concat($registry_identifier_normalise_api_url, '?identifier_value=', encode-for-uri(funderIdentifier), '&amp;identifier_type=', encode-for-uri(funderIdentifier/@funderIdentifierType))"/>
        <xsl:variable name="response" select="document($url)" />
        <xsl:variable name="normalisedIdentifier">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'value']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="normalisedIdentifierType">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'type']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable>   
        <xsl:variable name="upperCasedIdentifier" select="translate($normalisedIdentifier,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        <!-- don't create parties that we have many of already eg NHMRC -->
        <xsl:if test="not(contains($ignorePartiesWithIdentifierList, $upperCasedIdentifier))">
        <registryObject group="{$global_group}">
            <key>
                <xsl:choose>
                    <xsl:when test="string-length($normalisedIdentifier) &gt; 0">
                        <xsl:value-of select="concat($global_acronym, '/', $normalisedIdentifier)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dcrifcsFunc:formatKey(funderName)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            <!-- funding ref is always an organisation -->
            <party type="group">
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(funderName)"/>
                    </namePart>
                </name>
                <xsl:if test="boolean(string-length(funderIdentifier))">
                    <identifier>
                        <xsl:attribute name="type">
                            <xsl:value-of select="$normalisedIdentifierType"/>
                        </xsl:attribute>
                        <xsl:value-of select="$normalisedIdentifier"/>
                    </identifier>
                </xsl:if>
            </party>
        </registryObject> 
    </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="fundingReference" mode="datacite_4_to_rifcs_activity">
        <xsl:param name="originatingSource" as="xs:string"/>
        <xsl:variable name="url" select="concat($registry_identifier_normalise_api_url, '?identifier_value=', encode-for-uri(funderIdentifier), '&amp;identifier_type=', encode-for-uri(funderIdentifier/@funderIdentifierType))"/>
        <xsl:variable name="response" select="document($url)" />
        <xsl:variable name="normalisedIdentifier">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'value']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="normalisedIdentifierType">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'type']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable> 
        <registryObject group="{$global_group}">
            
            <key>
                <xsl:choose>
                    <xsl:when test="boolean(string-length(awardNumber/@awardURI))">
                        <xsl:value-of select="concat($global_acronym, '/', awardNumber/@awardURI)"/>
                    </xsl:when>
                    <xsl:when test="boolean(string-length(awardNumber))">
                        <xsl:value-of select="concat($global_acronym, '/', awardNumber)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dcrifcsFunc:formatKey(awardTitle)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <activity>
                <xsl:attribute name="type">
                    <xsl:text>grant</xsl:text> <!-- ToDo: Activity type is set to 'grant' but consider how to determine wehther 'grant' or 'investment' -->
                </xsl:attribute>
                <name type="primary">
                    <namePart>
                        <xsl:choose>
                            <xsl:when test="boolean(string-length(awardTitle))">
                                <xsl:value-of select="awardTitle"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="boolean(string-length(awardNumber))">
                                    <xsl:value-of select="concat('AwardNumber: ', awardNumber, ' ')"/>
                                </xsl:if>
                                <xsl:if test="boolean(string-length(awardNumber/@awardURI))">
                                    <xsl:value-of select="concat('AwardURI: ', awardNumber/@awardURI, ' ')"/>
                                </xsl:if>
                             </xsl:otherwise>
                          </xsl:choose>
                        
                    </namePart>
                </name>
                <xsl:choose>
                    <xsl:when test="
                        boolean(string-length(awardNumber/@awardURI)) and
                        boolean(string-length(awardNumber))">
                        <identifier type="{awardNumber/@awardURI}">
                            <xsl:value-of select="awardNumber"/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="boolean(string-length(awardNumber/@awardURI))">
                        <identifier type="{awardNumber/@awardURI}">
                            <xsl:value-of select="@awardURI"/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="boolean(string-length(awardNumber))">
                        <identifier type="{awardNumber}">
                            <xsl:value-of select="awardNumber"/>
                        </identifier>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:choose>
                    <xsl:when test="boolean(string-length(funderIdentifier))">
                        <relatedInfo>
                            <identifier>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="funderIdentifier/@funderIdentifierType"/>
                                </xsl:attribute>
                                <xsl:value-of select="funderIdentifier"/>
                            </identifier>
                            <relation type="isFundedBy"/>
                        </relatedInfo>
                    </xsl:when>
                    <xsl:when test="boolean(funderName) and $global_create_and_relate_party_missing_identifier">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="concat($global_acronym, '/', dcrifcsFunc:formatKey(funderName))"/>
                            </key>
                            <relation type="isFundedBy"/>
                        </relatedObject>
                    </xsl:when>
                </xsl:choose>
            </activity>
        </registryObject>
    </xsl:template>
    
    
    <xsl:template match="value | type" mode="getValue">
        <xsl:value-of select="text()"/>
    </xsl:template>
    
    
    <xsl:template match="contributor" mode="datacite_4_to_rifcs_party">
    
        <xsl:param name="originatingSource" as="xs:string*"/>
        <xsl:variable name="url" select="concat($registry_identifier_normalise_api_url, '?identifier_value=', encode-for-uri(nameIdentifier), '&amp;identifier_type=', encode-for-uri(nameIdentifier/@nameIdentifierScheme))"/>
        <xsl:variable name="response" select="document($url)" />
        <xsl:variable name="normalisedIdentifier">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'value']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="normalisedIdentifierType">
            <xsl:for-each select="$response/*">
                <xsl:apply-templates select="node()[name() = 'type']" mode="getValue"/>
            </xsl:for-each>
        </xsl:variable>
        <registryObject group="{$global_group}">
            
            <key>
                <xsl:choose>
                    <xsl:when test="string-length($normalisedIdentifier) &gt; 0">
                        <xsl:value-of select="concat($global_acronym, '/', $normalisedIdentifier)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dcrifcsFunc:formatKey(contributorName)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <party>
                <xsl:attribute name="type">
                    <xsl:apply-templates select="." mode="party_type_core"/>
                </xsl:attribute>
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(contributorName)"/>
                    </namePart>
                </name>
                <identifier>
                    <xsl:attribute name="type">
                        <xsl:value-of select="$normalisedIdentifierType"/>
                    </xsl:attribute>
                    <xsl:value-of select="$normalisedIdentifier"/>
                </identifier>
            </party>
        </registryObject>
    </xsl:template>
    
    <!-- ***************************************** -->
    <!-- FUNCTIONS -->
    
    <xsl:function name="dcrifcsFunc:formatName">
        <xsl:param name="nameNode" as="node()"/>
        
        <xsl:message select="concat('formatName input: ', $nameNode/text())"/>
        
        <!-- If name is organizational, leave as is -->
        <xsl:choose>
            <xsl:when test="'Organizational' = $nameNode/@nameType">
                <xsl:value-of select="$nameNode/text()"/>
            </xsl:when>
            <!-- HES-69 if name of the funder, leave as is -->
            <xsl:when test="local-name($nameNode)  = 'funderName'">
                <xsl:value-of select="$nameNode/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="namePart_sequence" as="xs:string*">
                    <xsl:analyze-string select="$nameNode/text()" regex="[A-Za-z()-]+">
                        <xsl:matching-substring>
                            <xsl:if test="regex-group(0) != '-'">
                                <xsl:value-of select="regex-group(0)"/>
                            </xsl:if>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="count($namePart_sequence) = 0">
                        <xsl:value-of select="$nameNode/text()"/>
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
    