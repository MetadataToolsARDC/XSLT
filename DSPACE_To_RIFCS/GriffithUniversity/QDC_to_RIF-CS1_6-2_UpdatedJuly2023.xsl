<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:qdc="http://dspace.org/qualifieddc/"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:custom="http://custom.nowhere.yet"
    version="2.0" exclude-result-prefixes="dc">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    
    <xsl:param name="global_originatingSource" select="'https://griffith.edu.au'"/>
    <xsl:param name="global_baseURI" select="'http://equella.rcs.griffith.edu.au'"/>
    <xsl:param name="global_group" select="'Griffith University'"/>
    <xsl:param name="global_publisherName" select="'Griffith University'"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="oai:OAI-PMH/*/oai:record">
         <xsl:variable name="oai_identifier" select="oai:header/oai:identifier"/>
         <xsl:message select="concat('identifier: ', oai:header/oai:identifier)"/>
         <xsl:if test="string-length($oai_identifier) > 0">
             
            <xsl:if test="count(oai:metadata/qdc:qualifieddc) > 0">
                 <xsl:apply-templates select="oai:metadata/qdc:qualifieddc" mode="collection">
                     <xsl:with-param name="oai_identifier" select="$oai_identifier"/>
                 </xsl:apply-templates>
                 
                 <xsl:apply-templates select="oai:metadata/qdc:qualifieddc" mode="party"/>
                 
             </xsl:if>
         </xsl:if>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc | qdc:qualifieddc" mode="collection">
        <xsl:param name="oai_identifier"/>
        
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="normalize-space(dc:type)"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$oai_identifier"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="$type = 'Dataset' or $type = ''">
                            <xsl:text>dataset</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
                <!-- ensuring that the DOI of the package is stored for later use, separated from the other identifiers -->
                <xsl:variable name="doiOfThisPackage_sequence" as="xs:string*">
                    <xsl:for-each select="dc:identifier">
                        <xsl:if test="'doi' = custom:getIdentifierType(.)">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:message select="concat('doiOfThisPackage_sequence[1]: ', $doiOfThisPackage_sequence[1])"></xsl:message>
                
        
                <!-- identifier -->
                <xsl:apply-templates select="dc:identifier" mode="object_identifier"/>
                
                <!-- name -->
                
                <xsl:apply-templates select="dc:title" mode="object_title"/>
                
                <!-- location -->
                <xsl:choose>
                    <xsl:when test="count($doiOfThisPackage_sequence) > 0">
                        <xsl:variable name="doiFormatted">
                            <xsl:choose>
                                <xsl:when test="starts-with($doiOfThisPackage_sequence[1], '10.')">
                                    <xsl:value-of select="concat('https://doi.org/', $doiOfThisPackage_sequence[1])"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$doiOfThisPackage_sequence[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="landingPage_url"> 
                            <xsl:with-param name="url" select="$doiFormatted"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- ToDo - find handle or some alternative for when there is no doi -->
                        <!--xsl:call-template name="landingPage_url"> 
                            <xsl:with-param name="url" select="$handle"/>
                        </xsl:call-template-->
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- related object -->
                <xsl:apply-templates select="dc:author" mode="object_relatedObject_author"/>
                <xsl:apply-templates select="dc:creator" mode="object_relatedObject_creator"/>
                
                <!-- subject -->
                <xsl:apply-templates select="dc:subject" mode="object_subject"/>
                
                <!-- description -->
                <xsl:apply-templates select="dcterms:abstract" mode="object_description_full"/>
                <xsl:apply-templates select="dcterms:description" mode="object_description_brief"/>
                
               
                

                
                <!-- coverage - temporal -->
                <xsl:variable name="temporalCoverage_sequence" as="xs:string*">
                    <xsl:for-each select="dc:coverage.temporal">
                        <xsl:if test="string-length(.) > 0">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:if test="count($temporalCoverage_sequence) &gt; 0 and count($temporalCoverage_sequence) &lt; 3">
                    <coverage>
                        <temporal>
                            <xsl:for-each select="distinct-values($temporalCoverage_sequence)">
                                <xsl:variable name="type">
                                    <xsl:choose>
                                        <xsl:when test="position() = 1">
                                            <xsl:text>dateFrom</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="position() = 2">
                                            <xsl:text>dateTo</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- assert confirms no otherwise -->      
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:if test="string-length($type) > 0">
                                    <date type="{$type}" dateFormat="W3CDTF">
                                        <xsl:value-of select="."/>
                                    </date>
                                </xsl:if>
                            </xsl:for-each>
                        </temporal>
                    </coverage>
                </xsl:if>
                
                <!-- spatial coverage - text -->
                <xsl:if test="string-length(dc:coverage.spatial) > 0">
                    <coverage>
                        <spatial type="text">
                            <xsl:value-of select="dc:coverage.spatial"/>
                        </spatial>
                    </coverage>
                </xsl:if>
                
                
                <!-- spatial coverage - points -->
                <xsl:if test="string-length(dc:coverage.spatial.long) > 0 and string-length(dc:coverage.spatial.lat)">
                     <coverage>
                        <spatial type="gmlKmlPolyCoords">
                            <xsl:value-of select="concat(dc:coverage.spatial.long, ',', dc:coverage.spatial.lat)"/>
                        </spatial>
                    </coverage>
                </xsl:if>
                
                <!-- dates -->
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'available'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'created'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'dateAccepted'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'dateSubmitted'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'issued'"/>
                </xsl:call-template>    
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'valid'"/>
                </xsl:call-template>   
                
                 <!-- rights -->
                <xsl:if test="(count(dc:rights.license) = 1) and string-length(dc:rights.license) > 0">
                    <xsl:variable name="licenseLink" select="dc:rights.license"/>
                    <xsl:for-each
                        select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
                        <xsl:if test="string-length(normalize-space(gml:remarks))">
                            <xsl:if test="contains($licenseLink, gml:remarks)">
                                <rights>
                                    <licence>
                                        <xsl:attribute name="type" select="gml:identifier"/>
                                        <xsl:attribute name="rightsUri" select="$licenseLink"/>
                                        <xsl:if test="string-length(normalize-space(gml:name))">
                                            <xsl:value-of select="normalize-space(gml:name)"/>
                                        </xsl:if>
                                    </licence>
                                </rights>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                
                <xsl:if test="(count(dc:rights.accessRights) = 1) and string-length(dc:rights.accessRights) > 0">
                    <xsl:if test="lower-case(dc:rights.accessRights) = 'open'">
                          <rights>
                            <accessRights type="open"/>
                          </rights>
                    </xsl:if>
                </xsl:if>
                
               <!-- citationInfo -->
                <xsl:if test="string-length(dc:identifier.bibliographicCitation)">
                    <citationInfo>
                        <fullCitation>
                            <xsl:value-of select="dc:identifier.bibliographicCitation"/>
                        </fullCitation>
                    </citationInfo>
                </xsl:if>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="dc:identifier" mode="object_identifier">
        <xsl:variable name="identifierAllContent" select="."/>
        <xsl:variable name="identifierExtracted_sequence" as="xs:string*">
            <xsl:choose>
                <xsl:when test="contains(lower-case($identifierAllContent), 'http') and
                    not(boolean(contains($identifierAllContent, ' ')))">
                    <xsl:analyze-string select="normalize-space($identifierAllContent)"
                        regex="(http|https):[^&quot;]*">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(0)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$identifierAllContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--xsl:message select="concat('identifierAllContent: ', $identifierAllContent)"></xsl:message-->
        <!--xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                        <xsl:message select="concat('identifierExtracted: ', .)"></xsl:message>
                    </xsl:for-each-->
        <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
            <xsl:variable name="identifierType" select="custom:getIdentifierType(.)"></xsl:variable>
            <xsl:if test="string-length(.) > 0">
                <identifier type="{$identifierType}">
                    <xsl:value-of select="."/>
                </identifier>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="dc:title" mode="object_title">
        <xsl:if test="string-length(.) > 0">
            <name type="primary">
                <namePart>
                    <xsl:value-of select="."/>
                </namePart>
            </name>
        </xsl:if>
    </xsl:template>
   
   <xsl:template name="landingPage_url">
       <xsl:param name="url"/>
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="$url"/>
                    </value>
                </electronic>
            </address>
        </location>
   </xsl:template>
    
    <xsl:template match="dc:author" mode="object_relatedObject_author">
        <xsl:if test="string-length(.) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space(.), ' ', ''))"/>
                </key>
                <relation type="hasCollector"/>
                
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <!-- related object -->
    <xsl:template match="dc:creator" mode="object_relatedObject_creator">
        <xsl:if test="string-length(.) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space(.), ' ', ''))"/>
                </key>
                <relation type="isCollectedBy"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <!-- subject -->
    <xsl:template match="dc:subject" mode="object_subject">
        <xsl:if test="string-length(.) > 0">
            <subject type="local">
                <xsl:value-of select="."/>
            </subject>
        </xsl:if>
    </xsl:template>
    
    <!-- description -->
    
    <xsl:template match="dcterms:abstract" mode="object_description_full">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="dcterms:description" mode="object_description_brief">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
               
    
    
    <xsl:template name="dates">
        <xsl:param name="dcType"/>
        <xsl:for-each select="*[contains(name(), $dcType)]">
            <xsl:if test="string-length(.) > 0">
                <!--xsl:message select="concat('Node name:', name())"/-->
                <xsl:variable name="type">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:text>dateFrom</xsl:text>
                        </xsl:when>
                        <xsl:when test="position() = 2">
                            <xsl:text>dateTo</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- assert confirms no otherwise -->      
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($type) > 0">
                    <xsl:variable name="dcType" select="substring-after(name(.), 'dc:date.')"/>
                    <dates type="{$dcType}">
                        <date type="{$type}" dateFormat="W3CDTF">
                            <xsl:value-of select="."/>
                        </date>
                    </dates>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc | qdc:qualifieddc" mode="party">
         <xsl:for-each select="dc:creator|dc:author|dc:funding">
            <xsl:if test="string-length(normalize-space(.)) > 0"></xsl:if>
            
            <xsl:variable name="key">
                <xsl:variable name="raw" select="translate(normalize-space(.), ' ', '')"/>
                <xsl:choose>
                    <xsl:when test="substring($raw, string-length($raw), 1) = '.'">
                        <xsl:value-of select="substring($raw, 0, string-length($raw))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$raw"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="objectType_sequence" as="xs:string*">
                <xsl:choose>
                    <xsl:when test="contains(name(), 'funding')">
                        <xsl:text>activity</xsl:text>
                        <xsl:text>grant</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., ',')">
                        <xsl:text>party</xsl:text>
                        <xsl:text>person</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>party</xsl:text>
                        <xsl:text>group</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable> 
            
            <xsl:variable name="object" select="$objectType_sequence[1]"/>
            <xsl:variable name="type" select="$objectType_sequence[2]"/>
            
            <xsl:if test="string-length($key) > 0">
                 <registryObject group="{$global_group}">
                     <key>
                         <xsl:value-of select="concat($global_baseURI, '/', $key)"/>
                     </key>
                     <originatingSource>
                         <xsl:value-of select="$global_originatingSource"/>
                     </originatingSource>
                     
                     <xsl:element name="{$object}">
                         <xsl:attribute name="type" select="$type"/>
                         <name type="primary">
                             <namePart>
                                <xsl:value-of select="."/>
                             </namePart>
                         </name>
                     </xsl:element>
                 </registryObject>
             </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
</xsl:stylesheet>
