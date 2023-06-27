<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dcrifcsFunc="http://dcrifcsFunc.nowhere.yet"
    exclude-result-prefixes="xsl custom fn xs xsi dcrifcsFunc">
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:strip-space elements="*"/>   
    
    <xsl:param name="global_originatingSource" select="'Crossref'"/>
    <xsl:param name="global_group" select="'Australian Research Data Commons'"/>
    <xsl:param name="global_acronym" select="'Crossref'"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_project_identifier_strings" select="'raid'" as="xs:string*"/>
    <xsl:param name="global_schemeFilter" select="'(Public Sector to Research Sector)|(National Data Assets)'" as="xs:string"/>
    <!--xsl:param name="global_schemeFilter" select="'Public Sector to Research Sector'"/-->
    <!--xsl:param name="global_baseURI" select="''"/-->
    <!--xsl:param name="global_path" select="''"/-->
      
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <xsl:message select="'Crossref_Grant_0.1.1_To_Rifcs'"/>
        <xsl:message select="concat('Creating ', count(JSON/message/items[matches(project/array/funding/array/scheme, $global_schemeFilter)]), ' Activity records where scheme contains :', $global_schemeFilter)"/>
        <registryObjects>
            <xsl:apply-templates select="JSON/message/items[matches(project/array/funding/array/scheme, $global_schemeFilter)]" mode="Crossref_0.1.1_to_rifcs_collection">
                <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            </xsl:apply-templates>  
        </registryObjects>
        
    </xsl:template>
    
    <xsl:template match="items" mode="resourceSubType">
        <xsl:choose>
            <xsl:when test="count(contains(lower-case(type), 'grant')) > 0">
                <xsl:value-of select="'investment'"/>
            </xsl:when>
            <xsl:when test="count(contains(lower-case(type), 'dataset')) > 0">
                <xsl:value-of select="'dataset'"/>
            </xsl:when>
            <xsl:when test="count(contains(lower-case(type), 'text')) > 0">
                <xsl:value-of select="'publication'"/>
            </xsl:when>
            <xsl:when test="count(contains(lower-case(type), 'text')) > 0">
                <xsl:value-of select="'software'"/>
            </xsl:when>
            <xsl:when test="count(contains(lower-case(type), 'service')) > 0">
               <xsl:value-of select="'report'"/>
            </xsl:when>
            <xsl:when test="count(contains(lower-case(type), 'website')) > 0">
                <xsl:value-of select="'report'"/>
            </xsl:when>
            <xsl:when test="count(contains(lower-case(type), 'model')) > 0">
                <xsl:value-of select="'generate'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'collection'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="items" mode="Crossref_0.1.1_to_rifcs_collection">
        <xsl:param name="originatingSource" as="xs:string*"/>
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            
            <key>
                <xsl:value-of select="concat($global_acronym, '/', DOI[1])"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <xsl:variable name="class">
                <xsl:choose>
                    <xsl:when test="count(contains(lower-case(type), 'grant')) > 0">
                        <xsl:value-of select="'activity'"/>
                    </xsl:when>
                    <xsl:when test="count(contains(lower-case(type), 'website')) > 0">
                        <xsl:value-of select="'service'"/>
                    </xsl:when>
                    <xsl:when test="count(contains(lower-case(type), 'service')) > 0">
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
             
                <xsl:apply-templates select="DOI" mode="activity_identifier_doi"/>  
                
                <xsl:apply-templates select="DOI" mode="activity_location_doi"/>
                
                <xsl:apply-templates select="." mode="activity_name"/>
               
                <xsl:apply-templates select="project/array/funding/array/scheme" mode="activity_description_scheme"/>
               
               <xsl:apply-templates select="project/array/award-amount" mode="activity_description_amount"/>
                
                <xsl:apply-templates select="project/array/funding/array/funder" mode="activity_relatedInfo_funder"/>
               
               
               <xsl:apply-templates select="project/array/lead-investigator/array[string-length(ORCID) > 0]" mode="activity_relatedInfo_party_orcid"/>
                   
               <!--xsl:apply-templates select="created" mode="activity_dates"/-->
               
               <xsl:apply-templates select="created" mode="activity_dates_existenceDates"/>
               
               <xsl:apply-templates select="project/array/project-description/array/description" mode="activity_description_brief"/>
               
               <!--
               <xsl:apply-templates select="relatedIdentifiers/relatedIdentifier" mode="activity_relatedInfo"/>
               
               <xsl:apply-templates select="relatedItems/relatedItem" mode="activity_relatedInfo"/>
               
               
               <xsl:apply-templates select="creators/creator[boolean(string-length(nameIdentifier))]" mode="activity_relatedInfo"/>
               <xsl:apply-templates select="contributors/contributor[boolean(string-length(nameIdentifier))]" mode="activity_relatedInfo"/>
               
               <xsl:apply-templates select="fundingReferences/fundingReference[boolean(string-length(awardNumber)) or boolean(string-length(awardNumber/@awardURI))]"  mode="activity_relatedInfo_grant"/>
               
               <xsl:apply-templates select="fundingReferences/fundingReference[boolean(string-length(awardTitle)) and (not(boolean(string-length(awardNumber))) and not(boolean(string-length(awardNumber/@awardURI))))]"  mode="activity_relatedObject_grant"/>
               
                <xsl:apply-templates select="subjects/subject" mode="activity_subject"/>
                
                <xsl:apply-templates select="geoLocations/geoLocation/geoLocationPlace[boolean(string-length(.))]" mode="activity_spatial_coverage"/>
                
                
                <xsl:apply-templates select="rightsList/rights[boolean(string-length(.))]" mode="activity_rights"/>
                
                <xsl:call-template name="rightsStatement"/>
                
                <xsl:choose>
                    <xsl:when test="count(descriptions/description[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="descriptions/description[boolean(string-length(.))]" mode="activity_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(titles/title[boolean(string-length(.))]) > 0">
                        <xsl:apply-templates select="titles/title[boolean(string-length(.))]" mode="activity_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="activity_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
               
               
                <xsl:apply-templates select="dates/date[(@dateType='Collected') and (boolean(string-length(.)))]" mode="activity_dates_coverage"/>  
                
                
                -->
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    
     <xsl:template match="@todo" mode="activity_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="identifier" mode="activity_extract_DOI_identifier">
        <!-- override to extract identifier from full citation, custom per provider -->
    </xsl:template>  
    
    <xsl:template match="DOI" mode="activity_identifier_doi">
        <identifier type="DOI">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="identifier[@xsi:type ='dcterms:URI']" mode="activity_location_if_no_DOI">
        <!--override if required-->
    </xsl:template>
    
    <xsl:template match="DOI" mode="activity_location_doi">
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
    
    <xsl:template match="items" mode="activity_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="concat(award, ' - ', normalize-space(project/array/project-title/array/title))"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="relatedIdentifier" mode="activity_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:apply-templates select="." mode="related_item_type"/>
            </xsl:attribute>
            
            <xsl:apply-templates select="." mode="identifier"/>
            <xsl:apply-templates select="." mode="relation"/>
            
        </relatedInfo>
    </xsl:template>
    
    <!-- For relating grant that has an awardNumber or awardNumber/@awardURI -->
    <xsl:template match="fundingReference" mode="activity_relatedInfo_grant">
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
    <xsl:template match="fundingReference" mode="activity_relatedObject_grant">
        <relatedObject>
            <key>
                <xsl:value-of select="dcrifcsFunc:formatKey(awardTitle)"/>
            </key>
            <relation type="isOutputOf"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="relatedItem" mode="activity_relatedInfo">
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
    
    <xsl:template match="contributor" mode="party_type_core">
        
        <xsl:choose>
            
            <!-- @nameType 'Personal' is default for nameType in Crossref, so only alter to group if 'Organizational' -->
            <xsl:when test="
                ('organizational' = lower-case(contributorName/@nameType)) or
                ('ror' = lower-case(nameIdentifier/@nameIdentifierScheme))"> 
                <xsl:text>group</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>person</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="creator" mode="party_type_core">
        
        <xsl:choose>
            
            <!-- @nameType 'Personal' is default for nameType in Crossref, so only alter to group if 'Organizational' -->
            <xsl:when test="
                ('organizational' = lower-case(creatorName/@nameType)) or
                ('ror' = lower-case(nameIdentifier/@nameIdentifierScheme))"> 
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
    
    
    
    <xsl:template match="lead-investigator/array" mode="activity_relatedInfo_party_orcid">
       <!-- Person -->
        <relatedInfo type='party'>
            <identifier type="ORCID">
                <xsl:value-of select="normalize-space(ORCID)"/>
            </identifier>
           <relation type="hasPrincipalInvestigator"/>
           <title>
               <xsl:value-of select="concat(given, ' ', family)"/>
           </title>
        </relatedInfo>
        
        <xsl:apply-templates select="affiliation/array[string-length(id/array/id) > 0]" mode="activity_relatedInfo_party_affiliation"/>
    </xsl:template>
    
    <xsl:template match="affiliation/array" mode="activity_relatedInfo_party_affiliation">
        
         <!-- Affiliated Group -->
         <relatedInfo type='party'>
             <identifier type="{id/array/id-type}">
                 <xsl:value-of select="normalize-space(id/array/id)"/>
             </identifier>
             <relation type="isManagedBy"/>
             <title>
                 <xsl:value-of select="name"/>
             </title>
         </relatedInfo>
    </xsl:template>
    
    <!-- For a creator who has a nameIdentifier -->
     <xsl:template match="creator" mode="activity_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <!-- Switch the two lines below (i.e. comment one and uncomment the other) 
                    if you want 'person' and 'group' rather than 'party' -->
                <!--xsl:apply-templates select="." mode="party_type_core"/-->
                <xsl:text>party</xsl:text>
            </xsl:attribute>
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="nameIdentifier/@nameIdentifierScheme"/>
                </xsl:attribute>
                <xsl:value-of select="nameIdentifier"/>
            </identifier>
            <title>
                <xsl:value-of select="dcrifcsFunc:formatName(creatorName)"/> 
            </title>
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template>
    
    <!-- For contributor who has a name identifier -->
    <xsl:template match="contributor" mode="activity_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <!-- Switch the two lines below (i.e. comment one and uncomment the other) 
                    if you want 'person' and 'group' rather than 'party' -->
                <!--xsl:apply-templates select="." mode="party_type_core"/-->
                <xsl:text>party</xsl:text>
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
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template>
    
   <!-- For funder who has a name identifier -->
    <xsl:template match="funder" mode="activity_relatedInfo_funder">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:text>party</xsl:text>
            </xsl:attribute>
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="id/array/id-type"/>
                </xsl:attribute>
                <xsl:value-of select="id/array/id"/>
            </identifier>
            <title>
                <xsl:value-of select="name"/> 
            </title>
            
            <!-- Was using vocab term 'isEnrichedBy' to relate this Collection to the (funder) Party, 
                 noting that the vocabs documentation specifies that 'isFundedBy' ought only be for where:
                - a Party is funded by a Party
                - a Party is funded by a (program) Activity
                - an Activity is funded by a (program) Activity 
            
                Now using newly proposed "isInvestedBy" -->
            <relation type="isInvestedBy"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="created" mode="activity_dates">
        <dates type="created">
            <date type="dateFrom">
                <xsl:value-of select="date-time"/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="created" mode="activity_dates_existenceDates">
        <existenceDates>
            <startDate dateFormat="W3CDTF">
                <xsl:value-of select="date-time"/>
            </startDate>
        </existenceDates>
    </xsl:template>

    
    <xsl:template match="subject" mode="activity_subject">
        <xsl:if test="boolean(string-length(.))">
            <subject type="local">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:if>
    </xsl:template>
   
    <xsl:template match="geoLocationPlace" mode="activity_spatial_coverage">
        <coverage>
            <spatial type='text'>
                <xsl:value-of select='normalize-space(.)'/>
            </spatial>
        </coverage>
    </xsl:template>
   
    <xsl:template name="rightsStatement">
        <!-- override with rights statement for all in olac_dc if required -->
    </xsl:template>
   
    <xsl:template match="rights" mode="activity_rights">
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
    
    <xsl:template name="activity_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="description" mode="activity_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="title" mode="activity_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="scheme" mode="activity_description_scheme">
        <description type="fundingScheme">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="award-amount" mode="activity_description_amount">
        <description type="fundingAmount">
            <xsl:value-of select="concat(amount, ' ', currency)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="date" mode="activity_dates_coverage">
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
    
    <xsl:template match="resource" mode="activity_citationInfo_citationMetadata">
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
    
    
    <xsl:template match="fundingReference" mode="Crossref_0.1.1_to_rifcs_activity">
        <xsl:param name="originatingSource" as="xs:string"/>
        
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
                
                <xsl:if test="boolean(string-length(funderIdentifier))">
                    <relatedInfo>
                        <identifier>
                            <xsl:attribute name="type">
                                <xsl:value-of select="funderIdentifier/@funderIdentifierType"/>
                            </xsl:attribute>
                            <xsl:value-of select="funderIdentifier"/>
                        </identifier>
                        <relation type="isFundedBy"/>
                    </relatedInfo>
                </xsl:if>
                    
            </activity>
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