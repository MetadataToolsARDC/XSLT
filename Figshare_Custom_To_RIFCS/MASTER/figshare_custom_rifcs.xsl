<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:figFunc="http://figfunc.nowhere.yet" xmlns:local="http://local.here.org"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsi xsl figFunc fn local xs">

    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_baseURI" select="'figshare.com'"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_key_source_prefix" select="''"/>

    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">

            <xsl:apply-templates select="datasets/dataset" mode="registry_object"/>

        </registryObjects>
    </xsl:template>

    <xsl:template match="dataset" mode="registry_object">
        
        <xsl:variable name="figshareIdentifier" select="concat($global_key_source_prefix, id)" as="xs:string"/>
        
        <xsl:message select="concat('key to use: ', substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($figshareIdentifier)) return string($n), ''), 0, 50))"/>
        
       
       <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="contains(fn:lower-case(defined_type_name), 'service')">
                    <xsl:text>service</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>collection</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>

            <key>
                <xsl:value-of select="
                        substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($figshareIdentifier))
                        return
                            string($n), ''), 0, 50)"/>
            </key>

            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$type}">

                <xsl:attribute name="type">
                    <xsl:value-of select="defined_type_name"/>
                </xsl:attribute>

                <xsl:apply-templates select="timeline/firstOnline[string-length(.) > 0]"
                    mode="collection_date_accessioned"/>

                <xsl:apply-templates select="doi[string-length(.) > 0]" mode="collection_identifier"/>

                <xsl:apply-templates select="handle[string-length(.) > 0]"
                    mode="collection_identifier"/>

                <xsl:choose>
                    <xsl:when test="count(doi[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="doi[string-length(.) > 0][1]"
                            mode="collection_location"/>
                    </xsl:when>
                    <xsl:when test="count(handle[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="handle[string-length(.) > 0][1]"
                            mode="collection_location"/>
                    </xsl:when>
                    <xsl:when test="count(figshare_url[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="figshare_url[string-length(.) > 0][1]"
                            mode="collection_location"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="url_public_html[(string-length(.) > 0)]"
                            mode="collection_location"/>
                    </xsl:otherwise>
                </xsl:choose>


                <xsl:apply-templates select="title[string-length(.) > 0]" mode="collection_name"/>

                <xsl:apply-templates select="authors" mode="collection_relatedInfo_party"/>

                <xsl:apply-templates select="categories/title[string-length(.) > 0]"
                    mode="collection_subject"/>

                <xsl:apply-templates select="licence" mode="collection_rights_licence"/>

                <xsl:apply-templates select="tags[string-length(.) > 0]" mode="collection_subject"/>

                <xsl:apply-templates select="description[string-length(.) > 0]"
                    mode="collection_description_full"/>

                <xsl:apply-templates select="funding_list" mode="collection_relatedInfo"/>

                <xsl:apply-templates select="published_date[string-length(.) > 0]"
                    mode="collection_dates_issued"/>

                <xsl:apply-templates select="created_date[string-length(.) > 0]"
                    mode="collection_dates_created"/>

                <xsl:apply-templates select="modified_date[string-length(.) > 0]"
                    mode="collection_dates_modified"/>
                
                <xsl:apply-templates select="custom_fields[string-length(.) > 0]"
                    mode="collection_custom_handling"/>

                <xsl:apply-templates select="citation" mode="collection_citationInfo_fullCitation"/>
            </xsl:element>
        </registryObject>

    </xsl:template>


    <xsl:template match="firstOnline" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="."/>
    </xsl:template>

    <xsl:template match="doi" mode="collection_identifier">
        <identifier type="doi">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

    <xsl:template match="handle" mode="collection_identifier">
        <identifier type="handle">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

    <xsl:template match="doi" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(., '10.')">
                                <xsl:value-of select="concat('https://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>

    <xsl:template match="handle" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(., 'http')">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('http://hdl.handle.net/', .)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>

    <xsl:template match="figshare_url | url_public_html" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>




    <xsl:template match="title" mode="collection_name">
        <name type="primary">
            <xsl:variable name="name" select="figFunc:characterReplace(., false())"/>
            <!-- maintain HTML false-->
            <namePart>
                <xsl:value-of select="$name"/>
            </namePart>
        </name>
    </xsl:template>



    <xsl:template match="authors" mode="collection_relatedInfo_party">
        <relatedInfo type="party">
            <xsl:apply-templates select="orcid_id" mode="identifier"/>

            <xsl:variable name="author_url"
                select="concat($global_baseURI, '/authors/', url_name, '/', id)"/>

            <xsl:if test="string-length($author_url) > 0">
                <identifier type="url">
                    <xsl:value-of select="$author_url"/>
                </identifier>
            </xsl:if>

            <title>
                <xsl:value-of select="full_name"/>
            </title>

            <relation type="hasCollector"/>
        </relatedInfo>


    </xsl:template>


    <xsl:template match="title" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>

    <xsl:template match="licence" mode="collection_rights_licence">
        <rights>
            <licence type="{name}" rightsUri="{url}">
                <xsl:value-of select="name"/>
            </licence>
        </rights>
    </xsl:template>

    <xsl:template match="tags" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>

    <xsl:template match="description" mode="collection_description_full">

        <xsl:variable name="description" select="figFunc:characterReplace(., true())"/>
        <!-- maintain HTML true-->
        <description type="full">
            <xsl:value-of select="$description"/>
        </description>
    </xsl:template>

    <xsl:template match="published_date" mode="collection_dates_issued">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>

    <xsl:template match="created_date" mode="collection_dates_created">
        <dates type="created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>

    <xsl:template match="modified_date" mode="collection_dates_modified">
        <dates type="modified">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>

    <xsl:template match="citation" mode="collection_citationInfo_fullCitation">
        <citationInfo>
            <fullCitation style="{@style}">
                <xsl:value-of select="figFunc:characterReplace(., false())"/>
                <!-- maintain HTML false-->
            </fullCitation>
        </citationInfo>
    </xsl:template>

    <xsl:template match="funding_list" mode="collection_relatedInfo">

        <relatedInfo type="activity">
            <xsl:apply-templates
                select="id[string-length(.) > 0] | grant_code[string-length(.) > 0] | url[string-length(.) > 0]"
                mode="identifier"/>
            <title>
                <xsl:value-of select="title"/>
            </title>
            <relation type="isFundedBy"/>
        </relatedInfo>

    </xsl:template>

    <xsl:template match="id | grant_code | url" mode="identifier">
        <identifier type="{local:getIdentifierType(.)}">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

    <xsl:template match="orcid_id" mode="identifier">
        <identifier type="orcid">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>



    <xsl:function name="local:getIdentifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'raid')">
                <xsl:text>raid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'ror')">
                <xsl:text>ror</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi.org')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'http')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'ftp')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>local</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="figFunc:characterReplace">
        <xsl:param name="input"/>
        <xsl:param name="maintainHTML" as="xs:boolean"/>
        <xsl:variable name="replaceSingleQuote"
            select='replace($input, "&#x00E2;&#x80;&#x99;", "&#x2019;")'/>
        <xsl:variable name="replaceLeftDoubleQuote"
            select='replace($replaceSingleQuote, "&#x00E2;&#x80;&#x9c;", "&#x201C;")'/>
        <xsl:variable name="replaceRightDoubleQuote"
            select='replace($replaceLeftDoubleQuote, "&#x00E2;&#x80;&#x9d;", "&#x201D;")'/>
        <xsl:variable name="replaceNarrowNoBreakSpace"
            select='replace($replaceRightDoubleQuote, "&#xE2;&#x80;&#xAF;", "&#x202F;")'/>

        <xsl:choose>
            <xsl:when test="$maintainHTML">
                <xsl:value-of select="$replaceNarrowNoBreakSpace"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="removeHTMLTags"
                    select="replace($replaceNarrowNoBreakSpace, '&lt;[^&gt;]+&gt;', '')"/>
                <xsl:value-of select="$removeHTMLTags"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>


</xsl:stylesheet>
