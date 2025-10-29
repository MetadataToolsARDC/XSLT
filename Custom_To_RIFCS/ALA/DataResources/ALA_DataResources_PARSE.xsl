<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:local="http://local.to.here"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs xsi xsl fn array map local">
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_acronym" select="'ALA'"/>
    <xsl:param name="global_baseURI" select="'https://collections.ala.org.au'"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_pathUI" select="'/public/show/'"/>
    <xsl:param name="global_pathWS" select="'/ws/dataResource'"/>
    <xsl:param name="global_group" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_publisherName" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    <!--xsl:param name="global_allKeysURL" select="'https://biocache.ala.org.au/ws/occurrences/facets?q=*:*&amp;facets=dataResourceUid&amp;count=true&amp;lookup=true&amp;flimit=10000'"/-->
    <xsl:param name="global_allKeysURL" select="'https://raw.githubusercontent.com/MetadataToolsARDC/XSLT/refs/heads/master/Custom_To_RIFCS/ALA/DataResources/CachedKeyCall_Mini.json'"/>
    <!--xsl:param name="global_base_url" select="'https://transfer.data.aad.gov.au'"/-->
    <!--xsl:param name="global_folder" select="'/aadc-metadata/'"/-->
    <!--xsl:param name="global_prefix" select="'?prefix=iso-19115-1/'"/-->
    
    
    <xsl:import href="ALA_DataResource_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="cwd" select="base-uri(/)"/>
    <xsl:variable name="cwdDir" select="replace($cwd, '[^/]+$', '')"/>
    
    <!-- Override key contructon to use old method -->
    <!--xsl:template match="mcc:code" mode="registryObject_key">
        <xsl:variable name="uuid_sequence" select="ancestor::mdb:MD_Metadata/mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(mcc:description, 'uuid') and (string-length(mcc:code) > 0)][1]/mcc:code" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($uuid_sequence[1])) > 0">
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', normalize-space($uuid_sequence[1]))"/>
                </key>
            </xsl:when>
            <xsl:otherwise>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
                </key>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template-->
    
    <xsl:function name="local:processArrayEntry">
        <xsl:message select="concat('Map size ', map:size(.))"/>
    </xsl:function>
   
    <xsl:template match="/">
        
        <xsl:message select="concat('getKeys has url: ', $global_allKeysURL)"/>
        
        
       <!-- Get all keys -->
        <xsl:variable name="allKeys" as="xs:string*">
            <xsl:call-template name="getKeys">
                <xsl:with-param name="url" select="$global_allKeysURL"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Batch the keys in groups of 200 -->
        <xsl:for-each-group select="$allKeys" group-adjacent="(position() - 1) idiv 200">
            <xsl:variable name="batch" select="current-group()"/>
            <xsl:variable name="ts" select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]T[H01][m01]')"/>
            <xsl:variable name="filename" select="concat($ts, '-', position(), '.xml')"/>
            
            <xsl:result-document href="{$filename}" method="xml" indent="yes">
                <registryObjects
                    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
                    
                    <xsl:for-each select="$batch">
                        <xsl:variable name="fullURL" select="concat($global_baseURI, $global_pathWS, '/', .)"/>
                        
                        
                        <xsl:try>
                            <xsl:variable name="doc" select="fn:json-to-xml($fullURL)"/>
                            
                            <xsl:choose>
                                <xsl:when test="not(has-children($doc))">
                                    <xsl:message select="'Doc is empty'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$doc" mode="process"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <xsl:catch>
                                <xsl:message select="concat('Failed to load or parse XML from: ', $fullURL)"/>
                            </xsl:catch>
                        </xsl:try>
                            
                    </xsl:for-each>
                    
                </registryObjects>
            </xsl:result-document>
        </xsl:for-each-group>
        
    </xsl:template>
    
    <!-- Recursive pagination through S3 listing (up to 2 pages) -->
    <xsl:template name="getKeys">
        <xsl:param name="url"/>
        
        <xsl:variable name="unparsedText" select="fn:unparsed-text($global_allKeysURL)"/>
        <xsl:variable name="parsedJson" select="fn:parse-json($unparsedText)"/>
        
        <xsl:message select="concat('Array size ', array:size($parsedJson))"/>
        
        <xsl:variable name="topMap1" select="array:get($parsedJson, 1)"/>
        <xsl:message select="concat('Map size ', map:size($topMap1))"/>
        
        <xsl:variable name="topMap1_keys" select="map:keys($topMap1)"/>
        
        <xsl:choose>
            <xsl:when test="map:contains($topMap1, 'fieldResult')">
                <xsl:message select="'Map contains fieldResult as expected'"/>
                <xsl:variable name="fieldResults" select="map:get($topMap1, 'fieldResult')"/>
                <xsl:message select="concat('Array size ', array:size($fieldResults))"/>
                <xsl:for-each select="array:flatten($fieldResults)">
                    <xsl:choose>
                        <xsl:when test="map:contains(., 'i18nCode')">
                            <xsl:variable name="i18nCode" select="map:get(., 'i18nCode')"/>
                            
                            <xsl:choose>
                                <xsl:when test="starts-with($i18nCode, 'dataResourceUid.dr') and (string-length(fn:substring-after($i18nCode, 'dataResourceUid.dr')) > 0)">
                                    <xsl:message select="concat('Retrieved i18nCode: ', fn:substring-after($i18nCode, 'dataResourceUid.'))"/>
                                    <xsl:value-of select="fn:substring-after($i18nCode, 'dataResourceUid.')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message select="'i18nCode does not conform to format expected where it is a value after dataResourceUid.dr'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                           
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message select="'Map does not contain i18nCode, so dataResource cannot be processed'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'Map does not contain fieldResult as expected, so no dataResources can be processed'"/>
            </xsl:otherwise>
        </xsl:choose>
     </xsl:template>
    
</xsl:stylesheet>
