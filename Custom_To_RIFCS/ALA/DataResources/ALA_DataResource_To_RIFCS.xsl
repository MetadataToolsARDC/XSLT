<?xml version="1.0" encoding="UTF-8"?>
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
    <xsl:param name="global_emlNamespace" select="'eml://ecoinformatics.org/eml-2.1.1'"/>
    <xsl:param name="global_prefixURL" select="'https://collections.ala.org.au/public/show/'"/>
    <xsl:param name="global_prefixKey" select="'ala.org.au/'"/>
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
          
          <xsl:variable name="key" as="xs:string">
            <xsl:value-of select="substring-after(/*/dataset/alternateIdentifier[contains(., $global_prefixURL)][1], $global_prefixURL)"/>
          </xsl:variable>
            <xsl:apply-templates select="/*" mode="process">
              <xsl:with-param name="key" select="$key"/>
            </xsl:apply-templates>
        </registryObjects>
    </xsl:template>
    
    <!--key for selecting a nodeset of identical parties based on the details-->
    <xsl:key name="keyPartyUnique" match="creator|associatedParty|metadataProvider|contact" 
        use="concat(individualName, organizationName, positionName, address, phone, electronicMailAddress)"/>
    
  <xsl:template match="/*[local-name()='eml' and namespace-uri()=$global_emlNamespace]" mode="process">
    <xsl:param name="key"/>
        <xsl:message select="concat('ALA source has children: ', has-children(.))"/>
    
     <!--<xsl:variable name="packageId" select="@packageId"/> -->
    <!--xsl:variable name="docid" select="concat(substring-before(string(@packageId),'.'),'.',substring-before(substring-after(string(@packageId),'.'),'.'))" /-->
    <!--xsl:variable name="revid" select="substring-after(string(@packageId), concat($docid, '.'))" /-->
    
    <xsl:variable name="docid" select="@packageId" />
    <xsl:variable name="revid" select="''"/> <!-- TODO: obtain revid from somewhere if required -->
    
    <!--xsl:element name="registryObjects"-->
      <xsl:apply-templates select="dataset">
        <xsl:with-param name="docid" select="$docid" />
        <xsl:with-param name="revid" select="$revid" />
        <xsl:with-param name="key" select="$key" />
      </xsl:apply-templates>
    <!--/xsl:element-->
  </xsl:template>
  
  <xsl:template match="dataset">
    <xsl:param name="docid"/>
    <xsl:param name="revid"/>
    <xsl:param name="key"/>
    
    <xsl:variable name="originatingSource">
      <xsl:choose>
        <xsl:when test="not($serverUrl)">
            <xsl:choose>
              <xsl:when test="count(creator/organizationName) > 0">
                <xsl:value-of select="creator/organizationName[1]"/>
              </xsl:when>
              <xsl:when test="count(publisher/organizationName) > 0">
                <xsl:value-of select="publisher/organizationName[1]"/>
              </xsl:when>
            </xsl:choose>
       </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$serverUrl" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- collection -->
    <xsl:call-template name="collection">
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="revid" select="$revid" />
      <xsl:with-param name="key" select="$key" />
    </xsl:call-template>
    
    <!-- party -->
    <xsl:apply-templates select="(creator|associatedParty|metadataProvider|contact)">
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="originatingSource" select="$originatingSource" />
    </xsl:apply-templates>
    
    <xsl:apply-templates select="(project|project/relatedProject)" mode="activity_registryObject">
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="originatingSource" select="$originatingSource"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  <!-- Create collection registryObject -->
  <xsl:template name="collection">
    <xsl:param name="docid"/>
    <xsl:param name="revid"/>
    <xsl:param name="key"/>
    
    
    <xsl:variable name="doi_sequence" select="alternateIdentifier[contains(text(), '10.')]"/>
    
    <xsl:element name="registryObject">
      <xsl:attribute name="group"><xsl:value-of select="$global_group" /></xsl:attribute>
      
      <xsl:element name="key"><xsl:value-of select="concat($global_prefixKey, $key)" /></xsl:element>
      
      <xsl:element name="originatingSource">
        <xsl:value-of select="$global_originatingSource" />
      </xsl:element>
      
      <xsl:element name="collection">
        <xsl:attribute name="type">dataset</xsl:attribute>
        <xsl:attribute name="dateAccessioned"><xsl:value-of select="$dateCreated" /></xsl:attribute>
        <xsl:attribute name="dateModified"><xsl:value-of select="$lastModified" /></xsl:attribute>
        
        <!--xsl:variable name="doi" select="alternateIdentifier[@system='doi']"/-->
        
        <!--xsl:element name="identifier">
          <xsl:attribute name="type">local</xsl:attribute>
          <xsl:value-of select="$docid" / This ID is for the whole packages, which can contain dataset, software etc. so it is higher than this object>
          <xsl:value-of select="@id"/>
        </xsl:element-->
        
        <xsl:if test="count($doi_sequence) > 0">
          <xsl:for-each select="$doi_sequence">
            <xsl:element name='identifier'>
              <xsl:attribute name="type">doi</xsl:attribute>
                <xsl:value-of select="local:format_doi(.)"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:if>

        <xsl:element name="name">
          <xsl:attribute name="type">primary</xsl:attribute>
          <xsl:element name="namePart">
            <xsl:attribute name="type">full</xsl:attribute>
            <xsl:value-of select="title[1]" />
          </xsl:element>
        </xsl:element>

        <!--TODO:pub date -->
        
        <xsl:element name="location">
          <xsl:element name="address">
              <xsl:choose>
                <!-- Don't use DOI because it might go elsewhere rather than in ALA -->
                <!--xsl:when test="(count($doi_sequence) > 0) and boolean(normalize-space($doi_sequence[1]))">
                  <xsl:element name="electronic">
                    <xsl:attribute name="type">url</xsl:attribute>
                    <xsl:element name="value">
                      <xsl:value-of select="local:format_doi($doi_sequence[1])"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:when-->
                <xsl:when test="count(distribution/online/url[string-length(text()) > 0]) > 0">
                  <xsl:element name="electronic">
                    <xsl:attribute name="type">url</xsl:attribute>
                    <xsl:element name="value">
                      <xsl:value-of select="distribution/online/url[string-length(text()) > 0][1]"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="alternateIdentifier[@system='url']">
                    <xsl:element name="electronic">
                      <xsl:attribute name="type">url</xsl:attribute>
                      <xsl:element name="value">
                        <xsl:value-of select="."/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
          </xsl:element>
        </xsl:element>

        <!--generate relationships to parties, implied by name of element -->
        <!--xsl:apply-templates select="(creator|associatedParty|metadataProvider|contact)[generate-id()=generate-id(key('keyPartyUnique', concat(individualName, organizationName, positionName, address, phone, electronicMailAddress))[1])]"
                             mode="relatedInfo"/-->

        <xsl:apply-templates select="keywordSet" />
        <xsl:apply-templates select="abstract/para[string-length(normalize-space(.)) > 0]" />
        
        <xsl:if test="count(abstract/para[string-length(normalize-space(.)) > 0]) = 0">
          <xsl:apply-templates select="title[1]" mode="description"/>
        </xsl:if>

        <xsl:if test="coverage/geographicCoverage or coverage/temporalCoverage">
          <xsl:element name="coverage">
            <xsl:apply-templates select="coverage/temporalCoverage"/>
            <xsl:apply-templates select="coverage/geographicCoverage"/>
          </xsl:element>
        </xsl:if>
        
       <xsl:apply-templates select="project">
         <xsl:with-param name="relation" select="'isOutputOf'"/>
       </xsl:apply-templates>
        
        <xsl:apply-templates select="additionalInfo/section"  mode="relatedInfo"/>
       
        <xsl:apply-templates select="intellectualRights/para" mode="rights"/>
        
        <!-- If no access element, 
          accessRights/@type be set to 'restricted'; otherwise, leave unset
          
          Justification for this is that according to the EML spec, access is recommended 
          to be set for the eml-package (metadata and any inline data) because not doing 
          so implies the default:
            "If this access element is omitted from the document, then the package submitter should be given full access to the package but all other users should be denied all access.
            To allow the package to be publicly viewable, the EML author must explicitly include a rule stating so. "
            https://sbclter.msi.ucsb.edu/external/InformationManagement/EML_211_schema/docs/eml-2.1.1/eml-access.html
            
          This package-level access is then overridden per distribution underneath one of either:
          dataTable; spatialRaster; spatialVector; storedProcedure; view; otherEntity.  
        
        -->
        
        <xsl:if test="count(//access) = 0">
          <xsl:element name="rights">
            <xsl:element name="accessRights">
              <xsl:attribute name="type">
                <xsl:text>restricted</xsl:text>
              </xsl:attribute>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
       
        <!-- If suggested citation, use it -->
        <xsl:element name="citationInfo">
          
          <xsl:message select="concat('additionalMetadata for citation present: ', count(following-sibling::additionalMetadata[(metadata/gbif/citation[string-length(text()) > 0])]))"></xsl:message>
          
          <xsl:choose>
          
          
            <!--xsl:when test="count(following-sibling::additionalMetadata[(metadata/citeAs[string-length(text()) > 0] and (describes = @id))]) > 0"-->
            <xsl:when test="count(following-sibling::additionalMetadata[(metadata/gbif/citation[string-length(text()) > 0])]) > 0">
              <xsl:for-each select="following-sibling::additionalMetadata[(metadata/gbif/citation[string-length(text()) > 0])]">
                <xsl:for-each select="metadata/gbif/citation">
                  <xsl:element name="fullCitation">
                    <xsl:apply-templates select="./text()"/>
                  </xsl:element>
                </xsl:for-each>
              </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
          
            <!-- Otherwise construct citation metadata -->
            <!-- citationInfo -->
            
              <xsl:element name="citationMetadata">
                <xsl:element name="identifier">
                  <xsl:choose>
                    <xsl:when test="normalize-space($doi_sequence[1])">
                      <xsl:attribute name="type">doi</xsl:attribute>
                      <xsl:value-of select="local:format_doi($doi_sequence[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="type">local</xsl:attribute>
                      <xsl:value-of select="$docid"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:apply-templates select="creator" mode="citationContributor"/>
                <xsl:element name="title">
                  <xsl:value-of select="title[1]"/>
                </xsl:element>
                
                <xsl:call-template name="citationMetadataVersion">
                  <xsl:with-param name="revid" select="$revid" />
                </xsl:call-template>
                
                <xsl:for-each select="publisher/organizationName">
                  <xsl:element name="publisher">
                    <xsl:value-of select="."/>
                  </xsl:element>
                </xsl:for-each>
                
                <xsl:element name="placePublished">
                  <xsl:value-of select="pubPlace"/>
                </xsl:element>
                <xsl:element name="date">
                  <xsl:attribute name="type">publicationDate</xsl:attribute>
                  <xsl:value-of select="pubDate"/>
                  <xsl:if test="not(normalize-space(pubDate))">
                    <xsl:value-of select="$dateCreated"/>
                  </xsl:if>
                </xsl:element>
                <!--xsl:element name="url">
                  <xsl:choose>
                    <xsl:when test="normalize-space($doi_sequence[1])">
                      <xsl:value-of select="local:format_doi($doi_sequence[1])"/>
                    </xsl:when>
                 </xsl:choose>
                </xsl:element-->
                <!--xsl:element name="context"></xsl:element-->
              </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="local:format_doi">
    <xsl:param name="doi"/>
    <xsl:choose>
      <xsl:when test="starts-with($doi, '10.')">
        <xsl:value-of select="concat('https://doi.org/', $doi)"/>
      </xsl:when>
      <xsl:when test="starts-with($doi, 'DOI:')">
        <xsl:value-of select="concat('https://doi.org/', substring-after($doi, 'DOI:'))"/>
      </xsl:when>
      <xsl:when test="starts-with($doi, 'doi:')">
        <xsl:value-of select="concat('https://doi.org/', substring-after($doi, 'doi:'))"/>
      </xsl:when>
      <xsl:when test="starts-with($doi, 'http')">
        <xsl:value-of select="$doi"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$doi"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="project">
    
      <!-- Related Project -->
      <xsl:element name="relatedInfo">
        <xsl:element name="identifier">
          <xsl:attribute name="type" select="'local'"/>
          <xsl:value-of select="concat($global_acronym, '/Activity/', local:format_keystring(@id))" />
        </xsl:element>
        <xsl:element name="relation">
          <xsl:attribute name="type">
            <xsl:text>isOutputOf</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
      
    <xsl:apply-templates select="funding/section" mode="relatedInfo"/>
    
    <xsl:apply-templates select="relatedProject"/>
    
  </xsl:template>
  
  
  <xsl:template match="section" mode="relatedInfo">
    
      <xsl:element name="relatedInfo">
        <xsl:attribute name="type">
          <xsl:value-of select="title[1]"/>
        </xsl:attribute>
        <xsl:element name="identifier">
          <xsl:attribute name="type">
            <xsl:value-of select="'uri'"/>
          </xsl:attribute>
          <xsl:value-of select="para[1]/ulink[1]/@url"/>
        </xsl:element>
        <xsl:element name="relation">
          <xsl:attribute name="type">
            <xsl:choose>
              <xsl:when test="lower-case(title) = 'publication'">
                <xsl:text>isCitedBy</xsl:text>
              </xsl:when>
              <xsl:when test="lower-case(title) = 'activity'">
                <xsl:text>isOutputOf</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>hasAssociationWith</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:element>
        
        <xsl:choose>
            <xsl:when test="string-length(para[1]/value[1]) > 0">
              <xsl:element name="title">
                <xsl:value-of select="para[1]/value[1]"/>
              </xsl:element>
            </xsl:when>
             <xsl:otherwise>
               <xsl:text>Funding Grant</xsl:text>
             </xsl:otherwise>
        </xsl:choose>
        
      </xsl:element>
    
  </xsl:template>
  
  <xsl:template match="relatedProject">
    <!-- Related Activity(grant) -->
    <xsl:element name="relatedInfo">
      <xsl:element name="identifier">
        <xsl:attribute name="type" select="'local'"/>
        <xsl:value-of select="concat($global_acronym, '/Activity/', local:format_keystring(@id))" />
      </xsl:element>
      <xsl:element name="relation">
        <xsl:attribute name="type">
          <xsl:text>isOutputOf</xsl:text>
        </xsl:attribute>
      </xsl:element>
    </xsl:element>
    
    <xsl:apply-templates select="funding"/>
    
  </xsl:template>
      
 
  
  <!-- intellectualRights -->
  <xsl:template match="para" mode="rights">
    <xsl:for-each-group select="ulink" group-by="@url">
      <xsl:element name="rights">
        <xsl:element name="licence">
          <xsl:if test="string-length(current-grouping-key()) > 0">
            <xsl:attribute name="rightsUri">
              <xsl:value-of select="current-grouping-key()"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="string-length(citetitle) > 0">
             <xsl:apply-templates select="citetitle/text()"/>
          </xsl:if>
        </xsl:element>
      </xsl:element>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="*/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template name="citationMetadataVersion">
    <xsl:param name="revid"/>
    <xsl:element name="version">
      <xsl:value-of select="$revid"/>
    </xsl:element>
  </xsl:template>

  <!--this will match all possible party nodes except the ones that contain references, overridden by template *[references] defined later-->
  <xsl:template match="creator|associatedParty|metadataProvider|contact">
    <xsl:param name="docid"/>
    <xsl:param name="originatingSource"/>
    <!--xsl:call-template name="party">
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="originatingSource" select="$originatingSource" />
    </xsl:call-template-->
  </xsl:template>

  <xsl:template match="creator|associatedParty|metadataProvider|contact" mode="relatedInfo">
    <xsl:element name="relatedInfo">
      <xsl:element name="identifier">
        <xsl:attribute name="type" select="'local'"/>
        <xsl:call-template name="partyIdentifier"/>
      </xsl:element>

      <xsl:apply-templates select="key('keyPartyUnique', concat(individualName, organizationName, positionName, address, phone, electronicMailAddress))" mode="relationCollection" />
      <xsl:apply-templates select="../*[references = current()/@id]" mode="relationCollection"/>
      <xsl:apply-templates select="organizationName" mode="related_title"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[references]"/>
  <xsl:template match="*[references]" mode="relatedInfo"/>
  
  <!--xsl:template name="party">
    <xsl:param name="docid"/>
    <xsl:param name="originatingSource"/>
    
    <xsl:element name="registryObject">
      <xsl:attribute name="group">
        <xsl:value-of select="$global_group"/>
      </xsl:attribute>
      
      <xsl:element name="key">
        <xsl:call-template name="partyIdentifier"/>
      </xsl:element>
      
      <xsl:element name="originatingSource">
        <xsl:value-of select="$originatingSource"/>
      </xsl:element>
      
      <xsl:element name="party">
        <xsl:attribute name="type">
          <xsl:choose>
            <xsl:when test="individualName or string(positionName)">
              <xsl:value-of select="'person'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'group'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>

        <xsl:apply-templates select="userId"/>
        <xsl:apply-templates select="individualName"/>
        <xsl:apply-templates select="positionName"/>
        <xsl:apply-templates select="organizationName"/>

        <xsl:call-template name="fillOutAddress"/>

      
    </xsl:element> 
  </xsl:template--> <!--name="party"-->
  
  <xsl:template match="organizationName" mode="related_title">
    <xsl:element name="title">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="partyIdentifier">
    <xsl:choose>
      <xsl:when test="individualName">
        <xsl:value-of select="concat($global_acronym, '/Party/', local:format_keystring(individualName/givenName), local:format_keystring(individualName/surName))" />
      </xsl:when>
      <xsl:when test="organizationName">
        <xsl:value-of select="concat($global_acronym, '/Party/', local:format_keystring(organizationName))" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($global_acronym, '/Party/', local:format_keystring(positionName))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="project | relatedProject" mode="activity_registryObject">
    <xsl:param name="docid"/>
    <xsl:param name="originatingSource"/>
    
    <xsl:element name="registryObject">
      <xsl:attribute name="group">
        <xsl:value-of select="$global_group" />
      </xsl:attribute>
      
      <xsl:element name="key">
        <xsl:value-of select="concat($global_acronym, '/Activity/', local:format_keystring(@id))" />
      </xsl:element>
      
      <xsl:element name="originatingSource">
        <xsl:value-of select="$originatingSource"/>
      </xsl:element>
      
      <xsl:element name="activity">
        <xsl:attribute name="type">
          <xsl:text>project</xsl:text>
        </xsl:attribute>
        
        <xsl:if test="string-length(title) > 0">
          <xsl:apply-templates select="title" mode="activity_registryobject_name"/>
        </xsl:if>
        
        <xsl:if test="string-length(abstract) > 0">
          <xsl:apply-templates select="abstract" mode="activity_registryobject_description"/>
        </xsl:if>
        
        <xsl:apply-templates select="funding">
          <xsl:with-param name="relation" select="'isFundedBy'"/>
        </xsl:apply-templates>
        
        <xsl:for-each select="personnel/userId">
          <xsl:element name="relatedInfo">
            <xsl:attribute name="type">
              <xsl:text>party</xsl:text>
            </xsl:attribute>
            <xsl:element name="identifier">
              <xsl:attribute name="type">
                <xsl:text>uri</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="."/>
            </xsl:element>
            <xsl:element name="relation">
              <xsl:attribute name="type">
                <xsl:choose>
                  <xsl:when test="ancestor::personnel/role[string-length(text()) > 0]">
                    <xsl:value-of select="ancestor::personnel/role"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>hasAssociationWith</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:element>
            <xsl:element name="title">
              <xsl:value-of select="ancestor::personnel/organizationName"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
      
    </xsl:element> <!--registryObject-->
  </xsl:template> <!--name="project"-->
  
  <xsl:template match="title" mode="activity_registryobject_name">
    <xsl:element name="name">
      <xsl:element name="namePart">
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="title" mode="description">
    <xsl:element name="description">
      <xsl:attribute name="type" select="'brief'"/>
      <xsl:apply-templates select="text()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="abstract" mode="activity_registryobject_description">
    <xsl:element name="description">
        <xsl:attribute name="type">
          <xsl:text>full</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="local:format_keystring">
    <xsl:param name="str"/>
    <xsl:value-of select="replace($str, ' |,', '_')"/>
  </xsl:function>
  
  <xsl:template match="creator" mode="citationContributor">
    <xsl:element name="contributor">
      <xsl:choose>
        <xsl:when test="./individualName">
          <xsl:apply-templates select="./individualName" mode="partsOnly"/>
        </xsl:when>
        <xsl:when test="normalize-space(./organizationName)">
          <xsl:element name="namePart">
            <xsl:value-of select="./organizationName" />
          </xsl:element>
        </xsl:when>
        <xsl:when test="normalize-space(./positionName)">
          <xsl:element name="namePart">
            <xsl:value-of select="./positionName" />
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="namePart"></xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="individualNameParts">
    <xsl:if test="normalize-space(./salutation)">
      <xsl:element name="namePart">
        <xsl:attribute name="type">title</xsl:attribute>
        <xsl:value-of select="./salutation" />
      </xsl:element>
    </xsl:if>
    <xsl:if test="normalize-space(./givenName)">
      <xsl:element name="namePart">
        <xsl:attribute name="type">given</xsl:attribute>
        <xsl:value-of select="./givenName" />
      </xsl:element>
    </xsl:if>
    <xsl:if test="normalize-space(./surName)">
      <xsl:element name="namePart">
        <xsl:attribute name="type">family</xsl:attribute>
        <xsl:value-of select="./surName" />
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="userId">
    <xsl:element name="identifier">
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="string-length(@directory) > 0">
            <xsl:value-of select="@directory"/>
          </xsl:when>
          <xsl:when test="starts-with(@directory, 'http')">
            <xsl:text>uri</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>local</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="contains(., 'orcid.org/')">
          <xsl:value-of select="substring-after(., 'orcid.org/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="individualName">
    <xsl:element name="name">
      <xsl:attribute name="type">primary</xsl:attribute>
      <xsl:call-template name="individualNameParts"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="individualName" mode="partsOnly">
    <xsl:call-template name="individualNameParts"/>
  </xsl:template>
  
  <xsl:template match="individualName" mode="full">
    <xsl:if test="givenName">
      <xsl:value-of select="givenName" />
    </xsl:if>
    <xsl:value-of select="surName" />
  </xsl:template>
  
  <xsl:template match="individualName" mode="partyIdentifier">
    <xsl:value-of select="concat($global_acronym, '/', givenName, surName)" />
  </xsl:template>

  <xsl:template match="positionName">
    <xsl:element name="name">
      <xsl:element name="namePart">
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="organizationName">
    <xsl:element name="name">
      <xsl:element name="namePart">
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="phone">
    <xsl:element name="physical">
      <xsl:element name="addressPart">
        <xsl:attribute name="type">telephoneNumber</xsl:attribute>
        <xsl:value-of select="translate(translate(.,'+',''),' ','-')" />
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="electronicMailAddress">
    <xsl:element name="electronic">
      <xsl:attribute name="type">email</xsl:attribute>
      <xsl:element name="value">
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="onlineUrl">
    <xsl:element name="electronic">
      <xsl:attribute name="type">url</xsl:attribute>
      <xsl:element name="value">
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="address">
    <xsl:if test="deliveryPoint or city or administrativeArea or postalCode or country">
      <xsl:element name="physical">
        <xsl:attribute name="type">streetAddress</xsl:attribute>
        <xsl:apply-templates select="deliveryPoint" />
        <xsl:apply-templates select="city" />
        <xsl:apply-templates select="administrativeArea" />
        <xsl:apply-templates select="postalCode" />
        <xsl:apply-templates select="country" />
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!--xsl:template match="organizationName">
    <xsl:element name="addressPart">
      <xsl:attribute name="type">organizationName</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template-->

  <xsl:template match="deliveryPoint">
    <xsl:element name="addressPart">
      <xsl:attribute name="type">addressLine</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template match="city">
    <xsl:element name="addressPart">
      <xsl:attribute name="type">suburbOrPlaceOrLocality</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template match="administrativeArea">
    <xsl:element name="addressPart">
      <xsl:attribute name="type">stateOrTerritory</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template match="postalCode">
    <xsl:element name="addressPart">
      <xsl:attribute name="type">postCode</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template match="country">
    <xsl:element name="addressPart">
      <xsl:attribute name="type">country</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template name="datetime">
    <xsl:param name="dateFormat">W3CDTF</xsl:param>
    <xsl:param name="type"/>
    <xsl:variable name="time">
      <xsl:if test="time">
        <xsl:value-of select="concat('T',time)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:element name="date">
      <xsl:attribute name="dateFormat"><xsl:value-of select="$dateFormat"/></xsl:attribute>
      <xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
      <xsl:value-of select="concat(calendarDate,$time)"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="singleDateTime">
    <xsl:call-template name="datetime">
      <xsl:with-param name="dateFormat">UTC</xsl:with-param>
      <xsl:with-param name="type">dateFrom</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="datetime">
      <xsl:with-param name="dateFormat">UTC</xsl:with-param>
      <xsl:with-param name="type">dateTo</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="rangeOfDates">
    <xsl:apply-templates select="beginDate"/>
    <xsl:apply-templates select="endDate"/>
  </xsl:template>
  
  <xsl:template match="beginDate">
    <xsl:call-template name="datetime">
      <xsl:with-param name="dateFormat">UTC</xsl:with-param>
      <xsl:with-param name="type">dateFrom</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="endDate">
    <xsl:call-template name="datetime">
      <xsl:with-param name="dateFormat">UTC</xsl:with-param>
      <xsl:with-param name="type">dateTo</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="temporalCoverage">
    <xsl:element name="temporal">
      <xsl:apply-templates select="singleDateTime"/>
      <xsl:apply-templates select="rangeOfDates"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="geographicCoverage">
    <xsl:apply-templates select="geographicDescription"/>
    <xsl:apply-templates select="boundingCoordinates"/>
  </xsl:template>
  
  <xsl:template match="boundingCoordinates">
    <xsl:variable name="isPointData" select="normalize-space(eastBoundingCoordinate)=normalize-space(westBoundingCoordinate) 
                                             and normalize-space(northBoundingCoordinate)=normalize-space(southBoundingCoordinate)"/>
      <!--xsl:call-template name="isPointData"/-->
		
    <xsl:element name="spatial">
      <xsl:choose>
        <xsl:when test="$isPointData">
          <!-- Point data, just give northing and southing in KML Coordinates -->
          <xsl:attribute name="type">kmlPolyCoords</xsl:attribute>
          <xsl:value-of select="concat(eastBoundingCoordinate, ',', northBoundingCoordinate)" />
        </xsl:when>
        <xsl:otherwise>
          <!-- We have a box, give four corners as coordinates -->
          <xsl:attribute name="type">iso19139dcmiBox</xsl:attribute>
          <xsl:value-of select="concat('northlimit=',northBoundingCoordinate,'; southlimit=',southBoundingCoordinate,'; westlimit=',westBoundingCoordinate,'; eastLimit=',eastBoundingCoordinate)" />
          <!--xsl:text>; projection=WGS84</xsl:text-->
        </xsl:otherwise>
        </xsl:choose>
    </xsl:element>    
  </xsl:template>

  <xsl:template match="geographicDescription">
    <xsl:element name="spatial">
      <xsl:attribute name="type">text</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template match="keywordSet">
    <xsl:variable name="typeAnzsrc" select="'anzsrc-for'"/>
    <xsl:variable name="typeGcmd" select="'gcmd'"/>
    <xsl:apply-templates select="keyword">
      <xsl:with-param name="keywordThesaurus">
        <xsl:variable name="subjectType" select="normalize-space(lower-case(keywordThesaurus))" />
        <xsl:choose>
          <xsl:when test="contains($subjectType, $typeAnzsrc)">
            <xsl:value-of select="$typeAnzsrc"/>
          </xsl:when>
         <xsl:when test="contains($subjectType, $typeGcmd)">
            <xsl:value-of select="$typeGcmd" />
          </xsl:when>
