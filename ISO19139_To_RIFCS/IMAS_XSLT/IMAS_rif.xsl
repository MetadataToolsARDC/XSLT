<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:dwc="http://rs.tdwg.org/dwc/terms/" 
    xmlns:gml="http://www.opengis.net/gml" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:geonet="http://www.fao.org/geonetwork" 
    gco:isoType="gmd:MD_Metadata" 
    xsi:schemaLocation="http://schemas.aodn.org.au/mcp-2.0 http://schemas.aodn.org.au/mcp-2.0/schema.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://rs.tdwg.org/dwc/terms/ http://schemas.aodn.org.au/mcp-2.0/mcpDwcTerms.xsd"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customIMAS="http://customIMAS.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xlink geonet gmx oai xsi gmd srv gml gco mcp dwc customIMAS custom">
    <xsl:import href="CustomFunctions.xsl"/>
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    
    <xsl:param name="global_IMAS_group" select="'UTAS:University of Tasmania, Australia'"/>
    <xsl:param name="global_IMAS_sourceURL" select="'http://metadata.imas.utas.edu.au'"/>
    <!--xsl:param name="global_IMAS_originatingSourceOrganisation" select="'undetermined'"/-->
    
    <xsl:param name="global_IMAS_path" select="'/geonetwork/srv/eng/metadata.show?uuid='"/>
    
    <xsl:param name="global_IMAS_cannedCitation" select="'The citation in a list of references is: citation author name/s (year metadata published), metadata title. Citation author organisation/s. File identifier and Data accessed at (add http link).'"/>
    <xsl:param name="global_IMAS_identifier_open" select="'39060c33-9246-49fe-8f97-758b67ced4ce'"/>
    
    <xsl:param name="global_IMAS_onlineResourceUrlSubset_sequence" select="'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/file.disclaimer?'" as="xs:string*"/>
    
    <xsl:param name="global_IMAS_ignoreOnlineResourceProtocolSubset_sequence" select="'OGC:WPS--gogoduck','IMOS:AGGREGATION--bodaac','IMOS:NCWMS--proto '" as="xs:string*"/>
    
    <!--xsl:param name="global_IMAS_ActivityKeyNERP" select="'to be determined'"/-->
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
    <xsl:template match="oai:responseDate"/>
    <xsl:template match="oai:request"/>
    <xsl:template match="oai:error"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:setSpec"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:setSpec"/>

    <xsl:template match="node()"/>

    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->

    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//*:MD_Metadata" mode="IMAS"/>
        </registryObjects>
    </xsl:template>
    

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="*:MD_Metadata" mode="IMAS">
        <xsl:param name="aggregatingGroup"/>
        
        <xsl:variable name="groupToUse">
            <xsl:choose>
                <xsl:when test="string-length($aggregatingGroup) > 0">
                    <xsl:value-of select="$aggregatingGroup"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_IMAS_group"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$global_debug">
         <xsl:message select="concat('groupToUse: ', $groupToUse)"/>
        </xsl:if>
        
        <xsl:variable name="metadataURL_sequence" select="customIMAS:getMetadataTruthURL_sequence(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions)[1]"/>
        <xsl:variable name="metadataURL">
            <xsl:choose>
                <xsl:when test="count($metadataURL_sequence) > 0">
                    <xsl:value-of select="$metadataURL_sequence[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        
        <xsl:if test="$global_debug">
         <xsl:message select="concat('metadataURL: ', $metadataURL)"/>
        </xsl:if>
        
        
        <xsl:variable name="datasetURI" select="gmd:dataSetURI"/>
        <xsl:if test="$global_debug">
            <xsl:message select="concat('datasetURI: ', $datasetURI)"/>
        </xsl:if>
        
        <xsl:variable name="originatingSourceURL">
            <xsl:choose>
                <xsl:when test="string-length($metadataURL) > 0">
                    <xsl:value-of select="custom:getDomainFromURL($metadataURL)"/>
                </xsl:when>
                <xsl:when test="string-length($datasetURI) > 0">
                    <xsl:value-of select="custom:getDomainFromURL($datasetURI)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>undetermined</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('originatingSourceURL: ', $originatingSourceURL)"/>
        </xsl:if>
        
        <xsl:variable name="dataSetURI" select="gmd:dataSetURI"/>
        <xsl:if test="$global_debug">
            <xsl:message select="concat('dataSetURI: ', $dataSetURI)"/>
        </xsl:if>
        
        <xsl:variable name="fileIdentifier" select="gmd:fileIdentifier[1]"/>
        <!--xsl:message select="concat('fileIdentifier: ', $fileIdentifier)"/-->

        <xsl:variable name="imasDataCatalogueURL">
            <xsl:if test="string-length($fileIdentifier) > 0">
                <xsl:copy-of select="concat($global_IMAS_sourceURL, $global_IMAS_path, $fileIdentifier)"/>
            </xsl:if>
        </xsl:variable>
        <!--xsl:message select="concat('imasDataCatalogueURL: ', $imasDataCatalogueURL)"/-->
        
        <xsl:variable name="projectionCode">
            <xsl:variable name="projectionCode_sequence" select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code"/>
            <!--xsl:message select="concat('total projectionCodes: ', count($projectionCode_sequence))"/-->
            <xsl:if test="count($projectionCode_sequence) > 0">
                <xsl:value-of select="$projectionCode_sequence[1]"/>
            </xsl:if>
        </xsl:variable>
        
        <!--xsl:message select="concat('projection code: ', $projectionCode)"/-->
              
        <xsl:variable name="scopeCode">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(gmd:hierarchyLevel/gmx:MX_ScopeCode/@codeListValue)) > 0">
                    <xsl:value-of select="normalize-space(gmd:hierarchyLevel/gmx:MX_ScopeCode/@codeListValue)"/>
                </xsl:when>
                <xsl:when test="string-length(normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)) > 0">
                    <xsl:value-of select="normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>dataset</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--xsl:message select="concat('scopeCode: ', $scopeCode)"/-->
        <xsl:variable name="pointOfContactNode_sequence" as="node()*">
            <xsl:if test="count(gmd:identificationInfo/mcp:MD_DataIdentification) > 0">
                <xsl:copy-of select="customIMAS:getPointOfContactSequence(gmd:identificationInfo/mcp:MD_DataIdentification)"/>
            </xsl:if>
            
            <xsl:if test="count(gmd:identificationInfo/mcp:MD_ServiceIdentification) > 0">
                <xsl:copy-of select="customIMAS:getPointOfContactSequence(gmd:identificationInfo/mcp:MD_ServiceIdentification)"/>
            </xsl:if>
            
            <xsl:if test="count(gmd:identificationInfo/srv:SV_ServiceIdentification) > 0">
                <xsl:copy-of select="customIMAS:getPointOfContactSequence(gmd:identificationInfo/srv:SV_ServiceIdentification)"/>
            </xsl:if>
            
        </xsl:variable>
        <!--xsl:for-each select="distinct-values($pointOfContactNode_sequence)">
            <xsl:message select="concat('pointOfContact: ', .)"/>
        </xsl:for-each-->
        
        <!--xsl:message select="concat('count pointOfContactNode_sequence: ', count($pointOfContactNode_sequence))"/-->
        
        <!-- Seek an individual who has role in either:  principal investigator, an author, or a co investigator - in that order -->
        <xsl:variable name="citationContributorIndividualName_specificRole_sequence" as="xs:string*">
            <!--xsl:message select="concat('count gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation: ', count(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation))"/-->
            <xsl:if test="count(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation) > 0">
                <xsl:copy-of select="customIMAS:getIndividualNameSequence(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation, 'principalInvestigator,author,coInvestigator')"/> 
            </xsl:if>
        </xsl:variable>
        <!--xsl:message select="concat('count citationContributorIndividualName_specificRole_sequence: ', count($citationContributorIndividualName_specificRole_sequence))"/-->
        
        <!-- Seek an organisation with no individual name, that has role in either:  principal investigator, an author, or a co investigator - in that order -->
        <xsl:variable name="citationContributorOrganisationNameNoIndividualName_specificRole_sequence" as="xs:string*">
            <xsl:if test="count(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation) > 0">
                <xsl:copy-of select="customIMAS:getOrganisationNameSequence(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation, 'principalInvestigator,author,coInvestigator')"/>    
            </xsl:if>
        </xsl:variable>
        <!--xsl:message select="concat('count citationContributorOrganisationNameNoIndividualName_specificRole_sequence: ', count($citationContributorOrganisationNameNoIndividualName_specificRole_sequence))"/-->
        
        <!-- Seek an individual of any role -->
        <xsl:variable name="citationContributorIndividualName_anyRole_sequence" as="xs:string*">
            <!--xsl:message select="concat('count gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation: ', count(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation))"/-->
            <xsl:if test="count(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation) > 0">
                <xsl:copy-of select="customIMAS:getIndividualNameSequence(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation, ',')"/> 
            </xsl:if>
        </xsl:variable>
        <!--xsl:message select="concat('count citationContributorIndividualName_anyRole_sequence: ', count($citationContributorIndividualName_anyRole_sequence))"/-->
        
        <!-- Seek an organisation, regardless of whether there is an individual name, that has any role -->
        <xsl:variable name="citationContributorAllOrganisation_anyRole_sequence" as="xs:string*">
            <xsl:if test="count(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation) > 0">
                <xsl:copy-of select="customIMAS:getAllOrganisationNameSequence(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation, ',')"/>
            </xsl:if>
        </xsl:variable>
        <!--xsl:message select="concat('count citationContributorAllOrganisation_anyRole_sequence: ', count($citationContributorAllOrganisation_anyRole_sequence))"/-->
        
        <xsl:variable name="pointOfContactOrganisationName_specificRole_sequence" as="xs:string*">
            <!-- Seek an organisation point of contact, regardless of whether there is an individual name, that has role in either:  principal investigator, an author, or a co investigator -->
            <xsl:for-each select="$pointOfContactNode_sequence">
                <xsl:copy-of select="customIMAS:getAllOrganisationNameSequence(., 'principalInvestigator,author,coInvestigator')"/>  
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="pointOfContactOrganisationName_anyRole_sequence" as="xs:string*">
            <!-- Seek an organisation point of contact, regardless of whether there is an individual name, of any role -->
            <xsl:for-each select="$pointOfContactNode_sequence">
                <xsl:copy-of select="customIMAS:getAllOrganisationNameSequence(., ',')"/>  
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="citationContributorName_sequence" as="xs:string*">
            <!-- ToDo - use individual if AAD, otherwise, organisation.. ? -->
            <xsl:choose>
                <xsl:when test="count($citationContributorIndividualName_specificRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($citationContributorIndividualName_specificRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="count($citationContributorOrganisationNameNoIndividualName_specificRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($citationContributorOrganisationNameNoIndividualName_specificRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="count($citationContributorIndividualName_anyRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($citationContributorIndividualName_anyRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="count($citationContributorAllOrganisation_anyRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($citationContributorAllOrganisation_anyRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="count($pointOfContactOrganisationName_specificRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($pointOfContactOrganisationName_specificRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                
                <xsl:when test="count($pointOfContactOrganisationName_anyRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($pointOfContactOrganisationName_anyRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
      
        <!--xsl:message select="concat('count citationContributorName_sequence: ', count($citationContributorName_sequence))"/-->
        <!--xsl:for-each select="distinct-values($citationContributorName_sequence)">
            <xsl:message select="concat('citation constributor: ', .)"/>
        </xsl:for-each-->
        
        <xsl:variable name="originatingSourceOrganisation_sequence" as="xs:string*">
            <!-- ToDo - use individual if AAD, otherwise, organisation.. ? -->
            <xsl:choose>
                <xsl:when test="count($citationContributorOrganisationNameNoIndividualName_specificRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($citationContributorOrganisationNameNoIndividualName_specificRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="count($citationContributorAllOrganisation_anyRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($citationContributorAllOrganisation_anyRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="count($pointOfContactOrganisationName_specificRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($pointOfContactOrganisationName_specificRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                
                
                <xsl:when test="count($pointOfContactOrganisationName_anyRole_sequence) > 0">
                    <xsl:for-each select="distinct-values($pointOfContactOrganisationName_anyRole_sequence)">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!--xsl:message select="concat('count originatingSource_sequence: ', count($originatingSource_sequence))"/-->
        <!--xsl:for-each select="distinct-values($originatingSource_sequence)">
            <xsl:message select="concat('originating source: ', .)"/>
        </xsl:for-each-->
        
        <xsl:variable name="originatingSourceOrganisation">
            <xsl:choose>
                <xsl:when test="count($originatingSourceOrganisation_sequence) > 0">
                    <xsl:value-of select="customIMAS:getTransformedOriginatingSourceOrganisation($originatingSourceOrganisation_sequence[1])"/>  
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_IMAS_sourceURL"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="publishingOrganisation">
            
            <xsl:variable name="publishingOrganisationNotTransformed">
                <xsl:variable name="baseURI">
                    <xsl:choose>
                        <xsl:when test="string-length($metadataURL) > 0">
                            <!--xsl:message select="concat('metadataTruthURL: ', $metadataURL)"/-->
                            <xsl:copy-of select="customIMAS:getBaseURI($metadataURL)"/>
                        </xsl:when>
                        <xsl:when test="string-length($dataSetURI) > 0">
                            <!--xsl:message select="concat('dataSetURI: ', $dataSetURI)"/-->
                            <xsl:copy-of select="customIMAS:getBaseURI($dataSetURI)"/> 
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                
                <!--xsl:message select="concat('baseURI: ', $baseURI)"/-->                
                
                <xsl:variable name="orgNameFromURI">
                    <xsl:if test="string-length($baseURI) > 0">
                        <xsl:copy-of select="customIMAS:getOrgNameFromBaseURI($baseURI)"/>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="string-length($orgNameFromURI) > 0">
                        <xsl:copy-of select="$orgNameFromURI"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                             <xsl:when test="count($pointOfContactOrganisationName_specificRole_sequence) > 0">
                                 <xsl:copy-of select="$pointOfContactOrganisationName_specificRole_sequence[1]"/>
                             </xsl:when>
                             <xsl:otherwise>
                                 <xsl:if test="count($pointOfContactOrganisationName_anyRole_sequence) > 0">
                                     <xsl:copy-of select="$pointOfContactOrganisationName_anyRole_sequence[1]"/>
                                 </xsl:if>
                             </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:value-of select="customIMAS:getTransformedPublisher($publishingOrganisationNotTransformed)"/>      
        
        </xsl:variable>
        
        <!--xsl:message select="concat('publishingOrganisation: ', $publishingOrganisation)"/-->

        <registryObject>
            <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>

            <xsl:apply-templates select="gmd:fileIdentifier" mode="IMAS_registryObject_key">
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:apply-templates>

            <originatingSource>
                <xsl:value-of select="$originatingSourceURL"/>
            </originatingSource>
            
            <xsl:variable name="metadataCreationDate">
                <xsl:if test="string-length(normalize-space(gmd:dateStamp/gco:Date)) > 0">
                    <xsl:value-of select="normalize-space(gmd:dateStamp/gco:Date)"/>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(gmd:dateStamp/gco:DateTime)) > 0">
                    <xsl:value-of select="normalize-space(gmd:dateStamp/gco:DateTime)"/>
                </xsl:if>
            </xsl:variable>

            <xsl:variable name="registryObjectTypeSubType_sequence" as="xs:string*">
                <xsl:call-template name="IMAS_getRegistryObjectTypeSubType">
                    <xsl:with-param name="scopeCode" select="$scopeCode"/>
                    <xsl:with-param name="publishingOrganisation" select="$publishingOrganisation"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="(count($registryObjectTypeSubType_sequence) = 2)">
                <xsl:element name="{$registryObjectTypeSubType_sequence[1]}">

                    <xsl:attribute name="type">
                        <xsl:value-of select="$registryObjectTypeSubType_sequence[2]"/>
                    </xsl:attribute>
                    
                    <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                        <xsl:if test="
                            (count(gmd:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and 
                            (string-length(gmd:dateStamp/*[contains(lower-case(name()),'date')][1]) > 0)">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="gmd:dateStamp/*[contains(lower-case(name()),'date')][1]"/>
                            </xsl:attribute>  
                        </xsl:if>
                        
                    </xsl:if>
                    
                    <xsl:call-template name="IMAS_set_registryObjectIdentifier">
                        <xsl:with-param name="identifier" select="gmd:fileIdentifier[1]"/>
                        <xsl:with-param name="type" select="'global'"/>
                    </xsl:call-template>
                    
                    <xsl:choose>
                        <xsl:when test="string-length($metadataURL) > 0">
                            <xsl:call-template name="IMAS_set_registryObjectIdentifier">
                                <xsl:with-param name="identifier" select="$metadataURL"/>
                                <xsl:with-param name="type" select="'uri'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string-length($imasDataCatalogueURL) > 0">
                                <xsl:call-template name="IMAS_set_registryObjectIdentifier">
                                    <xsl:with-param name="identifier" select="$imasDataCatalogueURL"/>
                                    <xsl:with-param name="type" select="'uri'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title"
                        mode="IMAS_registryObject_name"/>
                    
                    <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                        <xsl:apply-templates
                            select="gmd:identificationInfo/*:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date"
                            mode="IMAS_registryObject_dates"/>
                    </xsl:if>
                    
                    <xsl:apply-templates select="gmd:parentIdentifier"
                        mode="IMAS_registryObject_related_object">
                        <xsl:with-param name="groupToUse" select="$groupToUse"/>
                    </xsl:apply-templates>

                   <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution"
                        mode="IMAS_registryObject_location"/>
                    
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution"
                        mode="IMAS_registryObject_accessRights_type"/>
                    
                    
                    <xsl:for-each-group
                        select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)] |
                         gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                        group-by="gmd:individualName">
                        <xsl:apply-templates select="." mode="IMAS_registryObject_related_object">
                            <xsl:with-param name="groupToUse" select="$groupToUse"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>

                    <xsl:for-each-group
                        select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName[1])) > 0) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)] |
                         gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName[1])) > 0) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                        group-by="gmd:organisationName">
                        <xsl:apply-templates select="." mode="IMAS_registryObject_related_object">
                            <xsl:with-param name="groupToUse" select="$groupToUse"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>

                    <xsl:apply-templates select="mcp:children/mcp:childIdentifier"
                        mode="IMAS_registryObject_related_object">
                        <xsl:with-param name="groupToUse" select="$groupToUse"/>
                    </xsl:apply-templates>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode"
                        mode="IMAS_registryObject_subject"/>

                    <xsl:apply-templates select="gmd:identificationInfo/mcp:MD_DataIdentification"
                        mode="IMAS_registryObject_subject"/>

                    <xsl:apply-templates select="gmd:identificationInfo/srv:ServiceIdentification"
                        mode="IMAS_registryObject_subject"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/mcp:MD_ServiceIdentification"
                        mode="IMAS_registryObject_subject"/>

                    <xsl:apply-templates select="gmd:identificationInfo/*/gmd:abstract"
                        mode="IMAS_registryObject_description"/>
                    
                    <xsl:apply-templates
                        select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:statement"
                        mode="IMAS_registryObject_description_lineage"/>
                    
                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox"
                        mode="IMAS_registryObject_coverage_spatial">
                        <xsl:with-param name="code" select="$projectionCode"/>
                    </xsl:apply-templates>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon"
                        mode="IMAS_registryObject_coverage_spatial"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent"
                        mode="IMAS_registryObject_coverage_temporal"/>
                    
                    <xsl:if test="($registryObjectTypeSubType_sequence[1] = 'activity') or ($registryObjectTypeSubType_sequence[1] = 'party')">
                        <xsl:apply-templates
                            select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent"
                            mode="IMAS_registryObject_existence_dates"/>
                    </xsl:if>
                    
                    <!--xsl:apply-templates
                        select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions"
                        mode="IMAS_registryObject_relatedInfo"/-->
                    
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource" mode="IMAS_registryObject_relatedInfo"/>
                    

                    <xsl:apply-templates select="mcp:children/mcp:childIdentifier"
                        mode="IMAS_registryObject_relatedInfo"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn"
                        mode="IMAS_registryObject_relatedInfo"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/mcp:MD_CreativeCommons[
                            exists(mcp:licenseLink)]"
                        mode="IMAS_registryObject_rights_licence_creative"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/mcp:MD_CreativeCommons"
                        mode="IMAS_registryObject_rights_rightsStatement_creative"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/mcp:MD_Commons[
                            exists(mcp:licenseLink)]"
                        mode="IMAS_registryObject_rights_licence_creative"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/mcp:MD_Commons"
                        mode="IMAS_registryObject_rights_rightsStatement_creative"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints"
                        mode="IMAS_registryObject_rights_rightsStatement"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints[
                            exists(gmd:accessConstraints)]"
                        mode="IMAS_registryObject_rights_accessRights"/>

                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_Constraints"
                        mode="IMAS_registryObject_rights_rightsStatement"/>


                    <xsl:apply-templates
                        select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_Constraints"
                        mode="IMAS_registryObject_rights_accessRights"/>

                    <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">

                        <!--xsl:variable name="distributorContactNode_sequence" as="node()*">
                            <xsl:call-template name="IMAS_getDistributorContactSequence">
                                <xsl:with-param name="parent"
                                    select="gmd:distributionInfo/gmd:MD_Distribution"/>
                            </xsl:call-template>
                        </xsl:variable-->

                       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation">
                            <xsl:call-template name="IMAS_registryObject_citationMetadata_citationInfo">
                                <xsl:with-param name="metadataURL" select="$metadataURL"/>
                                <xsl:with-param name="imasDataCatalogueURL" select="$imasDataCatalogueURL"/>
                                <xsl:with-param name="originatingSourceOrganisation" select="$originatingSourceOrganisation"/>
                                <xsl:with-param name="publishingOrganisation" select="$publishingOrganisation"/>
                                <xsl:with-param name="citation" select="."/>
                                <xsl:with-param name="citationContributorName_sequence" select="$citationContributorName_sequence"/>
                                <xsl:with-param name="metadataCreationDate" select="$metadataCreationDate"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:element>
            </xsl:if>
        </registryObject>

        <!-- =========================================== -->
        <!-- Party RegistryObject Template          -->
        <!-- =========================================== -->

        <xsl:for-each-group
            select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
             (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)] |
             gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
             (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
            group-by="gmd:individualName">
            <xsl:call-template name="IMAS_party">
                <xsl:with-param name="type">person</xsl:with-param>
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:call-template>
        </xsl:for-each-group>

        <xsl:for-each-group
            select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName[1])) > 0) and 
             (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)] |
             gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName[1])) > 0) and 
             (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
            group-by="gmd:organisationName">
            <xsl:call-template name="IMAS_party">
                <xsl:with-param name="type">group</xsl:with-param>
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:call-template>
        </xsl:for-each-group>

        <!--/xsl:if-->

    </xsl:template>

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="IMAS_registryObject_key">
        <xsl:param name="groupToUse"/>
        <key>
            <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', normalize-space(.))"/>
        </key>
    </xsl:template>

    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="IMAS_registryObject_identifier">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>local</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$identifier"/>
            </identifier>
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>global</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$identifier"/>
            </identifier>
        </xsl:if>
    </xsl:template>

    <xsl:template name="IMAS_set_registryObjectIdentifier">
        <xsl:param name="identifier"/>
        <xsl:param name="type"/>
        <xsl:if test="string-length($identifier) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="$type"/>
                </xsl:attribute>
                <xsl:value-of select="$identifier"/>
            </identifier>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Name Element  -->
    <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title"
        mode="IMAS_registryObject_name">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <name>
                <xsl:attribute name="type">
                    <xsl:text>primary</xsl:text>
                </xsl:attribute>
                <namePart>
                    <xsl:value-of select="normalize-space(.)"/>
                </namePart>
            </name>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Point of Contact Sequence  -->

    <xsl:function name="customIMAS:getPointOfContactSequence" as="node()*">
        <xsl:param name="parent" as="node()"/>
        <xsl:for-each select="$parent/descendant::gmd:pointOfContact">
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="customIMAS:getDistributorContactSequence" as="node()*">
        <xsl:param name="parent"/>
        <xsl:for-each select="$parent/descendant::gmd:distributorContact">
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:function>

    <!-- RegistryObject - Dates Element  -->
    <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date"
        mode="IMAS_registryObject_dates">
        <xsl:variable name="dateValue">
            <xsl:if test="string-length(normalize-space(gmd:CI_Date/gmd:date/gco:Date)) > 0">
                <xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:Date)"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(gmd:CI_Date/gmd:date/gco:DateTime)) > 0">
                <xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:DateTime)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="dateCode"
            select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
        <xsl:variable name="transformedDateCode">
            <xsl:choose>
                <xsl:when test="contains($dateCode, 'creation')">
                    <xsl:text>created</xsl:text>
                </xsl:when>
                <xsl:when test="contains($dateCode, 'publication')">
                    <xsl:text>issued</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if
            test="
            (string-length($dateValue) > 0) and
            (string-length($transformedDateCode) > 0)">
            <dates>
                <xsl:attribute name="type">
                    <xsl:value-of select="$transformedDateCode"/>
                </xsl:attribute>
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>dateFrom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="dateFormat">
                        <xsl:text>W3CDTF</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$dateValue"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="gmd:parentIdentifier" mode="IMAS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', normalize-space(.))"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>isPartOf</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gmd:MD_Distribution" mode="IMAS_registryObject_accessRights_type">
        <xsl:variable name="open_sequence" as="xs:boolean*">
            <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
                <xsl:choose>
                    <xsl:when test="
                        contains(lower-case(gmd:protocol), 'get-map')">
                        <xsl:value-of select='true()'/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="count($open_sequence) > 0">
            <rights>
                <accessRights type='open'/>
            </rights>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gmd:MD_Distribution" mode="IMAS_registryObject_location">
        <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
            <xsl:choose>
                <!-- handing download data protocol without '?' or thredds in URL  here - download data protocol with '?' is handled by relatedInfo type='service' , as is thredds-->
                <xsl:when test="contains(lower-case(*:protocol), 'downloaddata') and (not(contains(*:linkage/*:URL, '?'))) and (not(contains(*:linkage/*:URL, 'thredds')))">
                    <xsl:if test="string-length(normalize-space(*:linkage/*:URL)) > 0">
                        <xsl:variable name="title" select="*:description"/>
                        <xsl:variable name="notes" select="''"/>
                        <xsl:variable name="mediaType" select="*:name/*:MimeFileType/@type"/>
                        <xsl:variable name="byteSize" select="../../*:transferSize/*:Real"/>
                        <location>
                            <address>
                            <electronic>
                                <xsl:attribute name="type">
                                    <xsl:text>url</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>directDownload</xsl:text>
                                </xsl:attribute>
                                <value>
                                    <xsl:value-of select="normalize-space(*:linkage/*:URL)"/>
                                </value>
                                <xsl:if test="string-length($title) > 0">
                                    <title>
                                        <xsl:value-of select="$title"/>
                                    </title>
                                </xsl:if>
                                <xsl:if test="string-length($notes) > 0">
                                    <notes>
                                        <xsl:value-of select="$notes"/>
                                    </notes>
                                </xsl:if>
                                <xsl:if test="string-length($mediaType) > 0">
                                    <mediaType>
                                        <xsl:value-of select="$mediaType"/>
                                    </mediaType>
                                </xsl:if>
                                <xsl:if test="string-length($byteSize) > 0">
                                    <byteSize>
                                        <xsl:value-of select="$byteSize"/>
                                    </byteSize>
                                </xsl:if>
                            </electronic>
                        </address>
                        </location>   
                    </xsl:if>
                </xsl:when>
                
                <xsl:when test="contains(lower-case(gmd:protocol), 'metadata-url')">
                    <location>
                        <address>
                            <electronic>
                                <xsl:attribute name="type">
                                    <xsl:text>url</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>landingPage</xsl:text>
                                </xsl:attribute>
                                <value>
                                    <xsl:value-of select="normalize-space(*:linkage/*:URL)"/>
                                </value>
                            </electronic>
                        </address>
                    </location>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="IMAS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
        
        <xsl:variable name="name" select="normalize-space(current-grouping-key())"/>
        <relatedObject>
            <key>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(customIMAS:nameNoTitle($name),' ',''))"/>
            </key>
            <!-- if current grouping key is organisation name and there is an individual name, make relation soft-->
            <xsl:choose>
                <xsl:when test="(current-grouping-key() = gmd:organisationName[1]) and (string-length(normalize-space(gmd:individualName)) > 0)">
                         <relation type="hasAssociationWith"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each-group select="current-group()/gmd:role"
                        group-by="gmd:CI_RoleCode/@codeListValue">
                        <xsl:variable name="code">
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:variable>
                        <relation>
                            <xsl:variable name="codelist"
                                select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_RoleCode']"/>
                            
                            <xsl:variable name="type">
                                <xsl:value-of select="$codelist/entry[code = $code]/description"/>
                            </xsl:variable>
                            
                            <xsl:attribute name="type">
                                <xsl:choose>
                                    <xsl:when test="string-length($type) > 0">
                                        <xsl:value-of select="$type"/>
                                    </xsl:when>
                                    <xsl:when test="string-length($code) > 0">
                                        <xsl:value-of select="$code"/>  
                                    </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:text>unknown</xsl:text>
                                     </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </relation>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </relatedObject>
    </xsl:template>

    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="mcp:childIdentifier" mode="IMAS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
        <!--xsl:message>mcp:children</xsl:message-->
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', normalize-space(.))"/>
                
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Subject Element -->
    <xsl:template match="mcp:MD_DataIdentification" mode="IMAS_registryObject_subject">
        <xsl:call-template name="IMAS_populateSubjects">
            <xsl:with-param name="parent" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="srv:ServiceIdentification" mode="IMAS_registryObject_subject">
        <xsl:call-template name="IMAS_populateSubjects">
            <xsl:with-param name="parent" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mcp:MD_ServiceIdentification" mode="IMAS_registryObject_subject">
        <xsl:call-template name="IMAS_populateSubjects">
            <xsl:with-param name="parent" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="IMAS_populateSubjects">
        <xsl:param name="parent"/>
        <xsl:for-each select="$parent/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/*">
            <xsl:variable name="idType">
                <xsl:choose>
                    <xsl:when test="contains(@xlink:href, 'anzsrc-for')">
                        <xsl:text>anzsrc-for</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@xlink:href, 'anzsrc-toa')">
                        <xsl:text>anzsrc-toa</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@xlink:href, 'anzsrc-toa')">
                        <xsl:text>anzsrc-for</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@xlink:href, 'anzsrc-seo')">
                        <xsl:text>anzsrc-seo</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@xlink:href, 'gcmd')">
                        <xsl:text>gcmd</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="termIdentifier" select="substring-after(@xlink:href, 'id=')"/>
            
            <xsl:variable name="id" select="tokenize($termIdentifier, '/')[last()]"/>
            
            <xsl:choose>
                <xsl:when test="contains($idType, 'anzsrc')">
                    <xsl:if test="string-length($id) > 0">
                        <subject type="{$idType}" termIdentifier="{$termIdentifier}">
                            <xsl:value-of select="$id"/>
                        </subject>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="string-length(.) > 0">
                        <subject type="{$idType}">
                            <xsl:if test="string-length($termIdentifier) > 0">
                                <xsl:attribute name="termIdentifier">
                                    <xsl:value-of select="$termIdentifier"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </subject>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode" mode="IMAS_registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."/>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:abstract" mode="IMAS_registryObject_description">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="full">
                <xsl:value-of select="normalize-space(.)"/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:statement" mode="IMAS_registryObject_description_lineage">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="lineage">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_GeographicBoundingBox" mode="IMAS_registryObject_coverage_spatial">
        <xsl:param name="code"/>
        <xsl:if
            test="
            (string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal)) > 0) and
            (string-length(normalize-space(gmd:southBoundLatitude/gco:Decimal)) > 0) and
            (string-length(normalize-space(gmd:westBoundLongitude/gco:Decimal)) > 0) and
            (string-length(normalize-space(gmd:eastBoundLongitude/gco:Decimal)) > 0)">
            <xsl:variable name="spatialString">
                <xsl:value-of
                    select="normalize-space(concat('northlimit=',gmd:northBoundLatitude/gco:Decimal,'; southlimit=',gmd:southBoundLatitude/gco:Decimal,'; westlimit=',gmd:westBoundLongitude/gco:Decimal,'; eastLimit=',gmd:eastBoundLongitude/gco:Decimal))"/>

                <xsl:if
                    test="
                    (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real)) > 0) and
                    (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real)) > 0)">
                    <xsl:value-of
                        select="normalize-space(concat('; uplimit=',gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real,'; downlimit=',gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real))"
                    />
                </xsl:if>
                <xsl:if test="string-length($code) > 0">
                    <xsl:value-of select="concat('; projection=', $code)"/>
                </xsl:if>
            </xsl:variable>
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>iso19139dcmiBox</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$spatialString"/>
                </spatial>
                <!--spatial>
                    <xsl:attribute name="type">
                        <xsl:text>text</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$spatialString"/>
                </spatial-->
            </coverage>
        </xsl:if>
    </xsl:template>


    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_BoundingPolygon" mode="IMAS_registryObject_coverage_spatial">
        <xsl:if
            test="string-length(normalize-space(gmd:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates))  > 0">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>gmlKmlPolyCoords</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of
                        select="replace(normalize-space(gmd:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates), ',0', '')"
                    />
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:extent" mode="IMAS_registryObject_coverage_temporal">
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0 or
                      string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
        
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:extent" mode="IMAS_registryObject_existence_dates">
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
            <existenceDates>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                    <startDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                        />
                    </startDate>
                </xsl:if>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                    <endDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                        />
                    </endDate>
                </xsl:if>
            </existenceDates>
        </xsl:if>
        
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
            <existenceDates>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0">
                    <startDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:beginPosition)"
                        />
                    </startDate>
                </xsl:if>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
                    <endDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:endPosition)"
                        />
                    </endDate>
                </xsl:if>
            </existenceDates>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - RelatedInfo Element  -->
    <!--xsl:template match="gmd:MD_DigitalTransferOptions" mode="IMAS_registryObject_relatedInfo">
        <xsl:for-each select="gmd:onLine/gmd:CI_OnlineResource">

            <xsl:variable name="protocol" select="normalize-space(gmd:protocol)"/>
            <xsl:if test="(string-length($protocol) > 0) and 
                not(contains($protocol, 'metadata-URL')) and
                not(contains($protocol, 'get-map')) and
                not(contains($protocol, 'get-capabilities')) and
                not(contains($protocol, 'downloaddata'))">

                <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
                <xsl:if test="string-length($identifierValue) > 0">
                    <relatedInfo>
                        <identifier>
                            <xsl:attribute name="type">
                                <xsl:choose>
                                    <xsl:when test="contains($identifierValue, 'doi')">
                                        <xsl:text>doi</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>uri</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of select="$identifierValue"/>
                        </identifier>

                        <xsl:choose>
                            <xsl:when test="string-length(normalize-space(gmd:name)) > 0">
                                <title>
                                    <xsl:value-of select="normalize-space(gmd:name)"/>
                                </title>
                                <xsl:if test="string-length(normalize-space(gmd:description)) > 0">
                                    <notes>
                                        <xsl:value-of select="normalize-space(gmd:description)"/>
                                    </notes>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="string-length(normalize-space(gmd:description)) > 0">
                                    <title>
                                        <xsl:value-of select="normalize-space(gmd:description)"/>
                                    </title>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>

                    </relatedInfo>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template-->
    
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:CI_OnlineResource" mode="IMAS_registryObject_relatedInfo">        
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        <xsl:variable name="protocol" select="normalize-space(gmd:protocol)"/>
        
        <xsl:if test="$global_debug">
            <xsl:if test="custom:strContainsSequenceSubset($identifierValue, $global_IMAS_onlineResourceUrlSubset_sequence)">
                <xsl:message select="concat('Ignoring onlineResource url: ', $identifierValue)"/>
            </xsl:if>
            
            <xsl:if test="custom:strContainsSequenceSubset($protocol, $global_IMAS_ignoreOnlineResourceProtocolSubset_sequence)">
                <xsl:message select="concat('Ignoring onlineResource protocol: ', $protocol)"/>
            </xsl:if>
        </xsl:if>
        
        <xsl:if test="
            not(custom:strContainsSequenceSubset($identifierValue, $global_IMAS_onlineResourceUrlSubset_sequence)) and
            not(custom:strContainsSequenceSubset($protocol, $global_IMAS_ignoreOnlineResourceProtocolSubset_sequence))">
        
             <xsl:choose>
                 <xsl:when test="
                     contains(gmd:protocol, 'OGC:') or 
                     contains(lower-case(gmd:linkage/gmd:URL), 'thredds') or
                     (contains(lower-case(gmd:protocol), 'downloaddata') and contains(lower-case(gmd:linkage/gmd:URL), '?'))">
                     <xsl:apply-templates select="." mode="IMAS_relatedInfo_service"/>
                 </xsl:when>
                 <xsl:when test="(contains(lower-case(gmd:protocol), 'publication')) or (contains(gmd:description, 'PUBLICATION'))">
                     <xsl:apply-templates select="." mode="IMAS_relatedInfo_publication"/>
                 </xsl:when>
                 <xsl:when test="(not(contains(lower-case(gmd:protocol), 'metadata-url'))) and (not(contains(gmd:protocol, 'downloaddata')))">
                     <xsl:apply-templates select="." mode="IMAS_relatedInfo_relatedInformation"/>
                 </xsl:when>
                 
             </xsl:choose>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="IMAS_relatedInfo_service">       
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        
            <relatedInfo>
                <xsl:attribute name="type" select="'service'"/>   
                
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>supports</xsl:text>
                    </xsl:attribute>
                    <xsl:if test="(contains($identifierValue, '?')) or (contains($identifierValue, '.nc'))">
                        <url>
                            <xsl:value-of select="$identifierValue"/>
                        </url>
                    </xsl:if>
                </relation>
                
                <xsl:apply-templates select="." mode="IMAS_relatedInfo_all"/>
            </relatedInfo>

    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="IMAS_relatedInfo_publication">       
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        
        <relatedInfo>
            <xsl:attribute name="type" select="'publication'"/>   
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>isCitedBy</xsl:text>
                </xsl:attribute>
                <xsl:if test="(contains($identifierValue, '?'))">
                    <url>
                        <xsl:value-of select="$identifierValue"/>
                    </url>
                </xsl:if>
            </relation>
            
            <xsl:apply-templates select="." mode="IMAS_relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="IMAS_relatedInfo_relatedInformation">       
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        
        <relatedInfo>
            <xsl:attribute name="type" select="'relatedInformation'"/>   
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>hasAssociationWith</xsl:text>
                </xsl:attribute>
                <xsl:if test="(contains($identifierValue, '?'))">
                    <url>
                        <xsl:value-of select="replace($identifierValue, ':/\(?=[^/]\)', '/')"/>
                    </url>
                </xsl:if>
            </relation>
            
            <xsl:apply-templates select="." mode="IMAS_relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
    
    <xsl:template match="gmd:CI_OnlineResource" mode="IMAS_relatedInfo_all">     
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        
            <identifier>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="contains(lower-case($identifierValue), 'doi')">
                            <xsl:text>doi</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>uri</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="contains($identifierValue, '?')">
                        <xsl:value-of select="substring-before(., '?')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$identifierValue"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </identifier>
            
            <xsl:choose>
                <!-- Use description as title if we have it... -->
                <xsl:when test="string-length(normalize-space(gmd:description)) > 0">
                    <title>
                        <xsl:value-of select="normalize-space(gmd:description)"/>
                        
                        <!-- ...and then name in brackets following -->
                        <xsl:if
                            test="string-length(normalize-space(gmd:name)) > 0">
                            <xsl:value-of select="concat(' (', gmd:name, ')')"/>
                        </xsl:if>
                    </title>
                </xsl:when>
                <!-- No description, so use name as title if we have it -->
                <xsl:otherwise>
                    <xsl:if
                        test="string-length(normalize-space(gmd:name)) > 0">
                        <title>
                            <xsl:value-of select="concat('(', gmd:name, ')')"/>
                        </title>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="mcp:childIdentifier" mode="IMAS_registryObject_relatedInfo">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedInfo type="collection">
                <identifier type="uri">
                    <xsl:value-of
                        select="concat($global_IMAS_sourceURL, $global_IMAS_path, $identifier)"/>
                </identifier>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
                <xsl:if test="string-length(normalize-space(@title)) > 0"/>
                <title>
                    <xsl:value-of select="normalize-space(@title)"/>
                </title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>

    <xsl:template match="srv:operatesOn" mode="IMAS_registryObject_relatedInfo">
        <xsl:variable name="abstract"
            select="normalize-space(gmd:MD_DataIdentification/gmd:abstract)"/>

        <xsl:variable name="uri">
            <xsl:if test="string-length($abstract) > 0">
                <xsl:copy-of
                    select="substring-before(substring-after($abstract, &quot;href=&quot;&quot;&quot;), &quot;&amp;&quot;)"
                />
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="uuid">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(@uuidref)) > 0">
                    <xsl:value-of select="normalize-space(@uuidref)"/>
                </xsl:when>
                <xsl:when test="(string-length($abstract) > 0) and contains($abstract, 'uuid')">
                    <xsl:value-of
                        select="substring-before(substring-after($abstract, &quot;uuid=&quot;), &quot;&amp;&quot;)"
                    />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if
            test="((string-length($uri) > 0) and contains($uri, 'http')) or (string-length($uuid) > 0)">
            <relatedInfo type="activity">
                <xsl:if test="((string-length($uri) > 0) and contains($uri, 'http'))">
                    <identifier type="uri">
                        <xsl:value-of select="$uri"/>
                    </identifier>
                </xsl:if>

                <xsl:if test="(string-length($uuid) > 0)">
                    <!--identifier type="global">
                        <xsl:value-of select="concat($global_IMAS_groupAcronym,'/', $uuid)"/>
                    </identifier-->
                    <xsl:variable name="constructedUri"
                        select="concat($global_IMAS_sourceURL, $global_IMAS_path, $uuid)"/>

                    <xsl:if test="$constructedUri != $uri">
                        <identifier type="uri">
                            <xsl:value-of select="$constructedUri"/>
                        </identifier>
                    </xsl:if>

                </xsl:if>

                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>supports</xsl:text>
                    </xsl:attribute>
                </relation>
                <xsl:variable name="title"
                    select="normalize-space(gmd:MD_DataIdentification/gmd:citation/gmd:title)"/>
                <xsl:if test="string-length($title) > 0"/>
                <title>
                    <xsl:value-of select="$title"/>
                </title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Rights Licence - From CreativeCommons -->
    <xsl:template match="mcp:MD_CreativeCommons" mode="IMAS_registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(mcp:licenseLink/gmd:URL)"/>
        <xsl:variable name="licenseName" select="normalize-space(*:licenseName)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="(lower-case(replace($licenseLink, '\d.\d|/', '')) = normalize-space(lower-case(replace(gml:remarks, '\{n\}|/', ''))))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space($licenseName)) > 0">
                                <xsl:value-of select="normalize-space($licenseName)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <!--xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.))">
                <rights>
                    <licence>
                        <xsl:value-of select='normalize-space(.)'/>
                    </licence>
                </rights>
            </xsl:if>
        </xsl:for-each-->
    </xsl:template>

    <!-- RegistryObject - Rights RightsStatement - From CreativeCommons -->
    <xsl:template match="mcp:MD_CreativeCommons"
        mode="IMAS_registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="mcp:attributionConstraints">
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - Rights Licence - From CreativeCommons -->
    <xsl:template match="mcp:MD_Commons" mode="IMAS_registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(mcp:licenseLink/gmd:URL)"/>
        <xsl:variable name="licenseName" select="normalize-space(*:licenseName)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="(lower-case(replace($licenseLink, '\d.\d|/', '')) = normalize-space(lower-case(replace(gml:remarks, '\{n\}|/', ''))))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space($licenseName)) > 0">
                                <xsl:value-of select="normalize-space($licenseName)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <!--xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.))">
            <rights>
            <licence>
            <xsl:value-of select='normalize-space(.)'/>
            </licence>
            </rights>
            </xsl:if>
            </xsl:for-each-->
    </xsl:template>

    <!-- RegistryObject - Rights RightsStatement - From CreativeCommons -->
    <xsl:template match="mcp:MD_Commons" mode="IMAS_registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="gmd:useLimitation">
            <xsl:if test="(string-length(normalize-space(.)) > 0)">
            <rights>
                <rightsStatement>
                    <xsl:value-of select="normalize-space(.)"/>
                </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>   
        <xsl:for-each select="*:otherConstraints">
            <xsl:if test="(string-length(normalize-space(.)) > 0)">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>   
        <xsl:for-each select="mcp:attributionConstraints">
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="(string-length(normalize-space(.)) > 0) and
                    not(contains(., global_IMAS_cannedCitation))">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="gmd:MD_Constraints" mode="IMAS_registryObject_rights_rightsStatement">
        <xsl:variable name="useLimitation_sequence" as="xs:string*">
            <xsl:for-each select="gmd:useLimitation">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($useLimitation_sequence)">
            <xsl:variable name="useLimitation" select="normalize-space(.)"/>
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($useLimitation) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$useLimitation"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
        <xsl:if test="not(exists(gmd:accessConstraints))">
            <xsl:for-each select="gmd:otherConstraints">
                <xsl:variable name="otherConstraints" select="normalize-space(.)"/>
                <!-- If there is text in other contraints, use this; otherwise, do nothing -->
                <xsl:if test="string-length($otherConstraints) > 0">
                    <rights>
                        <rightsStatement>
                            <xsl:value-of select="$otherConstraints"/>
                        </rightsStatement>
                    </rights>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>

    </xsl:template>
    
    <!-- RegistryObject - Rights AccessRights Element -->
    <xsl:template match="gmd:MD_Constraints" mode="IMAS_registryObject_rights_accessRights">
        <xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <accessRights>
                        <xsl:value-of select="normalize-space(.)"/>
                    </accessRights>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="IMAS_registryObject_rights_rightsStatement">
        <xsl:for-each select="gmd:useLimitation">
            <xsl:variable name="useLimitation" select="normalize-space(.)"/>
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($useLimitation) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$useLimitation"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
        <xsl:if test="not(exists(gmd:accessConstraints))">
            <xsl:for-each select="gmd:otherConstraints">
                <xsl:variable name="otherConstraints" select="normalize-space(.)"/>
                <!-- If there is text in other contraints, use this; otherwise, do nothing -->
                <xsl:if test="string-length($otherConstraints) > 0">
                    <xsl:for-each select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition">
                        <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                            <xsl:if test="contains($otherConstraints, gml:remarks)">
                                <!--xsl:message>Identifier <xsl:value-of select='gml:identifier'/></xsl:message-->
                                <!--xsl:message>Remarks <xsl:value-of select='gml:remarks'/></xsl:message-->
                                <rights>
                                    <licence>
                                     <xsl:attribute name="type" select="gml:identifier"/>
                                     <xsl:attribute name="rightsUri" select="gml:remarks"/>
                                     <xsl:value-of select="$otherConstraints"/>
                                    </licence>
                                </rights>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                    
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Rights AccessRights Element -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="IMAS_registryObject_rights_accessRights">
        <xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <accessRights>
                        <xsl:value-of select="normalize-space(.)"/>
                    </accessRights>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template name="IMAS_registryObject_citationMetadata_citationInfo">
        <xsl:param name="metadataURL"/>
        <xsl:param name="imasDataCatalogueURL"/>
        <xsl:param name="dataSetURI"/>
        <xsl:param name="originatingSourceOrganisation"/>
        <xsl:param name="publishingOrganisation"/>
        <xsl:param name="citation"/>
        <xsl:param name="citationContributorName_sequence" as="xs:string*"/>
         <xsl:param name="metadataCreationDate"/>


        <xsl:variable name="CI_Citation" select="." as="node()"/>

              <xsl:variable name="doiIdentifier_sequence" as="xs:string*" select="customIMAS:doiFromIdentifiers(gmd:identifier/gmd:MD_Identifier/gmd:code)"/>
        
        <xsl:variable name="identifierToUse">
            <xsl:choose>
            <xsl:when
                    test="count($doiIdentifier_sequence) and string-length($doiIdentifier_sequence[1])">
                <xsl:value-of select="$doiIdentifier_sequence[1]"/>
                    </xsl:when>
                        <xsl:when test="string-length($metadataURL) > 0">
                            <identifier>
                                <xsl:attribute name="type">
                                    <xsl:text>uri</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$metadataURL"/>
                            </identifier>
                        </xsl:when>
                        <xsl:when test="string-length($imasDataCatalogueURL) > 0">
                            <identifier>
                                <xsl:attribute name="type">
                                    <xsl:text>uri</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$imasDataCatalogueURL"/>
                            </identifier>
                        </xsl:when>
                        </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeToUse">
            <xsl:choose>
                <xsl:when
 test="count($doiIdentifier_sequence) and string-length($doiIdentifier_sequence[1])">
                            <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="count($citationContributorName_sequence) > 0">
            <citationInfo>
                <citationMetadata>
                    <xsl:if test="string-length($identifierToUse)">
                        <identifier>
                                <xsl:if test="string-length($typeToUse)">
                                <xsl:attribute name="type">
                                    <xsl:value-of select="$typeToUse"/>
                                </xsl:attribute>
                                </xsl:if>
                            <xsl:value-of select="$identifierToUse"/>
                            </identifier>
                        </xsl:if>
                    

