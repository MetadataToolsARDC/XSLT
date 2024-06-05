<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:bibo="http://purl.org/ontology/bibo/" 
    xmlns:datacite="http://purl.org/spar/datacite/" 
    xmlns:fabio="http://purl.org/spar/fabio/" 
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:literal="http://www.essepuntato.it/2010/06/literalreification/" 
    xmlns:obo="http://purl.obolibrary.org/obo/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#" 
    xmlns:vivo="http://vivoweb.org/ontology/core#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:figFunc="http://figfunc.nowhere.yet"
    xmlns:local="http://local.here.org"
    xmlns:exslt="http://exslt.org/common"
    xmlns:rifcis="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="oai dc bibo datacite fabio foaf literal obo rdf rdfs vcard vivo xs fn local exslt xsi figFunc rifcis">
   
    <xsl:variable name="categoryCodeList" select="document('https://raw.githubusercontent.com/MetadataToolsARDC/XSLT/master/Figshare_RDF_To_RIFCS/MASTER/figshare_categories.xml')"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_group" select="''"/>
    
    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes" encoding="UTF-8"/>
    
       
   <!--xsl:output method="xml" version="1.0" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/-->
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <!--xsl:apply-templates select="copy-of(oai:OAI-PMH/*/oai:record)"/-->
            <xsl:copy-of select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    

    <xsl:template match="oai:OAI-PMH/*/oai:record">
    <!-- Updated 16 August 2021 to reflect list retrieved from https://api.figshare.com/v2/oai?verb=ListSets
        
    <ListSets>
        <set>
          <setSpec>item_type_1</setSpec>
          <setName>Article type: figure</setName>
        </set>
        <set>
          <setSpec>item_type_2</setSpec>
          <setName>Article type: media</setName>
        </set>
        <set>
          <setSpec>item_type_3</setSpec>
          <setName>Article type: dataset</setName>
        </set>
        <set>
          <setSpec>item_type_5</setSpec>
          <setName>Article type: poster</setName>
        </set>
        <set>
          <setSpec>item_type_6</setSpec>
          <setName>Article type: journal contribution</setName>
        </set>
        <set>
          <setSpec>item_type_7</setSpec>
          <setName>Article type: presentation</setName>
        </set>
        <set>
          <setSpec>item_type_8</setSpec>
          <setName>Article type: thesis</setName>
        </set>
        <set>
          <setSpec>item_type_9</setSpec>
          <setName>Article type: software</setName>
        </set>
        <set>
          <setSpec>item_type_11</setSpec>
          <setName>Article type: online resource</setName>
        </set>
        <set>
          <setSpec>item_type_12</setSpec>
          <setName>Article type: preprint</setName>
        </set>
        <set>
          <setSpec>item_type_13</setSpec>
          <setName>Article type: book</setName>
        </set>
        <set>
          <setSpec>item_type_14</setSpec>
          <setName>Article type: conference contribution</setName>
        </set>
        <set>
          <setSpec>item_type_15</setSpec>
          <setName>Article type: chapter</setName>
        </set>
        <set>
          <setSpec>item_type_16</setSpec>
          <setName>Article type: peer review</setName>
        </set>
        <set>
          <setSpec>item_type_17</setSpec>
          <setName>Article type: educational resource</setName>
        </set>
        <set>
          <setSpec>item_type_18</setSpec>
          <setName>Article type: report</setName>
        </set>
        <set>
          <setSpec>item_type_19</setSpec>
          <setName>Article type: standard</setName>
        </set>
        <set>
          <setSpec>item_type_20</setSpec>
          <setName>Article type: composition</setName>
        </set>
        <set>
          <setSpec>item_type_21</setSpec>
          <setName>Article type: funding</setName>
        </set>
        <set>
          <setSpec>item_type_22</setSpec>
          <setName>Article type: physical object</setName>
        </set>
        <set>
          <setSpec>item_type_23</setSpec>
          <setName>Article type: data management plan</setName>
        </set>
        <set>
          <setSpec>item_type_24</setSpec>
          <setName>Article type: workflow</setName>
        </set>
        <set>
          <setSpec>item_type_25</setSpec>
          <setName>Article type: monograph</setName>
        </set>
        <set>
          <setSpec>item_type_26</setSpec>
          <setName>Article type: performance</setName>
        </set>
        <set>
          <setSpec>item_type_27</setSpec>
          <setName>Article type: event</setName>
        </set>
        <set>
          <setSpec>item_type_28</setSpec>
          <setName>Article type: service</setName>
        </set>
        <set>
          <setSpec>item_type_29</setSpec>
          <setName>Article type: model</setName>
        </set>
        <set>
          <setSpec>item_type_30</setSpec>
          <setName>Article type: registration</setName>
        </set>
    <ListSets>
    -->
    <!-- include figure, media, dataset, fileset and code for now -->
    
      <xsl:if test="
          (count(oai:header/oai:setSpec[text() = 'item_type_1']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_2']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_3']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_4']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_9']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_11']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_22']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_24']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_28']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_29']) > 0)">
                    
          <xsl:variable name="type_and_subtype_sequence" as="xs:string*">
                <xsl:choose>
                    <!-- figure -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_1']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- media -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_2']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- dataset -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_3']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>dataset</xsl:text>
                    </xsl:when>
                    <!-- fileset -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_4']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- code -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_9']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <!-- metadata -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_11']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- physical object -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_22']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- workflow -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_24']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <!-- service -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_28']) > 0">
                        <xsl:text>service</xsl:text>
                        <xsl:text>report</xsl:text>
                    </xsl:when>
                    <!-- model -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_29']) > 0">
                        <xsl:text>collection</xsl:text>
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
          
          <xsl:message select="concat('class determined: ', $type_and_subtype_sequence[1])"/>
          <xsl:message select="concat('mapped type determined: ', $type_and_subtype_sequence[2])"/>
          
          <xsl:if test="count($type_and_subtype_sequence) = 2"> <!-- if it isn't, we've forgot to add it to the bit above -->
            <xsl:variable name="oaiFigshareIdentifier" select="oai:header/oai:identifier"/>
            <xsl:if test="string-length($oaiFigshareIdentifier)">
              <xsl:apply-templates select="oai:metadata/rdf:RDF" mode="collection">
                  <xsl:with-param name="oaiFigshareIdentifier" select="$oaiFigshareIdentifier"/>
                  <xsl:with-param name="type" select="$type_and_subtype_sequence[1]" as="xs:string"/>
                  <xsl:with-param name="subtype" select="$type_and_subtype_sequence[2]" as="xs:string"/>
              </xsl:apply-templates>
              <!-- xsl:apply-templates select="oai:metadata/rdf:RDF/dc:funding" mode="funding_party"/ -->
              <!-- xsl:apply-templates select="oai:metadata/rdf:RDF" mode="party"/-->
            </xsl:if>
          </xsl:if>
    </xsl:if>