<!--
          <xsl:when test="normalize-space(./keywordThesaurus)">
            <xsl:value-of select="normalize-space(./keywordThesaurus)" />
          </xsl:when>
-->
          <xsl:otherwise>
            <xsl:text>local</xsl:text>
          </xsl:otherwise>
        </xsl:choose> 
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="keyword">
    <xsl:param name="keywordThesaurus"/>
    <xsl:element name="subject">
      <xsl:attribute name="type">
        <xsl:value-of select="$keywordThesaurus" />
      </xsl:attribute>
      <xsl:if test="starts-with(., 'http')">
          <xsl:attribute name="termIdentifier">
            <xsl:value-of select="." />
          </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="starts-with(., 'http')">
          <xsl:variable name="numChars" select="count(tokenize(., '/'))" as="xs:integer"/>
          <xsl:value-of select="tokenize(., '/')[$numChars]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:element>
  </xsl:template>

  <xsl:template match="para">
    <xsl:element name="description">
      <xsl:attribute name="type">brief</xsl:attribute>
      <xsl:apply-templates select="text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="fillOutAddress">
    <xsl:if test="phone or address or electronicMailAddress or onlineUrl">
      <xsl:element name="location">
        <xsl:element name="address">
          <xsl:apply-templates select="address"/>
          <xsl:apply-templates select="phone" />
          <xsl:apply-templates select="electronicMailAddress" />
          <xsl:apply-templates select="onlineUrl" />
        </xsl:element>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="relationAssociatedParty">
    <xsl:element name="relation">
      <xsl:attribute name="type">hasAssociationWith</xsl:attribute>
      <xsl:element name="description"><xsl:value-of select="role" /></xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="creator" mode="relationCollection">
    <xsl:element name="relation"><xsl:attribute name="type">isOwnedBy</xsl:attribute></xsl:element>
  </xsl:template>
  <xsl:template match="creator" mode="relationParty">
    <xsl:element name="relation"><xsl:attribute name="type">isOwnerOf</xsl:attribute></xsl:element>
  </xsl:template>
  <!-- Not doing contact at the moment because it is set as ALA, not contributor to ALA -->
  <xsl:template match="contact" mode="relationCollection">
    <xsl:element name="relation"><xsl:attribute name="type">isContactFor</xsl:attribute></xsl:element>
  </xsl:template>
  <xsl:template match="contact" mode="relationParty">
    <xsl:element name="relation"><xsl:attribute name="type">isManagerOf</xsl:attribute></xsl:element>
  </xsl:template>
  <xsl:template match="associatedParty" mode="relationCollection">
    <xsl:call-template name="relationAssociatedParty"/>
  </xsl:template>
  <xsl:template match="associatedParty" mode="relationParty">
    <xsl:call-template name="relationAssociatedParty"/>
  </xsl:template>
  <xsl:template match="publisher|metadataProvider|associatedParty[role='Publisher']|associatedParty[role='Metadata Provider']" mode="relationCollection">
    <xsl:element name="relation"><xsl:attribute name="type">hasCollector</xsl:attribute></xsl:element>
  </xsl:template>
  <xsl:template match="publisher|metadataProvider|associatedParty[role='Publisher']|associatedParty[role='Metadata Provider']" mode="relationParty">
    <xsl:element name="relation"><xsl:attribute name="type">isCollectorOf</xsl:attribute></xsl:element>
  </xsl:template>
  <xsl:template match="associatedParty[role='Principal Investigator']" mode="relationCollection">
    <xsl:element name="relation"><xsl:attribute name="type">hasPrincipalInvestigator</xsl:attribute></xsl:element>
  </xsl:template>
  <xsl:template match="associatedParty[role='Principal Investigator']" mode="relationParty">
    <xsl:element name="relation"><xsl:attribute name="type">isPrincipalInvestigatorOf</xsl:attribute></xsl:element>
  </xsl:template>
  
  <xsl:template match="node()" />
  
</xsl:stylesheet>
