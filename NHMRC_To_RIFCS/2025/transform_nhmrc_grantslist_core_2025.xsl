<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://local.to.here"
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" version="2.0"
    exclude-result-prefixes="fn xsi xs">

    <xsl:output method="xml"/>
    
    <xsl:template match="*"/>
    
    <!--xsl:variable name="InstitutionsWithIds" select="document('')"/--> <!-- Commenting out so an error is generated when no provided by XSLT that calls this one -->
    
    <xsl:template match="/root">
        <!--xsl:assert test="count($InstitutionsWithIds) > 0"/-->
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="registryObjects"
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
            <xsl:attribute name="xsi:schemaLocation">http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="row">
        
        <xsl:variable name="grantId">
            <xsl:choose>
                <xsl:when test="count(Application_ID) > 0">
                    <xsl:value-of select="Application_ID"/>
                </xsl:when>
                <xsl:when test="count(Application_ID) > 0">
                    <xsl:value-of select="Application_ID"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
       
        <xsl:if test="string-length($grantId) > 0">
            <xsl:element name="registryObject"
                xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
                <xsl:attribute name="group">National Health and Medical Research Council</xsl:attribute>
                <xsl:text>&#xA;</xsl:text>
                <xsl:variable name="key">
                    <xsl:value-of select="concat('http://purl.org/au-research/grants/nhmrc/', $grantId)"/>
                </xsl:variable>
                <xsl:element name="key">
                    <xsl:value-of select="$key"/>
                </xsl:element>
                <xsl:text>&#xA;</xsl:text>
                <xsl:element name="originatingSource">www.nhmrc.gov.au/grants/research-funding-statistics-and-data</xsl:element>
                <xsl:text>&#xA;</xsl:text>
                
                <xsl:element name="activity">
                    <xsl:attribute name="type">grant</xsl:attribute>
                    
                    <!-- identifiers -->
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="identifier">
                        <xsl:attribute name="type">purl</xsl:attribute>
                        <xsl:value-of select="$key"/>
                    </xsl:element>
                    
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="identifier">
                        <xsl:attribute name="type">nhmrc</xsl:attribute>
                        <xsl:value-of select="$grantId"/>
                    </xsl:element>
                    
                    <!-- name(s) -->
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:variable name="subTitle" select="normalize-space(Funding_Scheme)"/>
                    <xsl:variable name="mainTitle" select="normalize-space(Grant_Title)"/>
                    <!--                    <xsl:variable name="bothBlank" select="subTitle='' and mainTitle=''"/>-->
                    <xsl:variable name="bothSame" select="$subTitle = $mainTitle" as="xs:boolean"/>
                    <xsl:variable name="mainUseless" select="$mainTitle = ''" as="xs:boolean"/>
                    <xsl:variable name="subUseless" select="$subTitle = ''" as="xs:boolean"/>
                    <xsl:choose>
                        <!-- if both titles are blank or meaningless then make the primary name a concatenation of the funding scheme Level__Stream_or_Sub-Type and the grant ID -->
                        <xsl:when test="$mainUseless and $subUseless">
                            <xsl:variable name="noTitle"
                                select="concat(normalize-space(Level__Stream_or_Sub-Type), concat(' - Grant ID:', $grantId))"/>
                            <xsl:element name="name">
                                <xsl:attribute name="type">primary</xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:value-of select="$noTitle"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <!-- if the main title is meaningless and the subtitle is meaningful -->
                        <xsl:when test="$mainUseless and not($subUseless)">
                            <xsl:element name="name">
                                <xsl:attribute name="type">primary</xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:value-of select="$subTitle"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <!-- if the sub title is meaningless but the main title is meaningful  -->
                        <xsl:when test="$subUseless and not($mainUseless)">
                            <xsl:element name="name">
                                <xsl:attribute name="type">primary</xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:value-of select="$mainTitle"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <!-- both titles are the same and meaningful -->
                        <xsl:when test="$bothSame and not($mainUseless)">
                            <xsl:element name="name">
                                <xsl:attribute name="type">primary</xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:value-of select="$mainTitle"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <!--  otherwise we have two names, primary and alternative -->
                        <xsl:otherwise>
                            <xsl:element name="name">
                                <xsl:attribute name="type">primary</xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:value-of select="$mainTitle"/>
                                </xsl:element>
                            </xsl:element>
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:element name="name">
                                <xsl:attribute name="type">alternative</xsl:attribute>
                                <xsl:element name="namePart">
                                    <xsl:value-of select="$subTitle"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#xA;</xsl:text>
                    
                    <!-- funding body -->
                    <!--xsl:element name="relatedObject">
                        <xsl:element name="key"
                            >http://dx.doi.org/10.13039/501100000925</xsl:element>
                        <xsl:element name="relation">
                            <xsl:attribute name="type">isFundedBy</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                    <xsl:text>&#xA;</xsl:text-->
                    
                    <xsl:if test="Grant_Opportunity != '' and Grant_Opportunity != 'NULL'">
                        <xsl:element name="relatedInfo">
                            <xsl:attribute name="type">activity</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="Grant_Opportunity_ID != '' and Grant_Opportunity_ID != 'NULL'">
                                    <xsl:element name="identifier">
                                        <xsl:attribute name="type">local</xsl:attribute>
                                        <xsl:value-of select="Grant_Opportunity_ID"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise> <!-- Not expecting no id, but just in case -->
                                    <xsl:element name="identifier">
                                        <xsl:attribute name="type">local</xsl:attribute>
                                        <xsl:variable name="grantOpp_parts" select="tokenize(Grant_Opportunity, '\s+')"/>
                                        <xsl:if test="count($grantOpp_parts) > 0">
                                            <xsl:value-of select="$grantOpp_parts[1]"/>
                                        </xsl:if>
                                        <xsl:if test="count($grantOpp_parts) > 1">
                                            <xsl:value-of select="concat(' ', $grantOpp_parts[2])"/>
                                        </xsl:if>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:element name="title">
                                <xsl:value-of select="Grant_Opportunity"/>
                            </xsl:element>
                            <xsl:element name="relation">
                                <xsl:attribute name="type">isPartOf</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    
                    <xsl:if test="Chief_Investigator_A__Project_Lead_ != '' and Chief_Investigator_A__Project_Lead_ != 'NULL'">
                        <xsl:element name="relatedInfo">
                            <xsl:attribute name="type">party</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="CIA_ORCID_ID != '' and CIA_ORCID_ID != 'NULL'">
                                    <xsl:element name="identifier">
                                        <xsl:attribute name="type">orcid</xsl:attribute>
                                        <xsl:value-of select="CIA_ORCID_ID"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="identifier">
                                        <xsl:attribute name="type">local</xsl:attribute>
                                        <xsl:value-of select="replace(Chief_Investigator_A__Project_Lead_, '\s+', '_')"/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:element name="title">
                                <xsl:value-of select="Chief_Investigator_A__Project_Lead_"/>
                            </xsl:element>
                            <xsl:element name="relation">
                                <xsl:attribute name="type">hasPrincipalInvestigator</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <xsl:element name="relatedInfo">
                        <xsl:attribute name="type">party</xsl:attribute>
                        <xsl:element name="identifier">
                            <xsl:attribute name="type">doi</xsl:attribute>
                            <xsl:text>10.13039/501100000925</xsl:text>
                        </xsl:element>
                        <xsl:element name="title">
                            <xsl:text>National Health and Medical Research Council</xsl:text>
                        </xsl:element>
                        <xsl:element name="relation">
                            <xsl:attribute name="type">isFundedBy</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                    <xsl:text>&#xA;</xsl:text>
                    
                    <!-- administering institution -->
                    
                    <!-- This section uses a lookup table 'nhmrc_admin_institutions_manual_update_ror_id_2025_AfterParticipatingInstitutionsIncluded.xml'  generated by another stylesheet 
                       'NHMRC_To_RIFCS/CORE/ExtractKeys/nhmrc_extract_institutional_keys_RoR.xsl' to find an identifier to use.
                  -->
                    
                    <xsl:variable name="admin_inst" select="Administering_Institution"/>
                    <xsl:variable name="inst_id"
                        select="$InstitutionsWithIds/institutions/institution[name = $admin_inst]/identifier"/>
                    
                    <xsl:if test="string-length($admin_inst) > 0">
                        <xsl:element name="relatedInfo">
                            <xsl:attribute name="type">party</xsl:attribute>
                            <xsl:element name="identifier">
                                <xsl:choose>
                                    <xsl:when test="string-length($inst_id) > 0">
                                        <xsl:attribute name="type">uri</xsl:attribute>
                                        <xsl:value-of select="$inst_id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message select="concat('Unmatched admin organisation ', $admin_inst)"/>
                                        <xsl:attribute name="type">local</xsl:attribute>
                                        <xsl:value-of select="replace($admin_inst, '\s+', '_')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="title">
                                <xsl:value-of select="$admin_inst"/>
                            </xsl:element>
                            <xsl:element name="relation">
                                <xsl:attribute name="type">isManagedBy</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    
                    <xsl:for-each select="fn:tokenize(Participating_Institutions, '\|')">
                         <xsl:variable name="parti_inst" select="normalize-space(.)"/>
                         <xsl:variable name="inst_id"
                             select="$InstitutionsWithIds/institutions/institution[name = $parti_inst]/identifier"/>
                         
                         <xsl:if test="string-length($parti_inst) > 0">
                             <xsl:element name="relatedInfo">
                                 <xsl:attribute name="type">party</xsl:attribute>
                                 <xsl:element name="identifier">
                                     <xsl:choose>
                                         <xsl:when test="string-length($inst_id) > 0">
                                             <xsl:attribute name="type">uri</xsl:attribute>
                                             <xsl:value-of select="$inst_id"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:message select="concat('Unmatched parti organisation ', $parti_inst)"/>
                                             <xsl:attribute name="type">local</xsl:attribute>
                                             <xsl:value-of select="replace($parti_inst, '\s+', '_')"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:element>
                                 <xsl:element name="title">
                                     <xsl:value-of select="$parti_inst"/>
                                 </xsl:element>
                                 <xsl:element name="relation">
                                     <xsl:attribute name="type">hasParticipant</xsl:attribute>
                                 </xsl:element>
                             </xsl:element>
                             <xsl:text>&#xA;</xsl:text>
                         </xsl:if>
                    </xsl:for-each>
    
                    
                    
                    <!-- Subjects -->
                    <!-- if no FIELD_OF_RESEARCH_CODE supplied output code '11' for 'Medical and Health Sciences' -->
                    <xsl:if test="Broad_Research_Area = ''">
                        <xsl:element name="subject">
                            <xsl:attribute name="type">anzsrc-for</xsl:attribute>
                            <xsl:text>11</xsl:text>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    <!-- source spreadsheet data has leading zero stripped from 6-digit codes starting with zero that has to be replaced before looking up
                  ANZSRC-FOR vocabulary to verify it is a valid code -->
                    
                    <xsl:if test="Broad_Research_Area != ''">
                        <xsl:variable name="subjectArea" select="Broad_Research_Area"/>
                        <xsl:if test="lower-case($subjectArea) != 'not applicable'">
                            <xsl:element name="subject">
                                <xsl:attribute name="type">local</xsl:attribute>
                                <xsl:value-of select="$subjectArea"/>
                            </xsl:element>
                            <xsl:text>&#xA;</xsl:text>
                        </xsl:if>
                        
                    </xsl:if>
                    
                    <xsl:if test="Fields_of_Research != ''">
                        <xsl:variable name="subjectArea" select="Fields_of_Research"/>
                        <xsl:if test="lower-case($subjectArea) != 'not applicable'">
                            <xsl:for-each select="tokenize($subjectArea, '\|')">
                                <xsl:if test="string-length(normalize-space(.)) > 0">
                                    <xsl:element name="subject">
                                        <xsl:attribute name="type">anzsrc-for</xsl:attribute>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:element>
                                    <xsl:text>&#xA;</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:if>
                    
                    <xsl:if test="Research_Keywords != ''">
                        <xsl:variable name="keyWords" select="Research_Keywords"/>
                        <xsl:if test="lower-case($keyWords) != 'not applicable'">
                            <xsl:for-each select="tokenize($keyWords, '\|')">
                                <xsl:if test="string-length(normalize-space(.)) > 0">
                                    <xsl:element name="subject">
                                        <xsl:attribute name="type">local</xsl:attribute>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:element>
                                    <xsl:text>&#xA;</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:if>
                    
                    <!-- Descriptions -->
                    <!-- Chief Investigator Team -->
                    <xsl:if test="Chief_Investigator_Team != '' and Chief_Investigator_Team != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">Chief Investigator Team</xsl:attribute>
                            <xsl:variable name="chiefInvestigators" select="Chief_Investigator_Team"/>
                            <xsl:for-each select="tokenize($chiefInvestigators, '\|')">
                                <xsl:if test="string-length(normalize-space(.)) > 0">
                                    <xsl:value-of select="normalize-space(.)"/>
                                    <xsl:text>&lt;br/&gt;</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Collaborating Countries -->
                    <xsl:if test="Collaborating_Countries != '' and Collaborating_Countries != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">Collaborating Countries</xsl:attribute>
                            <xsl:variable name="collabCountries" select="Collaborating_Countries"/>
                            <xsl:for-each select="tokenize($collabCountries, '\|')">
                                <xsl:if test="string-length(normalize-space(.)) > 0">
                                    <xsl:value-of select="normalize-space(.)"/>
                                    <xsl:text>&lt;br/&gt;</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Date Announced-->
                    <xsl:if test="Date_Announced != '' and Date_Announced != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">Date Announced</xsl:attribute>
                            <xsl:value-of select="normalize-space(Date_Announced)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Application Year-->
                    <xsl:if test="Application_Year != '' and Application_Year != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">Application Year</xsl:attribute>
                            <xsl:value-of select="normalize-space(Application_Year)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Organisation_Type-->
                    <xsl:if test="Organisation_Type != '' and Organisation_Type != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">Organisation_Type</xsl:attribute>
                            <xsl:value-of select="normalize-space(Organisation_Type)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- brief -->
                    <xsl:if test="Media_Summary != '' and Media_Summary != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">brief</xsl:attribute>
                            <xsl:value-of select="normalize-space(Media_Summary)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- full -->
                    <xsl:if test="Plain_Description != '' and Plain_Description != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">full</xsl:attribute>
                            <xsl:value-of select="normalize-space(Plain_Description)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Funding Amount -->
                    <xsl:if test="Total_amount_awarded != ''">
                        <xsl:element name="description">
                            <xsl:attribute name="type">fundingAmount</xsl:attribute>
                            <xsl:value-of select="Total_amount_awarded"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Funding Scheme -->
                    <xsl:variable name="mainScheme" select="normalize-space(Funding_Type)"/>
                    <xsl:variable name="subScheme" select="normalize-space(Funding_Subtype)"/>
                    
                    <xsl:if test="string-length($mainScheme) > 0">
                        <xsl:element name="description">
                            <xsl:attribute name="type">fundingScheme</xsl:attribute>
                            <xsl:value-of select="$mainScheme"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    <xsl:if test="string-length($subScheme) > 0">
                        <xsl:element name="description">
                            <xsl:attribute name="type">notes</xsl:attribute>
                            <xsl:value-of select="$subScheme"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- State_or_Territory -->
                    <xsl:if test="State_or_Territory != ''">
                        <xsl:element name="coverage">
                            <xsl:element name="spatial">
                                <xsl:attribute name="type">text</xsl:attribute>
                                <xsl:value-of select="State_or_Territory"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- Existence Dates -->
                    <xsl:if test="Grant_Start_Date != ''">
                        <xsl:element name="existenceDates">
                            <xsl:element name="startDate">
                                <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                <xsl:value-of select="Grant_Start_Date"/>
                            </xsl:element>
                            <xsl:if test="Grant_End_Date">
                                <xsl:element name="endDate">
                                    <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                    <xsl:value-of select="Grant_End_Date"/>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                        
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                </xsl:element>
                <xsl:text>&#xA;</xsl:text>
                <!-- activity -->
            </xsl:element>
            <!-- registryObject -->
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>
