<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:here="http://here.nowhere.yet"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
    
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:variable name="keyPrefix" select="'usc.edu.au/'"/>
    <!--xsl:variable name="keyPrefix" select="''"/-->
    
    <xsl:param name="compareWithOtherDatasource" select="true()"/>
    <xsl:param name="registry_address_input" select="'researchdata.edu.au'"/>
    <!--xsl:param name="registry_address_input" select="'demo.researchdata.ardc.edu.au'"/-->
    <xsl:param name="registry_address_other" select="'researchdata.edu.au'"/>
    <!-- Presuming comparing demo xml with prod file -->
    <!-- change the following the the correct other datasource content for the contributor that you are working with and set $compareWithOtherDatasource to true()-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/UniversityOfCanberra/PURE-at-University-of-Canberra-RIF-CS-Export_demo_Collections.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/RMIT/RMIT-Figshare-RIF-CS-Export_DemoFigshare.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/UNE_Project/FromRDA/university-of-new-england-une-dspace-RIF-CS-Export_demo.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/SouthernCrossUniversity/InProdNew/SCU-Esploro-RIF-CS-Export_ProductionPublishedCollections_360.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/RMIT/RMIT-Redbox-RIF-CS-Export_ProdRedBox_PublishedCollections_Figshare_357.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/ACU_Victoria/ACU_20202/CompareDemoProd/ACU_InProdRDA.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('file:~/git/projects/CQU_Project/CompareKeys/Central-Queensland-University-RIF-CS-Export_OldProd.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="fn:document('file:~/git/projects/GriffithUniversity/From_PROD_GriffithUniversity_61/Griffith-University-RIF-CS-Export_PROD_Collections_Published_AfterDelete.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="fn:document('file:~/git/projects/University%20of%20Sunshine%20Coast%20(USC)/202310/DownloadFromRDA/University-of-the-Sunshine-Coast-RIF-CS-Export_PROD_139_COLLECTIONS_PUBLISHED.xml')"/-->
    <xsl:variable name="otherDatasourceRifCS" select="fn:document('file:/home/scruffy/git/projects/UniversitySouthernQueensland%20(UniSQ)/RDA_ProductionOld/University-of-Southern-Queensland-RIF-CS-Export_Collections_Published_Production_DS_140.xml')"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()[ancestor::field and not(self::text())]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="/">
       
        <xsl:text>location</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>key</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>class</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>originating_source</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>type</xsl:text><xsl:value-of select="$columnSeparator"/>
       <xsl:text>identifier_local</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>identifier_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>name</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>description_full</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>description_brief</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>electronic_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>doi</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:if test="$compareWithOtherDatasource = true()">
            <xsl:text>registry_match_name_if_exists</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>registry_match_key_if_exists</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>registry_match_url_if_exists</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>match_element_if_match_in_other_datasource_found</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>doi_other_datasource</xsl:text><xsl:value-of select="$columnSeparator"/>
        </xsl:if>
        
        <xsl:message select="concat('result: ', count(//registryObject[count(collection|service|party|activity) > 0]))"></xsl:message>
        
        <xsl:apply-templates select="//registryObject[count(collection|service|party|activity) > 0]"/>
    
    </xsl:template>
    
    
    <xsl:template match="registryObject">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: location -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat('https://', $registry_address_input, '/view?key=', key)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: key	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="key"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: class	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:choose>
            <xsl:when test="count(service) > 0">
                <xsl:text>service</xsl:text>
            </xsl:when>
            <xsl:when test="count(collection) > 0">
                <xsl:text>collection</xsl:text>
            </xsl:when>
            <xsl:when test="count(party) > 0">
                <xsl:text>party</xsl:text>
            </xsl:when>
            <xsl:when test="count(activity) > 0">
                <xsl:text>activity</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: type	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="originatingSource"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: originating_source	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier_local	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="*/identifier[@type = 'local']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier_uri	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/identifier[starts-with(lower-case(@type), 'ur')]"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: name	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
         <xsl:value-of select="string-join((collection|service|party|activity)/name/namePart, $valueSeparator)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: description full	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/description[@type='full']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: description brief	(optional) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/description[@type='brief']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: electronic url (mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/location/address/electronic[lower-case(@type) = 'url']/value"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:variable name="doi_sequence" as="xs:string*">
            <xsl:copy-of select="here:getRegObjDOI_sequence(.)"/>
        </xsl:variable>
        <xsl:message select="concat('DOIs found: ', count($doi_sequence))"/>
        <xsl:message select="concat('First DOI: ', $doi_sequence[1])"/>
        
            
        <!--	column: doi-->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="distinct-values($doi_sequence)[1]"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:variable name="objectNamePart" select="string-join((collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart, ' ')" as="xs:string"/>
        
        <xsl:variable name="handlePostFixFromKey" select="substring-after(key, $keyPrefix)"/>
        <xsl:message select="concat('$handlePostFixFromKey ', $handlePostFixFromKey)"/>
        
        <xsl:variable name="doiPostFixFromKey" select="substring-after(key, 'doi.org/')"/>
        <xsl:variable name="doiPostFixFromDoi">
            <xsl:choose>
                <xsl:when test="contains(distinct-values($doi_sequence)[1], 'doi.org/')">
                    <xsl:copy-of select="substring-after(distinct-values($doi_sequence)[1], 'doi.org/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="distinct-values($doi_sequence)[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="handlePostFixFromHandle" select="substring-after((collection|service|party|activity)/identifier[lower-case(@type)='handle'], 'e-publications.une.edu.au/')"/>
        <xsl:message select="concat('$handlePostFixFromHandle ', $handlePostFixFromHandle)"/>
        
        
        <xsl:if test="$compareWithOtherDatasource = true()">
            <!--	column: other_datasource_url_if_exists (mandatory) -->
            <!-- Find record in other datasource that has matching name -->
           
            <xsl:variable name="regObjFound_NameMatch_sequence" as="element()*">
                <xsl:if test="(string-length($objectNamePart) > 0)">
                    <xsl:copy-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(string-join(normalize-space(namePart), ' ')) = lower-case(normalize-space($objectNamePart))]]"/>
                </xsl:if>
            </xsl:variable>
            
            <xsl:variable name="regObjFound_HandleMatch_sequence" as="element()*">
                <xsl:if test="(string-length($handlePostFixFromKey) > 0)">
                    <xsl:copy-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]"/>
                 </xsl:if>
            </xsl:variable>
            
            <xsl:variable name="regObjFound_DoiMatch_sequence" as="element()*">
                <xsl:if test="(string-length($doiPostFixFromDoi) > 0)">
                    <xsl:copy-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]"/>
                </xsl:if>
            </xsl:variable>
            
              
            
            <xsl:choose>
                <xsl:when test="count($regObjFound_DoiMatch_sequence) > 0">
                    
                    <xsl:message select="concat('Using first regObj found by doi match [', $doiPostFixFromDoi, ']- has key: ', $regObjFound_NameMatch_sequence[1]/key)"/>
                    
                    <xsl:call-template name="writeRegObjValues">
                        <xsl:with-param name="matchVariable">
                            <xsl:value-of select="'doi'"/>
                        </xsl:with-param>
                        <xsl:with-param name="matchValue">
                            <xsl:value-of select="$doiPostFixFromDoi"/>
                        </xsl:with-param>
                        <xsl:with-param name="regObjMatched" as="element()">
                            <xsl:copy-of select="$regObjFound_DoiMatch_sequence[1]"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:when>
                <xsl:when test="count($regObjFound_HandleMatch_sequence) > 0">
                    
                    <xsl:message select="concat('Using first regObj found by handle match [', $handlePostFixFromKey, ']- has key: ', $regObjFound_NameMatch_sequence[1]/key)"/>
                    
                    <xsl:call-template name="writeRegObjValues">
                        <xsl:with-param name="matchVariable">
                            <xsl:value-of select="'handle'"/>
                        </xsl:with-param>
                        <xsl:with-param name="matchValue">
                            <xsl:value-of select="$handlePostFixFromKey"/>
                        </xsl:with-param>
                        <xsl:with-param name="regObjMatched" as="element()">
                            <xsl:copy-of select="$regObjFound_NameMatch_sequence[1]"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:when>
                <xsl:when test="count($regObjFound_NameMatch_sequence) > 0">
                    
                    <xsl:variable name="regObjTest" select="$regObjFound_NameMatch_sequence[1]"/>
                    
                    <xsl:call-template name="writeRegObjValues">
                        <xsl:with-param name="matchVariable">
                            <xsl:value-of select="'namePart'"/>
                        </xsl:with-param>
                        <xsl:with-param name="matchValue">
                            <xsl:value-of select="$objectNamePart"/>
                        </xsl:with-param>
                        <xsl:with-param name="regObjMatched" as="element()">
                            <xsl:copy-of select="$regObjFound_NameMatch_sequence[1]"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:message select="concat('No match found for: ', string-join((collection|service|party|activity)/name/namePart, ' '))"/>
                </xsl:otherwise>
            </xsl:choose>
           
        </xsl:if>
         
    </xsl:template>
    
    
    
    <xsl:template name="writeRegObjValues">
        <xsl:param name="matchVariable"/>
        <xsl:param name="matchValue"/>
        <xsl:param name="regObjMatched"/>
        
        <xsl:message select="concat('Using first regObj found by [', $matchVariable, '] match value: [', $matchValue, '] - has key: ', $regObjMatched/key)"/>
        
        <!-- registry_match_name_if_exists -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="string-join($regObjMatched/*/name, $valueSeparator)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!-- registry_match_key_if_exists -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$regObjMatched/key"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!-- registry_match_url_if_exists -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat('https://', $registry_address_other, '/view?key=', $regObjMatched/key)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!-- match_element_if_match_in_other_datasource_found -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$matchVariable"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: doi_otherDatasource -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="here:getRegObjDOI_sequence($regObjMatched)[1]"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
    </xsl:template>
    
    <xsl:function name="here:getRegObjDOI_sequence" as="xs:string*">
        <xsl:param name="regObj"/>
        
        <xsl:variable name="sequence" as="xs:string*">
       
            <xsl:copy-of select="$regObj/(collection|service|party|activity)/identifier[(lower-case(@type)='doi')]/text()"/>
            <xsl:copy-of select="$regObj/(collection|service|party|activity)/identifier[starts-with(text(), '10.')]/text()"/>
            <xsl:copy-of select="$regObj/(collection|service|party|activity)/citationInfo/citationMetadata/identifier[lower-case(@type)='doi']"/>
            <xsl:copy-of select="$regObj/(collection|service|party|activity)/citationInfo/citationMetadata/identifier[starts-with(text(), '10.')]"/>
            <xsl:copy-of select="$regObj/(collection|service|party|activity)/location/address/electronic/value[lower-case(@type)='doi']"/>
            <xsl:copy-of select="$regObj/(collection|service|party|activity)/location/address/electronic/value[starts-with(text(), '10.')]"/>
            <xsl:copy-of select="custom:getDOIFromString_sequence(normalize-space($regObj/*/citationInfo/fullCitation))[1]"/>
            
        </xsl:variable>
        
        <xsl:message select="concat('Function - DOIs found: ', count($sequence))"/>
        <xsl:message select="concat('Function - First DOI: ', $sequence[1])"/>
        
        <xsl:copy-of select="$sequence"/>
        
    </xsl:function>
    
    
   
    
</xsl:stylesheet>