</xsl:template>
    
     <xsl:function name="local:getTypeAndSubType" as="xs:string*">
         <xsl:param name="header_node" as="node()"/>
        
            <xsl:choose>
                <!-- figure -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_1']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>collection</xsl:text>
                </xsl:when>
                <!-- media -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_2']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>collection</xsl:text>
                </xsl:when>
                <!-- dataset -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_3']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>dataset</xsl:text>
                </xsl:when>
                <!-- fileset -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_4']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>collection</xsl:text>
                </xsl:when>
                <!-- code -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_9']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>software</xsl:text>
                </xsl:when>
                <!-- metadata -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_11']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>collection</xsl:text>
                </xsl:when>
                <!-- physical object -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_22']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>collection</xsl:text>
                </xsl:when>
                <!-- workflow -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_24']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>software</xsl:text>
                </xsl:when>
                <!-- service -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_28']) > 0">
                    <xsl:text>service</xsl:text>
                    <xsl:text>report</xsl:text>
                </xsl:when>
                <!-- model -->
                <xsl:when test="count($header_node/oai:setSpec[text() = 'item_type_29']) > 0">
                    <xsl:text>collection</xsl:text>
                    <xsl:text>software</xsl:text>
                </xsl:when>
            </xsl:choose>
        
    </xsl:function>
    
    <xsl:template match="rdf:RDF" mode="collection_key">
        <xsl:param name="oaiFigshareIdentifier" as="xs:string"/>
        <key>   
            <xsl:value-of select="substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($oaiFigshareIdentifier)) return string($n), ''), 0, 50)"/>
        </key>
    </xsl:template>
    
