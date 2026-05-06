<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
     xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.dspace.org/xmlns/dspace/dim"
    exclude-result-prefixes="oai oai_dc dc fn murFunc custom">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'{requires override}'"/>
    <xsl:param name="global_group" select="'{requires override}'"/>
    <xsl:param name="global_acronym" select="'{requires override}'"/>
    <xsl:param name="global_publisherName" select="'{requires override}'"/>
    <xsl:param name="global_baseURI" select="'{requires override}'"/>
        
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
  
    <xsl:template match="oai:OAI-PMH/*/oai:record">
        <xsl:variable name="oai_identifier" select="oai:header/oai:identifier"/>
        <xsl:message select="concat('identifier: ', oai:header/oai:identifier)"/>
        <xsl:if test="string-length($oai_identifier) > 0">
            <xsl:apply-templates select="oai:metadata/dim" mode="collection">
                <xsl:with-param name="oai_identifier" select="$oai_identifier"/>
            </xsl:apply-templates>
            <!--  xsl:apply-templates select="oai:metadata/metadata/dc:funding" mode="funding_party"/-->
            <xsl:apply-templates select="oai:metadata/dim/field[(@mdschema='dc') and (@element='contributor') and (@qualifier='author')]" mode="party_person"/> 
            <xsl:apply-templates select="oai:metadata/dim/field[(@mdschema='dc') and (@element='publisher') and (@qualifier!='place')]" mode="party_person"/> 
            <xsl:apply-templates select="oai:metadata/dim/field[(@mdschema='local') and (@element='datasetcontact') and (@qualifier='name')]" mode="party_person"/> 
            <xsl:apply-templates select="oai:metadata/dim/field[(@mdschema='local') and (@element='datasetcustodian') and (@qualifier='name')]" mode="party_person"/> 
            
            <xsl:apply-templates select="oai:metadata/dim/field[(@mdschema='dc') and (@element='contributor') and (@qualifier='corporate')]" mode="party_group"/> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dim" mode="collection">
        <xsl:param name="oai_identifier" as="xs:string"/>
        
        <xsl:variable name="class" select="'collection'"/>
        
        <xsl:variable name="key" select="$oai_identifier"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="contains(field[(@mdschema='dc') and (@element='type')], 'dataset')">
                            <xsl:value-of select="'dataset'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'collection'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'date') and (@qualifier = 'accessioned')][string-length(.) > 0]" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'date') and (@qualifier = 'issued')][string-length(.) > 0]" mode="collection_date_issued"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'date') and (@qualifier = 'deposit')][string-length(.) > 0]" mode="collection_date_deposit"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'relation') and (@qualifier = 'uri')][string-length(.) > 0]" mode="collection_relatedInfo_uri"/>
                
                <!--xsl:apply-templates select="field[@mdschema='dcterms']/field[@name ='relation']/field[@name ='none']" mode="collection_relatedInfo_none"/-->
                
                
                <xsl:apply-templates select="field[(@mdschema='local') and (@element = 'relation') and (@qualifier = 'grantdescription')][string-length(.) > 0]" mode="collection_relatedInfo_grantid"/>
                
                <xsl:apply-templates select="field[(@mdschema='local') and (@element = 'identifier') and (@qualifier = 'unepublicationid')][string-length(.) > 0]" mode="collection_identifier"/>
                
                <!--xsl:apply-templates select="field[@name ='local']/field[@name ='dcrelation']/field[@name='publication'][string-length(.) > 0]" mode="collection_description_notes_publicationTitle"/-->
                
                <xsl:apply-templates select="field[(@mdschema='local') and (@element = 'relation') and (@qualifier = 'fundingsourcenote')][string-length(.) > 0]" mode="collection_description_notes_fundingSource"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'uri')][string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'doi')][string-length(.) > 0]" mode="collection_identifier"/>
                
               <!-- if no doi, use handle as location -->
                <xsl:choose>
                    <xsl:when test="count(field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'doi')][string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'doi')][string-length(.) > 0]" mode="collection_location_doi"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'uri')][string-length(.) > 0]" mode="collection_location_uri"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!--xsl:apply-templates select="../../oai:header/oai:identifier[contains(.,'oai:eprints.utas.edu.au:')]" mode="collection_location_nodoi"/-->
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element ='title')][string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="dc:identifier.orcid" mode="collection_relatedInfo"/ -->
                
               <xsl:apply-templates select="field[(@mdschema='local') and (@element='datasetcontact') and (@qualifier='name')][string-length(.) > 0]" mode="collection_relatedObject_isOwnedBy"/>
                
                <!--xsl:apply-templates select="field[(@mdschema='local') and (@element='datasetcontact') and (@qualifier='email')][string-length(.) > 0]" mode="collection_contact_email"/-->
                
                <xsl:apply-templates select="field[(@mdschema='local') and (@element='datasetcustodian') and (@qualifier='name')][string-length(.) > 0]" mode="collection_relatedObject_isManagedBy"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='contributor') and (@qualifier='author')][string-length(.) > 0]" mode="collection_relatedObject"/> 
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='contributor') and (@qualifier='corporate')][string-length(.) > 0]" mode="collection_relatedObject"/> 
               
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='publisher') and (@qualifier!='place')][string-length(.) > 0]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='subject') and (@qualifier='keywords')][string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="field[(@mdschema='local') and (@element='subject') and (@qualifier='for2008')][string-length(.) > 0]" mode="collection_subject_for"/>
                
                <xsl:apply-templates select="field[(@mdschema='local') and (@element='subject') and (@qualifier='seo2008')][string-length(.) > 0]" mode="collection_subject_seo"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='coverage') and (@qualifier='spatial')][string-length(.) > 0]" mode="collection_spatial_coverage"/>
                
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='rights')][string-length(.) > 0]" mode="collection_rights"/>
                
                <xsl:apply-templates select="field[(@mdschema='dcterms') and (@element='accessRights')][string-length(.) > 0]" mode="collection_accessRights"/>
                
                <xsl:apply-templates select="field[(@mdschema='dcterms') and (@element='rightsHolder')][string-length(.) > 0]" mode="collection_rights_holder"/>
                
                <xsl:apply-templates select="field[(@mdschema='dcterms') and (@element='rightsHolder')][string-length(.) > 0]" mode="collection_rights_holder"/>
                
                <xsl:apply-templates select="field[(@mdschema='dcterms') and (@element='RightsStatement')][string-length(.) > 0]" mode="collection_rights"/>
                
                
                <xsl:choose>
                    <xsl:when test="count(field[(@mdschema='dc') and (@element='description') and (@qualifier='abstract')][string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="field[(@mdschema='dc') and (@element='description') and (@qualifier='abstract')][string-length(.) > 0]" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="field[(@mdschema='dc') and (@element ='title')][string-length(.) > 0]" mode="collection_description_brief"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                
               
                <xsl:apply-templates select="field[(@mdschema='dc') and (@element='coverage') and (@qualifier='temporal')][string-length(.) > 0]" mode="collection_coverage_temporal"/>
                
                <xsl:apply-templates select="." mode="collection_citation_information"/>
                
             
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="dim" mode="collection_citation_information">
        
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'doi')][string-length(.) > 0]) > 0">
                        <xsl:for-each select="field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'doi')][string-length(.) > 0]">
                            <identifier type="doi">
                                <xsl:value-of select="normalize-space(.)"/>
                            </identifier>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'uri')][string-length(.) > 0]) > 0">
                        <xsl:for-each select="field[(@mdschema='dc') and (@element = 'identifier') and (@qualifier = 'uri')][string-length(.) > 0]">
                            <identifier type="uri">
                                <xsl:value-of select="normalize-space(.)"/>
                            </identifier>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(field[(@mdschema='local') and (@element = 'identifier') and (@qualifier = 'unepublicationid')][string-length(.) > 0]) > 0">
                        <xsl:for-each select="field[(@mdschema='local') and (@element = 'identifier') and (@qualifier = 'unepublicationid')][string-length(.) > 0]">
                            <identifier type="local">
                                <xsl:value-of select="normalize-space(.)"/>
                            </identifier>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:for-each select="[(@mdschema='dc') and (@element='contributor') and (@qualifier='author')][string-length(.) > 0]">
                    <xsl:variable name="nameValueSpaceSeparated" select="tokenize(murFunc:formatName(.), '\s')" as="xs:string*"/> 
                    <contributor seq="{position()}">
                        <xsl:choose>
                            <xsl:when test="count($nameValueSpaceSeparated) > 1">
                                <namePart type="family">
                                    <xsl:value-of select="$nameValueSpaceSeparated[count($nameValueSpaceSeparated)]"/>
                                </namePart>
                                <namePart type="given">
                                    <xsl:value-of select="$nameValueSpaceSeparated[1]"/>
                                </namePart>
                            </xsl:when>
                            <xsl:when test="count($nameValueSpaceSeparated) = 1">
                                <namePart type="family">
                                    <xsl:value-of select="$nameValueSpaceSeparated[1]"/>
                                </namePart>
                            </xsl:when>
                        </xsl:choose>
                    </contributor>
                </xsl:for-each>
                
                
                <xsl:for-each select="field[@mdschema='dc']/field[@name ='contributor']/field[@name ='corporate']/field/field[@name='value'][string-length(.) > 0]">
                    <contributor>
                        <namePart type="family">
                            <xsl:value-of select="."/>
                        </namePart>
                    </contributor>
                </xsl:for-each>
                
                
                <xsl:for-each select="field[@mdschema='dc']/field[@name ='title'][string-length(.) > 0]">
                    <title>
                        <xsl:value-of select="normalize-space(.)"/>
                    </title>
                </xsl:for-each>                
                    
                <!--version>@todo</version-->
                
                <xsl:for-each select="field[@mdschema='dc']/field[@name ='publisher'][string-length(.) > 0]">
                    <publisher>
                        <xsl:value-of select="normalize-space(.)"/>
                    </publisher>
                </xsl:for-each>
                
                <xsl:for-each select="field[@mdschema='dc']/field[@name ='date']/field[@name ='issued'][string-length(.) > 0]">
                    <date type="publicationDate">
                        <xsl:value-of select="normalize-space(.)"/>
                    </date>
                </xsl:for-each>
            </citationMetadata>
        </citationInfo>
    </xsl:template>
   
    
     <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_date_issued">
       <dates type="dc.issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_date_deposit">
        <dates type="dc.dateSubmitted">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>
       
    <xsl:template match="field[@qualifier='unepublicationid']" mode="collection_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="field[@qualifier='uri']" mode="collection_identifier">
       <identifier type="url">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>   
    </xsl:template>
    
    <xsl:template match="field[@qualifier='doi']" mode="collection_identifier">
        <identifier type="doi">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    
    
    <!--xsl:template match="field" mode="collection_contact_email">
        <location>
            <address>
                <electronic type="email">
                    <value>
                        <xsl:value-of select="normalize-space(.)"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template-->
    
    <xsl:template match="field[@qualifier='doi']" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(normalize-space(.), '10.')">
                                <xsl:value-of select="concat('http://doi.org/', normalize-space(.))"/>
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
    
    <xsl:template match="field[@qualifier='uri']" mode="collection_location_uri">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="normalize-space(.)"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="field[@element ='title']" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
   <xsl:template match="dc:identifier.orcid" mode="collection_relatedInfo">
        <xsl:message select="concat('vivo:orcidId : ', .)"/>
                            
        <relatedInfo type='party'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_relatedInfo_uri">
        <relatedInfo type='relatedInformation'>
           <identifier type="uri">
               <xsl:value-of select="normalize-space(.)"/>
           </identifier>
            <relation type="hasAssociationWith"/>
       </relatedInfo>
    </xsl:template>
    
    <xsl:template match="field[@name='none']" mode="collection_relatedInfo_none">
        <xsl:for-each select="field[@name='value']">
            <xsl:if test="fn:starts-with(normalize-space(.), 'http')">
             <relatedInfo>
                 <identifier type="url">
                     <xsl:value-of select="normalize-space(.)"/>
                 </identifier>
                 <relation type="hasAssociationWith"/>
             </relatedInfo>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_relatedInfo_grantid">
        <relatedInfo type='activity'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:choose>
                    <xsl:when test="starts-with(normalize-space(.), 'ARC/')">
                        <xsl:value-of select="substring-after(normalize-space(.), 'ARC/')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(normalize-space(.), 'NHMRC/')">
                        <xsl:value-of select="substring-after(normalize-space(.), 'NHMRC/')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </identifier>
            <relation type="isOutputOf"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_relatedObject">
         <relatedObject>
             <key>
                 <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
             </key>
             <relation type="hasCollector"/>
         </relatedObject>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_relatedObject_isOwnedBy">
        <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="isOwnedBy"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="field" mode="collection_relatedObject_isManagedBy">
         <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="isManagedBy"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="field[(@element='contributor') and (@qualifier='author')]" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="field[(@element='contributor') and (@qualifier='corporate')]" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="hasAssociationWith"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="field[(@element='publisher') and (@qualifier!='place')]" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="publisher"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="field[@qualifier='keywords']" mode="collection_subject">
        <subject>
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="field[@qualifier='for2008']" mode="collection_subject_for">
        <subject type="anzsrc-for">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="field[@qualifier='seo2008']" mode="collection_subject_seo">
        <subject type="anzsrc-seo">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
   
    <xsl:template match="field[@qualifier ='spatial']" mode="collection_spatial_coverage">
          <coverage>
              <xsl:choose>
                  <xsl:when test="contains(lower-case(.), 'northlimit')">
                      <spatial type="iso19139dcmiBox">
                          <xsl:value-of select='normalize-space(.)'/>   
                      </spatial>
                  </xsl:when>
                  <xsl:when test="contains(lower-case(.), 'point') or contains(lower-case(.), 'polygon')">
                      <spatial type="gmlKmlPolyCoords">
                          <xsl:value-of select="normalize-space(.)"/>     
                      </spatial>
                  </xsl:when>
                  <xsl:otherwise>
                      <spatial type="text">
                          <xsl:value-of select='normalize-space(.)'/>  
                      </spatial>
                  </xsl:otherwise>
              </xsl:choose>
          </coverage>
    </xsl:template>
    
    <xsl:template match="field[(@element='rights') or (@element='RightsStatement')]" mode="collection_rights">
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="field[@element='rightsHolder']" mode="collection_rights_holder">
        <rights>
            <rightsStatement>
                <xsl:value-of select="concat('Rights holder: ', normalize-space(.))"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="field[@element ='accessRights']" mode="collection_accessRights">
        
       <rights>
            <accessRights>
                <xsl:attribute name="type">
                    <xsl:value-of select="fn:normalize-space(.)"/>
                </xsl:attribute>
            </accessRights>
       </rights>
     
    </xsl:template>
    
    <xsl:template match="field" mode="collection_rights_licence_uri">
        <rights>
            <licence rightsUri="{normalize-space(.)}"/>
        </rights>
    </xsl:template>
    
 
   
    
    <xsl:template match="field[@name ='title']" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="field[@name ='description']" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!--xsl:template match="field[@name='publication']" mode="collection_description_notes_publicationTitle">
        <xsl:if test="count(field/field[@name='value'][string-length(.) > 0]) > 0">
            <description type="note">
                <xsl:text>&lt;b&gt;Related Publications&lt;/b&gt;</xsl:text>
                <xsl:for-each select="element/field[@name='value'][string-length(.) > 0]">
                    <xsl:text>&lt;br/&gt;</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:for-each>
            </description>
        </xsl:if>
    </xsl:template-->
    
    <xsl:template match="field[@qualifier='fundingsourcenote']" mode="collection_description_notes_fundingSource">
        <description type="note">
            <xsl:text>&lt;b&gt;Funding Source&lt;/b&gt;</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name ='temporal']" mode="collection_coverage_temporal">
        <coverage>
            <temporal>
                <text>
                    <xsl:value-of select="normalize-space(.)"/>
                </text>
            </temporal>
        </coverage>
    </xsl:template>  
    
    <!--xsl:template match="dc:source" mode="collection_citation_info">
        <citationInfo>
           <fullCitation>
                <xsl:value-of select="normalize-space(.)"/>
            </fullCitation>
        </citationInfo>
    </xsl:template-->  
             
     <xsl:template match="field" mode="party_person">
        
         <!--xsl:for-each select="field[@mdschema='dc']/field[@name ='contributor']/field[(@name ='author') or (@name ='publisher')]"-->
            
             <xsl:for-each select="element/field[@name='value']">
                <xsl:variable name="name" select="normalize-space(.)"/>
                
                <xsl:if test="(string-length(.) > 0)">
                
                       <xsl:if test="string-length(normalize-space(.)) > 0">
                         <registryObject group="{$global_group}">
                            <key>
                                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                            </key>
                            <originatingSource>
                                 <xsl:value-of select="$global_originatingSource"/>
                            </originatingSource>
                            
                             <party>
                                <xsl:attribute name="type" select="'person'"/>
                                 
                                 <name type="primary">
                                     <namePart>
                                         <xsl:value-of select="murFunc:formatName(normalize-space(.))"/>
                                     </namePart>   
                                 </name>
                             </party>
                         </registryObject>
                       </xsl:if>
                    </xsl:if>
                </xsl:for-each>
         <!--/xsl:for-each-->
        </xsl:template>
    
    <xsl:template match="field" mode="party_group">
        
        <xsl:for-each select="field/field[@name='value']">
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(.) > 0)">
                
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                        </key>
                        <originatingSource>
                            <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                        <party>
                            <xsl:attribute name="type" select="'group'"/>
                            
                            <name type="primary">
                                <namePart>
                                    <xsl:value-of select="murFunc:formatName(normalize-space(.))"/>
                                </namePart>   
                            </name>
                        </party>
                    </registryObject>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
                   
    <xsl:function name="murFunc:formatName">
        <xsl:param name="name"/>
        
        <xsl:variable name="namePart_sequence" as="xs:string*">
            <xsl:analyze-string select="$name" regex="[A-Za-zÀ-ÿ()-]+">
                <xsl:matching-substring>
                    <xsl:if test="regex-group(0) != '-'">
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:if>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($namePart_sequence) = 0">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="orderedNamePart_sequence" as="xs:string*">
                    <!--  we are going to presume that we have surnames first - otherwise, it's not possible to determine by being
                            prior to a comma because we get:  "surname, firstname, 1924-" sort of thing -->
                    <!-- all names except surname -->
                    <xsl:for-each select="$namePart_sequence">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="$namePart_sequence[1]"/>
                </xsl:variable>
                <xsl:value-of select="string-join(for $i in $orderedNamePart_sequence return $i, ' ')"/>
    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="murFunc:formatKey">
        <xsl:param name="input"/>
        <xsl:variable name="raw" select="translate(normalize-space($input), ' ', '')"/>
        <xsl:variable name="temp">
            <xsl:choose>
                <xsl:when test="substring($raw, string-length($raw), 1) = '.'">
                    <xsl:value-of select="substring($raw, 0, string-length($raw))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$raw"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($global_acronym, '/', $temp)"/>
    </xsl:function>
    
</xsl:stylesheet>
    
