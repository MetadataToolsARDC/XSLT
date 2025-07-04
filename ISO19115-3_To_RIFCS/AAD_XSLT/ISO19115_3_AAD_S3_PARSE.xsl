<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s3="http://s3.amazonaws.com/doc/2006-03-01/"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0" 
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs xsi xsl s3 mdb mcc cit">
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_acronym" select="'AADC'"/>
    <xsl:param name="global_baseURI" select="'https://data.aad.gov.au'"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_path" select="'/metadata/'"/>
    <xsl:param name="global_group" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_publisherName" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    <xsl:param name="global_base_url" select="'https://transfer.data.aad.gov.au'"/>
    <xsl:param name="global_folder" select="'/aadc-metadata/'"/>
    <xsl:param name="global_prefix" select="'?prefix=iso-19115-1/'"/>
    
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="cwd" select="base-uri(/)"/>
    <xsl:variable name="cwdDir" select="replace($cwd, '[^/]+$', '')"/>
    
    <!-- Override key contructon to use old method -->
    <xsl:template match="mcc:code" mode="registryObject_key">
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
        
    </xsl:template>
    
    <xsl:template match="/">
        
        <!-- Fetch all keys using pagination (limited to 2 pages for now) -->
        <xsl:variable name="allKeys" as="element(s3:Key)*">
            <xsl:call-template name="get-all-keys">
                <xsl:with-param name="url" select="concat($global_base_url, $global_folder, $global_prefix)"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Batch the keys in groups of 200 -->
        <xsl:for-each-group select="$allKeys[ends-with(., '.xml')]" group-adjacent="(position() - 1) idiv 200">
            <xsl:variable name="batch" select="current-group()"/>
            <xsl:variable name="ts" select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]T[H01][m01]')"/>
            <xsl:variable name="filename" select="concat($ts, '-', position(), '.xml')"/>
            
            <xsl:result-document href="{$filename}" method="xml" indent="yes">
                <registryObjects
                    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
                    
                    <xsl:for-each select="$batch">
                        <xsl:variable name="relative_path" select="concat($global_folder, .)"/>
                        <xsl:variable name="full_url" select="resolve-uri($relative_path, $global_base_url)"/>
                        <xsl:message select="concat('Getting metadata from url: ', $full_url)"/>
                        
                        <xsl:try>
                            <xsl:variable name="doc" select="document($full_url)"/>
                            
                            <xsl:choose>
                                <xsl:when test="$doc//s3:Error">
                                    <xsl:message select="concat('Error returned: ', $doc//s3:Error)"/>
                                </xsl:when>
                                <xsl:when test="$doc/mdb:MD_Metadata">
                                    <xsl:apply-templates select="$doc/mdb:MD_Metadata" mode="process"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message select="'Unexpected metadata returned - skipping'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <xsl:catch>
                                <xsl:message select="concat('Failed to load or parse XML from: ', $full_url)"/>
                            </xsl:catch>
                        </xsl:try>
                        
                    </xsl:for-each>
                    
                </registryObjects>
            </xsl:result-document>
        </xsl:for-each-group>
        
        <!-- Main output: combined registryObjects -->
        <registryObjects
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <!--xsl:for-each select="$allTempFiles">
                <xsl:copy-of select="/*"/>
            </xsl:for-each-->
            
        </registryObjects>
        
    </xsl:template>
    
    <!-- Recursive pagination through S3 listing (up to 2 pages) -->
    <xsl:template name="get-all-keys">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="accum" as="element(s3:Key)*" select="()"/>
        <xsl:param name="page" as="xs:integer" select="1"/>
        
        <xsl:message select="concat('get-all-keys has url: ', $url)"/>
        <xsl:message select="concat('get-all-keys has page: ', $page)"/>
        
        <xsl:variable name="doc" select="document($url)"/>
        <xsl:variable name="newKeys" select="$doc//s3:Contents/s3:Key"/>
        <xsl:variable name="isTruncated" select="lower-case($doc//s3:IsTruncated) = 'true'"/>
        <xsl:variable name="nextMarker" select="string($doc//s3:NextMarker)"/>
        
        <xsl:message select="concat('nextMarker: ', $nextMarker)"/>
        
        <xsl:choose>
            <xsl:when test="$isTruncated and string-length($nextMarker) gt 0">
                <xsl:call-template name="get-all-keys">
                    <!--xsl:with-param name="url" select="concat($url, '&amp;marker=', encode-for-uri($nextMarker))"/-->
                    <xsl:with-param name="url" select="concat(concat($global_base_url, $global_folder, $global_prefix), '&amp;marker=', encode-for-uri($nextMarker))"/>
                    <xsl:with-param name="accum" select="$accum, $newKeys"/>
                    <xsl:with-param name="page" select="$page + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$accum, $newKeys"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
