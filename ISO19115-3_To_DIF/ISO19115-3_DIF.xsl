<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
    xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
    xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
    xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
    xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
    xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
    xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
    xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
    xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
    xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
    xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
    xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
    xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
    xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
    xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
    xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
    xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
    xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
    xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
    xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0"
    xmlns:local="http://local.function" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">
   
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="constant_unit_metres" select="'m'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//mdb:MD_Metadata" mode="DIF"/>
    </xsl:template>
    
    <!-- Conversion from ISO19115-3 XML to DIF 9.9.3 XML -->
    <!-- Applies mapping rules provided by Emma Flukes emma.flukes@utas.edu.au -->
    
    <xsl:template match="mdb:MD_Metadata" mode="DIF">
        
        <DIF xmlns="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/ https://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/dif_v9.9.3.xsd">
            
            <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code" mode="DIF_Entry_ID"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" mode="DIF_Entry_Title"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification" mode="DIF_Data_Set_Citation"/>
            
            <!--
            <xsl:apply-templates select="mdb:contact/cit:CI_Responsibility" mode="DIF_Personnel"/>
            <xsl:apply-templates select="mri:contact/cit:CI_Responsibility" mode="DIF_Personnel"/>
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility" mode="DIF_Personnel"/>
            -->
            
            <xsl:for-each-group select="mdb:contact/cit:CI_Responsibility | mri:contact/cit:CI_Responsibility | mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility" group-by="cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name">
                <xsl:apply-templates select="." mode="DIF_Personnel_Grouped"></xsl:apply-templates>
            </xsl:for-each-group>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords[contains(lower-case(mri:thesaurusName/cit:CI_Citation/cit:title), 'gcmd')]/mri:keyword" mode="DIF_Parameters"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode" mode="DIF_ISO_Topic_Category"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords[not (contains(lower-case(mri:thesaurusName/cit:CI_Citation/cit:title), 'gcmd'))]/mri:keyword" mode="DIF_Keyword"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod" mode="DIF_Temporal_Coverage"/>
            
            <!-- Ask Emma for an example of timePosition --> 
            <!--xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition" mode="DIF_Temporal_Coverage"/-->
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mcc:MD_ProgressCode" mode="DIF_Data_Set_Progress"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent" mode="DIF_Spatial_Coverage"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints[3]/mco:MD_LegalConstraints/mco:otherConstraints" mode="DIF_Access_Constraints"/>
            
            <xsl:apply-templates select="mdb:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode" mode="DIF_Data_Set_Language"/>
            
            <!--xsl:apply-templates select="mdb:contact/cit:CI_Responsibility/cit:party[contains(lower-case(*/cit:positionName), 'data manager')]" mode="DIF_Data_Centre"/-->
            
            <!-- Note defaulted area below needs to be changed if you aren't that data centre - you can use the line above if you want to make it conditional on actual values-->
            
            <Data_Center>
                <Data_Center_Name>
                    <Short_Name>AU/IMAS</Short_Name>
                    <Long_Name>Institute for Marine and Antarctic Studies (IMAS)</Long_Name>
                </Data_Center_Name>
                <Personnel>
                    <Role>DATA CENTER CONTACT</Role>
                    <First_Name>Institute for Marine and Antarctic Studies (IMAS)</First_Name>
                    <Middle_Name/>
                    <Last_Name/>
                    <Email>IMAS.DataManager@utas.edu.au</Email>
                </Personnel>
            </Data_Center>
            
            <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" mode="DIF_Distribution"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:credit" mode="DIF_Reference"/>
    
            <Summary>
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract" mode="DIF_Summary_Abstract"/>
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose" mode="DIF_Summary_Purpose"/>
            </Summary>
            
            <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource
                [not(contains(lower-case(cit:protocol), 'http--publication'))]"  mode="DIF_Related_URL_ExceptPublications"/>
            
            <xsl:apply-templates select="mdb:metadataLinkage/cit:CI_OnlineResource"  mode="DIF_Related_URL_ExceptPublications"/>
            
            <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions"  mode="DIF_Related_URL_OnlyPublications"/>
            
            <xsl:apply-templates select="mdb:parentMetadata" mode="DIF_Parent_DIF"/>
            
            <!-- Note defaulted values here -->
            <Originating_Metadata_Node>GCMD</Originating_Metadata_Node>
            <Metadata_Name>CEOS IDN DIF</Metadata_Name>
            <Metadata_Version>VERSION 9.9.3</Metadata_Version>
            
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date[contains(lower-case(cit:dateType/cit:CI_DateTypeCode/@codeListValue), 'creation')]/cit:date/*[contains(local-name(), 'Date')]" mode="DIF_Creation_Date"/>
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date[contains(lower-case(cit:dateType/cit:CI_DateTypeCode/@codeListValue), 'revision')]/cit:date/*[contains(local-name(), 'Date')]" mode="DIF_Revision_Date"/>
            
        </DIF>
    </xsl:template>
        
    <xsl:template match="mcc:code" mode="DIF_Entry_ID">
        <Entry_ID><xsl:value-of select="."/></Entry_ID>
    </xsl:template>
    
    <xsl:template match="cit:title" mode="DIF_Entry_Title">
        <Entry_Title><xsl:value-of select="."/></Entry_Title>
    </xsl:template>
    
    <xsl:template match="mri:MD_DataIdentification" mode="DIF_Data_Set_Citation">
        
        <xsl:variable name="citedResponsiblePartyIndividualNames_NoTitle_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values(mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name)">
                <xsl:variable name="individualNamesOnlyNoTitle_sequence" select="local:nameSeparatedNoTitle_sequence(.)"/>
                <xsl:for-each select="$individualNamesOnlyNoTitle_sequence">
                    <xsl:message select="concat('string length of ', ., ' is ', string-length(.))"/>
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="string-length(.) = 1">
                            <!-- Presume initial only, so add fullstop -->
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="string-length(.) = 2">
                            <xsl:choose>
                            <!-- if this is an initial and a full stop, just use it -->
                             <xsl:when test="substring(., 2, 1) = '.'">
                                 <xsl:value-of select="."/>
                             </xsl:when>
                             <xsl:otherwise>
                                 <xsl:value-of select="concat(substring(., 1, 1),'.')"/>
                             </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="string-length(.) > 2">
                           <!-- More than an initial and fullstop, so truncate to initial and fullstop -->
                            <xsl:value-of select="concat(substring(., 1, 1),'.')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        
        <Data_Set_Citation>
            <Dataset_Creator>
                <xsl:value-of select="string-join($citedResponsiblePartyIndividualNames_NoTitle_sequence, ', ')"/>
            </Dataset_Creator>
            <Dataset_Title>
                <xsl:value-of select="mri:citation/cit:CI_Citation/cit:title"/>
            </Dataset_Title>
            <Dataset_Release_Date>
                <xsl:value-of select="mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[contains(cit:dateType/cit:CI_DateTypeCode/@codeListValue, 'publication')]/cit:date/gco:Date"/>
            </Dataset_Release_Date>
            
            <xsl:variable name="citedResponsiblePartyOrganisationNames_sequence"
                select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name">
            </xsl:variable>
            <Dataset_Publisher>
                <xsl:if test="count($citedResponsiblePartyOrganisationNames_sequence) > 0">
                    <xsl:value-of select="$citedResponsiblePartyOrganisationNames_sequence[1]"/>
                </xsl:if>
            </Dataset_Publisher>
            <Dataset_DOI>
                <xsl:variable name="doi" select="mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:authority/cit:CI_Citation/cit:title), 'digital object identifier')]/mcc:code[contains(., 'doi') or contains(., '10.')]"/>
                <xsl:choose>
                    <xsl:when test="contains($doi, 'doi:')">
                        <xsl:value-of select="substring-after($doi, 'doi:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$doi"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </Dataset_DOI>
        </Data_Set_Citation>
    </xsl:template>
    <xsl:template match="cit:CI_Responsibility" mode="DIF_Personnel_Grouped">
        <xsl:variable name="namePart_sequence" select="local:nameSeparatedNoTitle_sequence(current-grouping-key())" as="xs:string*"/>
        
        <Personnel>
            <xsl:variable name="mapped_role_Sequence" as="xs:string*">
                <xsl:for-each-group select="current-group()" group-by="local:mapRole_ISO_DIF(cit:role/cit:CI_RoleCode/@codeListValue)">
                    <xsl:value-of select="current-grouping-key()"/>
                </xsl:for-each-group>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="local:sequenceContains($mapped_role_Sequence, 'INVESTIGATOR')">
                    <Role>INVESTIGATOR</Role>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Just take the first one if there is no INVESTIGATOR -->
                    <Role><xsl:value-of select="$mapped_role_Sequence[1]"/></Role>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:choose>
                <xsl:when test="(count($namePart_sequence) > 0)">
                    <First_Name>
                        <xsl:if test="count($namePart_sequence) > 1">
                            <xsl:value-of select="$namePart_sequence[2]"/>
                        </xsl:if>
                    </First_Name>
                    <Last_Name>
                        <xsl:if test="count($namePart_sequence) > 0">
                            <xsl:value-of select="$namePart_sequence[1]"/>
                        </xsl:if>
                    </Last_Name>
                </xsl:when>
               </xsl:choose>
            <xsl:apply-templates select="current-group()[1]/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address" mode="DIF_Personnel_Address"/>
        </Personnel>
        
    </xsl:template>
       
    <xsl:template match="cit:CI_Address" mode="DIF_Personnel_Address">
            <Email>
                <xsl:value-of select="cit:electronicMailAddress"/>
            </Email>
            <Contact_Address>
                <xsl:for-each select="cit:deliveryPoint">
                    <Address>
                        <xsl:value-of select="."/>
                    </Address>
                </xsl:for-each>    
                <City>
                    <xsl:value-of select="cit:city"></xsl:value-of>
                </City>
                <Province_or_State>
                    <xsl:value-of select="cit:administrativeArea"></xsl:value-of>
                </Province_or_State>
                <Postal_Code>
                    <xsl:value-of select="cit:postalCode"></xsl:value-of>
                </Postal_Code>
                <Country>
                        <xsl:value-of select="cit:country"></xsl:value-of>
                </Country>
            </Contact_Address>
    </xsl:template>


    <xsl:template match="mri:keyword" mode="DIF_Parameters">
        
        <xsl:variable name="parameter_sequence" select="tokenize(., '\|')"/>
        
        <Parameters>
            
        <xsl:if test="count($parameter_sequence) > 0">
        
                <Category>
                    <xsl:if test="count($parameter_sequence) > 0">
                        <xsl:value-of select="normalize-space($parameter_sequence[1])"/>
                    </xsl:if>
                </Category>
                <Topic>
                    <xsl:if test="count($parameter_sequence) > 1">
                        <xsl:value-of select="normalize-space($parameter_sequence[2])"/>
                    </xsl:if>
                </Topic>
                <Term>
                    <xsl:if test="count($parameter_sequence) > 2">
                        <xsl:value-of select="normalize-space($parameter_sequence[3])"/>
                    </xsl:if>
                </Term>
                <Variable_Level_1>
                    <xsl:if test="count($parameter_sequence) > 3">
                        <xsl:value-of select="normalize-space($parameter_sequence[4])"/>
                    </xsl:if>
                </Variable_Level_1>
                
            <Variable_Level_2>
                <xsl:if test="count($parameter_sequence) > 4">
                    <xsl:value-of select="normalize-space($parameter_sequence[5])"/>
                </xsl:if>
            </Variable_Level_2>
            
            </xsl:if>
        </Parameters>
    </xsl:template>
    
    <xsl:template match="mri:MD_TopicCategoryCode" mode="DIF_ISO_Topic_Category">
        <ISO_Topic_Category>
            <xsl:value-of select="."/>
        </ISO_Topic_Category>
    </xsl:template>
    
    <xsl:template match="mri:keyword" mode="DIF_Keyword">
        <Keyword>
            <xsl:value-of select="."/>
        </Keyword>
    </xsl:template>
    
    <xsl:template match="gml:TimePeriod" mode="DIF_Temporal_Coverage">
    
        <Temporal_Coverage>
            <Start_Date>
                <xsl:value-of select="local:truncDate(gml:beginPosition)"/>
            </Start_Date>
            <Stop_Date>
                <xsl:value-of select="local:truncDate(gml:endPosition)"/>
            </Stop_Date>
        </Temporal_Coverage>
        
    </xsl:template>
    
    <!--xsl:template match="gml:timePosition" mode="DIF_Temporal_Coverage">
        
        <Temporal_Coverage>
            <Start_Date>
                <xsl:value-of select="local:truncDate(.)"/>
            </Start_Date>
        </Temporal_Coverage>
    </xsl:template-->
    

    <xsl:template match="mcc:MD_ProgressCode" mode="DIF_Data_Set_Progress">
        <Data_Set_Progress>
            <xsl:choose>
                <xsl:when test="contains(lower-case(@codeListValue), 'ongoing')">
                    <xsl:text>IN WORK</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(@codeListValue), 'completed')">
                    <xsl:text>COMPLETE</xsl:text>
                </xsl:when>
            </xsl:choose>
        </Data_Set_Progress>
    </xsl:template>
    
    <xsl:template match="gex:EX_Extent" mode="DIF_Spatial_Coverage">
    
        <Spatial_Coverage>
            <Southernmost_Latitude>
                <xsl:value-of select="gex:geographicElement/gex:EX_GeographicBoundingBox/gex:southBoundLatitude"/>
            </Southernmost_Latitude>
            <Northernmost_Latitude>
                <xsl:value-of select="gex:geographicElement/gex:EX_GeographicBoundingBox/gex:northBoundLatitude"/>
            </Northernmost_Latitude>
            <Westernmost_Longitude>
                <xsl:value-of select="gex:geographicElement/gex:EX_GeographicBoundingBox/gex:westBoundLongitude"/>
            </Westernmost_Longitude>
            <Easternmost_Longitude>
                <xsl:value-of select="gex:geographicElement/gex:EX_GeographicBoundingBox/gex:eastBoundLongitude"/>
            </Easternmost_Longitude>
            
            <xsl:apply-templates select="gex:verticalElement/gex:EX_VerticalExtent" mode="DIF_Spatial_Coverage_Vertical"/>
            
        </Spatial_Coverage>
        
    </xsl:template>
    
    <xsl:template match="gex:EX_VerticalExtent" mode="DIF_Spatial_Coverage_Vertical">
        <xsl:variable name="units" select="local:unitsFromVerticalCRS(gex:verticalCRS/gml:VerticalCRS/gml:identifier)"/>
        
        <xsl:apply-templates select="gex:minimumValue[string-length(.) > 0]" mode="DIF_Spatial_Coverage_Vertical_Minimum">
            <xsl:with-param name="units" select="$units"/>
        </xsl:apply-templates>
    
        <xsl:apply-templates select="gex:maximumValue[string-length(.) > 0]" mode="DIF_Spatial_Coverage_Vertical_Maximum">
            <xsl:with-param name="units" select="$units"/>
        </xsl:apply-templates>
    
    </xsl:template>
    
    <xsl:template match="gex:minimumValue" mode="DIF_Spatial_Coverage_Vertical_Minimum">
        <xsl:param name="units"/>
        <Minimum_Depth>
            <xsl:value-of select="concat(., $units)"/>
        </Minimum_Depth>
    </xsl:template>
    
    <xsl:template match="gex:maximumValue" mode="DIF_Spatial_Coverage_Vertical_Maximum">
        <xsl:param name="units"/>
        <Maximum_Depth>
            <xsl:value-of select="concat(., $units)"/>
        </Maximum_Depth>
    </xsl:template>
    
    <xsl:template match="mco:otherConstraints" mode="DIF_Access_Constraints">
        <Access_Constraints>
           <xsl:value-of select="."/>
        </Access_Constraints>
    </xsl:template>
    
    <xsl:template match="lan:LanguageCode" mode="DIF_Data_Set_Language">
        <Data_Set_Language>
            <xsl:if test="contains(lower-case(@codeListValue), 'eng')">
                <xsl:text>English</xsl:text>
            </xsl:if>
        </Data_Set_Language>
    </xsl:template>
    
    <!--
  
    <xsl:template match="cit:party" mode="DIF_Data_Centre">
        <Data_Center>
            <Data_Center_Name>
                <Short_Name>
                    <xsl:if test="contains(lower-case(cit:CI_Organisation/cit:name), 'imas') or contains(lower-case(cit:CI_Organisation/cit:name), 'institute for marine and antarctic studies')">
                        <xsl:text>AU/IMAS</xsl:text>
                    </xsl:if>
                </Short_Name>
                <Long_Name>
                    <xsl:choose>
                        <xsl:when test="contains(cit:CI_Organisation/cit:name, ',')">
                            <xsl:value-of select="substring-before(cit:CI_Organisation/cit:name, ',')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="cit:CI_Organisation/cit:name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </Long_Name>
            </Data_Center_Name>
            <Personnel>
                <Role>DATA CENTER CONTACT</Role>
                <First_Name>
                    <xsl:choose>
                        <xsl:when test="contains(cit:CI_Organisation/cit:name, ',')">
                            <xsl:value-of select="substring-before(cit:CI_Organisation/cit:name, ',')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="cit:CI_Organisation/cit:name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </First_Name>
                <Middle_Name/>
                <Last_Name/>
                <xsl:for-each select="//cit:electronicMailAddress">
                    <Email>
                        <xsl:value-of select="."/>
                    </Email>
                </xsl:for-each>
                
            </Personnel>
        </Data_Center>
    </xsl:template>
    -->
    
    <xsl:template match="cit:title" mode="DIF_Distribution">
        <Distribution>
            <Distribution_Media>FTP</Distribution_Media>
            <Distribution_Format>
                <xsl:value-of select="."/>
             </Distribution_Format>
        </Distribution>
        
    </xsl:template>
    
    <xsl:template match="mri:credit" mode="DIF_Reference">
        <Reference>
           <xsl:value-of select="."/>
        </Reference>
    </xsl:template>
   
    <xsl:template match="mri:abstract" mode="DIF_Summary_Abstract">
        <Abstract>
            <xsl:value-of select="."/>
        </Abstract>
    </xsl:template>
    
    <xsl:template match="mri:purpose" mode="DIF_Summary_Purpose">
        <Purpose>
            <xsl:value-of select="."/>
        </Purpose>
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource"  mode="DIF_Related_URL_ExceptPublications">
        <Related_URL>
            <URL_Content_Type>
                <Type>
                    <xsl:value-of select="local:mapRelatedUrlType_ISO_DIF(cit:protocol)"/>
                </Type>
                <xsl:if test="string-length(local:mapRelatedUrlSubType_ISO_DIF(cit:protocol)) > 0">
                    <Subtype>
                        <xsl:value-of select="local:mapRelatedUrlSubType_ISO_DIF(cit:protocol)"/>
                    </Subtype>
                </xsl:if>
            </URL_Content_Type>
            <URL>
                <xsl:value-of select="cit:linkage"/>
            </URL>
            <Description>
                <xsl:choose>
                    <xsl:when test="contains(lower-case(cit:protocol), 'wfs') or contains(lower-case(cit:protocol), 'wms')">
                        <xsl:value-of select="cit:description"/>
                        <xsl:if test="string-length(cit:name) > 0">
                            <xsl:value-of select="concat(' (', cit:name, ')')"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="contains(lower-case(cit:protocol), 'http--metadata-url')">
                        <xsl:value-of select="cit:description"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="cit:name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </Description>
        </Related_URL>
    </xsl:template>
    
    <xsl:template match="mdb:parentMetadata" mode="DIF_Parent_DIF">
            <Parent_DIF>
                <xsl:value-of select="@uuidref"/>
            </Parent_DIF>
        </xsl:template>
        
        <xsl:template match="*[contains(local-name(), 'Date')]" mode="DIF_Creation_Date">
            <DIF_Creation_Date>
                <xsl:value-of select="local:truncDate(.)"/>
             </DIF_Creation_Date>
        </xsl:template>
    
    <xsl:template match="*[contains(local-name(), 'Date')]" mode="DIF_Revision_Date">
        <DIF_Revision_Date>
            <xsl:value-of select="local:truncDate(.)"/>
        </DIF_Revision_Date>
    </xsl:template>
        
        <!--xsl:template match="??" mode="DIF_Last_DIF_Revision_Date">
            <Last_DIF_Revision_Date>
                <xsl:value-of select="local:truncDate(.)"/>
            </Last_DIF_Revision_Date>
        </xsl:template-->
    
    
    
    <xsl:template match="mrd:MD_DigitalTransferOptions"  mode="DIF_Related_URL_OnlyPublications">
        
        <xsl:if test="count(mrd:onLine/cit:CI_OnlineResource[not(contains(lower-case(cit:protocol), 'http--publication'))]) > 0">
            <Related_URL>
                <URL_Content_Type>
                    <Type>VIEW RELATED INFORMATION</Type>
                    <Subtype>PUBLICATIONS</Subtype>
                </URL_Content_Type>
                <xsl:for-each select="mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:protocol), 'http--publication')]/cit:linkage">
                    <URL>
                        <xsl:value-of select="."/>
                    </URL>
                </xsl:for-each>
             </Related_URL>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="local:unitsFromVerticalCRS">
        <xsl:param name="verticalCRS_identifier"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($verticalCRS_identifier), 'epsg::5715')">
                <xsl:text>m</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:mapRelatedUrlType_ISO_DIF">
        <xsl:param name="protocol"/>
            <xsl:choose>
                <xsl:when test="contains(lower-case($protocol), 'downloaddata')">
                    <xsl:text>GET DATA</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'http--portal')">
                    <xsl:text>GOTO WEB TOOL</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'http--readme')">
                    <xsl:text>VIEW RELATED INFORMATION</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'http--manual')">
                    <xsl:text>VIEW RELATED INFORMATION</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'http--metadata-url')">
                    <xsl:text>DATA SET LANDING PAGE</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'wms')">
                    <xsl:text>USE SERVICE API</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'wfs')">
                    <xsl:text>USE SERVICE API</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($protocol), 'http--') and contains(lower-case($protocol), 'www:link')">
                    <xsl:text>VIEW RELATED INFORMATION</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:mapRelatedUrlSubType_ISO_DIF">
        <xsl:param name="protocol"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($protocol), 'downloaddata')">
                <xsl:text>DIRECT DOWNLOAD</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'http--portal')">
                <xsl:text>MAP VIEWER</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'http--readme')">
                <xsl:text>READ-ME</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'http--manual')">
                <xsl:text>USER’S MANUAL</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'http--metadata-url')">
                <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'wms')">
                <xsl:text>WEB MAP SERVICE (WMS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'wfs')">
                <xsl:text>WEB FEATURE SERVICE (WFS)</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($protocol), 'http--') and contains(lower-case($protocol), 'www:link')">
                <xsl:text></xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="local:mapRole_ISO_DIF">
        <xsl:param name="role"></xsl:param>
        <xsl:choose>
            <!-- Check with Emma that 'AUTHOR' is correct here -->
            <xsl:when test="contains(lower-case($role), 'author')">
                <xsl:text>AUTHOR</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($role), 'principalinvestigator')">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($role), 'coinvestigator')">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($role), 'pointofcontact')">
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:nameSeparatedNoTitle_sequence" as="xs:string*">
        <xsl:param name="individualName"/>
        
        <!-- Filter out each name and title, so allow a '/' as in 'Assoc/Prof', and include '.' as after an initial-->
        <xsl:analyze-string select="$individualName" regex="[A-z./]+">
            <xsl:matching-substring>
                <!-- then return names only - no titles -->
                <xsl:if test="not(matches(regex-group(0), '(Miss|Mr|Mrs|Ms|Dr|PhD|Assoc/Prof|Professor|Prof)'))">
                    <xsl:value-of select="regex-group(0)"/>
                </xsl:if>
            </xsl:matching-substring>
        </xsl:analyze-string>
  
    </xsl:function>
    
    <xsl:function name="local:truncDate">
        <xsl:param name="dateIn"></xsl:param>
        <xsl:choose>
            <xsl:when test="contains($dateIn, 'T')">
                <xsl:value-of select="substring-before($dateIn, 'T')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$dateIn"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="local:sequenceContains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="str" as="xs:string"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="contains(lower-case(.), lower-case($str))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    
</xsl:stylesheet>
