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
    
    <!-- Conversion from ISO19115-3 XML to DIF 9.9.3 XML -->
    <!-- Applies mapping rules provided by Emma Flukes emma.flukes@utas.edu.au -->
    
    <!-- If you are using this for the first time, you will need to provide default 
        values within the params below, to suit your needs.  You can either update 
        the values within your own copy of this file, or if you want to keep this 
        as-is for multiple users, you can call this XSLT from another new XSLT that 
        sets the defaults (all it needs is a line: <xsl:import href="ISO19115-3_DIF.xsl"/> 
        followed by the defaults as shown below, but populated with your own values)
        See for example https://github.com/MetadataToolsARDC/XSLT/blob/master/ISO19115-3_To_DIF/ISO19115_3_DIF_IMAS_TopLevel.xsl 
        that calls this file https://github.com/MetadataToolsARDC/XSLT/blob/master/ISO19115-3_To_DIF/ISO19115-3_DIF_9.9.3.xsl
    -->
    
    <xsl:param name="default_units_depth" select="''"/>
    <xsl:param name="default_units_altitude" select="''"/>
    <xsl:param name="default_discipline_name" select="''"/>
    <xsl:param name="default_data_centre_short_name" select="''"/>
    <xsl:param name="default_data_centre_long_name" select="''"/>
    <xsl:param name="default_data_centre_url" select="''"/>
    <xsl:param name="default_data_centre_personnel_role" select="''"/>
    <xsl:param name="default_data_centre_personnel_first_name" select="''"/>
    <xsl:param name="default_data_centre_personnel_last_name" select="''"/>
    <xsl:param name="default_data_centre_personnel_email" select="''"/>
    <xsl:param name="default_originating_metadata_node" select="''"/>
    <xsl:param name="default_IDN_Node_sequence" select="'', '', '', ''"/>
    <xsl:param name="default_metadata_name" select="'CEOS IDN DIF'"/>
    <xsl:param name="default_metadata_version" select="'VERSION 9.9.3'"/>
    <xsl:param name="default_target_group" select="'gov.nasa.gsfc.gcmd'"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//mdb:MD_Metadata" mode="DIF"/>
    </xsl:template>
    
    <xsl:template match="mdb:MD_Metadata" mode="DIF">
        
        <DIF xmlns="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/ https://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/dif_v9.9.3.xsd">
            
            <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code" mode="DIF_Entry_ID"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title" mode="DIF_Entry_Title"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification" mode="DIF_Data_Set_Citation"/>
            
            <xsl:for-each-group select="
                mdb:contact/cit:CI_Responsibility | 
                mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility |
                mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility" 
                group-by="cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name">
                <xsl:apply-templates select="." mode="DIF_Personnel_Grouped"></xsl:apply-templates>
            </xsl:for-each-group>
            
            <Discipline>
                <Discipline_Name>
                    <xsl:value-of select="$default_discipline_name"/>
                </Discipline_Name>
            </Discipline>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords[contains(lower-case(mri:thesaurusName/cit:CI_Citation/cit:title), 'gcmd')]/mri:keyword" mode="DIF_Parameters"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode" mode="DIF_ISO_Topic_Category"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords[not (contains(lower-case(mri:thesaurusName/cit:CI_Citation/cit:title), 'gcmd'))]/mri:keyword" mode="DIF_Keyword"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod" mode="DIF_Temporal_Coverage"/>
               
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimeInstant/gml:timePosition[string-length() > 0]" mode="DIF_Temporal_Coverage_TimePosition"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mcc:MD_ProgressCode" mode="DIF_Data_Set_Progress"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent" mode="DIF_Spatial_Coverage"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification" mode="DIF_Constraints"/>
            
            <xsl:apply-templates select="mdb:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode" mode="DIF_Data_Set_Language"/>
            
            <Data_Center>
                <Data_Center_Name>
                    <Short_Name>
                        <xsl:value-of select="$default_data_centre_short_name"/>
                    </Short_Name>
                    <Long_Name>
                        <xsl:value-of select="$default_data_centre_long_name"/>
                    </Long_Name>
                </Data_Center_Name>
                
                <Data_Center_URL>
                    <xsl:value-of select="$default_data_centre_url"/>
                </Data_Center_URL>
                
                <Personnel>
                    <Role>
                        <xsl:value-of select="$default_data_centre_personnel_role"/>
                    </Role>
                    <First_Name>
                        <xsl:value-of select="$default_data_centre_personnel_first_name"/>
                    </First_Name>
                    <Last_Name>
                        <xsl:value-of select="$default_data_centre_personnel_last_name"/>
                    </Last_Name>
                    <Email>
                        <xsl:value-of select="$default_data_centre_personnel_email"/>
                    </Email>
                </Personnel>
            </Data_Center>
            
            <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title" mode="DIF_Distribution"/>
            
            <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:supplementalInformation" mode="DIF_Reference"/>
    
            <Summary>
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract" mode="DIF_Summary_Abstract"/>
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose" mode="DIF_Summary_Purpose"/>
            </Summary>
            
            <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource
                [not(contains(lower-case(cit:protocol), 'http--publication'))]"  mode="DIF_Related_URL_ExceptPublications"/>
            
            <xsl:apply-templates select="mdb:metadataLinkage/cit:CI_OnlineResource"  mode="DIF_Related_URL_ExceptPublications"/>
            
            <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions"  mode="DIF_Related_URL_OnlyPublications"/>
            
            <xsl:apply-templates select="mdb:parentMetadata" mode="DIF_Parent_DIF"/>
            
            <!-- Internal Directory Name (IDN) field is a specific keyword used by GCMD/CEOS to determine where record should be propagated to. The author may populate <IDN_Node> from a set of controlled keywords available at  https://gcmd.earthdata.nasa.gov/KeywordViewer (under 'Other') -->
            <xsl:for-each select="$default_IDN_Node_sequence">
                <IDN_Node>
                    <Short_Name>
                        <xsl:value-of select="."/>
                    </Short_Name>
                </IDN_Node>
            </xsl:for-each>
            
            <Originating_Metadata_Node>
                <xsl:value-of select="$default_originating_metadata_node"/>
            </Originating_Metadata_Node>
            
            <Metadata_Name>
                <xsl:value-of select="$default_metadata_name"/>
            </Metadata_Name>
            
            <Metadata_Version>
                <xsl:value-of select="$default_metadata_version"/>
            </Metadata_Version>
            
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date[contains(lower-case(cit:dateType/cit:CI_DateTypeCode/@codeListValue), 'creation')]/cit:date/*[contains(local-name(), 'Date')]" mode="DIF_Creation_Date"/>
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date[contains(lower-case(cit:dateType/cit:CI_DateTypeCode/@codeListValue), 'revision')]/cit:date/*[contains(local-name(), 'Date')]" mode="DIF_Last_DIF_Revision_Date"/>
            <xsl:apply-templates select="." mode="DIF_Extended_Metadata"/>
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
            
            <xsl:choose>
                <xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility[(cit:role/cit:CI_RoleCode/@codeListValue = 'publisher') and (cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])]) > 0">
                    <Dataset_Publisher>
                        <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility[(cit:role/cit:CI_RoleCode/@codeListValue = 'publisher') and (cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])][1]/cit:party/cit:CI_Organisation/cit:name"/>
                    </Dataset_Publisher>
                </xsl:when>
                <xsl:when test="count(mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[(cit:role/cit:CI_RoleCode/@codeListValue = 'publisher') and (cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])]) > 0">
                    <Dataset_Publisher>
                        <xsl:value-of select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty[(cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'publisher') and (cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])][1]/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name"/>
                    </Dataset_Publisher>
                </xsl:when>
                <xsl:when test="count(mri:pointOfContact[(cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'publisher') and (string-length(cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name))]) > 0">
                    <Dataset_Publisher>
                        <xsl:value-of select="mri:pointOfContact[(cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'publisher') and (string-length(cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name))][1]/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name"/>
                    </Dataset_Publisher>
                    
                </xsl:when>
            </xsl:choose>
            
            <xsl:if test="string-length(normalize-space(mri:citation/cit:CI_Citation/cit:edition)) > 0">
                <Version>
                    <xsl:value-of select="normalize-space(mri:citation/cit:CI_Citation/cit:edition)"/>
                </Version>
            </xsl:if>
           
            
            <xsl:variable name="doi" select="mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:authority/cit:CI_Citation/cit:title), 'digital object identifier')]/mcc:code[contains(., 'doi') or contains(., '10.')]"/>
            <xsl:if test="string-length($doi) > 0">
                <Dataset_DOI>
                 <xsl:choose>
                     <xsl:when test="contains($doi, 'doi:')">
                         <xsl:value-of select="substring-after($doi, 'doi:')"/>
                     </xsl:when>
                     <xsl:otherwise>
                         <xsl:value-of select="$doi"/>
                     </xsl:otherwise>
                 </xsl:choose>
                </Dataset_DOI>
            </xsl:if>
            
            
            <xsl:for-each select="ancestor::mdb:MD_Metadata/mdb:metadataLinkage/cit:CI_OnlineResource[contains(cit:protocol, 'http--metadata-URL')]/cit:linkage">
                <Online_Resource>
                    <xsl:value-of select="normalize-space(.)"/>
                </Online_Resource>
            </xsl:for-each>
        </Data_Set_Citation>
    </xsl:template>
    <xsl:template match="cit:CI_Responsibility" mode="DIF_Personnel_Grouped">
       
        <xsl:variable name="namePart_sequence" select="local:nameSeparatedNoTitle_sequence(current-grouping-key())" as="xs:string*"/>
        
       <xsl:variable name="mapped_role_Sequence" as="xs:string*">
                <!-- Retrieve DIF role per source ISO Role -->
                <xsl:for-each select="current-group()/cit:role/cit:CI_RoleCode/@codeListValue[string-length() > 0]">
                    <xsl:if test="string-length(local:mapRole_ISO_DIF(.)) > 0">
                        <xsl:message select="concat('Mapped role: ', ., ' to ',  local:mapRole_ISO_DIF(.))"></xsl:message>
                        <xsl:value-of select="local:mapRole_ISO_DIF(.)"/>
                    </xsl:if>
                </xsl:for-each>
                
                <!-- If one of these cit:CI_Responsibilities for this person has parent mdb:contact, add "METADATA AUTHOR" to the mapping-->
                <xsl:if test="count(current-group()[name(..) = 'mdb:contact']) > 0">
                    <xsl:message select="concat('Adding METADATA AUTHOR to: ', current-grouping-key())"></xsl:message>
                    
                    <xsl:text>METADATA AUTHOR</xsl:text>
                </xsl:if>
        </xsl:variable>
        
        <!-- If a relevant role was not found in the mapping to DIF roles,
            ignore this responsible party as they are not relevant for Personnel in this DIF -->
        <xsl:if test="count($mapped_role_Sequence) > 0">
          
          <Personnel>
              
              <xsl:for-each select="distinct-values($mapped_role_Sequence)">
                  <Role>
                      <xsl:value-of select="."/>
                  </Role>
              </xsl:for-each>
              
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
        </xsl:if>
        
    </xsl:template>
       
    <xsl:template match="cit:CI_Address" mode="DIF_Personnel_Address">
        <xsl:if test="string-length(cit:electronicMailAddress) > 0">
            <Email>
                <xsl:value-of select="cit:electronicMailAddress"/>
            </Email>
        </xsl:if>
      
        <xsl:if test="
            (count(cit:deliveryPoint[string-length() > 0]) > 0) or
            (string-length(cit:city) > 0) or
            (string-length(cit:administrativeArea) > 0) or
            (string-length(cit:postalCode) > 0) or
            (string-length(cit:country) > 0) ">
            <Contact_Address>
                <xsl:for-each select="cit:deliveryPoint">
                    <Address>
                        <xsl:value-of select="."/>
                    </Address>
                </xsl:for-each>    
                <xsl:if test="(string-length(cit:city) > 0)">
                    <City>
                        <xsl:value-of select="cit:city"></xsl:value-of>
                    </City>
                </xsl:if>
                <xsl:if test="(string-length(cit:administrativeArea) > 0)">
                    <Province_or_State>
                        <xsl:value-of select="cit:administrativeArea"></xsl:value-of>
                    </Province_or_State>
                </xsl:if>
                <xsl:if test="(string-length(cit:postalCode) > 0)">
                    <Postal_Code>
                        <xsl:value-of select="cit:postalCode"></xsl:value-of>
                    </Postal_Code>
                </xsl:if>
                <xsl:if test="(string-length(cit:country) > 0)">
                    <Country>
                            <xsl:value-of select="cit:country"></xsl:value-of>
                    </Country>
                </xsl:if>
            </Contact_Address>
        </xsl:if>
    </xsl:template>


    <xsl:template match="mri:keyword" mode="DIF_Parameters">
        
        <xsl:variable name="parameter_sequence" select="tokenize(., '\|')"/>
        
        <!-- Category, Topic and Term are all required, so only do this if all three exist and construct
            the element even if an empty string was found so that each element is included -->
        <xsl:if test="count($parameter_sequence) > 2">
            
             <Parameters>
                     
                 <Category>
                         <xsl:value-of select="normalize-space($parameter_sequence[1])"/>
                 </Category>
             
             
                 <Topic>
                         <xsl:value-of select="normalize-space($parameter_sequence[2])"/>
                 </Topic>
             
             
                 <Term>
                     <xsl:value-of select="normalize-space($parameter_sequence[3])"/>
                 </Term>
             
             
                 <xsl:if test="(count($parameter_sequence) > 3) and string-length(normalize-space($parameter_sequence[4])) > 0">
                     <Variable_Level_1>
                         <xsl:value-of select="normalize-space($parameter_sequence[4])"/>
                     </Variable_Level_1>
                 </xsl:if>
             
           
                 <xsl:if test="(count($parameter_sequence) > 4) and string-length(normalize-space($parameter_sequence[5])) > 0">
                     <Variable_Level_2>
                         <xsl:value-of select="normalize-space($parameter_sequence[5])"/>
                     </Variable_Level_2>
                 </xsl:if>
             
             </Parameters>
            
        </xsl:if>
            
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
    
        <xsl:if test="(string-length(gml:beginPosition) > 0) or (string-length(gml:endPosition) > 0)">
            <Temporal_Coverage>
                <xsl:if test="(string-length(gml:beginPosition) > 0)">
                 <Start_Date>
                     <xsl:value-of select="local:truncDate(gml:beginPosition)"/>
                 </Start_Date>
                </xsl:if>
                <xsl:if test=" (string-length(gml:endPosition) > 0)">
                    <Stop_Date>
                        <xsl:value-of select="local:truncDate(gml:endPosition)"/>
                    </Stop_Date>
                </xsl:if>
            </Temporal_Coverage> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gml:timePosition" mode="DIF_Temporal_Coverage_TimePosition">
        
        <Temporal_Coverage>
            <xsl:if test="(string-length(.) > 0)">
                <Start_Date>
                    <xsl:value-of select="local:truncDate(.)"/>
                </Start_Date>
            </xsl:if>
        </Temporal_Coverage>
     </xsl:template>
    
    <xsl:template match="mcc:MD_ProgressCode" mode="DIF_Data_Set_Progress">
        
        <xsl:choose>
            <xsl:when test="string-length(@codeListValue) > 0">
                <Data_Set_Progress>
                    <xsl:choose>
                        <xsl:when test="
                            @codeListValue = 'planned' or
                            @codeListValue = 'required' or
                            @codeListValue = 'pending' or
                            @codeListValue = 'proposed'">
                            <xsl:text>PLANNED</xsl:text>
                        </xsl:when>
                        <xsl:when test="
                            @codeListValue = 'underDevelopment' or
                            @codeListValue = 'onGoing'">
                            <xsl:text>IN WORK</xsl:text>
                        </xsl:when>
                        <xsl:when test="
                            @codeListValue = 'completed' or
                            @codeListValue = 'historicalArchive' or
                            @codeListValue = 'obsolete' or
                            @codeListValue = 'superseded'">
                            <xsl:text>COMPLETE</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </Data_Set_Progress>
            </xsl:when>
        </xsl:choose>
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
        
        <xsl:if test="matches(lower-case(gex:verticalCRS/gml:VerticalCRS/gml:identifier), 'epsg.*5715')">
            <!-- Depth -->
            <xsl:if test="string-length(gex:minimumValue) > 0">
                <Minimum_Depth>
                    <xsl:value-of select="concat(gex:minimumValue, ' ', $units)"/>
                </Minimum_Depth>
            </xsl:if>
            <xsl:if test="string-length(gex:maximumValue) > 0">
                 <Maximum_Depth>
                     <xsl:value-of select="concat(gex:maximumValue, ' ', $units)"/>
                 </Maximum_Depth>
            </xsl:if>
        </xsl:if> 
        
        <xsl:if test="matches(lower-case(gex:verticalCRS/gml:VerticalCRS/gml:identifier), 'epsg.*5714')">
            <!-- Altitude -->
            <xsl:if test="string-length(gex:minimumValue) > 0">
                <Minimum_Altitude>
                    <xsl:value-of select="concat(gex:minimumValue, ' ', $units)"/>
                </Minimum_Altitude>
            </xsl:if>
            <xsl:if test="string-length(gex:maximumValue) > 0">
                <Maximum_Altitude>
                    <xsl:value-of select="concat(gex:maximumValue, ' ', $units)"/>
                </Maximum_Altitude>
            </xsl:if>
            
        </xsl:if> 
    </xsl:template>
    
    <xsl:template match="mri:MD_DataIdentification" mode="DIF_Constraints">
        
        <xsl:if test="count(mri:resourceConstraints/mco:MD_Constraints/mco:useLimitation[string-length(.) > 0]) > 0">
            <Access_Constraints>
                <xsl:for-each select="mri:resourceConstraints/mco:MD_Constraints/mco:useLimitation[string-length(.) > 0]">
                    <xsl:if test="position() != 1">
                        <xsl:text> - </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </Access_Constraints>
        </xsl:if>
        
        <xsl:if test="count(mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints[string-length(.) > 0]) > 0">
            <Use_Constraints>
                <xsl:for-each select="mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints">
                    <xsl:if test="position() != 1">
                        <xsl:text> - </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </Use_Constraints>
        </xsl:if>
        
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
            <Distribution_Media>HTTP</Distribution_Media>
            <Distribution_Format>
                <xsl:value-of select="."/>
             </Distribution_Format>
        </Distribution>
        
    </xsl:template>
    
    <xsl:template match="mri:supplementalInformation" mode="DIF_Reference">
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
    
    <xsl:template match="*[contains(local-name(), 'Date')]" mode="DIF_Last_DIF_Revision_Date">
        <Last_DIF_Revision_Date>
            <xsl:value-of select="local:truncDate(.)"/>
        </Last_DIF_Revision_Date>
    </xsl:template>
    
    <xsl:template match="mdb:MD_Metadata" mode="DIF_Extended_Metadata">
        <Extended_Metadata>
            <Metadata>
                <Group>
                    <xsl:value-of select="$default_target_group"/>
                </Group>
                <Name>metadata.uuid</Name>
                <Value>
                    <xsl:value-of select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code"/>
                </Value>
            </Metadata>
            <Metadata>
                <Group>
                    <xsl:value-of select="$default_target_group"/>
                </Group>
                <Name>metadata.extraction_date</Name>
                <Value>
                    <xsl:value-of select="mdb:dateInfo/cit:CI_Date[contains(lower-case(cit:dateType/cit:CI_DateTypeCode/@codeListValue), 'revision')]/cit:date/*[contains(local-name(), 'Date')]"/>
                </Value>
            </Metadata>
            <Metadata>
                <Group>
                    <xsl:value-of select="$default_target_group"/>
                </Group>
                <Name>metadata.keyword_version</Name>
                <Value>
                    <xsl:value-of select="mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:thesaurusName/cit:CI_Citation[contains(lower-case(cit:title), 'gcmd')]/cit:edition"/>
                </Value>
            </Metadata>
        </Extended_Metadata>
        
    </xsl:template>
    
    <xsl:template match="mrd:MD_DigitalTransferOptions"  mode="DIF_Related_URL_OnlyPublications">
        
        <xsl:if test="count(mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:protocol), 'http--publication')]) > 0">
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
            <xsl:when test="
                matches(lower-case($verticalCRS_identifier), 'epsg.*5715')">
                <xsl:value-of select="$default_units_depth"/>
            </xsl:when>
            <xsl:when test="
                matches(lower-case($verticalCRS_identifier), 'epsg.*5714')">
                <xsl:value-of select="$default_units_altitude"/>
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
                <xsl:text>USER'S GUIDE</xsl:text>
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
            <!-- An entry here indicates that the Personnel with this role ought to be included in the DIF  -->
            <xsl:when test="lower-case($role) = 'owner'">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'principalinvestigator'">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'collaborator'">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'contributor'">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'resourceprovider'">
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'distributor'">
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'pointofcontact'">
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'custodian'">
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'originator'">
                <xsl:text>DIF AUTHOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'author'">
                <xsl:text>DIF AUTHOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'coauthor'">
                <xsl:text>DIF AUTHOR</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($role) = 'publisher'">
                <xsl:text>DIF AUTHOR</xsl:text>
            </xsl:when>
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
