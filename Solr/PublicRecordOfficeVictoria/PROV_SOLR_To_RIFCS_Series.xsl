<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://wiki.apache.org/solr/"
    exclude-result-prefixes="xsl murFunc custom fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
      
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="doc"  mode="collection">
        <xsl:param name="metadata_datestamp"/>
        
        <xsl:variable name="class">
            <xsl:value-of select="'collection'"/>
        </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <!-- Generate key from doi if there is one (this means key will stay the same in future harvests even if harvest api or source xml changes form-->
            <xsl:apply-templates select="str[@name='citation']" mode="collection_key"/>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="collection">
                
                <xsl:attribute name="type">
                    <xsl:value-of select="'collection'"/>
                </xsl:attribute>
             
                <xsl:apply-templates select="$metadata_datestamp" mode="date_modified"/>
                
                <xsl:apply-templates select="str[@name='identifier.PROV_ACM.id']" mode="collection_identifier"/>
                <xsl:apply-templates select="str[@name='series_id']" mode="collection_identifier"/>
                
                <xsl:choose>
                    <xsl:when test="count(str[@name='doi']) > 0">
                        <xsl:apply-templates select="str[@name='doi'][1]" mode="collection_location_doi"/>
                    </xsl:when>
                    <xsl:when test="count(str[@name='citation']) > 0">
                        <xsl:apply-templates select="str[@name='citation'][1]" mode="collection_location_url"/>
                    </xsl:when>
                </xsl:choose>
               
                <xsl:apply-templates select="str[@name='title']" mode="collection_name"/>
                
                <xsl:choose>
                    <xsl:when test="count(arr[@name='function_content']/str) > 0">
                        <xsl:apply-templates select="arr[@name='function_content']/str" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(str[@name='title']) > 0">
                        <xsl:apply-templates select="str[@name='title']" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="arr[@name='rights_status']" mode="collection_rights_access"/>
                
                <xsl:apply-templates select="str[@name='creator']" mode="collection_relatedObject_agency"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
   <xsl:template match="str" mode="collection_key">
        <key>
            <xsl:value-of select="concat($global_acronym, ' ', normalize-space(.))"/>
        </key>
    </xsl:template>
    
    
    <xsl:template match="*" mode="date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="str" mode="collection_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
   <xsl:template match="str" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="str" mode="collection_location_url">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, '/', replace(., ' ', ''))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="str" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="str" mode="collection_relatedObject_agency">
        <relatedObject>
            <key>
                <xsl:if test="starts-with(series.agency.control.no, 'AGY-')">
                    <xsl:value-of select="$global_acronym"/>
                    <xsl:value-of select="'/agencies/'"/>
                    <xsl:value-of select="substring-after(series.agency.control.no, 'AGY-')"/>
                </xsl:if>
            </key>
            <relation type="hasManager"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="series.person.related" mode="relatedObject_person">
        <relatedObject>
            <key>
                <xsl:if test="starts-with(series.person.related.no, 'PER-')">
                    <xsl:value-of select="$global_acronym"/>
                    <xsl:value-of select="'/persons/'"/>
                    <xsl:value-of select="substring-after(series.person.related.no, 'PER-')"/>
                </xsl:if>
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="Create.Agency" mode="relatedObject_agency">
        <relatedObject>
            <key>
                <xsl:if test="starts-with(series.agency.create.no, 'AGY-')">
                    <xsl:value-of select="$global_acronym"/>
                    <xsl:value-of select="'/agencies/'"/>
                    <xsl:value-of select="substring-after(series.agency.create.no, 'AGY-')"/>
                </xsl:if>
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <!--xsl:template match="Part_of" mode="relatedInfo_partOf">
        <relatedInfo type="{lower-case(part_of.description_level)}">
            <identifier type="uri">
                <xsl:value-of select="concat($global_baseURI, $global_path, part_of_reference.lref)"/>
            </identifier>
            <relation>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="lower-case(part_of.description_level) = 'activity'">
                            <xsl:text>isOutputOf</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>isPartOf</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </relation>
            <title>
                <xsl:value-of select="concat(part_of.title, '[',part_of_reference,'] (', part_of_reference.date.start, ' to ', part_of_reference.date.end, ')')"/>
            </title>
        </relatedInfo>
    </xsl:template-->
    
    <xsl:template match="Production_date" mode="collection_date">
        <dates type="dc.created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="production.date.start"/>
            </date>
            <date type="dateTo" dateFormat="W3CDTF">
                <xsl:value-of select="production.date.end"/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="Production_date" mode="collection_coverage_temporal">
        
        <coverage>
            <temporal>
                <date type="dateFrom" dateFormat="W3CDTF">
                    <xsl:value-of select="content_start_date"/>
                </date>
                <date type="dateTo" dateFormat="W3CDTF">
                    <xsl:value-of select="content_end_date"/>
                </date>
            </temporal>
        </coverage>
        
    </xsl:template>
    
    <xsl:template match="Related_object" mode="collection_related_object">
        <relatedObject>
            <key>
                <xsl:if test="starts-with(related_object.reference, 'NRS-')">
                    <xsl:value-of select="$global_acronym"/>
                    <xsl:value-of select="'/series/'"/>
                    <xsl:value-of select="substring-after(related_object.reference, 'NRS-')"></xsl:value-of>
                </xsl:if>
            </key>
            <relation type="hasAssociationWith"/>
        </relatedObject>
    </xsl:template>     
 
    <xsl:template match="arr" mode="collection_rights_access">
        <rights>
            <accessRights type="other">
                <xsl:text>Series Access Rights: </xsl:text>
                <xsl:variable name="count" select="count(str)"/>
                   
                    <xsl:for-each select="str">
                        <xsl:value-of select="."/>
                        <xsl:if test="$count > fn:position()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
            </accessRights>
        </rights>
        
    </xsl:template>
    
    <xsl:template match="rights" mode="collection_rights">
        <rights>
            <accessRights>
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="@rightsURI"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="(lower-case(.) = 'open access')">
                            <xsl:text>open</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'embargoed access')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'restricted access')">
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="(lower-case(.) = 'metadata only access')">
                            <xsl:text>conditional</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                
                <xsl:value-of select="."/>
            </accessRights>
        </rights>
        
    </xsl:template>
    
    <xsl:template name="collection_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="str" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="str" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="record" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(str[@name='doi']) > 0">
                        <xsl:apply-templates select="str[@name='doi'][1]" mode="collection_identifier"/>
                    </xsl:when>
                    <xsl:when test="count(str[@name='citation']) > 0">
                        <xsl:apply-templates select="str[@name='citation'][1]" mode="collection_identifier"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:for-each select="creators/creator/creatorName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <xsl:apply-templates select="Create.Agency" mode="citationMetadata_contributor"/>
                
                <title>
                    <xsl:value-of select="normalize-space(string-join(Title, ' - '))"/>
                </title>
                
                <!--version></version-->
                <!--placePublished></placePublished-->
                <publisher>
                    <xsl:value-of select="normalize-space(string-join(control.agency/series.agency.control.name, ', '))"/>
                </publisher>
                <date type="publicationDate">
                    <xsl:value-of select="publicationYear"/>
                </date>
                <!--url>
                    <xsl:choose>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'URL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'URL')][1]"/>
                        </xsl:when>
                        <xsl:when test="count(alternateIdentifier[(@alternateIdentifierType = 'PURL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]"/>
                        </xsl:when>
                    </xsl:choose>
                </url-->
            </citationMetadata>
        </citationInfo>
        
    </xsl:template>
    
    <xsl:template match="Create.Agency" mode="citationMetadata_contributor">
        <contributor>
            <namePart type="family">
                <xsl:if test="count(series.agency.create.no) > 0">
                    <xsl:value-of select="normalize-space(series.agency.create.no[1])"/>
                </xsl:if>
                <xsl:if test="count(agency.name) > 0">
                    <xsl:text> | </xsl:text>
                    <xsl:value-of select="normalize-space(agency.name[1])"/>
                </xsl:if>
            </namePart>
         </contributor>
    </xsl:template>
    
             
     
   </xsl:stylesheet>
    