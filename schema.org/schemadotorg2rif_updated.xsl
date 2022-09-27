<?xml version="1.0" encoding="UTF-8"?>
<!-- Mostly a copy of https://git.ands.org.au/projects/RD/repos/harvester/browse/resources/schemadotorg2rif.xsl but with a few additions -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="originatingSource" select="'https://researchdata.ardc.edu.au'"/>
    <xsl:param name="group" select="'ARDC Sitemap Crawler - 1 March 2022'"/>
    <!--xsl:variable name="xsd_url" select="'/Users/leomonus/dev/ands/registry/applications/registry/registry_object/schema/registryObjects.xsd'"/-->
    <xsl:variable name="xsd_url" select="'http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd'"/>
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects {$xsd_url}">
            <xsl:apply-templates select="dataset | datasets"/>
            <xsl:apply-templates select="//includedInDataCatalog" mode="catalog"/>
            <xsl:apply-templates select="//publisher | //funder | //contributor | //provider" mode="party"/>
        </registryObjects>
    </xsl:template>

    <xsl:template match="publisher| funder | contributor | provider" mode="party">
        <xsl:if test="type = 'Organization' and name(parent::node()) = 'dataset'">
            <xsl:variable name="keyValue">
                <xsl:call-template name="getKeyValue"/>
            </xsl:variable>
            <!-- don't create a related party object if we can't identify its key -->
            <xsl:if test="$keyValue != ''">
                <xsl:element name="registryObject">
                    <xsl:attribute name="group">
                        <xsl:value-of select="$group"/>
                    </xsl:attribute>
                    <xsl:element name="key">
                        <xsl:value-of select="$keyValue"/>
                    </xsl:element>
                    <xsl:element name="originatingSource">
                        <xsl:value-of select="$originatingSource"/>
                    </xsl:element>
                    <xsl:element name="party">
                        <xsl:attribute name="type">
                            <xsl:text>group</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates select="name | legalName | title" mode="primary"/>
                        <xsl:if test="url">
                            <xsl:element name="location">
                                <xsl:element name="address">
                                    <xsl:apply-templates select="url"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                        <xsl:apply-templates select="contactPoint"/>
                        <xsl:apply-templates select="identifier | id"/>
                        <xsl:apply-templates select="url" mode="identifier"/>
                        <xsl:apply-templates select="description | logo"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>         
        </xsl:if>
    </xsl:template>


    <xsl:template match="includedInDataCatalog" mode="catalog">
        <xsl:variable name="keyValue">
            <xsl:call-template name="getKeyValue"/>
        </xsl:variable>
        <!-- don't create a related collection object if we can't identify its key -->
        <xsl:if test="$keyValue != ''">
            <xsl:element name="registryObject">
                <xsl:attribute name="group">
                    <xsl:value-of select="$group"/>
                </xsl:attribute>
                <xsl:element name="key">
                    <xsl:value-of select="$keyValue"/>
                </xsl:element>
                <xsl:element name="originatingSource">
                    <xsl:value-of select="$originatingSource"/>
                </xsl:element>
                <xsl:element name="collection">
                    <xsl:attribute name="type">
                        <xsl:text>catalog</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="name" mode="primary"/>
                    <xsl:apply-templates select="identifier | id"/>
                    <xsl:apply-templates select="url" mode="identifier"/>
                    <xsl:apply-templates select="name" mode="description"/>
                    <xsl:if test="distribution | url">
                        <xsl:element name="location">
                            <xsl:element name="address">
                                <xsl:apply-templates select="url"/>
                                <xsl:apply-templates select="distribution"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>          
                </xsl:element>
            </xsl:element>
        </xsl:if>       
    </xsl:template>

    <xsl:template match="dataset | datasets">
        <xsl:variable name="type" select="translate(normalize-space(type), 'DATASET', 'dataset')"/>
        <xsl:if test="$type = 'dataset'">
            <xsl:element name="registryObject">
                <xsl:attribute name="group">
                    <xsl:value-of select="$group"/>
                </xsl:attribute>
                <xsl:call-template name="getKey"/>
                <xsl:call-template name="getOriginatingSource"/>
                <xsl:element name="collection">
                    <xsl:attribute name="type">
                        <xsl:value-of select="$type"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="name" mode="primary"/>
                    <xsl:apply-templates select="alternateName"/>
                    <xsl:call-template name="getKeyAsIdentifier"/>
                    <xsl:apply-templates select="id" mode="identifier"/>
                    <xsl:apply-templates select="identifier/id | identifier/value | identifier/url" mode="identifier"/>
                    <xsl:apply-templates select="title" mode="primary"/>
                    <xsl:apply-templates select="datePublished | dateCreated | temporalCoverage| spatialCoverage"/>
                    <xsl:apply-templates select="keywords | description | license | publishingPrinciples | isAccessibleForFree | conditionsOfAccess | copyrightHolder"/>
                    <xsl:apply-templates select="prov_wasAssociatedWith"/>
                    <xsl:call-template name="addCitationMetadata"/>
                    <xsl:if test="url | distribution">
                        <xsl:element name="location">
                            <xsl:element name="address">
                                <xsl:apply-templates select="url"/>
                                <xsl:apply-templates select="provider/contactPoint/email"/>
                                <xsl:apply-templates select="distribution"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:apply-templates select="isPartOf | hasPart"/>
                    <xsl:apply-templates select="publisher | funder | contributor | provider | includedInDataCatalog | citation | creator" mode="relatedInfo"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:apply-templates select="dataset"/>
    </xsl:template>

