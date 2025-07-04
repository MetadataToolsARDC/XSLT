<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:csw="http://www.opengis.net/cat/csw"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0" 
    xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0" 
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0" 
    xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0" 
    xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0" 
    xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0" 
    xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0" 
    xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0" 
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0" 
    xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0" 
    xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0" 
    xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0" 
    xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0" 
    xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0" 
    xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0" 
    xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0" 
    xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0" 
    xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0" 
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0" 
    xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0" 
    xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0" 
    xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0" 
    xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0" 
    xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0" 
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0" 
    xmlns:gml="http://www.opengis.net/gml/3.2" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs csw fn lan mrc xlink srv mrd mas mri mcc mrl xs mco mrs xsi mda msr mdb mds mdq cat mdt mac cit mex gco gcx mmi gex mpc gml custom">
   
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="false()" as="xs:boolean"/>
    <xsl:param name="global_regex_URLinstring" select="'(https?:)(//([^#\s]*))?'"/>
    
    
    <!-- Override the following by constructing a stylesheet with the params below populated appropriately, then import this stylesheet.  Run the stylesheet with the params, on your source XML -->
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_path" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_spatialProjection" select="''"/>
    <xsl:param name="global_includeServiceAccessLinks" select="false()"/>
    <!--xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/-->
    <!--xsl:variable name="codelists" select="document('codelists_ISO19115-1.xml')"/-->
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <!--xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//mdb:MD_Metadata" mode="registryObjects"/>
        </registryObjects>
    </xsl:template-->
    
    <!--xsl:template match="node()"/-->

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->
    
   <xsl:template match="mdb:MD_Metadata" mode="process">
        
        <xsl:variable name="originatingSource">
            <xsl:choose>
                <xsl:when test="count(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                    <xsl:value-of select="distinct-values(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])"/>
                </xsl:when>
                <xsl:when test="count(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                    <xsl:value-of select="distinct-values(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_originatingSource"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_group"/>    
            </xsl:attribute>
            
            <xsl:choose>
                <xsl:when test="count(mdb:metadataIdentifier/mcc:MD_Identifier[contains(mcc:codeSpace, 'uuid')]/mcc:code[string-length(.) > 0]) > 0">
                    <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier[contains(mcc:codeSpace, 'uuid')][1]/mcc:code[string-length(.) > 0][1]" mode="registryObject_key"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier[1]/mcc:code[string-length(.) > 0][1]" mode="registryObject_key"/>
                </xsl:otherwise>
            </xsl:choose>
            
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <xsl:variable name="registryObjectTypeSubType_sequence" as="xs:string*">
                <xsl:variable name="scopeCode" select="mdb:metadataScope[1]/mdb:MD_MetadataScope[1]/mdb:resourceScope[1]/mcc:MD_ScopeCode[1]/@codeListValue[1]"/>
                <xsl:choose>
                    <xsl:when test="string-length($scopeCode) > 0">
                        <xsl:choose>
                            <xsl:when test="substring(lower-case($scopeCode), 1, fn:string-length('service')) = 'service'">
                                <xsl:text>service</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="string-length(mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType) > 0">
                                        <xsl:value-of select="normalize-space(mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>report</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('software')) = 'software'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>software</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('model')) = 'model'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>software</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('nongeographicdataset')) = 'nongeographicdataset'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>publication</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('document')) = 'document'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>publication</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('dataset')) = 'dataset'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>dataset</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('collectionhardware')) = 'collectionhardware'">
                                <xsl:text>activity</xsl:text>
                                <xsl:text>project</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('fieldsession')) = 'fieldsession'">
                                <xsl:text>activity</xsl:text>
                                <xsl:text>project</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('series')) = 'series'">
                                <xsl:text>activity</xsl:text>
                                <xsl:text>program</xsl:text>
                            </xsl:when>
                            <xsl:when test="fn:substring(lower-case($scopeCode), 1, fn:string-length('collectionsession')) = 'collectionsession'">
                                <xsl:text>activity</xsl:text>
                                <xsl:text>program</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>collection</xsl:text>
                                <xsl:text>dataset</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>collection</xsl:text>
                        <xsl:text>dataset</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:element name="{$registryObjectTypeSubType_sequence[1]}">
    
                <xsl:attribute name="type" select="$registryObjectTypeSubType_sequence[2]"/>
                        
                <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                    <xsl:if test="count(mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date[string-length() > 0]) > 0">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="mdb:dateInfo[(cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation') and (cit:CI_Date/cit:date[string-length() > 0])][1]/cit:CI_Date/cit:date"/>
                            </xsl:attribute>  
                        </xsl:if>
                </xsl:if>
                
                <xsl:for-each select=".//mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource">
                    <!-- Test for service (then call relatedService but only if current registry object is a collection); otherwise, handle as non service for all objects -->
                    <xsl:choose>
                        <xsl:when test="$global_includeServiceAccessLinks and ($registryObjectTypeSubType_sequence[1] = 'collection') and 
                            (contains(lower-case(cit:protocol), 'esri') or 
                            contains(lower-case(cit:protocol), 'ogc') or 
                            contains(cit:linkage, '?') or
                            contains(lower-case(cit:linkage), 'thredds') or
                            contains(lower-case(cit:linkage), 'geoserver/ows') or
                            contains(lower-case(cit:linkage), 'geoserver/wms') or
                            contains(lower-case(cit:linkage), 'geoserver/wmts') or
                            contains(lower-case(cit:linkage), 'geoserver/wps') or
                            contains(lower-case(cit:linkage), 'geoserver/wcs') or
                            contains(lower-case(cit:linkage), 'geoserver/wfs'))">
                            <xsl:if test="$global_debug"><xsl:message select="concat('cit:protocol for service', cit:protocol)"></xsl:message></xsl:if>
                            <xsl:apply-templates select="." mode="registryObject_relatedInfo_service"/>
                        </xsl:when>
                        <xsl:when test="not(contains(lower-case(cit:protocol), 'metadata-URL'))">
                            <xsl:if test="$global_debug"><xsl:message select="concat('cit:protocol for non-service', cit:protocol)"></xsl:message></xsl:if>
                            <xsl:apply-templates select="." mode="registryObject_relatedInfo_nonService"/>
                        </xsl:when>
                        
                    </xsl:choose>
                </xsl:for-each>
                
                <xsl:apply-templates select="mdb:parentMetadata" mode="registryObject_relatedInfo_parent"/>
                
                <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier" mode="global_identifier"/>
                
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[not(contains(lower-case(mcc:code), 'dataset doi'))]"/>
                
                <xsl:choose>
                   <xsl:when test="count(mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage) > 0">
                        <xsl:apply-templates 
                            select="mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage" 
                            mode="registryObject_identifier_metadata_URL"/>
                       
                       <xsl:apply-templates 
                           select="mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage" 
                           mode="registryObject_location_metadata_URL"/>
                    </xsl:when>
                    <xsl:when test="count(.//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'persistent identifier')]/mcc:code[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="(.//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'persistent identifier')]/mcc:code[string-length(.) > 0])[1]"
                            mode="registryObject_location_PID"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier[contains(mcc:codeSpace, 'uuid')]/mcc:code"
                                mode="registryObject_location_uuid"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates 
                    select="mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mcc:MD_ProgressCode[string-length(.) > 0]"
                    mode="registryObject_description_lineage"/>
                
                <xsl:apply-templates 
                    select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency/mmi:MD_MaintenanceFrequencyCode"
                    mode="registryObject_description_lineage"/>
                
                <xsl:apply-templates
                    select="mdb:resourceLineage"
                    mode="registryObject_description_lineage"/>
                
                <xsl:apply-templates
                    select="mdb:identificationInfo/*/mri:credit[string-length(.) > 0]"
                    mode="registryObject_description_notes"/>
                
                <xsl:apply-templates
                    select="mdb:identificationInfo/*/mri:purpose[string-length(.) > 0]"
                    mode="registryObject_description_notes"/>
                   
                <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                    <xsl:with-param name="registryObjectTypeSubType_sequence" select="$registryObjectTypeSubType_sequence"/>
                </xsl:apply-templates>
            </xsl:element>
                
        </registryObject>
        
        <!--xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
            <xsl:with-param name="originatingSource" select="$originatingSource"/>
        </xsl:apply-templates-->

    </xsl:template>
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="registryObjectTypeSubType_sequence"/>
        
        <!--xsl:for-each-group select="mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address" group-by="cit:electronicMailAddress">
            <xsl:apply-templates select="cit:electronicMailAddress" mode="registryObject_location_email"/>
        </xsl:for-each-group-->
        
        <xsl:apply-templates select="srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/cit:CI_OnlineResource/cit:linkage" mode="registryObject_identifier_service_URL"/>
        <xsl:apply-templates select="srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/cit:CI_OnlineResource/cit:linkage" mode="registryObject_location_service_URL"/>
        
        <xsl:apply-templates select="srv:operatesOn[string-length(@uuidref) > 0]" mode="registryObject_relatedObject_isSupportedBy"/>
        
        <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:title[string-length(.) > 0]" mode="registryObject_name"/>
        
        
        
        <!--xsl:variable name="organisationNamesOnly_sequence" as="xs:string*">
            <xsl:for-each-group
                select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party /cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0]"
                group-by="cit:name">
                <xsl:value-of select="current-grouping-key()"/>
            </xsl:for-each-group>
        </xsl:variable-->
        
         <xsl:for-each
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party">
            <xsl:apply-templates select="." mode="registryObject_related_object">
                <!--xsl:with-param name="orgNamesOnly_sequence" select="$organisationNamesOnly_sequence" as="xs:string*"/-->
            </xsl:apply-templates>
        </xsl:for-each>
        
        <xsl:apply-templates
            select="mri:topicCategory/mri:MD_TopicCategoryCode[string-length(.) > 0]"
            mode="registryObject_subject"/>
        
        <xsl:apply-templates
            select="mri:descriptiveKeywords/mri:MD_Keywords"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
             select="mri:abstract[string-length(.) > 0]"
            mode="registryObject_description_full"/>
        
        <xsl:apply-templates select="mri:extent/gex:EX_Extent" mode="registryObject_coverage_spatial"/>
       
       
        <xsl:apply-templates
            select="mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
        
        <!--xsl:apply-templates select="mri:resourceConstraints/*" mode="registryObject_rights_licence_type_and_uri"/-->
        
        <xsl:apply-templates select="mri:resourceConstraints/mco:MD_LegalConstraints"/>
        <xsl:apply-templates select="mri:resourceConstraints/mco:MD_Constraints"/>
        <xsl:apply-templates select="mri:resourceConstraints/mco:MD_SecurityConstraints"/>
        
        <xsl:apply-templates select="mri:associatedResource/mri:MD_AssociatedResource" mode="registryObject_relatedInfo_associatedResource"/>
        
        <!--xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(count(mco:reference/cit:CI_Citation) = 0) and matches(mco:useConstraints/mco:MD_RestrictionCode/@codeListValue,  'licen.e') and (count(mco:otherConstraints[string-length() > 0]) > 0)]"
            mode="registryObject_rights_license_otherConstraint"/>
        
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(count(mco:reference/cit:CI_Citation) = 0) and matches(mco:useConstraints/mco:MD_RestrictionCode/@codeListValue,  'licen.e') and (count(mco:useLimitation[string-length() > 0]) > 0)]"
            mode="registryObject_rights_license_useLimitation"/-->
       
        <!--xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(count(mco:reference/cit:CI_Citation) > 0)]"
            mode="registryObject_rights_license_citation"/-->
        
        <xsl:apply-templates
            select="."
           mode="registryObject_rights_access"/>
        
        
        <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:date/cit:CI_Date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="registryObjectTypeSubType_sequence" select="$registryObjectTypeSubType_sequence"/>
            </xsl:apply-templates>
        </xsl:if>
        
         
        
   </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
        <xsl:param name="originatingSource"/>
        
        <xsl:for-each
            select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)]">
            <xsl:apply-templates select="." mode="party_person">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:for-each>
    
        <xsl:for-each
            select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]  |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]">
            <xsl:apply-templates select="." mode="party_group">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="mcc:code" mode="registryObject_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
        </key>
    </xsl:template>
    
     <!--xsl:template match="mcc:code" mode="identifier_anywhere">
        <xsl:choose>
            <xsl:when test="
                (count(ancestor::mcc:MD_Identifier/mcc:authority/cit:CI_Citation/cit:title[contains(lower-case(.), 'digital object identifier')]) > 0) or
                (count(ancestor::mcc:MD_Identifier/mcc:authority/cit:CI_Citation/cit:title[contains(lower-case(.), 'doi')]) > 0) or
                (count(ancestor::mcc:MD_Identifier/mcc:authority/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code[contains(lower-case(.), 'iso 26324:2012')]) > 0) or
                contains(custom:getIdentifierType(.), 'doi')">
                <xsl:variable name="coreValue">
                    <xsl:choose>
                       <xsl:when test="starts-with(., 'doi:')">
                            <xsl:value-of select="normalize-space(replace(.,'doi:', ''))"/>   
                        </xsl:when>
                        <xsl:when test="matches(., 'https?://dx.doi.org/')">
                            <xsl:value-of select="normalize-space(substring-after(.,'dx.doi.org/'))"/>   
                        </xsl:when>
                        <xsl:when test="matches(., 'https?://doi.org/')">
                            <xsl:value-of select="normalize-space(substring-after(.,'doi.org/'))"/>   
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="starts-with($coreValue, '10.') and (string-length($coreValue) > 3)">
                    <identifier type="doi">
                        <xsl:attribute name="type" select="'doi'"/>
                        <xsl:value-of select="$coreValue"/>
                    </identifier>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <identifier type="{custom:getIdentifierType(.)}">
                    <xsl:choose>
                        <xsl:when test="contains(., 'hdl:')">
                            <xsl:attribute name="type" select="'handle'"/>
                            <xsl:value-of select="normalize-space(replace(.,'hdl:', ''))"/>   
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </identifier>
            </xsl:otherwise>
        </xsl:choose>   
    </xsl:template-->
    
    <!-- RegistryObject - Identifier Element  -->
    
    <xsl:template match="cit:linkage" mode="registryObject_identifier_service_URL">
        <identifier type="uri">
            <xsl:choose>
                <xsl:when test="contains(.,'?')">
                    <xsl:value-of select="substring-before(., '?')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>    
                </xsl:otherwise>
            </xsl:choose>
        </identifier>
    </xsl:template>
    
    <xsl:template match="cit:linkage" mode="registryObject_location_service_URL">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                     <!--xsl:attribute name="target">
                        <xsl:text>online</xsl:text>
                    </xsl:attribute-->
                    <value>
                        <xsl:value-of select="."/>    
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    
    
    <xsl:template match="cit:linkage" mode="registryObject_identifier_metadata_URL">
        <identifier type="uri">
            <xsl:value-of select="."/>    
        </identifier>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_location_PID">
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
    
   <!--xsl:template match="mcc:code" mode="registryObject_identifier">
        <identifier>
            <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="string-length(following-sibling::mcc:codeSpace) > 0">
                            <xsl:choose>
                             <xsl:when test="custom:getIdentifierType(following-sibling::mcc:codeSpace) != 'local'">
                                 <xsl:value-of select="custom:getIdentifierType(following-sibling::mcc:codeSpace)"/>
                             </xsl:when>
                                <xsl:when test="custom:getIdentifierType(.) != 'local'">
                                    <xsl:value-of select="custom:getIdentifierType(.)"/>
                                </xsl:when>
                             <xsl:otherwise>
                                 <xsl:value-of select="following-sibling::mcc:codeSpace"/>
                             </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="custom:getIdentifierType(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains(., 'hdl:')">
                    <xsl:value-of select="normalize-space(replace(.,'hdl:', ''))"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>   
                </xsl:otherwise>
            </xsl:choose>
            
        </identifier>
    </xsl:template-->
    
    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="cit:linkage" mode="registryObject_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="cit:linkage" mode="registryObject_location_metadata_URL">
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
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_location_uuid">
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
                        <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    <xsl:template match="cit:electronicMailAddress" mode="registryObject_location_email">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>email</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    

    <!-- RegistryObject - Name Element  -->
    <xsl:template match="mri:citation/cit:CI_Citation/cit:title" mode="registryObject_name">
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
    
    <!-- RegistryObject - Dates Element  -->
    <xsl:template match="cit:CI_Date" mode="registryObject_dates">
        
        <xsl:variable name="dateValue_sequence" select="normalize-space(cit:date/gco:DateTime)" as="xs:string*"/>
        <xsl:variable name="dateCode_sequence" select="normalize-space(cit:dateType/cit:CI_DateTypeCode/@codeListValue)" as="xs:string*"/>
        
        <xsl:if test="$global_debugExceptions">
            <xsl:if test="count($dateValue_sequence) = 0">
                <xsl:message select="'Exception - No value in cit:date/gco:DateTime'"/>
            </xsl:if>
            <xsl:if test="count($dateValue_sequence) > 1">
                <xsl:message select="'Exception - More than one value in cit:date/gco:DateTime'"/>
            </xsl:if>
            <xsl:if test="count($dateCode_sequence) = 0">
                <xsl:message select="'Exception - No value in cit:dateType/cit:CI_DateTypeCode/@codeListValue'"/>
            </xsl:if>
            <xsl:if test="count($dateCode_sequence) > 1">
                <xsl:message select="'Exception - More than one value in cit:dateType/cit:CI_DateTypeCode/@codeListValue'"/>
            </xsl:if>
        </xsl:if>
        
        <xsl:if test="(count($dateValue_sequence) > 0) and (string-length($dateValue_sequence[1]) > 0)">
            <dates>
                
                <xsl:choose>
                    <xsl:when test="count($dateCode_sequence) > 0 and (string-length($dateCode_sequence[1]) > 0)">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'creation')">
                                    <xsl:text>created</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'publication')">
                                    <xsl:text>issued</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'revision')">
                                    <xsl:text>modified</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$dateCode_sequence[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type" select="'unknown'"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>dateFrom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="dateFormat">
                        <xsl:text>W3CDTF</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$dateValue_sequence[1]"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>
    
     <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="cit:party" mode="registryObject_related_object">
        <!--xsl:param name="orgNamesOnly_sequence" as="xs:string*"/-->
        
        <xsl:variable name="identifier_sequence" select="*/cit:partyIdentifier/mcc:MD_Identifier[string-length(mcc:code) > 0]" as="item()*"/>
         
            <xsl:variable name="name">
                <xsl:choose>
                    <xsl:when test="string-length(*/cit:name) > 0">
                        <xsl:value-of select="*/cit:name"/>
                    </xsl:when>
                    <xsl:when test="string-length(*/cit:positionName) > 0">
                        <xsl:value-of select="*/cit:positionName"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
        
              
            
            <xsl:choose>
                <!-- If dealing with an organisation that has an individual, don't use the person's role to relate the organisation - only
                        relate this organisation if not already related, and use general 'hasAssociationWithin'-->
                <xsl:when test="(string-length(cit:CI_Organisation/cit:name) > 0) and (count(cit:CI_Organisation/cit:individual/cit:CI_Individual) > 0)">
                    <xsl:choose>
                        <xsl:when test="count($identifier_sequence) > 0">
                            <relatedInfo type="party">
                                <xsl:apply-templates select="$identifier_sequence"/>
                                <relation>
                                    <xsl:attribute name="type">
                                        <xsl:text>hasAssociationWith</xsl:text>
                                    </xsl:attribute>
                                </relation>
                            </relatedInfo>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string-length($name) > 0">
                                <relatedInfo type="party">
                                 <identifier type="local">
                                     <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                 </identifier>
                                    <title>
                                        <xsl:value-of select="normalize-space($name)"/>
                                    </title>
                                    <relation>
                                        <xsl:attribute name="type">
                                            <xsl:text>hasAssociationWith</xsl:text>
                                        </xsl:attribute>
                                    </relation>
                                </relatedInfo>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="count(distinct-values(preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue)) > 0">
                            <xsl:for-each select="distinct-values(preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue)">
                                <xsl:variable name="role" select="."/>
                                <xsl:choose>
                                    <xsl:when test="count($identifier_sequence) > 0">
                                        <relatedInfo type="party">
                                            <xsl:apply-templates select="$identifier_sequence"/>
                                            <relation>
                                                <xsl:attribute name="type">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length($role) > 0">
                                                            <xsl:value-of select="$role"/>  
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text>unknown</xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                            </relation>
                                        </relatedInfo>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="string-length($name) > 0">
                                            <relatedInfo type="party">
                                                <identifier type="local">
                                                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                                </identifier>
                                                <title>
                                                    <xsl:value-of select="normalize-space($name)"/>
                                                </title>
                                                <relation>
                                                    <xsl:attribute name="type">
                                                        <xsl:choose>
                                                            <xsl:when test="string-length($role) > 0">
                                                                <xsl:value-of select="$role"/>  
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:text>unknown</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:attribute>
                                                </relation>
                                            </relatedInfo>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                       <xsl:otherwise>
                           <xsl:choose>
                             <xsl:when test="count($identifier_sequence) > 0">
                                 <relatedInfo type="party">
                                      <xsl:apply-templates select="$identifier_sequence"/>
                                      <relation>
                                          <xsl:attribute name="type">
                                              <xsl:text>hasAssociationWith</xsl:text>
                                          </xsl:attribute>
                                      </relation>
                                  </relatedInfo>
                              </xsl:when>
                              <xsl:otherwise>
                                  <xsl:if test="string-length($name) > 0">
                                     <relatedInfo type="party">
                                         <identifier type="local">
                                             <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                         </identifier>
                                         <title>
                                             <xsl:value-of select="normalize-space($name)"/>
                                         </title>
                                         <relation>
                                           <xsl:attribute name="type">
                                               <xsl:text>hasAssociationWith</xsl:text>
                                           </xsl:attribute>
                                         </relation>
                                     </relatedInfo> 
                                  </xsl:if>
                              </xsl:otherwise>
                           </xsl:choose>
                       </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        <xsl:apply-templates select="cit:CI_Organisation/cit:individual/cit:CI_Individual" mode="registryObject_related_object"/>

    </xsl:template>

    <xsl:template match="cit:CI_Individual" mode="registryObject_related_object">
        
        <xsl:variable name="identifier_sequence" select="cit:partyIdentifier/mcc:MD_Identifier[string-length(mcc:code) > 0]" as="item()*"/>
        
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="string-length(cit:name) > 0">
                    <xsl:value-of select="cit:name"/>
                </xsl:when>
                <xsl:when test="string-length(cit:positionName) > 0">
                    <xsl:value-of select="cit:positionName"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count(distinct-values(ancestor::cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue)) > 0">
                <xsl:for-each select="distinct-values(ancestor::cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue)">
                    <xsl:variable name="role" select="."/>
                    <xsl:choose>
                        <xsl:when test="count($identifier_sequence) > 0">
                            <relatedInfo type="party">
                                <xsl:apply-templates select="$identifier_sequence"/>
                                <relation>
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="string-length($role) > 0">
                                                <xsl:value-of select="$role"/>  
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>unknown</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </relation>
                            </relatedInfo>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string-length($name) > 0">
                                <relatedInfo type="party">
                                    <identifier type="local">
                                        <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                    </identifier>
                                    <title>
                                        <xsl:value-of select="normalize-space($name)"/>
                                    </title>
                                    <relation>
                                        <xsl:attribute name="type">
                                            <xsl:choose>
                                                <xsl:when test="string-length($role) > 0">
                                                    <xsl:value-of select="$role"/>  
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text>unknown</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                    </relation>
                                </relatedInfo>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="count($identifier_sequence) > 0">
                        <relatedInfo type="party">
                            <xsl:apply-templates select="$identifier_sequence"/>
                            <relation>
                                <xsl:attribute name="type">
                                    <xsl:text>hasAssociationWith</xsl:text>
                                </xsl:attribute>
                            </relation>
                        </relatedInfo>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="string-length($name) > 0">
                         <relatedInfo type="party">
                             <identifier type="local">
                                 <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                             </identifier>
                             <title>
                                 <xsl:value-of select="normalize-space($name)"/>
                             </title>
                             <relation>
                                 <xsl:attribute name="type">
                                     <xsl:text>hasAssociationWith</xsl:text>
                                 </xsl:attribute>
                             </relation>
                         </relatedInfo> 
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
      
    </xsl:template>
    
    <xsl:template match="mri:MD_TopicCategoryCode" mode="registryObject_subject">
        <subject type="local">
            <xsl:value-of select="."></xsl:value-of>
        </subject>
    </xsl:template>
    
    

    <xsl:template match="mri:MD_Keywords" mode="registryObject_subject">
        <!-- Grab thesaurus citation if there is one - in case there is more than one, grab the one that has a title or an identifier -->
        <xsl:variable name="thesaurusCitation" select="mri:thesaurusName/cit:CI_Citation[(string-length(cit:title) > 0) or (count(cit:identifier/mcc:MD_Identifier/mcc:code) > 0)]" as="node()*"/>
        <xsl:variable name="thesaurusTitle" select="$thesaurusCitation[1]/cit:title"/>
        <xsl:variable name="thesaurusID" select="$thesaurusCitation[1]/cit:identifier[1]/mcc:MD_Identifier[1]/mcc:code[1]"/>
        
        <xsl:variable name="keywordChildNode_Sequence" as="node()*" select="mri:keyword/node()"/>
       
        <xsl:for-each select="$keywordChildNode_Sequence">
            <subject>
                <xsl:choose>
                    <xsl:when test="count($thesaurusCitation) > 0"> <!-- Can only be one according to spec but if there are more, just take the first -->
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="
                                    contains(lower-case($thesaurusTitle), 'anzsrc') or
                                    (contains(lower-case($thesaurusTitle), 'australian and new zealand standard research classification') and contains(lower-case($thesaurusTitle), 'fields of research')) or
                                    contains(lower-case($thesaurusID), 'anzsrc')"> <!-- Not technically FOR, could be SEO, but Geonetwork tends to prefer the FOR? -->
                                    <xsl:text>anzsrc-for</xsl:text>  
                                </xsl:when>
                                <xsl:when test="
                                    contains(lower-case($thesaurusTitle), 'global change master directory')"> 
                                    <xsl:text>GCMD</xsl:text>  
                                </xsl:when>
                                <xsl:when test="string-length($thesaurusTitle) > 0">
                                    <xsl:value-of select="$thesaurusTitle"/>
                                </xsl:when>
                                <xsl:when test="string-length($thesaurusID) > 0">
                                    <xsl:value-of select="$thesaurusID"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>local</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:text>local</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="boolean(string-length(@xlink:href))">
                    <xsl:attribute name="termIdentifier">
                        <xsl:value-of select="@xlink:href"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space(text())"/>
            </subject>
        </xsl:for-each>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="mri:abstract" mode="registryObject_description_full">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="full">
                <xsl:value-of select="custom:preserveWhitespaceHTML(.)"/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mcc:MD_ProgressCode" mode="registryObject_description_lineage">
        
        <description type="lineage">
            <xsl:value-of select="concat('Progress Code: ',.)"/>
        </description>
        
    </xsl:template>
    
    <xsl:template match="mmi:MD_MaintenanceFrequencyCode" mode="registryObject_description_lineage">
        
        <xsl:if test="string-length(@codeListValue) > 0">
            <description type="lineage">
                <xsl:value-of select="concat('Maintenance and Update Frequency: ', @codeListValue)"/>
            </description>
        </xsl:if>
        
    </xsl:template>
    
    <!-- RegistryObject - Decription Element - lineage -->
    <xsl:template match="mdb:resourceLineage" mode="registryObject_description_lineage">
        
        <description type="lineage">
            <xsl:if test="string-length(normalize-space(mrl:LI_Lineage/mrl:statement[string-length(.) > 0])) > 0">
                <xsl:value-of select="concat('Statement: ', mrl:LI_Lineage/mrl:statement)"/>
            </xsl:if>
        </description>
        
        <relatedInfo type="reuseInformation">
            <title>
                <xsl:value-of select="mrl:LI_Lineage/mrl:additionalDocumentation/cit:CI_Citation/cit:title"/>
            </title>
            <identifier type="uri">
                <xsl:value-of select="mrl:LI_Lineage/mrl:additionalDocumentation/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage"/>
            </identifier>
            <relation type="isSupplementTo"></relation>
            <notes>
                <xsl:value-of select="mrl:LI_Lineage/mrl:additionalDocumentation/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:description"/>
            </notes>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="mri:credit" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:text>&lt;b&gt;Credit&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mri:purpose" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:text>&lt;b&gt;Purpose&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="*:polygon | *:Polygon" mode="registryObject_coverage_spatial">
        
        
        <xsl:call-template name="writeYoungestChildTextNode">
            <xsl:with-param name="currentNode" select="."/>
        </xsl:call-template>
    </xsl:template>
    
   
    
    <xsl:template name="writeYoungestChildTextNode">
        <xsl:param name="currentNode" as="node()"/>
        
        <xsl:for-each select="$currentNode/child::node()">
            <xsl:choose>
                <xsl:when test="string-length(self::text()) > 0">
                    <xsl:call-template name="outputLineString">
                        <xsl:with-param name="lineString" select="normalize-space(self::text())"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- ignore any addition child called (case insensitive) 'polygon' because we are handling each lowest-level 
                    polygon element because otherwise, if a polygon has a child polygon, this will be repeated if we don't filter it out -->
                <xsl:when test="boolean(not(contains(lower-case(name(.)), 'polygon')))">
                    <xsl:call-template name="writeYoungestChildTextNode">
                        <xsl:with-param name="currentNode" select="."/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
       
    </xsl:template>
    
    <xsl:template name="outputLineString">
        <xsl:param name="lineString" as="xs:string"/>
        
        <xsl:if test="string-length($lineString) > 0">
            
            <xsl:variable name="srsNameAncestor_sequence" select="ancestor::node()[string-length(@srsName) > 0]/@srsName" as="xs:string*"/>
            <xsl:variable name="lastIndex" as="xs:integer" select="count($srsNameAncestor_sequence)"/>
            <xsl:variable name="coordinateReferenceSystem" select="$srsNameAncestor_sequence[$lastIndex]"/>
        
          <!-- RDA doesn't handle altitude yet and if altitude is provided, the shapes aren't shown on the
              map so I'm removing altitude from the map coords but keeping them in the text if they are there -->
          
          
            
          <xsl:variable name="coordsFormatted" select="custom:formatCoordinates(normalize-space(.), $coordinateReferenceSystem)"/>
            <spatial>
              <xsl:attribute name="type">
                  <xsl:text>kmlPolyCoords</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="$coordsFormatted"/>
          </spatial>
          <!--
              <spatial>
                  <xsl:attribute name="type">
                      <xsl:text>text</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="normalize-space(.)"/>
              </spatial>
              -->
        </xsl:if>
        
    </xsl:template>
    
    
   <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gex:EX_Extent" mode="registryObject_coverage_spatial">
        
        <coverage>
            
            <xsl:apply-templates select=".//gex:polygon[count(child::gml:Polygon) = 0]" mode="registryObject_coverage_spatial"/>
            <xsl:apply-templates select=".//gml:Polygon" mode="registryObject_coverage_spatial"/>
            
            <xsl:for-each select="gex:geographicElement/gex:EX_GeographicBoundingBox">
            
             <xsl:if
                 test="
                 (string-length(normalize-space(gex:northBoundLatitude/gco:Decimal)) > 0) and
                 (string-length(normalize-space(gex:southBoundLatitude/gco:Decimal)) > 0) and
                 (string-length(normalize-space(gex:westBoundLongitude/gco:Decimal)) > 0) and
                 (string-length(normalize-space(gex:eastBoundLongitude/gco:Decimal)) > 0)">
                     <xsl:variable name="horizontalCoordinatesWithProjection">
                         <xsl:value-of
                             select="normalize-space(concat('westlimit=', gex:westBoundLongitude/gco:Decimal,'; southlimit=', gex:southBoundLatitude/gco:Decimal, '; eastlimit=', gex:eastBoundLongitude/gco:Decimal,'; northlimit=', gex:northBoundLatitude/gco:Decimal))"/>
                            <xsl:if test="count(ancestor::mdb:MD_Metadata/mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code[string-length(.) > 0]) = 1">
                                <xsl:value-of select="concat('; projection=', ancestor::mdb:MD_Metadata/mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code[string-length(.) > 0])"/>
                            </xsl:if>
                     </xsl:variable>
                
                    <xsl:if test="string-length($horizontalCoordinatesWithProjection) > 0">
                            <spatial>
                                <xsl:attribute name="type">
                                    <xsl:text>iso19139dcmiBox</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$horizontalCoordinatesWithProjection"/>
                            </spatial>
                            <spatial>
                                <xsl:attribute name="type">
                                    <xsl:text>text</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$horizontalCoordinatesWithProjection"/>
                            </spatial>
                    </xsl:if>
                         
                </xsl:if>     
        </xsl:for-each>
                         
                
            <xsl:for-each select="gex:verticalElement/gex:EX_VerticalExtent">
                
                <xsl:variable name="verticalLimitsWithProjection">
                    
                    <xsl:if test="
                        (string-length(normalize-space(gex:maximumValue/gco:Real[string-length(.) > 0])) > 0) or
                        (string-length(normalize-space(gex:minimumValue/gco:Real[string-length(.) > 0])) > 0)">
                        
                        <xsl:value-of select="concat('uplimit=', gex:maximumValue/gco:Real)"/>
                        <xsl:value-of select="concat('; downlimit=', gex:minimumValue/gco:Real)"/>
                        
                        <xsl:if test="string-length(gex:verticalCRSId/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code) > 0">
                             <xsl:value-of select="concat('; projection=', gex:verticalCRSId/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code)"/>
                         </xsl:if>
                    </xsl:if>
                       
                </xsl:variable>
                
                <xsl:if test="string-length($verticalLimitsWithProjection) > 0">
                    <spatial>
                            <xsl:attribute name="type">
                                <xsl:text>iso19139dcmiBox</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$verticalLimitsWithProjection"/>
                    </spatial>
                    <spatial>
                            <xsl:attribute name="type">
                                <xsl:text>text</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$verticalLimitsWithProjection"/>
                    </spatial>
                
                </xsl:if>
                
            </xsl:for-each>
        </coverage>
    </xsl:template>
    
      
    
    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gex:EX_TemporalExtent" mode="registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gex:extent/gml:TimePeriod/gml:beginPosition)) > 0) or
            (string-length(normalize-space(gex:extent/gml:TimePeriod/gml:endPosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gex:extent/gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gex:extent/gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gex:extent/gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gex:extent/gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <xsl:template match="srv:operatesOn" mode="registryObject_relatedObject_isSupportedBy">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', normalize-space(@uuidref))"/>
                </key>
                <relation type="isSupportedBy"/>
            </relatedObject>
    </xsl:template>
    
  <xsl:template match="cit:CI_OnlineResource" mode="registryObject_relatedInfo_service">       
        
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                 <xsl:when test="contains(cit:linkage, '?')">
                    <xsl:value-of select="substring-before(., '?')"/>
                </xsl:when>
                <!-- if we are refering to a thredds endpoint but we are not at catalogue level but rather down in a file
                        we can truncate up to the root catalogue -->
                <xsl:when test="contains(cit:linkage, '/thredds/') and not(contains(cit:linkage, 'catalog.'))">
                    <xsl:value-of select="concat(substring-before(., '/thredds/'), '/thredds/', 'catalog.html')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="cit:linkage"/>
                </xsl:otherwise>
                </xsl:choose>
        </xsl:variable> 
        
        <relatedInfo>
            <xsl:attribute name="type" select="'service'"/>   
            
            <xsl:apply-templates select="." mode="relatedInfo_all">
                <xsl:with-param name="identifierToUse" select="$identifierToUse"/>
            </xsl:apply-templates>
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>supports</xsl:text>
                </xsl:attribute>
                <xsl:if test="not(string-length($identifierToUse) = string-length(cit:linkage))">
                    <url>
                     <xsl:choose>
                            <xsl:when test="contains(cit:linkage, '?')">
                                <xsl:value-of select="concat(fn:iri-to-uri(substring-before(cit:linkage, '?')), '?', fn:encode-for-uri(substring-after(cit:linkage, '?')))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="fn:iri-to-uri(cit:linkage)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </url>
                </xsl:if>
            </relation>
            
        </relatedInfo>
        
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource" mode="registryObject_relatedInfo_nonService">  
        
        <relatedInfo>
            <xsl:attribute name="type" select="'relatedInformation'"/>   
            
            <xsl:apply-templates select="." mode="relatedInfo_all">
                <xsl:with-param name="identifierToUse" select="cit:linkage"/>
            </xsl:apply-templates>
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>hasAssociationWith</xsl:text>
                </xsl:attribute>
            </relation>
            
            
        </relatedInfo>
        
    </xsl:template>
    
    <xsl:template match="mdb:parentMetadata" mode="registryObject_relatedInfo_parent">  
        
        <relatedInfo>
            <!--xsl:attribute name="type" select="'relatedInformation'"/--> <!-- we don't know the type of the parent -->   
            
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="'global'"/>
                </xsl:attribute>
                <xsl:value-of select="@uuidref"/>
            </identifier>
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>isPartOf</xsl:text>
                </xsl:attribute>
            </relation>
            
        </relatedInfo>
        
    </xsl:template>
    
    
    <xsl:template match="cit:CI_OnlineResource" mode="relatedInfo_all">     
        <xsl:param name="identifierToUse" select="normalize-space(cit:linkage)"/> <!-- can be overriden -->
        
        <identifier>
            <xsl:attribute name="type">
                <xsl:value-of select="custom:getIdentifierType($identifierToUse)"/>
            </xsl:attribute>
            <xsl:value-of select="$identifierToUse"/>
        </identifier>
        
        <xsl:choose>
            <!-- Use description as title if we have it... -->
            <xsl:when test="string-length(normalize-space(cit:description)) > 0">
                <title>
                    <xsl:value-of select="normalize-space(cit:description)"/>
                    
                    <!-- ...and then name in brackets following -->
                    <xsl:if
                        test="not(normalize-space(cit:name) = normalize-space(cit:description)) and string-length(normalize-space(cit:name)) > 0">
                        <xsl:value-of select="concat(' (', cit:name, ')')"/>
                    </xsl:if>
                </title>
            </xsl:when>
            <!-- No description, so use name as title if we have it -->
            <xsl:otherwise>
                <xsl:if
                    test="string-length(normalize-space(cit:name)) > 0">
                    <title>
                        <xsl:value-of select="concat('(', cit:name, ')')"/>
                    </title>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_otherConstraint">
        
        <xsl:if test="$global_debug = true()">
            <xsl:message select="'registryObject_rights_license_otherConstraint'"/>
        </xsl:if>
        <xsl:for-each select="mco:otherConstraints">
            <xsl:variable name="licenceText" select="."/>
            <xsl:call-template name="populateLicence">
                <xsl:with-param name="licenceText" select="$licenceText"/>
            </xsl:call-template>
        </xsl:for-each>
     </xsl:template-->
    
    <!--xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_useLimitation">
        
        <xsl:if test="$global_debug = true()">
            <xsl:message select="'registryObject_rights_license_useLimitation'"/>
        </xsl:if>
        <xsl:for-each select="mco:useLimitation">
            <xsl:variable name="licenceText" select="."/>
            <xsl:call-template name="populateLicence">
                <xsl:with-param name="licenceText" select="$licenceText"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template-->
   
    <!--xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_citation">
        
        <xsl:if test="$global_debug = true()">
            <xsl:message select="'registryObject_rights_license_citation'"/>
        </xsl:if>
        
        <xsl:for-each select="mco:reference/cit:CI_Citation">
         <xsl:variable name="licenceText" select="cit:title"/>
         <xsl:call-template name="populateLicence">
             <xsl:with-param name="licenceText" select="$licenceText"/>
         </xsl:call-template>
        </xsl:for-each>
        
    </xsl:template-->
    
   <!-- RegistryObject - Rights License -->
    <!--xsl:template name="populateLicence">
        <xsl:param name="licenceText"/>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('count $licenseCodelist : ', count($licenseCodelist))"/>
        </xsl:if>
        
                    
                    <xsl:variable name="inputTransformed" select="normalize-space(replace(replace(replace($licenceText, 'icence', 'icense', 'i'), '[\d.]+', ''), '-', ''))"/>
                    <xsl:variable name="codeDefinition_sequence" select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition[normalize-space(replace(replace(gml:name, '\{n\}', ' '), '-', '')) = $inputTransformed]" as="node()*"/>
                    
                    <xsl:if test="$global_debug">
                         <xsl:message select="concat('count $codeDefinition_sequence : ', count($codeDefinition_sequence))"/>
                    </xsl:if>
                     
                    <xsl:choose>
                        <xsl:when test="count($codeDefinition_sequence) > 0">
                             <xsl:for-each select="$codeDefinition_sequence">
                                 <xsl:variable name="codeDefinition" select="." as="node()"/>
                                  <xsl:variable name="licenceVersion" as="xs:string*">
                                     <xsl:analyze-string select="normalize-space($licenceText)"
                                         regex="[\d.]+">
                                         <xsl:matching-substring>
                                             <xsl:value-of select="regex-group(0)"/>
                                         </xsl:matching-substring>
                                     </xsl:analyze-string>
                                  </xsl:variable>
                                 
                                 <xsl:variable name="licenceURI">
                                      <xsl:choose>
                                          <xsl:when test="(number($licenceVersion) > 3) and contains(gml:remarks, '/au')">
                                                  <xsl:value-of select="substring-before(replace($codeDefinition/gml:remarks, '\{n\}', $licenceVersion), '/au')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="replace($codeDefinition/gml:remarks, '\{n\}', $licenceVersion)"/>
                                            </xsl:otherwise>
                                      </xsl:choose>
                                  </xsl:variable>
                     
                                  <xsl:if test="$global_debug">
                                     <xsl:message select="concat('licenceURI : ', $licenceURI)"/>
                                  </xsl:if>
                                  
                                 <xsl:variable name="type" select="gml:identifier"/>
                                 
                                 <rights>
                                     <licence>
                                         
                                         <xsl:if test="string-length($licenceURI) and count($licenceVersion) > 0">
                                              <xsl:attribute name="rightsUri">
                                                  <xsl:value-of select="$licenceURI"/>
                                              </xsl:attribute>
                                         </xsl:if>
                                         
                                         <xsl:if test="string-length($type) > 0">
                                              <xsl:attribute name="type">
                                                  <xsl:value-of select="$type"/>
                                              </xsl:attribute>
                                         </xsl:if>
                                         
                                         <xsl:value-of select="$licenceText"/>
                                     </licence>
                                  </rights>
                                 
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <rights>
                                <licence>
                                    <xsl:value-of select="$licenceText"/>
                                </licence>
                            </rights>
                            <xsl:for-each select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage">
                                <rights>
                                    <licence>
                                        <xsl:attribute name="rightsUri">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </licence>
                                </rights>
                            </xsl:for-each>
                         </xsl:otherwise>
                    </xsl:choose>
     </xsl:template-->
    
    <!--xsl:template match="*" mode="registryObject_rights_licence_type_and_uri">
        <xsl:variable name="topNode" select="." as="node()"/>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Extracting urls from : ', string-join(.//*[contains(name(), 'CharacterString')],  '&#xA;'))"/>
        </xsl:if>
        
        <xsl:variable name="licenseLink_sequence" as="xs:string*">
            <xsl:analyze-string select="string-join(.//*[contains(name(), 'CharacterString')],  '&#xA;')" regex="(https?:)(//([^#\s]*))?(licens?c?)+(([^#\s]*))?">
                <xsl:matching-substring>
                    <matching0>
                        <xsl:value-of select="regex-group(0)"/>
                    </matching0>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Count extracted license link : ', count($licenseLink_sequence))"/>
        </xsl:if>
        
        <xsl:for-each select="distinct-values($licenseLink_sequence)">
            <xsl:variable name="licenseLink" select="."/>
            <xsl:variable name="licenseLinkTransformed">
                <xsl:variable name="normalized" select="normalize-space(replace(replace(., 'icence', 'icense', 'i'), 'https', 'http', 'i'))"/>
                <xsl:choose>
                    <xsl:when test="contains($normalized, 'creativecommons') and contains($normalized, '/legalcode')">
                        <xsl:value-of select="substring-before($normalized, '/legalcode')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$normalized"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <rights>
                <licence>
                    <xsl:if test="count($licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[(@*:id='LicenseCodeAustralia') or (@*:id='LicenseCodeInternational')]/gmx:codeEntry/gmx:CodeDefinition[contains(lower-case($licenseLinkTransformed), lower-case(replace(*:remarks, '\{n\}', '')))]/*:identifier) > 0">
                        <xsl:attribute name="type" select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[(@*:id='LicenseCodeAustralia') or (@*:id='LicenseCodeInternational')]/gmx:codeEntry/gmx:CodeDefinition[contains(lower-case($licenseLinkTransformed), lower-case(replace(*:remarks, '\{n\}', '')))]/*:identifier[1]"/>
                        <xsl:attribute name="rightsUri" select="$licenseLink"/>
                        
                        <Find all character strings that contained this link, and add them to licence text if they contain more text than only the link itself (otherwise we double up with rightsUri)>
                        <xsl:value-of select="string-join($topNode//*[contains(name(), 'CharacterString') and contains(text(), $licenseLink) and (string-length(text()) > string-length($licenseLink))], '&#xA;')"/>
                    </xsl:if>
                </licence>
            </rights>
        </xsl:for-each-->
        
        <!-- Add rightsStatement for each character string that did not contain a known license link and therefore was not handled above -->
        <!--xsl:for-each select="$topNode//*[contains(name(), 'CharacterString')][string-length(.) > 0]">
            
            <xsl:variable name="currentText" select="." as="xs:string"/>
            
            <xsl:variable name="alreadyWritten_booleanSequence" as="xs:boolean*">
                <xsl:for-each select="distinct-values($licenseLink_sequence)">
                    <xsl:variable name="licenseLink" select="."/>
                    <xsl:variable name="licenseLinkTransformed" select="normalize-space(replace(replace(., 'icence', 'icense', 'i'), 'https', 'http', 'i'))"/>
                    <xsl:if test="count($licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[(@*:id='LicenseCodeAustralia') or (@*:id='LicenseCodeInternational')]/gmx:codeEntry/gmx:CodeDefinition[contains(lower-case($licenseLinkTransformed), lower-case(replace(*:remarks, '\{n\}', '')))]/*:identifier) > 0">
                        <xsl:if test="contains($currentText, $licenseLink)">
                            <xsl:value-of select="true()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:if test="count($alreadyWritten_booleanSequence) = 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$currentText"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
            
        </xsl:for-each>
        
        
        
    </xsl:template-->
    
    <xsl:template match="mri:MD_AssociatedResource" mode="registryObject_relatedInfo_associatedResource">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:value-of select="mri:initiativeType/mri:DS_InitiativeTypeCode/@codeListValue"/>
            </xsl:attribute>
            
                <xsl:apply-templates select="mri:name/cit:CI_Citation/cit:identifier/mcc:MD_Identifier"/>
                <xsl:apply-templates select="mri:name/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage"  mode="identifier"/>
                <xsl:apply-templates select="mri:metadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier"/>
                <xsl:apply-templates select="mri:metadataReference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage"  mode="identifier"/>
                
                
                <relation>
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="matches(lower-case(mri:associationType/mri:DS_AssociationTypeCode/@codeListValue), 'dependency')">
                                <xsl:text>isOutputOf</xsl:text>
                            </xsl:when>
                           <xsl:otherwise>
                               <xsl:text>hasAssociationWith</xsl:text>
                           </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </relation>
            
            <title>
                <xsl:value-of select="concat(string-join(mri:name/cit:CI_Citation/cit:title[string-length(.) > 0], ' '), ' ', string-join(mri:metadataReference/cit:CI_Citation/cit:title[string-length(.) > 0], ' '))"/>
            </title>
        </relatedInfo>
    </xsl:template>
    
    <!--xsl:template match="mcc:code">
        
        <identifier>
            <xsl:attribute name="type">
                <xsl:value-of select="custom:getIdentifierType(.)"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template-->
    
    <xsl:template match="cit:linkage" mode="identifier">
        
        <identifier>
            <xsl:attribute name="type">
                <xsl:value-of select="custom:getIdentifierType(.)"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="mco:MD_LegalConstraints">
        
        <xsl:apply-templates select="mco:reference/cit:CI_Citation" mode="licence"/> 
        <xsl:apply-templates select="mco:otherConstraints[string-length(.) > 0]" mode="licence"/> 
        <xsl:apply-templates select="mco:useLimitation[string-length(.) > 0]" mode="rightsStatement"/> 
        <xsl:apply-templates select="mco:otherConstraints[string-length(.) > 0]" mode="rightsStatement"/> 
        
        
    </xsl:template>
    
    <xsl:template match="mco:MD_Constraints">
        
        <xsl:apply-templates select="mco:useLimitation[string-length(.) > 0]" mode="rightsStatement"/> 
        <xsl:apply-templates select="mco:otherConstraints[string-length(.) > 0]" mode="rightsStatement"/>     
        
    </xsl:template>
    
    
    <xsl:template match="cit:CI_Citation" mode="licence"> 
        <rights>
            <licence>
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="(contains(lower-case(cit:onlineResource/cit:CI_OnlineResource/cit:linkage), 'creativecommons.org/licenses/by/')) or
                            (matches(lower-case(cit:title), 'creative commons attribution \d'))">
                        <xsl:attribute name="type">
                            <xsl:text>CC-BY</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:value-of select="cit:alternateTitle"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="cit:title"/>
            </licence>
        </rights>
    </xsl:template>
        
    <xsl:template match="mco:otherConstraints" mode="licence"> 
        
        <xsl:if test="matches(lower-case(.), 'creative commons attribution \d')">
            <rights>
                <licence>
                    <xsl:attribute name="type">
                        <xsl:value-of select="'CC-BY'"/>
                    </xsl:attribute>
                </licence>
            </rights>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mco:MD_SecurityConstraints">
        <xsl:apply-templates select="mco:reference/cit:CI_Citation" mode="rightsStatement"/> 
        <xsl:apply-templates select="mco:useLimitation[string-length(.) > 0]" mode="rightsStatement"/> 
        <xsl:apply-templates select="mco:otherConstraints[string-length(.) > 0]" mode="rightsStatement"/> 
    </xsl:template>
    
    <xsl:template match="cit:CI_Citation" mode="rightsStatement"> 
        <rights>
            <rightsStatement>
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage"/>
                </xsl:attribute>
                <xsl:value-of select="cit:title"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="mco:useLimitation" mode="rightsStatement"> 
         <rights>
            <rightsStatement>
                <xsl:value-of select="."/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    
    <xsl:template match="mco:otherConstraints" mode="rightsStatement"> 
        <rights>
            <rightsStatement>
                <xsl:value-of select="."/>
            </rightsStatement>
        </rights>
    </xsl:template>
   
        
     
    
    <!-- RegistryObject - Rights Statement Access -->
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject_rights_access">
        <!-- if there is one or more MD_ClassificationCode of 'unclassified', and all occurences of MD_ClassificationCode are 'unclassified', set accessRights to 'open' -->
        <rights>
            <accessRights>
                <xsl:choose>
                    <xsl:when test="count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode[@codeListValue = 'unclassified']) > 0 and
                        count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode[not(@codeListValue = 'unclassified') and (string-length(normalize-space(@codeListValue)) > 0)]) = 0">
                        <xsl:attribute name="type">
                            <xsl:text>open</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <!-- when MD_ClassificationCode is populated, but not as above -->
                    <xsl:when test="count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode[not(@codeListValue = 'unclassified') and (string-length(normalize-space(@codeListValue)) > 0)]) > 0">
                        <xsl:attribute name="type">
                            <xsl:text>restricted</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <!-- all other cases -->
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:text>other</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </accessRights>
        </rights>
    </xsl:template>
    
     <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="registryObjectTypeSubType_sequence"/>
        
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
            <xsl:apply-templates select="." mode="selectCitationContributors"/>
        </xsl:variable>
        
       <xsl:if test="$global_debug">
            <xsl:for-each select="$allContributorName_sequence">
                    <xsl:message select="concat('Contributor name: ', .)"/>
            </xsl:for-each>
        </xsl:if>
        
        
        <xsl:variable name="priorityIdentifier_sequence" select="cit:identifier/mcc:MD_Identifier/mcc:code[(string-length(.) > 0) and not(contains(lower-case(.), 'dataset doi'))]" as="node()*"/>
        
        
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <identifier>
                        <xsl:choose>
                                <xsl:when test="(count($priorityIdentifier_sequence) > 0)">
                                    <xsl:attribute name="type" select="custom:getIdentifierType($priorityIdentifier_sequence[1])"/>
                                    <xsl:variable name="identifier" select="$priorityIdentifier_sequence[1]"/>
                                    <xsl:choose>
                                        <xsl:when test="starts-with($identifier, 'hdl:')">
                                            <xsl:value-of select="normalize-space(replace($identifier,'hdl:', ''))"/>   
                                        </xsl:when>
                                        <xsl:when test="starts-with($identifier, 'doi:')">
                                            <xsl:value-of select="normalize-space(replace($identifier,'doi:', ''))"/>   
                                        </xsl:when>
                                        <xsl:when test="matches($identifier, 'https?://dx.doi.org/')">
                                            <xsl:value-of select="normalize-space(substring-after($identifier,'dx.doi.org/'))"/>   
                                        </xsl:when>
                                        <xsl:when test="matches($identifier, 'https?://doi.org/')">
                                            <xsl:value-of select="normalize-space(substring-after($identifier,'doi.org/'))"/>   
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$identifier"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage[string-length(.) > 0]) > 0">
                                    <xsl:attribute name="type" select="'uri'"/>
                                    <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage[string-length(.) > 0][1]"/> 
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="type" select="'uri'"/>
                                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::mdb:MD_Metadata/mdb:metadataIdentifier[1]/mcc:MD_Identifier[1]/mcc:code[1])"/>
                                </xsl:otherwise>
                        </xsl:choose>
                    </identifier>
             
                    <title>
                        <xsl:value-of select="cit:title"/>
                    </title>
                    
                    <xsl:if test="$global_debugExceptions">
                        <xsl:choose>
                            <xsl:when test="count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 1">
                                <xsl:message select="'Exception: more than one publication date in citation block'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    
                   <date>
                        <xsl:attribute name="type">
                            <xsl:text>publicationDate</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 0) and
                                      (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 0) and
                                    (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 0) and
                                    (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            </xsl:choose>
                    </date>
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisher_sequence" as="node()*" select="
                        cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party |
                        ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party"/>  
                    
                    
                    <xsl:choose>
                        <xsl:when test="count($allContributorName_sequence) > 0">
                            <xsl:for-each select="distinct-values($allContributorName_sequence)">
                                        <contributor seq="{position()}">
                                            <namePart>
                                                <xsl:value-of select="."/>
                                            </namePart>
                                        </contributor>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    
                    <publisher>
                        <xsl:choose>
                            <xsl:when test="count(cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'][1]/cit:party[1]/cit:CI_Organisation/cit:name"/>    
                            </xsl:when>
                            <xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'][1]/cit:party[1]/cit:CI_Organisation/cit:name"/>
                            </xsl:when>
                            <xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'][1]/cit:party[1]/cit:CI_Organisation/cit:name"/>
                            </xsl:when>
                            <!--xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility[1]/cit:party[1]/cit:CI_Organisation/cit:name"/>
                            </xsl:when-->
                        </xsl:choose>
                    </publisher>
                    
               </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cit:CI_Citation" mode="selectCitationContributors">
       <!-- override if you want to filter citation contributors-->
        <xsl:choose>
            <!-- use any invidual names of any role -->
            <xsl:when test="
                ((count(cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0) or
                (count(cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0))">
                <!-- note that even when no results are found, value-of constructs empty text node, so copy-of is used below instead -->
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- there are no invidual names that are either author or coAuthor, so use organisation names -->
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]"/>
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
  
    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <xsl:template match="cit:CI_Individual" mode="party_person">
        <xsl:param name="originatingSource"/>
        
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="string-length(cit:name) > 0">
                    <xsl:value-of select="cit:name"/>
                </xsl:when>
                <xsl:when test="string-length(cit:positionName) > 0">
                    <xsl:value-of select="cit:positionName"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <registryObject group="{$global_group}">
            
            <key>
                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
            
            <party type="person">
                <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                <xsl:apply-templates select="cit:partyIdentifier/mcc:MD_Identifier"/>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space($name)"/>
                    </namePart>
                </name>
                
                
                <!-- If this individual does not have contactInfo, and is a child of CI_Organisation , associate email and phone number from the Organisation with this individual -->
                <xsl:choose>
                    <xsl:when test="(count(cit:contactInfo) = 0) and contains(name(../..), 'CI_Organisation')">
                        <!--xsl:apply-templates select="ancestor::cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/-->
                        <!--xsl:apply-templates select="ancestor::cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/-->
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
                        <!--xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/-->
                        <!--xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/-->
                    </xsl:otherwise>
                </xsl:choose>
                
                
                
            </party>
        </registryObject>
    </xsl:template>
        
    <xsl:template match="cit:CI_Organisation" mode="party_group">
        <xsl:param name="originatingSource"/>
            
           <registryObject group="{$global_group}">
            
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
               </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="group">
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    <xsl:apply-templates select="cit:partyIdentifier/mcc:MD_Identifier"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource[contains(lower-case(.), 'abn')]" mode="ABN"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:name)"/>
                        </namePart>
                    </name>
                    
                    <xsl:choose>
                        <xsl:when test="(count(cit:individual/cit:CI_Individual) > 0)"> 
                            <!--  individual position name, so relate this individual to this organisation... -->
                            <xsl:for-each select="cit:individual/cit:CI_Individual">
                                <xsl:variable name="name">
                                    <xsl:choose>
                                        <xsl:when test="string-length(cit:name) > 0">
                                            <xsl:value-of select="cit:name"/>
                                        </xsl:when>
                                        <xsl:when test="string-length(cit:positionName) > 0">
                                            <xsl:value-of select="cit:positionName"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <xsl:if test="(string-length($name) > 0)">
                                  <relatedInfo type="party">
                                      <identifier type="local">
                                          <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                      </identifier>
                                      <title>
                                          <xsl:value-of select="normalize-space($name)"/>
                                      </title>
                                      <relation type="hasMember"/>
                                  </relatedInfo>
                                </xsl:if>  
                             </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--  no individual position name, so use this address for this organisation -->
                            <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
                            <!--xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/-->
                            <!--xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/-->
                        </xsl:otherwise>
                   </xsl:choose>
                    
                </party>
        </registryObject>
        <!--xsl:if test="(count(cit:individual/cit:CI_Individual) > 0) and (string-length(cit:individual/cit:CI_Individual/cit:positionName) > 0)"> 
            <xsl:apply-templates select="." mode="party_position">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:if-->
     </xsl:template>     
     
     <!--xsl:template match="cit:CI_Organisation" mode="party_position">
            <xsl:param name="originatingSource"/>
            
           <registryObject group="{$global_group}">
            
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:individual/cit:CI_Individual/cit:positionName),' ',''))"/>
               </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="person">
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:individual/cit:CI_Individual/cit:positionName)"/>
                        </namePart>
                    </name>
                    
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone"/>
                    
                </party>
        </registryObject>
     </xsl:template-->
    
    <xsl:template match="cit:CI_OnlineResource">
        <xsl:if test="string-length(cit:linkage) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="custom:getIdentifierType(cit:linkage)"/>       
                </xsl:attribute>
                <xsl:value-of select="cit:linkage"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
   <xsl:template match="mcc:MD_Identifier">
        <xsl:if test="string-length(mcc:code) > 0">
            <identifier>
                <xsl:choose>
                    <xsl:when test="string-length(mcc:codeSpace) > 0">
                        <xsl:attribute name="type">
                            <xsl:value-of select="custom:getIdentifierType(mcc:codeSpace)"/>       
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:value-of select="custom:getIdentifierType(mcc:code)"/>       
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="mcc:code"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mcc:MD_Identifier" mode="global_identifier">
        <xsl:if test="string-length(mcc:code) > 0">
            <identifier>
               <xsl:attribute name="type">
                    <xsl:text>global</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="mcc:code"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource[contains(lower-case(.), 'abn')]" mode="ABN">
        <xsl:if test="string-length(cit:linkage) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>ABN</xsl:text>
                </xsl:attribute>
                <xsl:analyze-string select="cit:linkage" regex="[\d]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </identifier>
        </xsl:if>
    </xsl:template>
    
                     
    <xsl:template match="cit:CI_Address">
        <xsl:if test="
            (count(cit:deliveryPoint[string-length(.) > 0]) > 0) or
            (count(cit:city[string-length(.) > 0]) > 0) or
            (count(cit:administrativeArea[string-length(.) > 0]) > 0) or
            (count(cit:postalCode[string-length(.) > 0]) > 0) or
            (count(cit:country[string-length(.) > 0]) > 0)">
            <location>
                <address>
                    <physical type="streetAddress">
                       
                        <xsl:for-each select="cit:deliveryPoint">
                             <addressPart type="addressLine">
                                 <xsl:value-of select="normalize-space(.)"/>
                             </addressPart>
                        </xsl:for-each>
                        
                         <xsl:for-each select="cit:city">
                              <addressPart type="suburbOrPlaceLocality">
                                  <xsl:value-of select="normalize-space(.)"/>
                              </addressPart>
                        </xsl:for-each>
                        
                         <xsl:for-each select="cit:administrativeArea">
                             <addressPart type="stateOrTerritory">
                                 <xsl:value-of select="normalize-space(.)"/>
                             </addressPart>
                         </xsl:for-each>
                            
                         <xsl:for-each select="cit:postalCode">
                             <addressPart type="postCode">
                                 <xsl:value-of select="normalize-space(.)"/>
                             </addressPart>
                         </xsl:for-each>
                         
                          <xsl:for-each select="cit:country">
                             <addressPart type="country">
                                 <xsl:value-of select="normalize-space(.)"/>
                             </addressPart>
                        </xsl:for-each>
                    </physical>
                </address>
            </location>
        </xsl:if>
    </xsl:template>
    
    
    <!--xsl:template match="cit:electronicMailAddress">

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
    
    <!--xsl:template match="cit:CI_Telephone">
        <xsl:for-each select=".[cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'facsimile']/cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:attribute name="type">
                                <xsl:text>faxNumber</xsl:text>
                            </xsl:attribute>
                           <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
        
        <xsl:for-each select=".[cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'voice']/cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:attribute name="type">
                                <xsl:text>telephoneNumber</xsl:text>
                            </xsl:attribute>
                           <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template-->
    
   
    
</xsl:stylesheet>