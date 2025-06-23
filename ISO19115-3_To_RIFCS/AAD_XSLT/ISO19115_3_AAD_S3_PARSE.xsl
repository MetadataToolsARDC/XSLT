<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s3="http://s3.amazonaws.com/doc/2006-03-01/"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
    exclude-result-prefixes="xs xsi xsl s3 mdb">
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_acronym" select="'AAD'"/>
    <xsl:param name="global_baseURI" select="'https://data.aad.gov.au'"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_path" select="'/metadata/'"/>
    <xsl:param name="global_group" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_publisherName" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    <xsl:param name="global_base_url" select="'https://transfer.data.aad.gov.au'"/>
    <xsl:param name="global_folder" select="'/aadc-metadata/'"/>
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="cwd" select="base-uri(/)"/>
    <xsl:variable name="cwdDir" select="replace($cwd, '[^/]+$', '')"/>
    
    <xsl:template match="/">
        <!-- Write temp files -->
        <xsl:for-each select="/*/s3:Contents/s3:Key[ends-with(., '.xml')]">
            <xsl:variable name="relative_path" select="concat($global_folder, .)"/>
            <xsl:variable name="full_url" select="resolve-uri($relative_path, $global_base_url)"/>
            <xsl:message select="concat('Full url: ', $full_url)"/>
            <xsl:variable name="doc" select="document($full_url)"/>
            <xsl:if test="$doc/mdb:MD_Metadata">
                <xsl:variable name="ts" select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]T[H01][m01]')"/>
                <xsl:variable name="filename" select="concat($ts, '-', position(), '.xml')"/>
                <xsl:message select="concat('Writing file: ', $filename)"/>
                <xsl:result-document href="{$filename}" method="xml" indent="yes">
                    <xsl:apply-templates select="$doc/mdb:MD_Metadata" mode="process"/>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
        
        <!-- Load all temp files -->
        <xsl:variable name="allTempFiles" select="collection(concat($cwdDir, '?select=????????T????-*.xml;recurse=no'))"/>
        
        <xsl:message select="concat('Number of temp files: ', count($allTempFiles))"/>
        
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
    
</xsl:stylesheet>
