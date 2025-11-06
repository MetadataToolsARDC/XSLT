<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    exclude-result-prefixes="xs math xsi"
    version="3.0">
        
    <xsl:param name="global_originatingSource" select="'Research Organization Registry (ROR)'"/>
    <xsl:param name="global_group" select="'Research Organization Registry (ROR)'"/> 
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*" />
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//items"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="items">
        <xsl:variable name="key" as="xs:string">
            <xsl:value-of select="id"/>
        </xsl:variable>
        <xsl:apply-templates select="." mode="process">
            <xsl:with-param name="key" select="$key"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="items" mode="process">
        <xsl:param name="key"/>
        <xsl:message select="concat('RoR source has children: ', has-children(.))"/>
        <xsl:message select="concat('Received key: ', $key)"/>
        
        <registryObject group="{$global_group}">
            
            <xsl:call-template name="key">
                <xsl:with-param name="key" select="$key"/>
            </xsl:call-template>
            
            <xsl:call-template name="originatingSource">
                <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            </xsl:call-template>
            
            <xsl:apply-templates select="." mode="collection">
                <xsl:with-param name="key" select="$key"/>
            </xsl:apply-templates>
            
        </registryObject>
    </xsl:template>
    
    <xsl:template name="key">
        <xsl:param name="key"/>
        
        <xsl:if test="string-length($key) > 0">
            <key>
                <xsl:value-of select="$key"/>
            </key>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="originatingSource">
        <xsl:param name="originatingSource"/>
        <originatingSource>
            <xsl:value-of select="$originatingSource"/>
        </originatingSource>
    </xsl:template>
    
    <xsl:template match="items" mode="collection">
        <xsl:param name="key"/>
        
        <party type="group">
            
            <xsl:apply-templates select="id[string-length(.) > 0]" mode="identifier"/>
            
            <xsl:apply-templates select="names[count(types[contains(., 'ror_display')]) > 0]"/>
            
            <xsl:apply-templates select="id[string-length(.) > 0]" mode="location"/>
            
            <xsl:apply-templates select="source[string-length(.) > 0]" mode="description_notes"/>
            
            <!-- ToDo: Dates -->
            
            
            <xsl:apply-templates select="./*[starts-with(local-name(.), 'classification')]" mode="subject_classification"/>
            
            <xsl:apply-templates select="type[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="domain[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="description[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="notes[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="locations"/>
            
            <xsl:apply-templates select="." mode="rights_licence"/>
            
        </party>
    </xsl:template>
    
    <xsl:template match="id" mode="identifier">
        <identifier type="url">
            <xsl:apply-templates select="text()"/>
        </identifier>
        
        <xsl:if test="contains(.,'ror.org/')">
            <identifier type="ror">
                <xsl:value-of select="substring-after(., 'ror.org/')"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="names">
        <name type="primary">
            <namePart>
                <xsl:apply-templates select="value/text()"/>
            </namePart>
        </name>
        
    </xsl:template>
    
    
    <xsl:template match="description">
        <description type="brief">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="notes">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    
    <xsl:template match="id" mode="location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:apply-templates select="text()"/>
                    </value>
                </electronic>
            </address>
        </location>
        
    </xsl:template>
    
    <xsl:template match="source" mode="description_notes">
        <description type="notes">
            <xsl:value-of select="concat('Source: ', .)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="*" mode="subject_classification">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="type" mode="subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="domain" mode="subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    
    <xsl:template match="locations" mode="coverage">
        <xsl:apply-templates select="geonames_details"/>
        <xsl:apply-templates select="geonames_id"/>
    </xsl:template>
    
    
    <xsl:template match="geonames_details">
    
        <xsl:call-template name="spatial_point">
            <xsl:with-param name="lon" select="lng"/>
            <xsl:with-param name="lat" select="lat"/>
        </xsl:call-template>
        
        <xsl:apply-templates select="country_name[string-length(.) > 0]"/>
        <xsl:apply-templates select="country_subdivision_name[string-length(.) > 0]"/>
        <xsl:apply-templates select="continent_name[string-length(.) > 0]"/>
        
        
    </xsl:template>
    
    <xsl:template match="geonames_id">
        <!-- ToDo -->
    </xsl:template>
    
    <xsl:template match="country_name | country_subdivision_name | continent_name">
        <coverage>
            <spatial>
                <text>
                    <xsl:apply-templates select="text()"/>
                </text>
            </spatial>
        </coverage>
    </xsl:template>


    <xsl:template name="spatial_point">
        <xsl:param name="lon"/>
        <xsl:param name="lat"/>
        
        <xsl:if test="(string-length($lon) > 0) and (string-length($lat) > 0)">
            <coverage>
                <spatial type="kmlPolyCoords">
                    <xsl:value-of select="concat($lon, ',', $lat)"/>
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="items" mode="spatial_box">
        <xsl:if test="(string-length(maxlongitude) > 0)
            and (string-length(minlongitude) > 0)
            and (string-length(maxlatitude) > 0)
            and (string-length(minlatitude) > 0)">
            
            <coverage>
                <spatial type="iso19139dcmiBox">
                    <xsl:value-of select="concat('northlimit=',maxlatitude,'; southlimit=-',minlatitude,'; westlimit=',minlongitude,'; eastLimit=', maxlongitude,';')"/>
                </spatial> 
            </coverage>
            
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="items" mode="rights_licence">
        <rights>
            <licence>
                <xsl:if test="string-length(licence_link) > 0">
                    <xsl:attribute name="rightsUri">
                        <xsl:value-of select="licence_link"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="string-length(licence_notes) > 0">
                    <xsl:value-of select="licence_notes"/>
                </xsl:if>
            </licence>
        </rights>
    </xsl:template>
    
    <xsl:template match="*/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
</xsl:stylesheet>