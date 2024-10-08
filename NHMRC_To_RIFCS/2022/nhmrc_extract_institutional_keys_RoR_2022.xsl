<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    version="2.0" >
 <!-- this stylesheet attempt to match all values in the Admin_Institution column from the supplied NHMRC grant data 
     spreadsheet against a party record entry in RDA for this institution so that the activity(grant) record can be related 
     to it's managin insitution via a related object key.
     
     The output is an xml document listing the institutions with their name as used by the NHMRC and the corresponding key 
     for their party record in RDA. This is used as a lookup table by the main transformation -  NHMRC grant row to RIF-CS record
  -->
    
    <xsl:output method="xml"/>
    
    <xsl:variable name="queryroot" 
        select="'https://api.ror.org/v2/organizations?query.advanced='"/>
           
    <xsl:template match="/root">
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="institutions">                           
            <xsl:for-each-group select="row" group-by="Admin_Institution">
                <xsl:variable name="admin_inst" select="lower-case(normalize-space(Admin_Institution))"/>
                
               
                <xsl:variable name="searchterms" select="replace(replace($admin_inst,'the ',''),' of ',' ')"/>
                <xsl:variable name="searchterms" select="replace(replace($searchterms,' for ',' '),' and ',' ')"/>
                <xsl:variable name="searchterms" select="replace($searchterms,' ',' AND ')"/>
                <xsl:variable name="query" select="concat($queryroot,'(',encode-for-uri($searchterms),')')"/>
                
                <xsl:variable name="institutionMap" select="fn:json-doc($query)" as="item()*"/>
                <xsl:variable name="items" select="map:get($institutionMap, 'items')" as="item()*"/>
                 
                
                <xsl:text>&#xA;</xsl:text>
                <!--xsl:element name="institution">
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="name"><xsl:value-of select="Admin_Institution"/></xsl:element>
                    <xsl:if test="$institution">
                    <xsl:variable name="identifier" select="$institution/ro:registryObjects/ro:registryObject/ro:party/ro:identifier[@type='AU-ANL:PEAU']"/>
                    <xsl:variable name="instKey" select="$institution/ro:registryObjects/ro:registryObject[@group='Australian Research Institutions']/ro:key"/>

                    <xsl:choose>
                        <xsl:when test="$identifier != ''">
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:element name="key">
                                <xsl:value-of select="$identifier[1]"/>
                            </xsl:element>
                            <xsl:message>
                                <xsl:text>Matched </xsl:text>
                                <xsl:value-of select="Admin_Institution"/>
                            </xsl:message>  
                        </xsl:when>
                        <xsl:when test="$instKey != ''">
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:element name="key">
                              <xsl:value-of select="$instKey"/>
                            </xsl:element> 
                            <xsl:message>
                                <xsl:text>Matched </xsl:text>
                                <xsl:value-of select="Admin_Institution"/>
                            </xsl:message>        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>
                                <xsl:text>Unmatched </xsl:text>
                                <xsl:value-of select="Admin_Institution"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="$query"/>
                            </xsl:message>  
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>    
                </xsl:element-->    
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
