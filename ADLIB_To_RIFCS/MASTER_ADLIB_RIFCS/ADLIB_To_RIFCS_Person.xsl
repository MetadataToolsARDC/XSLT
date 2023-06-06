<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
    exclude-result-prefixes="xsl murFunc custom dc oai fn xs xsi">
    
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
    <xsl:param name="global_path_organisations" select="''"/>
    <xsl:param name="global_path_persons" select="''"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:message select="concat('name(OAI-PMH): ', name(OAI-PMH))"/>
            <xsl:message select="concat('num record element: ', count(OAI-PMH/ListRecords/record))"/>
            <xsl:apply-templates select="OAI-PMH/ListRecords/record"/>
            
        </registryObjects>
    </xsl:template>
    
    
    <xsl:template match="record">
        <xsl:apply-templates select="metadata/record" mode="party"/>
    </xsl:template>
    
    <xsl:template match="record"  mode="party">
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <xsl:apply-templates select="reference_number" mode="person_key"/>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <party type="person">
                
                <xsl:apply-templates select="@modification" mode="party_date_modified"/>
                
                <!--xsl:apply-templates select="identifier" mode="party_identifier"/-->
                
                <xsl:apply-templates select="@priref[1]" mode="party_identifier"/>
                
                <xsl:apply-templates select="@priref[1]" mode="party_location_url"/>
                
                <xsl:apply-templates select="." mode="party_name"/>
                
                <xsl:apply-templates select="." mode="party_existence_dates"/>
                
                <xsl:apply-templates select="biography" mode="party_description_full"/>
                
                <xsl:apply-templates select="reference_number" mode="party_description_brief"/>
                
                <xsl:apply-templates select="person_office_held/person_office_held" mode="party_description_notes"/>
                
            </party>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="reference_number" mode="person_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/persons/')"/>
            <xsl:choose>
                <xsl:when test="starts-with(., 'PER-')">
                    <xsl:value-of select="substring-after(., 'PER-')"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </key>
    </xsl:template>
    
    <xsl:template match="@modification" mode="party_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="datestamp" mode="party_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="identifier" mode="party_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="@priref" mode="party_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path_persons, normalize-space(.))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="@priref" mode="party_identifier">
        <identifier type="uri">
            <xsl:value-of select="concat($global_baseURI, $global_path_persons, normalize-space(.))"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="record" mode="party_name">
        <name type="primary">
            <namePart type="title">
                
            </namePart>
            <namePart type="family">
                <xsl:value-of select="surname"/>
            </namePart>
            <namePart type="given">
                <xsl:value-of select="forename"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="record" mode="party_existence_dates">
        <existenceDates>
            <startDate dateFormat="W3CDTF">
                <xsl:value-of select="birth.date.start"/>
            </startDate>
            <endDate dateFormat="W3CDTF">
                <xsl:value-of select="death.date.start"/>
            </endDate>
        </existenceDates>
    </xsl:template>
    
    <xsl:template name="party_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="biography" mode="party_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="reference_number" mode="party_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="person_office_held" mode="party_description_notes">
        <description type="notes">
            <!--xsl:value-of select="'Position(s): &lt;br/&gt;'"/-->
            <xsl:for-each select="fn:tokenize(., '&#10;')">
                <xsl:value-of select="concat(normalize-space(.), '&lt;br/&gt;')"/> 
            </xsl:for-each>
        </description>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>
