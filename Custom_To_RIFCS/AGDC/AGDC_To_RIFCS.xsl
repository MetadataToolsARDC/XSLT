<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:local="http://local/function" 
    exclude-result-prefixes="xs math local xsi"
    version="3.0">
    
    <xsl:param name="global_group" select="'Australian Government Data Catalogue'"/>
    <xsl:param name="global_acronym" select="'AGDC'"/>
    <xsl:param name="global_originatingSource" select="'Australian Government Data Catalogue'"/>
    <xsl:param name="global_prefixURL" select="'https://www.dataplace.gov.au/dataset/'"/>
    <xsl:param name="global_prefixKey" select="'AGDC/'"/>
    <xsl:param name="serverUrl"/>
    <xsl:param name="dateCreated" />
    <xsl:param name="lastModified" />
    
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*" />
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="datasets/value" mode="process"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="value" mode="process">
        <xsl:message select="concat('AGDC source has children: ', has-children(.))"/>
        
        <registryObject group="{$global_group}">
            
            <xsl:call-template name="key">
                <xsl:with-param name="key" select="concat($global_prefixKey, id)"/>
            </xsl:call-template>
            
            <xsl:call-template name="originatingSource">
                <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            </xsl:call-template>
            
            <xsl:apply-templates select="." mode="collection"/>
            
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
    
    <xsl:template match="value" mode="collection">
        
        <collection type="dataset">
            
            <xsl:apply-templates select="createdon"/>
            
            <xsl:apply-templates select="id[string-length(.) > 0]" mode="identifier"/>
            
            <xsl:apply-templates select="dp_identifier[string-length(.) > 0]" mode="identifier"/>
            
            <xsl:apply-templates select="id[string-length(.) > 0]" mode="identifier_url"/>
            
            <xsl:apply-templates select="dp_title[string-length(.) > 0]"/>
            
            <xsl:call-template name="location">
                <xsl:with-param name="key" select="id"/>
            </xsl:call-template>
            
            
            <xsl:apply-templates select="dp_publisher[string-length(.) > 0]" mode="relatedInfo"/>
            <xsl:apply-templates select="dp_datacustodian[string-length(.) > 0]" mode="relatedInfo"/>
            
            <!-- ToDo: Dates -->
            
            
            <xsl:apply-templates select="dp_keyword[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="dp_updatefrequency[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="dp_securityclassification[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="dp_format[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="dp_purpose[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="dp_description[string-length(.) > 0]"/>
            
            <xsl:if test="(count(dp_purpose[string-length(.) > 0]) = 0)
                and (count(dp_description[string-length(.) > 0]) = 0)">
                
                <xsl:apply-templates select="dp_title[string-length(.) > 0]" mode="description"/>
                
            </xsl:if>
            
            <xsl:apply-templates select="dp_location[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="dp_accessrights[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="dp_license[string-length(.) > 0]"/>
           
           
            <xsl:apply-templates select="dp_publishdate[string-length(.) > 0]"/>
            
            
        </collection>
    </xsl:template>
    
    <xsl:template match="createdon">
        <xsl:attribute name="dateAccessioned">
            <xsl:apply-templates select="text()"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="id | dp_identifier" mode="identifier">
        <identifier type="local">
            <xsl:apply-templates select="text()"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="id" mode="identifier_url">
        <identifier type="url">
            <xsl:value-of select="concat($global_prefixURL, .)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="dp_title">
        <name type="primary">
            <namePart>
                <xsl:apply-templates select="text()"/>
            </namePart>
        </name>
        
    </xsl:template>
    
    <xsl:template match="dp_title" mode="description">
        <description type="brief">
            <xsl:apply-templates select="text()"/>
        </description>
        
    </xsl:template>
    
    
    <xsl:template match="dp_purpose">
        <description type="notes">
            <xsl:apply-templates select="text()"/>
        </description>
    </xsl:template>
    
    
    <xsl:template match="dp_description">
        <description type="full">
            <xsl:apply-templates select="text()"/>
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
    
    <xsl:template match="dp_publisher" mode="relatedInfo">
        <relatedInfo type="party">
            <identifier type="local">
                <xsl:value-of select="concat($global_acronym, '/', translate(., ' ', ''))"/>
            </identifier>
            <xsl:apply-templates select="." mode="title"/>
            <relation type="isPublishedBy"/>
        </relatedInfo>
    </xsl:template>
    
    
    <xsl:template match="dp_datacustodian" mode="relatedInfo">
        <relatedInfo type="party">
            <identifier type="local">
                <xsl:value-of select="concat($global_acronym, '/', translate(., ' ', ''))"/>
            </identifier>
            <xsl:apply-templates select="." mode="title"/>
            <relation type="isManagedBy"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="*" mode="title">
        <title>
            <xsl:apply-templates select="text()"/>
        </title>
    </xsl:template>
    
    <xsl:template match="dp_keyword | dp_updatefrequency | dp_securityclassification | dp_format" mode="subject">
        <subject type="local">
            <xsl:apply-templates select="text()"/>
        </subject>
    </xsl:template>
    
    
    <xsl:template match="dp_location">
        <coverage>
            <spatial type="text">
                <xsl:apply-templates select="text()"/>
            </spatial>
        </coverage>
    </xsl:template>
    
    <xsl:template match="dp_accessrights">
        <rights>
            <accessRights>
                <xsl:attribute name="type">
                    <xsl:apply-templates select="lower-case(text())"/>
                </xsl:attribute>
            </accessRights>
        </rights>
    </xsl:template>
    
    <xsl:template match="dp_license">
        <rights>
            <licence>
                <xsl:apply-templates select="text()"/>
            </licence>
        </rights>
    </xsl:template>
    
    
    <xsl:template match="dp_publishdate">
        <dates type="dc.issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:apply-templates select="text()"/>
            </date>
        </dates>
        
    </xsl:template>
    
    
 
    <xsl:template match="*/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    
</xsl:stylesheet>    