<title>
                        <xsl:value-of select="gmd:title"/>
                    </title>

                    <xsl:variable name="current_CI_Citation" select="."/>
                    <xsl:variable name="CI_Date_sequence" as="node()*">
                        <xsl:variable name="type_sequence" as="xs:string*"
                            select="'publication,revision,creation'"/>
                        <xsl:for-each select="tokenize($type_sequence, ',')">
                            <xsl:variable name="type" select="."/>
                            <xsl:for-each select="$current_CI_Citation/gmd:date/gmd:CI_Date">
                                <xsl:variable name="code"
                                    select="normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
                                <xsl:if test="contains(lower-case($code), $type)">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>


                    <xsl:variable name="codelist"
                        select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>

                    <xsl:variable name="dateType">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:variable name="codevalue"
                                select="$CI_Date_sequence[1]/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                            <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                        </xsl:if>
                    </xsl:variable>

                    <xsl:variable name="dateValue">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:if test="string-length($CI_Date_sequence[1]/gmd:date/gco:Date) > 3">
                                <xsl:value-of
                                    select="substring($CI_Date_sequence[1]/gmd:date/gco:Date, 1, 4)"
                                />
                            </xsl:if>
                            <xsl:if
                                test="string-length($CI_Date_sequence[1]/gmd:date/gco:DateTime) > 3">
                                <xsl:value-of
                                    select="substring($CI_Date_sequence[1]/gmd:date/gco:DateTime, 1, 4)"
                                />
                            </xsl:if>
                        </xsl:if>
                    </xsl:variable>

                    <xsl:choose>
                        <xsl:when test="(string-length($dateType) > 0) and (string-length($dateValue) > 0)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="$dateType"/>
                                </xsl:attribute>
                                <xsl:value-of select="$dateValue"/>
                            </date>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string-length($metadataCreationDate) > 3">
                                <date>
                                    <xsl:attribute name="type">
                                        <xsl:text>publicationDate</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="substring($metadataCreationDate, 1, 4)"/>
                                </date>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:choose>
                        <xsl:when test="count($citationContributorName_sequence)">
                            <xsl:for-each select="distinct-values($citationContributorName_sequence)">
                                <contributor>
                                    <namePart>
                                        <xsl:value-of select="."/>
                                    </namePart>
                                </contributor>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>

                    <xsl:if test="string-length($publishingOrganisation) > 0">
                        <publisher>
                            <xsl:value-of select="$publishingOrganisation"/>
                        </publisher>
                    </xsl:if>

                </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>

    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="IMAS_party">
        <xsl:param name="type"/>
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="groupToUse"/>
        <registryObject>
            <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>

            <xsl:variable name="name" select="normalize-space(current-grouping-key())"/>
            <!-- Name is to be 'surname,firstname' or 'surname,i', to attempt to reduce replicated records -->
            <key>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(customIMAS:nameNoTitle($name),' ',''))"/>
            </key>

            <originatingSource>
                <xsl:value-of select="$originatingSourceURL"/>
            </originatingSource>

            <!-- Use the party type provided, except for exception:
                    Because sometimes AIMS is used for an author, appearing in individualName,
                    we want to make sure that we use 'group', not 'person', if this anomoly occurs -->

            <xsl:variable name="typeToUse">
               <xsl:choose>
                   <xsl:when test="boolean(customIMAS:isKnownOrganisation($name)) = true()">
                        <!--xsl:message select="concat('Is known organisation ', $transformedName)"/-->
                        <xsl:text>group</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$type"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:if test="$global_debug">
                <xsl:message select="concat('name:', $name)"/>
                <xsl:message select="concat('type:', $type)"/>
                <xsl:message select="concat('typeToUse:', $typeToUse)"/>
            </xsl:if>
            
            <party type="{$typeToUse}">
                
                <identifier type="global">
                    <xsl:value-of select="translate(customIMAS:nameNoTitle($name),' ','')"/>
                </identifier>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="$name"/>
                    </namePart>
                </name>

                <!-- If we have are dealing with individual who has an organisation name:
                    - leave out the address (so that it is on the organisation only); and 
                    - relate the individual to the organisation -->

                <!-- If we are dealing with an individual...-->
                <xsl:choose>
                    <xsl:when test="contains($type, 'person')">
                        <xsl:variable name="organisationName" select="normalize-space(gmd:organisationName[1])"/>
                     
                        <xsl:choose>
                            <xsl:when
                                test="string-length($organisationName) > 0">
                                <!--  Individual has an organisation name, so relate the individual to the organisation, and omit the address 
                                        (the address will be included within the organisation to which this individual is related) -->
                                <relatedObject>
                                    <key>
                                        <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space($organisationName),' ',''))"/>
                                    </key>
                                    <relation type="isMemberOf"/>
                                </relatedObject>
                            </xsl:when>

                         </xsl:choose>

                        <!-- Individual - Phone and email on the individual, regardless of whether there's an organisation name -->
                        <xsl:call-template name="IMAS_telephone"/>
                        <xsl:call-template name="IMAS_facsimile"/>
                        <xsl:call-template name="IMAS_email"/>
                        <xsl:call-template name="IMAS_onlineResource"/>
                        <xsl:call-template name="IMAS_physicalAddress"/>

                    </xsl:when>
                    <xsl:otherwise>
                        <!-- If we are dealing with an Organisation with no individual name, phone and email must pertain to this organisation -->
                        <xsl:variable name="individualName"
                            select="normalize-space(gmd:individualName)"/>
                        <xsl:if test="string-length($individualName) = 0">
                            <xsl:call-template name="IMAS_telephone"/>
                            <xsl:call-template name="IMAS_facsimile"/>
                            <xsl:call-template name="IMAS_email"/>
                            <xsl:call-template name="IMAS_onlineResource"/>
                            <xsl:call-template name="IMAS_physicalAddress"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </party>
        </registryObject>
    </xsl:template>

    <xsl:template name="IMAS_physicalAddress">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)">

                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString[string-length(text()) > 0]">
                                     <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </xsl:for-each>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)) > 0">
                                      <addressPart type="suburbOrPlaceLocality">
                                          <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)"/>
                                      </addressPart>
                                 </xsl:if>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)) > 0">
                                     <addressPart type="stateOrTerritory">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)"/>
                                     </addressPart>
                                 </xsl:if>
                                     
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)) > 0">
                                     <addressPart type="postCode">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)"/>
                                     </addressPart>
                                 </xsl:if>
                                 
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)) > 0">
                                     <addressPart type="country">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)"/>
                                     </addressPart>
                                 </xsl:if>
                            </physical>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="IMAS_telephone">
        <xsl:variable name="phone_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each
                    select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($phone_sequence)">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart type="telephoneNumber">
                            <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="IMAS_facsimile">
        <xsl:variable name="facsimile_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each
                    select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($facsimile_sequence)">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart type="faxNumber">
                            <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="IMAS_email">
        <xsl:variable name="email_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each
                    select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($email_sequence)">
            <location>
                <address>
                    <electronic type="email">
                        <value>
                            <xsl:value-of select="normalize-space(.)"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="IMAS_onlineResource">
        <xsl:variable name="url_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each
                    select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($url_sequence)">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="contains(lower-case(.), 'orcid')">
                            <xsl:text>orcid</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(lower-case(.), 'doi')">
                            <xsl:text>doi</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>uri</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </identifier>
        </xsl:for-each>
    </xsl:template>




    <!-- Modules -->

    <xsl:function name="customIMAS:isKnownOrganisation">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when
                test="
                contains($name, 'Institute for Marine and Antarctic Studies') or
                contains($name, 'University of Tasmania') or
                contains($name, 'Institute for Marine &amp; Antarctic Studies') or 
                contains($name, 'Integrated Marine Observing System') or
                contains($name, 'Australian Institute of Marine Science') or
                contains($name, 'Australian Antarctic Data Centre') or
                contains($name, 'Australian Antarctic Division') or
                contains($name, 'CSIRO Marine and Atmospheric Research') or
                contains($name, 'Commonwealth Scientific and Industrial Research Organisation')">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

   <xsl:function name="customIMAS:doiFromIdentifiers">
        <xsl:param name="identifier_sequence"/>
        <xsl:for-each select="distinct-values($identifier_sequence)">
            <xsl:if test="contains(lower-case(normalize-space(.)), 'doi')">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    

   <xsl:function name="customIMAS:getOrgNameFromBaseURI" as="xs:string">
        <xsl:param name="inputString"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($inputString), 'imas')">
                <xsl:text>Institute for Marine and Antarctic Studies, University of Tasmania</xsl:text>
            </xsl:when>
            <xsl:when test="contains($inputString, 'imos')">
                <xsl:text>Integrated Marine Observing System (IMOS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains($inputString, 'aad.gov.au')">
                <xsl:text>Australian Antarctic Data Centre (AADC)</xsl:text>
            </xsl:when>
            <xsl:when test="contains($inputString, 'aims.gov.au')">
                <xsl:text>Australian Institute of Marine Science (AIMS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains($inputString, 'csiro.au')">
                <xsl:text>Commonwealth Scientific and Industrial Research Organisation (CSIRO)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="customIMAS:getBaseURI">
        <xsl:param name="inputString"/>
        <!-- Match will match the uri up to the third forward slash, e.g. it will match "http(s)://data.aims.gov.au/"
            from examples like the following:  http(s)://http://data.aims.gov.au// http(s)://http://data.aims.gov.au//morethings http(s)://http://data.aims.gov.au/more/stuff/-->
        <xsl:variable name="match">
            <xsl:analyze-string select="normalize-space($inputString)"
                regex="(http:|https:)//(\S+?)(/)">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(0)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="(string-length($match) > 0) and (substring($match, string-length($match), 1) = '/')">
                <xsl:value-of select="substring($match, 1, string-length($match)-1)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- If we didn't match that pattern, just include the entire thing - rare but possible -->
                <xsl:value-of select="normalize-space($inputString)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="IMAS_getRegistryObjectTypeSubType" as="xs:string*">
        <xsl:param name="scopeCode"/>
        <xsl:param name="publishingOrganisation"/>
        <xsl:choose>
            <xsl:when test="contains($scopeCode, 'nonGeographicDataset')">
                <xsl:text>collection</xsl:text>
                <xsl:text>publication</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'collectionSession')">
                <xsl:text>activity</xsl:text>
                <xsl:text>program</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'series')">
                <xsl:text>activity</xsl:text>
                <xsl:text>program</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'fieldSession')">
                <xsl:text>activity</xsl:text>
                <xsl:text>project</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'collectionHardware')">
                <xsl:text>activity</xsl:text>
                <xsl:text>project</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'service')">
                <xsl:text>service</xsl:text>
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'software')">
                <xsl:text>collection</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'model')">
                <xsl:text>collection</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'model')">
                <xsl:text>collection</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:message>Defaulting due to unknown scope code <xsl:value-of select="$scopeCode"></xsl:value-of></xsl:message-->
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    
    <xsl:function name="customIMAS:currentHasRole" as="xs:boolean*">
        <xsl:param name="current"/>
        <xsl:param name="role"/>
        <xsl:for-each-group select="$current/gmd:role"
            group-by="gmd:CI_RoleCode/@codeListValue">
            <xsl:if test="(string-length($role) > 0) and contains(current-grouping-key(), $role)">
                <xsl:value-of select="true()"/>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:function>

    <!-- Finds name of organisation with particular role - ignores organisations that don't have an individual name -->
    <xsl:function name="customIMAS:getOrganisationNameSequence">
        <xsl:param name="parent" as="node()"/>
        <xsl:param name="role_sequence" as="xs:string*"/>
        <!--xsl:message>getOrganisationNameSequence - Parent: <xsl:value-of select="name($parent)"/>, Num roles: <xsl:value-of select="count($role_sequence)"/></xsl:message-->

        <!-- Return organisation name of party, only if no individual name.  If role is provided, only return organisation name if role of party matches that provided -->
        <xsl:choose>
            <xsl:when test="(count($role_sequence) > 0)">
                <xsl:for-each select="tokenize($role_sequence, ',')">
                    <xsl:variable name="role" select="normalize-space(.)"/>
                    <!--xsl:message select="concat('Role: ', $role)"/-->
                    
                    <xsl:for-each-group
                        select="$parent/descendant::gmd:CI_ResponsibleParty[
                        (string-length(normalize-space(gmd:organisationName[1])) > 0) and 
                        (string-length(normalize-space(gmd:individualName))) > 0]"
                        group-by="gmd:organisationName">

                        <xsl:variable name="organisationName" select="normalize-space(current-grouping-key())"/>
                        
                        <xsl:choose>
                            <xsl:when test="string-length($role) > 0">
                                <xsl:variable name="userHasRole_sequence" as="xs:boolean*" select="customIMAS:currentHasRole(current-group(), $role)"/>
                                <xsl:if test="count($userHasRole_sequence)">
                                    <!--xsl:message>getOrganisationNameSequence - Returning 
                                        <xsl:value-of select="$organisationName"/> 
                                        for role
                                        <xsl:value-of select="$role"/>
                                    </xsl:message-->
                                    <xsl:value-of select="$organisationName"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- No role specified, so return the name -->
                                <!--xsl:message>Role is empty</xsl:message-->
                                <!--xsl:message>getOrganisationNameSequence - Returning 
                                    <xsl:value-of select="$organisationName"/> 
                                    for no role
                                </xsl:message-->
                                <xsl:if test="string-length($organisationName) > 0">
                                    <xsl:value-of select="$organisationName"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <!-- Finds name of organisation for an individual of a particular role - whether or not there in an individual name -->
    <xsl:function name="customIMAS:getAllOrganisationNameSequence">
        <xsl:param name="parent" as="node()"/>
        <xsl:param name="role_sequence" as="xs:string*"/>
        <!--xsl:message>getAllOrganisationNameSequence - Parent: <xsl:value-of select="name($parent)"/>, Num roles: <xsl:value-of select="count($role_sequence)"/></xsl:message-->

        <!-- Return organisation name of party, even if an individual name exists, too.  If role is provided, only return organisation name if role of party matches that provided -->
        <xsl:choose>
            <xsl:when test="(count($role_sequence) > 0)">
                <!--xsl:message select="concat('Number of roles: ', count($role_sequence))"/-->
                <xsl:for-each select="tokenize($role_sequence, ',')">
                    <xsl:variable name="role" select="normalize-space(.)"/>
                    <!--xsl:message select="concat('Role: ', $role)"/-->
                    
                    <xsl:for-each-group
                        select="$parent/descendant::gmd:CI_ResponsibleParty[
                        (string-length(normalize-space(gmd:organisationName[1])) > 0)]"
                        group-by="gmd:organisationName">
                        
                        <!--xsl:message>For each...</xsl:message-->

                        <xsl:variable name="organisationName" select="normalize-space(current-grouping-key())"/>
                    
                        <xsl:choose>
                            <xsl:when test="string-length($role) > 0">
                                <xsl:variable name="userHasRole_sequence" as="xs:boolean*" select="customIMAS:currentHasRole(current-group(), $role)"/>
                                <xsl:if test="count($userHasRole_sequence)">
                                    <!--xsl:message>getAllOrganisationNameSequence - Returning 
                                        <xsl:value-of select="$organisationName"/> 
                                        for role
                                        <xsl:value-of select="$role"/>
                                    </xsl:message-->
                                    <xsl:value-of select="$organisationName"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- No role specified, so return the name -->
                                <!--xsl:message>getAllOrganisationNameSequence - Returning 
                                    <xsl:value-of select="$organisationName"/> 
                                    for no role
                                </xsl:message-->
                                <xsl:if test="string-length($organisationName) > 0">
                                    <xsl:value-of select="$organisationName"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="customIMAS:getIndividualNameSequence" as="xs:string*">
        <xsl:param name="parent" as="node()"/>
        <xsl:param name="role_sequence" as="xs:string"/>
        <!--xsl:message>getIndividualNameSequence - Parent: <xsl:value-of select="name($parent)"/>, Num roles: <xsl:value-of select="count($role_sequence)"/></xsl:message-->
        
        <!-- Return individual name of party.  If role is provided, only return individual name if role of party matches that provided -->
        <xsl:choose>
            <xsl:when test="(count($role_sequence) > 0)">
                <xsl:for-each select="tokenize($role_sequence, ',')">
                    <xsl:variable name="role" select="normalize-space(.)"/>
                    <!--xsl:message select="concat('Role: ', $role)"/-->
                    
                    <xsl:for-each-group
                        select="$parent/descendant::gmd:CI_ResponsibleParty[
                        (string-length(normalize-space(gmd:individualName)) > 0)]"
                        group-by="gmd:individualName">

                        <xsl:choose>
                            <xsl:when test="string-length($role) > 0">
                                <xsl:variable name="userHasRole_sequence" as="xs:boolean*" select="customIMAS:currentHasRole(current-group(), $role)"/>
                                <xsl:if test="count($userHasRole_sequence)">
                                    <!--xsl:message>getIndividualNameSequence - Returning 
                                        <xsl:value-of select="normalize-space(current-grouping-key())"/> 
                                        for role
                                        <xsl:value-of select="$role"/>
                                    </xsl:message-->
                                    <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- No role specified, so return the name -->
                                <xsl:if
                                    test="string-length(normalize-space(current-grouping-key())) > 0">
                                    <!--xsl:message>getIndividualNameSequence - Returning 
                                        <xsl:value-of select="normalize-space(current-grouping-key())"/> 
                                        for no role
                                    </xsl:message-->
                                    <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customIMAS:getTransformedOriginatingSourceOrganisation">
        <xsl:param name="inputString"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($inputString), 'imas')">
                <xsl:text>Institute for Marine and Antarctic Studies, University of Tasmania</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'imos')">
                <xsl:text>Integrated Marine Observing System (IMOS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'aims')">
                <xsl:text>Australian Institute of Marine Science (AIMS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'aad')">
                <xsl:text>Australian Antarctic Data Centre (AADC)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'cmar') or 
                contains(lower-case($inputString), 'csiro')">
                <xsl:text>Commonwealth Scientific and Industrial Research Organisation (CSIRO)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$inputString"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customIMAS:getTransformedPublisher">
        <xsl:param name="inputString"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($inputString), 'imas')">
                <xsl:text>Institute for Marine and Antarctic Studies, University of Tasmania</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'imos')">
                <xsl:text>Integrated Marine Observing System (IMOS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'aims')">
                <xsl:text>Australian Institute of Marine Science (AIMS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'aad')">
                <xsl:text>Australian Antarctic Data Centre (AADC)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($inputString), 'cmar') or 
                contains(lower-case($inputString), 'csiro')">
                <xsl:text>Commonwealth Scientific and Industrial Research Organisation (CSIRO)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$inputString"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
   <!--xsl:function name="customIMAS:nameNoTitle">
        <xsl:param name="name"/>
        <xsl:variable name="extractedTitle_sequence" select="customIMAS:extractTitle($name)"/>
        <xsl:choose>
            <xsl:when test="count($extractedTitle_sequence) > 0">
                <xsl:message select="concat('Name before extract:', $name)"/>
                <xsl:variable name="temp">
                    <xsl:for-each select="distinct-values($extractedTitle_sequence)">
                        <xsl:value-of select="replace($name, ., '')"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="nameNoTitle" select="normalize-space(translate($temp, '.', ''))"/>
                <xsl:choose>
                 <xsl:when test="substring($nameNoTitle, string-length($nameNoTitle), 1) = ','">
                     <xsl:message select="concat('Returning:', substring($nameNoTitle, 1, string-length($nameNoTitle)-1))"/>
                     <xsl:value-of select="substring($nameNoTitle, 1, string-length($nameNoTitle)-1)"/>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:message select="concat('Returning nameNoTitle:', $nameNoTitle)"/>
                     <xsl:value-of select="$nameNoTitle"/>
                 </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
   </xsl:function-->
    
    <xsl:function name="customIMAS:nameNoTitle">
        <xsl:param name="name"/>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Name before extract:', $name)"/>
        </xsl:if>
        
        <xsl:variable name="temp" select="replace($name, '(Miss|Mr|Mrs|Ms|Dr|PhD|Assoc/Prof|Professor|Prof)', '')"/>
        <xsl:variable name="nameNoTitle" select="normalize-space(translate($temp, '.', ''))"/>
        <xsl:choose>
            <xsl:when test="substring($nameNoTitle, string-length($nameNoTitle), 1) = ','">
                <xsl:if test="$global_debug">
                    <xsl:message select="concat('Returning without last comma: ', substring($nameNoTitle, 1, string-length($nameNoTitle)-1))"/>
                </xsl:if>
                <xsl:value-of select="substring($nameNoTitle, 1, string-length($nameNoTitle)-1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$global_debug">
                    <xsl:message select="concat('Returning nameNoTitle: ', $nameNoTitle)"/>
                </xsl:if>
                <xsl:value-of select="$nameNoTitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customIMAS:extractTitle" as="xs:string*">
        <xsl:param name="name"/>
       <xsl:analyze-string select="$name"
            regex="(Miss|Mr|Mrs|Ms|Dr|PhD|Assoc/Prof|Professor|Prof)">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(0)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
   <xsl:function name="customIMAS:getMetadataTruthURL_sequence" as="xs:string*">
        <xsl:param name="transferOptions"/>
        
        <xsl:variable name="metadataTruth_sequence" as="xs:string*">
            <xsl:for-each select="$transferOptions/gmd:onLine/gmd:CI_OnlineResource">
                <xsl:if test="contains(gmd:protocol, 'http--metadata-URL')">
                    <xsl:value-of select="normalize-space(gmd:linkage/gmd:URL)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:if test="count($metadataTruth_sequence) > 0">
            <xsl:copy-of select="$metadataTruth_sequence[1]"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