<!-- the group and originating source is mandatory 
        TODO: we should find more than these 2 places  
        -->
    <xsl:template name="getOriginatingSource">
        <xsl:element name="originatingSource">
            <xsl:variable name="valueFound">
                <xsl:choose>
                    <xsl:when test="sourceOrganization">
                        <xsl:apply-templates select="sourceOrganization" mode="originatingSource"/>
                    </xsl:when>
                    <xsl:when test="includedInDataCatalog/url">
                        <xsl:apply-templates select="includedInDataCatalog/url" mode="originatingSource"/>
                    </xsl:when>
                    <xsl:when test="publisher">
                        <xsl:apply-templates select="publisher" mode="originatingSource"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$originatingSource"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$valueFound != ''">
                    <xsl:value-of select="$valueFound"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$originatingSource"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template name="getGroup">
        <xsl:attribute name="group">
            <xsl:variable name="valueFound">
                <xsl:choose>
                    <xsl:when test="sourceOrganization">
                        <xsl:apply-templates select="sourceOrganization" mode="group"/>
                    </xsl:when>
                    <xsl:when test="publisher">
                        <xsl:apply-templates select="publisher" mode="group"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$valueFound != ''">
                    <xsl:value-of select="$valueFound"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$group"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
<!-- 
    Citation metadata has 4 mandatory elements
    identifier, contributor(s) publisher and date(s)
    don't proceed unless the json-ld has all 4
    -->
    <xsl:template name="addCitationMetadata">
        <xsl:choose>  
            <xsl:when test="creator and (identifier or id or  url) and publisher and (datePublished or dateCreated)">
                <xsl:element name="citationInfo">
                    <xsl:element name="citationMetadata">
                        <xsl:choose>
                            <xsl:when test="identifier">
                                <xsl:apply-templates select="identifier[1]"/>
                            </xsl:when>
                            <xsl:when test="id">
                                <xsl:apply-templates select="id[1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="url" mode="identifier"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="name">
                                <xsl:apply-templates select="name[1]"/>
                            </xsl:when>
                            <xsl:when test="title">
                                <xsl:apply-templates select="title[1]"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:apply-templates select="publisher" mode="CitationMetadata"/>
                        <xsl:apply-templates select="locationCreated | version | url" mode="CitationMetadata"/>
                        <xsl:apply-templates select="datePublished | dateCreated" mode="CitationMetadata"/>
                        <xsl:for-each select="creator">
                            <xsl:element name="contributor">
                                <xsl:attribute name="seq">
                                    <xsl:value-of select="position()"/>
                                </xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:attribute name="type">
                                        <xsl:value-of select="'family'"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="givenName/text()"/>
                                </xsl:element>
                                <xsl:element name="namePart">
                                    <xsl:attribute name="type">
                                        <xsl:value-of select="'given'"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="familyName/text()"/>
                                </xsl:element>
                              </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- if we have a citation but unable to construct citation metadata maybe use it -->
                <xsl:apply-templates select="citation"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <xsl:template match="datePublished" mode="CitationMetadata">
        <xsl:element name="date">
            <xsl:attribute name="type">
                <xsl:text>publicationDate</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="dateCreated" mode="CitationMetadata">
        <xsl:element name="date">
            <xsl:attribute name="type">
                <xsl:text>created</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="publisher" mode="CitationMetadata">
        <xsl:element name="publisher">
            <xsl:choose>
                <xsl:when test="name">
                    <xsl:apply-templates select="name/text()"/>
                </xsl:when>
                <xsl:otherwise>            
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="version" mode="CitationMetadata">
        <xsl:element name="version">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="url" mode="CitationMetadata">
        <xsl:element name="url">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="locationCreated" mode="CitationMetadata">
        <xsl:element name="placePublished">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    

    <xsl:template match="publisher | sourceOrganization" mode="originatingSource">
        <xsl:choose>
            <xsl:when test="url">
                <xsl:value-of select="normalize-space(url)"/>
            </xsl:when>
            <xsl:when test="name">
                <xsl:value-of select="normalize-space(name)"/>
            </xsl:when>
            <xsl:when test="legalName">
                <xsl:value-of select="normalize-space(legalName)"/>
            </xsl:when>
            <xsl:when test="normalize-space(.)">
                <xsl:apply-templates select="text()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="publisher|  sourceOrganization" mode="group">
        <xsl:choose>
            <xsl:when test="name">
                <xsl:value-of select="normalize-space(name)"/>
            </xsl:when>
            <xsl:when test="legalName">
                <xsl:value-of select="normalize-space(legalName)"/>
            </xsl:when>
            <xsl:when test="url">
                <xsl:value-of select="normalize-space(url)"/>
            </xsl:when>
            <xsl:when test="normalize-space(.)">
                <xsl:apply-templates select="text()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="datePublished">
        <xsl:element name="dates">
            <xsl:attribute name="type">
                <xsl:text>dc.available</xsl:text>
            </xsl:attribute>
            <xsl:element name="date">
                <xsl:attribute name="type">
                    <xsl:text>dateFrom</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="dateFormat">
                    <xsl:text>W3CDTF</xsl:text>
                </xsl:attribute>
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dateCreated">
        <xsl:element name="dates">
            <xsl:attribute name="type">
                <xsl:text>dc.created</xsl:text>
            </xsl:attribute>
            <xsl:element name="date">
                <xsl:attribute name="type">
                    <xsl:text>dateFrom</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="dateFormat">
                    <xsl:text>W3CDTF</xsl:text>
                </xsl:attribute>
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- 
        getKey template from a jsonld (xml)
    if this logic changes the native metadata loader must be updated accordingly
    in the import pipeline
    -->
    <xsl:template name="getKey">
        <xsl:element name="key">
            <xsl:call-template name="getKeyValue"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="getKeyValue">
        <xsl:choose>
            <xsl:when test="identifier/value">
                <xsl:value-of select="identifier[1]/value/text()"/>
            </xsl:when>
            <xsl:when test="identifier">
                <xsl:value-of select="identifier[1]/text()"/>
            </xsl:when>
            <xsl:when test="id">
                <xsl:value-of select="id[1]/text()"/>
            </xsl:when>
            <xsl:when test="url">
                <xsl:value-of select="url/text()"/>
            </xsl:when>
            <xsl:when test="landingPage">
                <xsl:value-of select="landingPage/text()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="getKeyAsIdentifier">
        <xsl:choose>
            <!-- these will be Identifiers - so ignore them here -->
            <xsl:when test="identifier/value"/>
            <xsl:when test="identifier"/>
            <xsl:when test="id"/>
            <!-- if the key is generated from url or landinPage add an Identifier as well -->
            <xsl:when test="url">
                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="url/text()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="landingPage">
                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="landingPage/text()"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="type">
        <xsl:attribute name="type">
            <xsl:apply-templates select="text()"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="keywords">
        <!-- TODO - handle type = "DefinedTerm" -->
        <xsl:variable name="keywordsList" select="tokenize(text(),'\s?[,;:]\s?')" as="xs:string*"/>
        <xsl:for-each select="$keywordsList">
            <xsl:element name="subject">
                <xsl:attribute name="type">local</xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="contentSize">
        <xsl:element name="byteSize">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="distribution/description">
        <xsl:element name="notes">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="description">
        <xsl:element name="description">
            <xsl:attribute name="type">brief</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="prov_wasAssociatedWith">
        <xsl:apply-templates select="prov_plan"/>
    </xsl:template>
    
    <xsl:template match="prov_plan">
        <xsl:element name="description">
            <xsl:attribute name="type">lineage</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="name" mode="description">
        <xsl:element name="description">
            <xsl:attribute name="type">brief</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="logo">
        <xsl:element name="description">
            <xsl:attribute name="type">logo</xsl:attribute>
            <xsl:apply-templates select="text()"/>
            <xsl:apply-templates select="url/text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="citation">
        <xsl:element name="citationInfo">
            <xsl:element name="fullCitation">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <xsl:template match="license">
        <xsl:element name="rights">
            <xsl:choose>
                <xsl:when test="starts-with(url, 'http')">
                    <xsl:element name="rightsStatement">
                        <xsl:attribute name="rightsUri">
                            <xsl:value-of select="normalize-space(url)"/>
                        </xsl:attribute>
                        <xsl:value-of select="name"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="rightsStatement">
                        <xsl:value-of select="normalize-space(text())"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="publishingPrinciples | conditionsOfAccess | copyrightHolder">
        <xsl:element name="rights">
            <xsl:choose>
                <xsl:when test="url">
                    <xsl:element name="rightsStatement">
                        <xsl:attribute name="rightsUri">
                            <xsl:apply-templates select="url/text()"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="name/text()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="rightsStatement">
                        <xsl:value-of select="normalize-space(text())"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    
    
    <!-- accessRights ‘Accessible for free’ -->
    
    
    <xsl:template match="isAccessibleForFree">
        <xsl:variable name="value" select="translate(normalize-space(.), 'true', 'TRUE')"/>
        <xsl:choose>
            <xsl:when test="$value = 'TRUE'">
                <xsl:element name="rights">
                    <xsl:element name="accessRights">
                        <xsl:text>Accessible for free</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="landingPage">
        <xsl:element name="electronic">
            <xsl:attribute name="type">
                <xsl:text>url</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>landingPage</xsl:text>
            </xsl:attribute>
            <xsl:element name="value">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="identifier">
        <xsl:element name="identifier">
            <xsl:choose>
                <xsl:when test="propertyID">
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="contains(propertyID/text(), 'registry.identifiers.org/registry/')">
                                <xsl:value-of select="substring-after(propertyID/text(), 'registry.identifiers.org/registry/')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="propertyID/text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="value">
                            <xsl:choose>
                                <xsl:when test="contains(value/text(), concat(substring-after(propertyID/text(), 'registry.identifiers.org/registry/'),':'))">
                                    <xsl:value-of select="substring-after(value/text(), concat(substring-after(propertyID/text(), 'registry.identifiers.org/registry/'),':'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="value/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="id">
                            <xsl:value-of select="id/text()"/>
                        </xsl:when>
                        <xsl:when test="url">
                            <xsl:value-of select="url/text()"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="id">
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="propertyID">
                                <xsl:value-of select="propertyID/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>url</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="id/text()"/>
                </xsl:when>
                <xsl:when test="url">
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type">
                        <xsl:text>local</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="url | email">
        <xsl:if test="text() != ''">
            <xsl:element name="electronic">
                <xsl:attribute name="type">
                    <xsl:value-of select="name()"/>
                </xsl:attribute>
                <xsl:element name="value">
                    <xsl:apply-templates select="text()"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="contactPoint">
        <xsl:if test="email/text() != '' or url/text() != ''">
            <xsl:element name="location">
                <xsl:element name="address">
                    <xsl:apply-templates select="url"/>
                    <xsl:apply-templates select="email"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:if test="telephone/text() != '' or name/text() != ''">
            <xsl:element name="location">
                <xsl:element name="address">
                    <xsl:element name="physical">
                        <xsl:apply-templates select="type"/>
                        <xsl:apply-templates select="name" mode="addressPart"/>
                        <xsl:apply-templates select="telephone" mode="addressPart"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name | telephone" mode="addressPart">
        <xsl:element name="addressPart">
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="name() = 'telephone'">
                        <xsl:text>telephoneNumber</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>addressLine</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="distribution">
        <xsl:if test="node()">
            <xsl:element name="electronic">
                <xsl:attribute name="type">
                    <xsl:text>url</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>directDownload</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="downloadURL">
                        <xsl:apply-templates select="downloadURL"/>
                    </xsl:when>
                    <xsl:when test="accessURL">
                        <xsl:apply-templates select="accessURL"/>
                    </xsl:when>
                    <xsl:when test="contentUrl">
                        <xsl:apply-templates select="contentUrl"/>
                    </xsl:when>
                    <xsl:when test="url">
                        <xsl:apply-templates select="url" mode="distribution"/>    
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="name"/>
                <xsl:apply-templates select="description"/>
                <xsl:apply-templates select="mediaType | encodingFormat"/>
                <xsl:apply-templates select="type" mode="distribution"/>
                <xsl:apply-templates select="contentSize"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="accessURL | downloadURL | contentUrl">
        <xsl:element name="value">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="url" mode="distribution">
        <xsl:element name="value">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="encodingFormat | mediaType">
        <xsl:if test="text() != ''">
            <xsl:element name="mediaType">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="type" mode="distribution">
        <xsl:if test="text() != ''">
            <xsl:element name="mediaType">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name | title | legalName" mode="primary">
        <xsl:element name="name">
            <xsl:attribute name="type">
                <xsl:text>primary</xsl:text>
            </xsl:attribute>
            <xsl:element name="namePart">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <xsl:template match="alternateName">
        <xsl:element name="name">
            <xsl:attribute name="type">
                <xsl:text>alternative</xsl:text>
            </xsl:attribute>
            <xsl:element name="namePart">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <xsl:template match="hasPart">
        <xsl:element name="relatedInfo">
            <xsl:apply-templates select="type"/>
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>hasPart</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:apply-templates select="name"/>
            <xsl:apply-templates select="id | identifier"/>
            <xsl:apply-templates select="url" mode="identifier"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="isPartOf">
        <xsl:element name="relatedInfo">
            <xsl:apply-templates select="type"/>
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>isPartOf</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:apply-templates select="name"/>
            <xsl:apply-templates select="id | identifier"/>
            <xsl:apply-templates select="url" mode="identifier"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="publisher | provider | funder | contributor | includedInDataCatalog | citation | creator" mode="relatedInfo">
        <xsl:variable name="keyValue">
            <xsl:call-template name="getKeyValue"/>
        </xsl:variable>
        <!-- don't create relatedInfo if we can't add an identifier  -->
        <xsl:if test="$keyValue != ''">
            <xsl:element name="relatedInfo">
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="type = 'WebPage'">
                            <xsl:text>website</xsl:text>
                        </xsl:when>
                        <xsl:when test="type = 'PublicationIssue'">
                            <xsl:text>publication</xsl:text>
                        </xsl:when>
                        <xsl:when test="type = 'SoftwareSourceCode'">
                            <xsl:text>collection</xsl:text>
                        </xsl:when>
                        <xsl:when test="name() = 'includedInDataCatalog'">
                            <xsl:text>collection</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>party</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:element name="relation">
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="type = 'WebPage'">
                                <xsl:text>isSupplementTo</xsl:text>
                            </xsl:when>
                            <xsl:when test="type = 'PublicationIssue'">
                                <xsl:text>isCitedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="type = 'SoftwareSourceCode'">
                                <xsl:text>isProducedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="name() = 'publisher'">
                                <xsl:text>isPublishedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="name() = 'provider'">
                                <xsl:text>isProvidedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="name() = 'funder'">
                                <xsl:text>isFundedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="name() = 'contributor'">
                                <xsl:text>hasAssociationWith</xsl:text>
                            </xsl:when>
                            <xsl:when test="name() = 'includedInDataCatalog'">
                                <xsl:text>isPartOf</xsl:text>
                            </xsl:when>
                            <xsl:when test="name() = 'creator'">
                                <xsl:text>hasCollector</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
                <xsl:choose>
                    <xsl:when test="string-length(name) > 0">
                        <xsl:apply-templates select="name"/>
                    </xsl:when>
                    <xsl:when test="(string-length(givenName) + string-length(familyName)) > 0">
                        <!--xsl:call-template name="title">
                            <xsl:with-param name="value">
                                <xsl:value-of select="concat(givenName, ' ', familyName)"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when-->
                        <xsl:element name="title">
                            <xsl:apply-templates select="concat(givenName, ' ', familyName)"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:apply-templates select="description" mode="notes"/>
                <!--xsl:apply-templates select="id"/-->
                <xsl:apply-templates select="identifier"/>
                <xsl:apply-templates select="url" mode="identifier"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name | title">
        <xsl:element name="title">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="title">
        <xsl:param name="value"/>
        <xsl:element name="title">
            <xsl:apply-templates select="$value"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="description" mode="notes">
        <xsl:element name="notes">
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="id | value | url" mode="identifier">
        <xsl:element name="identifier">
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(., 'registry.identifiers.org/registry/')">
                        <xsl:value-of select="substring-after(., 'registry.identifiers.org/registry/')"/>
                    </xsl:when>
                    <xsl:when test="contains(., 'doi')">
                        <xsl:text>doi</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'hdl.handle.net')">
                        <xsl:text>handle</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'http')">
                        <xsl:text>url</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
           </xsl:attribute>
            <xsl:choose>
                <xsl:when test="(string-length(../propertyID/text()) > 0) and contains(text(), concat(substring-after(../propertyID/text(), 'registry.identifiers.org/registry/'),':'))">
                    <xsl:value-of select="substring-after(text(), concat(substring-after(../propertyID/text(), 'registry.identifiers.org/registry/'),':'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--xsl:apply-templates select="text()"/-->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="temporalCoverage">
        <xsl:element name="coverage">
            <xsl:element name="temporal">
                <xsl:choose>
                     <xsl:when test="contains(., '/')">
                         <xsl:variable name="dateList" select="tokenize(text(),'/')" as="xs:string*"/>
                         <xsl:if test="count($dateList) = 2">
                             <xsl:element name="date">
                                 <xsl:attribute name="type">
                                     <xsl:text>dateFrom</xsl:text>
                                 </xsl:attribute>
                                 <xsl:attribute name="dateFormat">
                                     <xsl:text>W3CDTF</xsl:text>
                                 </xsl:attribute>
                                 <xsl:value-of select="$dateList[1]"/>
                             </xsl:element>
                             <xsl:element name="date">
                                 <xsl:attribute name="type">
                                     <xsl:text>dateTo</xsl:text>
                                 </xsl:attribute>
                                 <xsl:attribute name="dateFormat">
                                     <xsl:text>W3CDTF</xsl:text>
                                 </xsl:attribute>
                                 <xsl:value-of select="$dateList[2]"/>
                             </xsl:element>
                         </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="date">
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="spatialCoverage">
        <xsl:element name="coverage">
                <xsl:choose>
                    <xsl:when test="geo or name">
                        <xsl:apply-templates select="geo"/>
                        <xsl:apply-templates select="name" mode="spatial"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="spatial">
                            <xsl:attribute name="type">
                                <xsl:text>text</xsl:text>
                            </xsl:attribute>
                            <xsl:apply-templates select="text()"/>    
                        </xsl:element>
                    </xsl:otherwise>           
                </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="geo">
        <xsl:choose>
            <xsl:when test="type = 'GeoCoordinates'">
                <xsl:element name="spatial">
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="not(abs(number(longitude/text())) &gt; 180) and not(abs(number(latitude/text())) &gt; 180)">
                                <xsl:text>kmlPolyCoords</xsl:text>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>text</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="concat(longitude/text(), ',' , latitude/text())"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="type = 'GeoShape'">
                <xsl:apply-templates select="box | polygon | line"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="name" mode="spatial">
        <xsl:element name="spatial">
            <xsl:attribute name="type">
                <xsl:text>text</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="box">
        <xsl:variable name="coords" select="tokenize(text(),'\s?[, ]\s?')" as="xs:string*"/>
        <xsl:element name="spatial">
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="not(abs(number($coords[1])) &gt; 180) and not(abs(number($coords[3])) &gt; 180) and not(abs(number($coords[2])) &gt; 90) and not(abs(number($coords[4])) &gt; 90)">
                        <xsl:text>iso19139dcmiBox</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>text</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        <xsl:value-of select="concat('westlimit=',$coords[1], '; southlimit=', $coords[2], '; eastlimit=', $coords[3], '; northlimit=', $coords[4],'; projection=WGS84')"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="line | polygon">
        <xsl:element name="spatial">
            <xsl:attribute name="type">
                <xsl:text>kmlPolyCoords</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

</xsl:stylesheet>
