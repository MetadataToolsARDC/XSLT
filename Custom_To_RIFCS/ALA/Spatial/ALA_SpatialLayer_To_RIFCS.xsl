<xsl:stylesheet 
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
    <xsl:param name="global_prefixURL" select="'https://spatial.ala.org.au/ws/layers/view/more/'"/>
    <xsl:param name="global_prefixKey" select="'ala.org.au/uid_'"/>
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
            
            <xsl:apply-templates select="//dataset"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="dataset">
        <xsl:variable name="key" as="xs:string">
            <xsl:value-of select="id"/>
        </xsl:variable>
        <xsl:apply-templates select="." mode="process">
            <xsl:with-param name="key" select="$key"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="dataset" mode="process">
        <xsl:param name="key"/>
        <xsl:message select="concat('ALA source has children: ', has-children(.))"/>
        
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
             <xsl:value-of select="concat($global_prefixKey, $key)"/>
         </key>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="originatingSource">
        <xsl:param name="originatingSource"/>
        <originatingSource>
            <xsl:value-of select="$originatingSource"/>
        </originatingSource>
    </xsl:template>
    
    <xsl:template match="dataset" mode="collection">
        <xsl:param name="key"/>
        
        <collection type="dataset">
            
            <xsl:apply-templates select="name[string-length(.) > 0]" mode="identifier"/>
            
            <xsl:apply-templates select="displayname[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="name[string-length(.) > 0]" mode="location"/>
            
            <xsl:apply-templates select="source[string-length(.) > 0]" mode="description_notes"/>
            
            <!-- ToDo: Dates -->
            
            
            <xsl:apply-templates select="./*[starts-with(local-name(.), 'classification')]" mode="subject_classification"/>
            
            <xsl:apply-templates select="type[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="domain[string-length(.) > 0]" mode="subject"/>
            
            <xsl:apply-templates select="description[string-length(.) > 0]"/>
            
            <xsl:apply-templates select="notes[string-length(.) > 0]"/>
            
           <xsl:apply-templates select="." mode="spatial_box"/>
            
            <xsl:apply-templates select="." mode="rights_licence"/>
            
        </collection>
    </xsl:template>
    
    <xsl:template match="name" mode="identifier">
          <identifier type="url">
             <xsl:value-of select="concat($global_prefixURL, .)"/>
         </identifier>
    </xsl:template>
    
    <xsl:template match="displayname">
        <name type="primary">
            <namePart>
                <xsl:value-of select="."/>
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
    
    
    <xsl:template match="name" mode="location">
         <location>
             <address>
                 <electronic type="url" target="landingPage">
                     <value>
                         <xsl:value-of select="concat($global_prefixURL, .)"/>
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
    
    
    <xsl:template match="dataset" mode="spatial_box">
        <xsl:if test="(string-length(maxlongitude) > 0)
            and (string-length(minlongitude) > 0)
            and (string-length(maxlatitude) > 0)
            and (string-length(minlatitude) > 0)">
            
            <coverage>
                <spatial type="iso19139dcmiBox">
                    <xsl:value-of select="concat('northlimit=',maxlatitude,'; southlimit=',minlatitude,'; westlimit=',minlongitude,'; eastLimit=', maxlongitude,';')"/>
                </spatial> 
            </coverage>
            
        </xsl:if>
    </xsl:template>
   
   
    <xsl:template match="dataset" mode="rights_licence">
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
    
</xsl:stylesheet>
    
    