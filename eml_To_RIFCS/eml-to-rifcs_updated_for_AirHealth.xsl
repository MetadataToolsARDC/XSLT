<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exslt="http://exslt.org/common">

  <!-- the registry object group -->
  <xsl:param name="groupName">AirHealth</xsl:param>
  <xsl:param name="emlNamespace">eml://ecoinformatics.org/eml-2.1.1</xsl:param>
  <xsl:param name="repositoryIdentifier"/>
  <xsl:param name="serverUrl"/>
  <xsl:param name="contextUrl"/>
  <xsl:param name="servletUrl" select="'http://cardat.github.io/data_inventory'"/>
  <xsl:param name="lastModified" />
  <xsl:param name="dateCreated" />
  <xsl:param name="predefinedLicences"/>
  <xsl:param name="defaultLicence"/>
  
  <xsl:variable name="rifcsVersion" select="1.5"/>
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

  <xsl:strip-space elements="*" />
  
  <!--key for selecting a nodeset of identical parties based on the details-->
  <xsl:key name="keyPartyUnique" match="creator|associatedParty|metadataProvider|contact|publisher" 
           use="concat(individualName, organizationName, positionName, address, phone, electronicMailAddress)"/>
  
  <!--dynamically match the root eml element based on the eml namespace that contains the version-->
  <xsl:template match="/*[local-name()='eml' and namespace-uri()=$emlNamespace]">
    <!--<xsl:variable name="packageId" select="@packageId"/> -->
    <!--xsl:variable name="docid" select="concat(substring-before(string(@packageId),'.'),'.',substring-before(substring-after(string(@packageId),'.'),'.'))" /-->
    <xsl:variable name="docid" select="concat(substring-before(string(@packageId),'.'),'.',substring-before(substring-after(string(@packageId),'.'),'.'))" />
    <xsl:variable name="revid" select="substring-after(string(@packageId), concat($docid, '.'))" />
    
    <xsl:element name="registryObjects" xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
      <xsl:apply-templates select="dataset">
        <xsl:with-param name="docid" select="$docid" />
        <xsl:with-param name="revid" select="$revid" />
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="dataset">
    <xsl:param name="docid"/>
    <xsl:param name="revid"/>
    
    <xsl:variable name="originatingSource">
      <xsl:choose>
        <xsl:when test="not($serverUrl)">
          <xsl:value-of select="creator[1]/organizationName" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$serverUrl" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- collection -->
    <xsl:call-template name="collection">
      <xsl:with-param name="originatingSource" select="$originatingSource" />
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="revid" select="$revid" />
    </xsl:call-template>
    
    <!-- party -->
    <xsl:apply-templates select="(creator|associatedParty|metadataProvider|contact|publisher)[generate-id()=generate-id(key('keyPartyUnique', concat(individualName, organizationName, positionName, address, phone, electronicMailAddress))[1])]">
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="originatingSource" select="$originatingSource" />
    </xsl:apply-templates>
  </xsl:template>
  
  
  <!-- Create collection registryObject -->
  <xsl:template name="collection">
    <xsl:param name="docid"/>
    <xsl:param name="revid"/>
    <xsl:param name="originatingSource"/>
    
    <!-- This is the one change from TERN's apart from some condition checking -->
    <!--xsl:variable name="datasetUrl" select="concat($servletUrl,'/', $docid ,'/html')"/-->
    <xsl:variable name="datasetUrl" select="concat($servletUrl,'/', $docid)"/>
    
      <xsl:variable name="doi" select="alternateIdentifier[@system='doi']"/>
    
    <xsl:element name="registryObject">
      <xsl:attribute name="group"><xsl:value-of select="$groupName" /></xsl:attribute>
      
      <xsl:element name="key"><xsl:value-of select="$docid" /></xsl:element>
      
      <xsl:element name="originatingSource">
        <xsl:value-of select="$originatingSource" />
      </xsl:element>
      
      <xsl:element name="collection">
        <xsl:attribute name="type">dataset</xsl:attribute>
        <xsl:attribute name="dateAccessioned"><xsl:value-of select="$dateCreated" /></xsl:attribute>
        <xsl:attribute name="dateModified"><xsl:value-of select="$lastModified" /></xsl:attribute>
        
        <!--xsl:variable name="doi" select="alternateIdentifier[@system='doi']"/-->
        
        <xsl:element name="identifier">
          <xsl:attribute name="type">local</xsl:attribute>
          <xsl:value-of select="$docid" />
        </xsl:element>
        
        <xsl:if test="$doi!=''">
          <xsl:element name='identifier'>
            <xsl:attribute name="type">doi</xsl:attribute>
            <xsl:value-of select="$doi" />
          </xsl:element>
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
            <xsl:element name="electronic">
              <xsl:attribute name="type">url</xsl:attribute>
              <xsl:element name="value">
                <xsl:choose>
                  <xsl:when test="normalize-space($doi)">
                    <xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="$doi"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$datasetUrl"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!--generate relationships to parties, implied by name of element -->
        <xsl:apply-templates select="(creator|associatedParty|metadataProvider|contact|publisher)[generate-id()=generate-id(key('keyPartyUnique', concat(individualName, organizationName, positionName, address, phone, electronicMailAddress))[1])]"
                             mode="relatedObject"/>

        <xsl:apply-templates select="keywordSet" />
        <xsl:apply-templates select="abstract" />

        <xsl:if test="coverage/geographicCoverage or coverage/temporalCoverage">
          <xsl:element name="coverage">
            <xsl:apply-templates select="coverage/temporalCoverage"/>
            <xsl:apply-templates select="coverage/geographicCoverage"/>
          </xsl:element>
        </xsl:if>
        
        <!-- TODO:relatedInfo -->

        <!-- intellectualRights -->
        <xsl:element name="rights">
          <xsl:for-each select="intellectualRights">
            <!--parse the first line of licence paragraph-->
            <xsl:variable name="firstLine" select="normalize-space(substring-before(concat(para, '&#x0A;'), '&#x0A;'))"/>
            <xsl:variable name="licenceCode">
              <xsl:choose>
                <xsl:when test="$firstLine!=''">
                  <xsl:choose>
                    <xsl:when test="string-length($firstLine) &lt; 25">
                      <xsl:value-of select="translate($firstLine, $uppercase, $smallcase)" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>Other</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$defaultLicence" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="string-length($predefinedLicences) > 0">
                <xsl:variable name="licences" select="exslt:node-set($predefinedLicences)" as="node()*"/>
                <xsl:variable name="licence1" select="$licences//*[local-name()=$licenceCode]" as="node()*"/>
              
                <xsl:message> 
                  <xsl:value-of select="concat('Count: ', count($licence1))"/>           
                </xsl:message>
                
                <xsl:variable name="licence2">
                  <xsl:if test="not($licence1)">
                    <xsl:variable name="licenceText" select="para"/>
                    <xsl:for-each select="$licences/*">
                      <xsl:variable name="uriPart" select="substring-after(@uri, '://')"/>
                      <xsl:if test="contains($licenceText, $uriPart)">
                        <xsl:copy-of select="." />
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:if>
                </xsl:variable>
                <xsl:variable name="licence" select="$licence1 | exslt:node-set($licence2)/*"/>
                <xsl:variable name="type">
                  <xsl:choose>
                    <xsl:when test="$licence">
                      <!--xsl:value-of select="$licenceCode"/-->
                      <xsl:value-of select="local-name($licence)"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>Other</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
      
                <xsl:if test="normalize-space($licence/@name)">
                  <xsl:element name="rightsStatement">
                    <xsl:value-of select="$licence/@name" />
                  </xsl:element>
                </xsl:if>
                <xsl:element name="licence">
                  <xsl:if test="normalize-space($type)">
                    <xsl:attribute name="type"><xsl:value-of select="$type" /></xsl:attribute>
                  </xsl:if>
                  <xsl:if test="normalize-space($licence/@uri)">
                    <xsl:attribute name="rightsUri"><xsl:value-of select="$licence/@uri" /></xsl:attribute>
                  </xsl:if>
                  <xsl:choose>
                    <xsl:when test="$licence1">
                      <xsl:value-of select="$licence"/>
                      <xsl:value-of select="substring-after(para, $firstLine)"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="para"/>
                      <xsl:if test="para=''">
                        <xsl:text>Permission required from data owner</xsl:text>
                      </xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
              </xsl:when>
              <xsl:when test="string-length(para) > 0">
                <xsl:element name="rightsStatement">
                  <xsl:value-of select="para" />
                </xsl:element>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:element> <!--rights-->
        
        <!-- citationInfo -->
        <xsl:element name="citationInfo">
          <xsl:element name="citationMetadata">
            <xsl:element name="identifier">
              <xsl:choose>
                <xsl:when test="normalize-space($doi)">
                  <xsl:attribute name="type">doi</xsl:attribute>
                  <xsl:value-of select="$doi"/>
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
            
            <xsl:element name="publisher">
              <xsl:choose><xsl:when test="publisher/organizationName">
                <xsl:value-of select="publisher/organizationName"/>
              </xsl:when><xsl:otherwise>
                <xsl:value-of select="$groupName"/>
              </xsl:otherwise></xsl:choose>
            </xsl:element>
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
            <xsl:element name="url">
              <xsl:choose>
                <xsl:when test="normalize-space($doi)">
                  <xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="$doi"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$datasetUrl"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
            <xsl:element name="context"></xsl:element>
          </xsl:element>
        </xsl:element> <!-- citationInfo -->
      </xsl:element> <!--collection-->
    </xsl:element> <!--registryObject-->
  </xsl:template>  <!--name="collection"-->

  <xsl:template name="citationMetadataVersion">
    <xsl:param name="revid"/>
    <xsl:element name="version">
      <xsl:value-of select="$revid"/>
    </xsl:element>
  </xsl:template>

  <!--this will match all possible party nodes except the ones that contain references, overriden by template *[references] defined later-->
  <xsl:template match="creator|associatedParty|metadataProvider|contact|publisher">
    <xsl:param name="docid"/>
    <xsl:param name="originatingSource"/>
    <xsl:call-template name="party">
      <xsl:with-param name="docid" select="$docid" />
      <xsl:with-param name="originatingSource" select="$originatingSource" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="creator|associatedParty|metadataProvider|contact|publisher" mode="relatedObject">
    <xsl:element name="relatedObject">
      <xsl:element name="key">
        <xsl:call-template name="partyKey"/>
      </xsl:element>

      <xsl:apply-templates select="key('keyPartyUnique', concat(individualName, organizationName, positionName, address, phone, electronicMailAddress))" mode="relationCollection" />
      <xsl:apply-templates select="../*[references = current()/@id]" mode="relationCollection"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[references]"/>
  <xsl:template match="*[references]" mode="relatedObject"/>
  
  <xsl:template name="party">
    <xsl:param name="docid"/>
    <xsl:param name="originatingSource"/>
    
    <xsl:element name="registryObject" xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
      <xsl:attribute name="group"><xsl:value-of select="$groupName" /></xsl:attribute>
      
      <xsl:element name="key">
        <xsl:call-template name="partyKey"/>
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

        <xsl:apply-templates select="userId[@directory='ORCID']"/>
        <xsl:apply-templates select="individualName"/>
        <xsl:apply-templates select="positionName"/>
        <xsl:apply-templates select="organizationName"/>

        <xsl:call-template name="fillOutAddress"/>

        <xsl:element name="relatedObject">
          <xsl:element name="key">
            <xsl:value-of select="$docid" />
          </xsl:element>

          <xsl:apply-templates select="key('keyPartyUnique', concat(individualName, organizationName, positionName, address, phone, electronicMailAddress))" mode="relationParty" />
          <xsl:apply-templates select="../*[references = current()/@id]" mode="relationParty"/>
        </xsl:element>
      </xsl:element>
      
    </xsl:element> <!--registryObject-->
  </xsl:template> <!--name="party"-->

  <xsl:template name="partyKey">
    <xsl:choose>
      <xsl:when test="individualName">
        <xsl:value-of select="concat('urn:person:', $repositoryIdentifier, ':', individualName/givenName, individualName/surName)" />
      </xsl:when>
      <xsl:when test="organizationName">
        <xsl:value-of select="concat('urn:org:', $repositoryIdentifier, ':', organizationName)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('urn:role:', $repositoryIdentifier, ':', positionName)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
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
      <xsl:attribute name="type">orcid</xsl:attribute>
      <xsl:value-of select="."/>
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
  
  <xsl:template match="individualName" mode="partyKey">
    <xsl:value-of select="concat('urn:person:', $repositoryIdentifier, ':', givenName, surName)" />
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
  
  <xsl:template match="geographicCoverage/boundingCoordinates">
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

  <xsl:template match="geographicCoverage/geographicDescription">
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
        <xsl:variable name="subjectType" select="translate(normalize-space(./keywordThesaurus), $uppercase, $smallcase)" />
        <xsl:choose>
          <xsl:when test="contains($subjectType, $typeAnzsrc)">
            <xsl:value-of select="$typeAnzsrc" />
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
    <xsl:param name="keywordThesaurus">local</xsl:param>
    <xsl:element name="subject">
      <xsl:attribute name="type">
        <xsl:value-of select="$keywordThesaurus" />
      </xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>

  <xsl:template match="abstract">
    <xsl:element name="description">
      <xsl:attribute name="type">brief</xsl:attribute>
      <xsl:value-of select="." />
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
  <xsl:template match="contact" mode="relationCollection">
    <xsl:element name="relation"><xsl:attribute name="type">isManagedBy</xsl:attribute></xsl:element>
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
