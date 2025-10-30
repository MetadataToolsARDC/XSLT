<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:local="http://local.to.here"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
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
    <xsl:param name="global_pathDataResource_ws" select="'/ws/dataResource'"/>
    <xsl:param name="global_pathEML_ws" select="'/ws/eml'"/>
    <xsl:param name="global_group" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_publisherName" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    <!--xsl:param name="global_allKeysURL" select="'https://biocache.ala.org.au/ws/occurrences/facets?q=*:*&amp;facets=dataResourceUid&amp;count=true&amp;lookup=true&amp;flimit=10000'"/-->
    <!--xsl:param name="global_allKeysURL" select="'https://metadatatoolsardc.github.io/XSLT/ALA/CachedKeyCall_Mini.json'"/-->
    <xsl:param name="global_allKeysURL" select="'file:/home/melanie/git/XSLT/docs/ALA/CachedKeyCall_Mini.json'"/>
   
    
    <xsl:param name="global_ElementNameKeyArray" select="'fieldResult'"/>
    <xsl:param name="global_ElementNameKey" select="'i18nCode'"/>
    <xsl:param name="global_KeyPrefix" select="'dataResourceUid.'"/>
    
    <!-- Keys at: https://biocache.ala.org.au/ws/occurrences/facets?q=*:*&amp;facets=dataResourceUid&amp;count=true&amp;lookup=true&amp;flimit=10000 -->
    <!-- EML XML at: https://collections.ala.org.au/ws/eml/dr23206 -->
    <!-- Custom Json at: https://collections.ala.org.au/ws/dataResource/dr23206 -->
    
    <xsl:import href="ALA_DataResource_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
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
                        
                        <xsl:variable name="fullURL" select="concat($global_baseURI, $global_pathEML_ws, '/', .)"/>
                        <xsl:variable name="fullURL" select="'file:/home/melanie/git/XSLT/docs/ALA/dr23206_eml.xml'"/>
                        <xsl:variable name="fullURL" select="'file:/home/melanie/git/projects/CentreForSafeAir/2.1.1_AlteredExampleFromAirHealth_OneDatasetOnly_Valid_20220221_IvanAttemptMelanieUpdated.xml'"/>
                        <xsl:message select="concat('Loading doc from: ', $fullURL)"/>
                        
                        <xsl:choose>
                            <xsl:when test="fn:doc-available($fullURL)">
                                <xsl:try>
                                    <xsl:variable name="doc" select="fn:doc($fullURL)"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="not(has-children($doc))">
                                            <xsl:message select="'Doc is empty'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="$doc"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                    <xsl:catch>
                                        <xsl:message select="concat('Failed to load or parse XML from: ', $fullURL)"/>
                                        <xsl:value-of select="concat('&#x00a0;Error code: ', $err:code, ' and Error Desc is: ', $err:description)"/>
                                    </xsl:catch>
                                </xsl:try>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message select="concat('No doc available at: ', $fullURL)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                                
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
            <xsl:when test="map:contains($topMap1, $global_ElementNameKeyArray)">
                <xsl:message select="concat('Map contains ', $global_ElementNameKeyArray, ' as expected')"/>
                <xsl:variable name="results" select="map:get($topMap1, $global_ElementNameKeyArray)"/>
                <xsl:message select="concat('Array size ', array:size($results))"/>
                <xsl:for-each select="array:flatten($results)">
                    <xsl:choose>
                        <xsl:when test="map:contains(., $global_ElementNameKey)">
                            <xsl:variable name="key" select="map:get(., $global_ElementNameKey)"/>
                            
                            <xsl:choose>
                                <xsl:when test="starts-with($key, 'dataResourceUid.dr') and (string-length(fn:substring-after($key, $global_KeyPrefix)) > 2)">
                                    <xsl:message select="concat('Retrieved key: ', fn:substring-after($key, $global_KeyPrefix))"/>
                                    <xsl:value-of select="fn:substring-after($key, $global_KeyPrefix)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message select="concat('Key ', $key, ' found does not conform to format expected, as there is no value after ', $global_KeyPrefix)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                           
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message select="'Map does not contain element ', $global_ElementNameKey, ', so dataResource cannot be processed'"/>
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