<xsl:template match="rdf:RDF" mode="collection">
        <xsl:param name="oaiFigshareIdentifier" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="subtype" as="xs:string"/>
        
        
        <xsl:message select="concat('type: ', $type)"/>
        <xsl:message select="concat('subtype: ', $subtype)"/>
    
        <xsl:variable name="doiFull" select="*/bibo:doi"/>
        <xsl:variable name="doiLastPart" select="tokenize($doiFull, '/')[count(tokenize($doiFull, '/'))]"/>
    
        
    <xsl:message select="concat('doiLastPart: ', $doiLastPart)"/>
    <xsl:message select="concat('key to use: ', substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($oaiFigshareIdentifier)) return string($n), ''), 0, 50))"/>
    

    <registryObject>
        <xsl:attribute name="group" select="$global_group"/>
        
        <xsl:apply-templates select="." mode="collection_key">
            <xsl:with-param name="oaiFigshareIdentifier" select="$oaiFigshareIdentifier"/>
        </xsl:apply-templates>
        
        <originatingSource>
            <xsl:value-of select="$global_originatingSource"/>
        </originatingSource>
        <xsl:element name="{$type}">
            
            <xsl:attribute name="type" select="$subtype"/>
         
            <xsl:apply-templates select="*/vivo:dateModified/@rdf:resource[string-length(.) > 0]" mode="collection_date_modified"/>
            
            <xsl:apply-templates select="*/bibo:doi[string-length(.) > 0]" mode="collection_identifier"/>
            
            <xsl:apply-templates select="*/bibo:handle[string-length(.) > 0]" mode="collection_identifier"/>
            
            <xsl:choose>
                <xsl:when test="count(*/bibo:doi[string-length(.) > 0]) > 0">
                    <xsl:apply-templates select="*/bibo:doi[string-length(.) > 0][1]" mode="collection_location"/>
                </xsl:when>
                <xsl:when test="count(*/bibo:handle[string-length(.) > 0]) > 0">
                    <xsl:apply-templates select="*/bibo:handle[string-length(.) > 0][1]" mode="collection_location"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*[1]/@rdf:about[(string-length(.) > 0)]" mode="collection_location"/>
                </xsl:otherwise>
            </xsl:choose>
            
            
            <xsl:apply-templates select="*/rdfs:label[string-length(.) > 0]" mode="collection_name"/>
            
            <xsl:apply-templates select="vivo:Authorship/vivo:relates/vcard:Individual/obo:ARG_2000029/foaf:Person[string-length(vivo:orcidId/@rdf:resource) > 0]" mode="collection_relatedInfo_orcid"/>
            
            <xsl:apply-templates select="vivo:Authorship/vivo:relates/vcard:Individual[count(obo:ARG_2000029/foaf:Person/vivo:orcidId/@rdf:resource) = 0]/vcard:hasName" mode="collection_relatedInfo_noOrcid"/>
            
            <!--xsl:apply-templates select="vcard:Name" mode="collection_relatedObject"/-->
           
            <xsl:apply-templates select="*/bibo:freetextKeyword[string-length(.) > 0]" mode="collection_subject"/>
            
            <xsl:apply-templates select="*/dc:rights[string-length(.) > 0]" mode="collection_rights_access"/>
            
            <xsl:apply-templates select="ancestor::oai:record/oai:header/oai:setSpec[contains(., 'category_')]" mode="collection_subject"/>
           
            <xsl:apply-templates select="*/bibo:abstract[string-length(.) > 0]" mode="collection_description_full"/>
           
            <xsl:apply-templates select="rifcis:registryObjects/rifcis:registryObject/rifcis:relatedInfo" mode="collection_relatedInfo"/>
            
            <xsl:apply-templates select="*/vivo:datePublished/@rdf:resource[string-length(.) > 0]" mode="collection_dates_issued"/>  
         
            <xsl:apply-templates select="*/vivo:dateCreated/@rdf:resource[string-length(.) > 0]" mode="collection_dates_created"/>  
            
            <!-- RDA Harvest import reports error if you have fullCitation and also citationMetadata, so 
                if there is a fullCitation, use just that - otherwise, use citationMetadata -->
            <xsl:choose>
                <xsl:when test="count(rifcis:registryObjects/rifcis:registryObject/rifcis:citationInfo/rifcis:fullCitation[string-length(text()) > 0]) > 0">
                    <xsl:apply-templates select="rifcis:registryObjects/rifcis:registryObject/rifcis:citationInfo/rifcis:fullCitation" mode="collection_citationInfo_fullCitation"/>
                </xsl:when>
                <!--xsl:when test="count(rifcis:registryObjects/rifcis:registryObject/rifcis:citationInfo/rifcis:citationMetadata) > 0">
                    <xsl:apply-templates select="rifcis:registryObjects/rifcis:registryObject/rifcis:citationInfo/rifcis:citationMetadata" mode="collection_citationInfo_citationMetadata"/>
                </xsl:when-->
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="collection_citationInfo_citationMetadata"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </registryObject>
    
    </xsl:template>
   
    
    <xsl:template match="@rdf:resource" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="substring-after(., 'http://openvivo.org/a/date')"/>
    </xsl:template>
       
    <xsl:template match="bibo:doi" mode="collection_identifier">
        <identifier type="doi">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('https://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="bibo:handle" mode="collection_identifier">
        <identifier type="handle">
            <xsl:value-of select="."/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="@rdf:about" mode="collection_identifier_URI">
        <identifier type="URI">
            <xsl:value-of select="."/>
        </identifier>    
    </xsl:template>
    
     <xsl:template match="bibo:doi" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
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
    
    <xsl:template match="bibo:handle" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , 'http')">
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
    
    <xsl:template match="rdfs:label" mode="collection_name">
        <name type="primary">
           <xsl:variable name="name" select="figFunc:characterReplace(.)"/>
            <namePart>
                <xsl:value-of select='$name'/>
            </namePart>
        </name>
    </xsl:template>
    
    
    <xsl:template match="@rdf:about" mode="collection_location">
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
    
    <xsl:template match="vcard:hasName" mode="collection_relatedInfo_noOrcid">
        
        <!-- value of @rdf:resource will only resolve if it contains a name with a number, 
            so if it's only a number just make a unique identifier for
            this client that obviously does not resolve, to avoid confusion -->
        
        <xsl:message select="concat('@rdf:resource [', @rdf:resource, ']')"/>
        
           
       <!-- extract name part from url - may be just an underscore, so we will test this later with length-->
      <xsl:variable name="nameFromURL">
          <xsl:analyze-string select="substring-after(@rdf:resource, 'authors/')" regex="^[a-zA-ZÀ-ÿ-]*[_+][a-zA-ZÀ-ÿ-]*">
              <xsl:matching-substring>
                  <xsl:value-of select="regex-group(0)"/>
              </xsl:matching-substring>
          </xsl:analyze-string>
      </xsl:variable>
        
        <xsl:message select="concat('nameFromURL ', $nameFromURL)"/>
        
           <xsl:variable name="personID">
                <xsl:analyze-string select="@rdf:resource" regex="[\d]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            
                <relatedInfo type='party'>
                    <xsl:choose>
                        <xsl:when test="string-length($nameFromURL) > 1">
                            <identifier type="url">
                                <xsl:value-of select="substring-before(@rdf:resource, '-name')"/>
                            </identifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <identifier type="local">
                                <xsl:value-of select="$personID"/>
                            </identifier>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="ancestor::rdf:RDF/vcard:Name[contains(@rdf:about, $personID)]">
                        <title>
                            <xsl:value-of select="normalize-space(concat(vcard:givenName, ' ', vcard:familyName))"/>
                        </title>
                    </xsl:for-each>
                    <relation type="hasCollector"/>
                </relatedInfo>
    </xsl:template>
    
    <xsl:template match="foaf:Person" mode="collection_relatedInfo_orcid">
        <relatedInfo type='party'>
             <identifier type="{local:getIdentifierType(vivo:orcidId/@rdf:resource)}">
                <xsl:value-of select="vivo:orcidId/@rdf:resource"/>
            </identifier>
             <xsl:if test="string-length(rdfs:label) > 0">   
            <title>
                <xsl:value-of select="rdfs:label"/>
            </title>
            </xsl:if>
            <relation type="hasCollector"/>
        </relatedInfo>
          
        
    </xsl:template>
    
    <xsl:template match="vcard:hasName" mode="citationMetadata_contributor">
        
        <!-- value of @rdf:resource will only resolve if it contains a name with a number, 
            so if it's only a number just make a unique identifier for
            this client that obviously does not resolve, to avoid confusion -->
        
        <xsl:message select="concat('@rdf:resource [', @rdf:resource, ']')"/>
        
        <xsl:variable name="nameFromURL">
            <xsl:analyze-string select="substring-after(@rdf:resource, 'authors/')" regex="^[a-zA-ZÀ-ÿ-]*[_+][a-zA-ZÀ-ÿ-]*">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(0)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        
        <xsl:message select="concat('nameFromURL ', $nameFromURL)"/>
        
        <xsl:variable name="personID">
            <xsl:analyze-string select="@rdf:resource" regex="[\d]+">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(0)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:for-each select="ancestor::rdf:RDF/vcard:Name[contains(@rdf:about, $personID)]">
           <contributor>
               <namePart>
                <xsl:value-of select="normalize-space(concat(vcard:givenName, ' ', vcard:familyName))"/>
               </namePart>
           </contributor>
        </xsl:for-each>

    </xsl:template>
    
   
    <xsl:template match="bibo:freetextKeyword" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
   
    <xsl:template match="dc:rights" mode="collection_rights_access">
        
        <xsl:choose>
            <xsl:when test="matches(upper-case(.), 'CC.BY')">
                <xsl:variable name="ccNoNumber" as="xs:string*">
                    <xsl:analyze-string select="." regex="[A-Za-zÀ-ÿ\s-]+">
                        <xsl:matching-substring>
                            <xsl:if test="string-length(regex-group(0)) > 0">
                                <xsl:value-of select="regex-group(0)"/>
                            </xsl:if>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <rights>
                    <licence type="{upper-case(replace(normalize-space($ccNoNumber[1]), ' ', '-'))}">
                        <xsl:value-of select="upper-case(replace(normalize-space(.), ' ', '-'))"/>
                    </licence>
                </rights>   
            </xsl:when>
            <xsl:otherwise>
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="."/>
                    </rightsStatement>
                </rights>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="oai:setSpec" mode="collection_subject">
       <xsl:variable name="categoryId" select="substring-after(., 'category_')" as="xs:string"/>
       <xsl:variable name="mappedValue" select="$categoryCodeList/root/row[id = $categoryId]/title"/>
       
            
            
        <xsl:choose>
            <xsl:when test="string-length($mappedValue) > 0">
                <xsl:message select="concat('categoryId [', $categoryId, '] mapped to [', $mappedValue, ']')"/>
                <subject type="local">
                    <xsl:value-of select="$mappedValue"/>
                </subject>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat('No text found for categoryId [', $categoryId, ']')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="bibo:abstract" mode="collection_description_full">
        
        <!--xsl:variable name="name" select='replace(.,"&#x00E2;&#x80;&#x99;", "&#8217;")'/-->
        <xsl:variable name="description" select="figFunc:characterReplace(.)"/>
        <description type="full">
            <xsl:value-of select="$description"/>
        </description>
    </xsl:template>
    
    <xsl:template match="@rdf:resource" mode="collection_dates_issued">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="substring-after(., 'http://openvivo.org/a/date')"/>
            </date>
        </dates>
    </xsl:template>  
             
    <xsl:template match="@rdf:resource" mode="collection_dates_created">
        <dates type="created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="substring-after(., 'http://openvivo.org/a/date')"/>
            </date>
        </dates>    
    </xsl:template>
    
    <xsl:template match="rifcis:fullCitation" mode="collection_citationInfo_fullCitation">
        <citationInfo>
            <xsl:copy-of copy-namespaces="no" select="."></xsl:copy-of>
        </citationInfo>
    </xsl:template>

    <!-- Don't use the following template because the source isn't always complete, so best 
        instead to construct manually with collection_citationInfo_citationMetadata for now 
        - but only if there is no fullCitation (to use as first priority)
    <xsl:template match="rifcis:citationMetadata" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <xsl:copy-of copy-namespaces="no" select="."></xsl:copy-of>
        </citationInfo>
    </xsl:template-->
    
    <xsl:template match="rifcis:relatedInfo" mode="collection_relatedInfo">
        <xsl:copy-of copy-namespaces="no" select="."></xsl:copy-of>
     </xsl:template>
    
    <xsl:template match="rdf:RDF" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(*/bibo:doi[string-length() > 0]) > 0">
                        <xsl:apply-templates select="*/bibo:doi[string-length() > 0][1]" mode="collection_identifier"/>
                    </xsl:when>
                    <xsl:when test="count(*[1]/@rdf:about[(string-length(.) > 0)]) > 0">
                        <xsl:apply-templates select="*[1]/@rdf:about[(string-length(.) > 0)]" mode="collection_identifier_URI"/>
                    </xsl:when>
               </xsl:choose>
                
                <xsl:for-each select="vivo:Authorship/vivo:relates/vcard:Individual/vcard:hasName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <title>
                    <xsl:value-of select="string-join(*/rdfs:label[string-length(.) > 0][1], ' - ')"/>
                </title>
                
                <!--version></version-->
                <!--placePublished></placePublished-->
                <xsl:choose>
                    <xsl:when test="string-length(dc:publisher[1]) > 0">
                        <publisher>
                            <xsl:value-of select="dc:publisher[1]"/>
                        </publisher>
                    </xsl:when>
                    <xsl:when test="string-length(vivo:publisher[1]) > 0">
                        <publisher>
                            <xsl:value-of select="vivo:publisher[1]"/>
                        </publisher>
                    </xsl:when>
                    <xsl:when test="string-length(rifcis:registryObjects/rifcis:registryObject/rifcis:citationInfo/rifcis:citationMetadata/rifcis:publisher[1]) > 0">
                        <publisher>
                            <xsl:value-of select="rifcis:registryObjects/rifcis:registryObject/rifcis:citationInfo/rifcis:citationMetadata/rifcis:publisher[1]"/>
                        </publisher>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:apply-templates select="*/vivo:datePublished/@rdf:resource[string-length(.) > 0]" mode="collection_citation_publicationDate"/>  
                
                <!--url>
                    <xsl:choose>
                        <xsl:when test="count(datacite:alternateIdentifier[(@alternateIdentifierType = 'URL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="datacite:alternateIdentifier[(@alternateIdentifierType = 'URL')][1]"/>
                        </xsl:when>
                        <xsl:when test="count(datacite:alternateIdentifier[(@alternateIdentifierType = 'PURL') and (string-length() > 0)]) > 0">
                            <xsl:value-of select="datacite:alternateIdentifier[(@alternateIdentifierType = 'PURL')][1]"/>
                        </xsl:when>
                    </xsl:choose>
                </url-->
            </citationMetadata>
        </citationInfo>
        
    </xsl:template>
    
    
    <xsl:template match="@rdf:resource" mode="collection_citation_publicationDate">
        <date type="publicationDate">
            <xsl:value-of select="substring(substring-after(., 'http://openvivo.org/a/date'), 1, 4)"/>
        </date>
    </xsl:template> 
    
    <!--xsl:template match="rdf:RDF" mode="party">
        
        <xsl:for-each select="vcard:Name">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(@rdf:about) > 0)">
            
                   <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="custom:registryObjectKeyFromString(local:unifyAuthorURL(@rdf:about))"/>
                        </key> 
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                           
                            <identifier type="uri">
                                <xsl:value-of select="local:unifyAuthorURL(@rdf:about)"/> 
                            </identifier>  
                             
                            <xsl:variable name="currentPersonURL" select="@rdf:about"/>
                            <xsl:for-each select="ancestor::rdf:RDF/vivo:Authorship/vivo:relates/vcard:Individual/obo:ARG_2000029/foaf:Person[contains($currentPersonURL, @rdf:about)]">
                                <xsl:for-each select="vivo:orcidId[string-length(@rdf:resource) > 0]">
                                    <identifier type="orcid">
                                        <xsl:value-of select="@rdf:resource"/>
                                    </identifier>
                                </xsl:for-each>
                            </xsl:for-each>
                             <name type="primary">
                                 <namePart type="given">
                                     <xsl:value-of select="vcard:givenName"/>
                                 </namePart>    
                                 <namePart type="family">
                                     <xsl:value-of select="vcard:familyName"/>
                                 </namePart>
                             </name>
                        </party>
                     </registryObject>
                   </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:template-->
        
        
        <xsl:function name="local:getIdentifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
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
        <!--xsl:variable name="name" select='replace(.,"&#x00E2;&#x80;&#x99;", "&#8217;")'/-->
        <xsl:variable name="replaceSingleQuote" select='replace($input,"&#x00E2;&#x80;&#x99;", "&#x2019;")'/>
        <xsl:variable name="replaceLeftDoubleQuote" select='replace($replaceSingleQuote, "&#x00E2;&#x80;&#x9c;", "&#x201C;")'/>
        <xsl:variable name="replaceRightDoubleQuote" select='replace($replaceLeftDoubleQuote, "&#x00E2;&#x80;&#x9d;", "&#x201D;")'/>
        <xsl:variable name="replaceNarrowNoBreakSpace" select='replace($replaceRightDoubleQuote, "&#xE2;&#x80;&#xAF;", "&#x202F;")'/>
        <xsl:value-of select="$replaceNarrowNoBreakSpace"/>
    </xsl:function>
    
 
</xsl:stylesheet>
