<xsl:stylesheet 
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:local="http://local/function" 
    exclude-result-prefixes="xs math local xsi"
    version="3.0">
    
    <xsl:param name="global_group" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_acronym" select="'ALA'"/>
    <xsl:param name="global_originatingSource" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_prefixURL" select="'https://collections.ala.org.au/public/show/'"/>
    <xsl:param name="global_prefixKey" select="'ala.org.au/'"/>
    <xsl:param name="serverUrl"/>
    <xsl:param name="dateCreated" />
    <xsl:param name="lastModified" />
    
    <xsl:variable name="rifcsVersion" select="1.6"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*" />
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:variable name="key" as="xs:string">
                <xsl:value-of select="map/string[@key='uid']"/>
            </xsl:variable>
            <xsl:apply-templates select="." mode="process">
                <xsl:with-param name="key" select="$key"/>
            </xsl:apply-templates>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="map" mode="process">
        <xsl:param name="key"/>
        <xsl:message select="concat('ALA source has children: ', has-children(.))"/>
        
        <registryObject group="{$global_group}">
            
            <xsl:call-template name="key">
                <xsl:with-param name="key" select="concat($global_prefixKey, $key)"/>
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
        <key>
            <xsl:value-of select="$key"/>
        </key>
    </xsl:template>
    
    <xsl:template name="originatingSource">
        <xsl:param name="originatingSource"/>
        <originatingSource>
            <xsl:value-of select="$originatingSource"/>
        </originatingSource>
    </xsl:template>
    
    <xsl:template match="map" mode="collection">
        <xsl:param name="key"/>
        
        <collection type="collection">
            
            <xsl:call-template name="identifier">
                <xsl:with-param name="key" select="$key"/>
            </xsl:call-template>
            
            <xsl:apply-templates select="string[@key='name'][string-length(.) > 0]"/>
            
             <xsl:call-template name="location">
                <xsl:with-param name="key" select="$key"/>
            </xsl:call-template>
            
            
            <xsl:apply-templates select="map[@key='institution'][count(string[@key='uid'][string-length(.) > 0]) > 0]" mode="relatedInfo"/>
            <xsl:apply-templates select="array[@key='linkedRecordProviders']/map[count(string[@key='uid'][string-length(.) > 0]) > 0]" mode="relatedInfo_provider"/>
            
            <!-- ToDo: Dates -->
            
            
            <xsl:apply-templates select="array[@key='keywords']/string[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="array[@key='collectionType']/string[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="string[@key='pubShortDescription'][string-length(.) > 0]"/>
            
            <xsl:apply-templates select="string[@key='pubDescription'][string-length(.) > 0]"/>
            
            <xsl:if test="(count(string[@key='pubShortDescription'][string-length(.) > 0]) = 0)
                and (count(string[@key='pubDescription'][string-length(.) > 0]) = 0)">
                
                <xsl:apply-templates select="string[@key='name'][string-length(.) > 0]" mode="description"/>
                
            </xsl:if>
            
            <xsl:call-template name="spatial_point">
                <xsl:with-param name="lon" select="number[@key='longitude']"/>
                <xsl:with-param name="lat" select="number[@key='latitude']"/>
            </xsl:call-template>
            
            <xsl:apply-templates select="map[@key='geographicRange'][has-children(.)]" mode="spatial_box"/>
            
        </collection>
    </xsl:template>
    
    <xsl:template name="identifier">
        <xsl:param name="key"/>
        <identifier type="url">
            <xsl:value-of select="concat($global_prefixURL, $key)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="string[@key='name']">
        <name type="primary">
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
        
    </xsl:template>
    
    <xsl:template match="string[@key='name']" mode="description">
        <description type="brief">
            <xsl:value-of select="."/>
        </description>
        
    </xsl:template>
    
    
    <xsl:template match="string[@key='pubShortDescription']">
         <description type="brief">
             <xsl:value-of select="."/>
         </description>
    </xsl:template>
    
    
    <xsl:template match="string[@key='pubDescription']">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template name="location">
        <xsl:param name="key"/>
         <location>
             <address>
                 <electronic type="url" target="landingPage">
                     <value>
                         <xsl:value-of select="concat($global_prefixURL, $key)"/>
                     </value>
                 </electronic>
             </address>
         </location>
         
    </xsl:template>
    
    <xsl:template match="map[@key='institution']" mode="relatedInfo">
        <relatedInfo type="party">
            <identifier type="url">
                <xsl:value-of select="concat($global_prefixURL, string[@key='uid'])"/>
            </identifier>
            <xsl:apply-templates select="string[@key='name']" mode="title"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="map" mode="relatedInfo_provider">
        <relatedInfo type="party">
            <identifier type="url">
                <xsl:value-of select="concat($global_prefixURL, string[@key='uid'])"/>
            </identifier>
            <xsl:apply-templates select="string[@key='name']" mode="title"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="string[@key='name']" mode="title">
         <title>
             <xsl:value-of select="."/>
         </title>
    </xsl:template>
    
    <xsl:template match="string" mode="subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
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
    
    <xsl:template match="map[@key='geographicRange']" mode="spatial_box">
        <xsl:if test="(string-length(number[@key='eastCoordinate']) > 0)
            and (string-length(number[@key='westCoordinate']) > 0)
            and (string-length(number[@key='northCoordinate']) > 0)
            and (string-length(number[@key='southCoordinate']) > 0)">
            
            <coverage>
                <spatial type="iso19139dcmiBox">
                    <xsl:value-of select="concat('northlimit=',number[@key='northCoordinate'],'; southlimit=-',number[@key='southCoordinate'],'; westlimit=',number[@key='westCoordinate'],'; eastLimit=', number[@key='eastCoordinate'],';')"/>
                </spatial> 
            </coverage>
            
        </xsl:if>
    </xsl:template>
   
    
    
</xsl:stylesheet>    