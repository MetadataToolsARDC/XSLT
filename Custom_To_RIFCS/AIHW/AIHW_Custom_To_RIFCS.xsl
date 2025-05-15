<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="xs xsl">
    
    <xsl:param name="global_originatingSource" select="'http://aihw.gov.au'"/>
    <xsl:param name="global_acronym" select="'AIHW'"/>
    <xsl:param name="global_group" select="'Australian Institute of Health and Welfare'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:apply-templates select="root/row" mode="collection"/>
            
        </registryObjects>
    </xsl:template>
    
   <xsl:template match="row" mode="collection">

        <registryObject group="{$global_group}">
            <key>
                <xsl:value-of select="translate(concat($global_acronym, '/', normalize-space(Name)), ' ','')"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <collection type="collection">
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(Name)"/>
                    </namePart>
                </name>
                <location>
                    <address>
                        <electronic type="url">
                            <value>
                                <xsl:value-of select="normalize-space(Location_URL)"/>
                            </value>
                        </electronic>
                    </address>
                </location>
                <coverage>
                    <spatial type="text">
                        <xsl:value-of select="normalize-space(Geographical_coverage)"/>
                    </spatial>
                    <temporal>
                        <date type="dateFrom" dateFormat="W3CDTF">
                            <xsl:value-of select="Temporal__coverage__from"/>
                        </date>
                        <date type="dateTo" dateFormat="W3CDTF">
                            <xsl:value-of select="Temporal__coverage__to"/>
                        </date>
                    </temporal>
                </coverage>
               <description type="lineage">
                    <xsl:value-of select="concat('Methodology: ',normalize-space(Methodology))"/>
                </description>
                <description type="full">
                    <xsl:value-of select="concat(normalize-space(Description), '&lt;br&gt;&lt;br&gt;', normalize-space(Data_scope))"/>
                  </description>
                <description type="note">
                    <xsl:value-of select="concat('Variables to support reporting and linkage: ',normalize-space(Variables_to__support__reporting_and_linkage))"/>
                </description>
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(Data_availability)"/>
                    </rightsStatement>
                </rights>
                <rights>
                    <accessRights>
                        <xsl:value-of select="normalize-space(Restricted__Access)"/>
                    </accessRights>
                </rights>
            </collection>
        </registryObject>
   </xsl:template>
</xsl:stylesheet>
