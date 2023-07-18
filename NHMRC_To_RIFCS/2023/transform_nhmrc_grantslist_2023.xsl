<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" version="2.0">

    <!-- version 2022 has updates:
     - takes different input file and has different element names for input file 
     ~/git/XSLT/NHMRC_To_RIFCS/2022/1-summary_of_results_2022_app_round_24022023.xml -->


    <xsl:output method="xml"/>
    <xsl:variable name="AdminInstitutions" select="document('nhmrc_admin_institutions_manual_update_nla_id_2023.xml')"/>
    <xsl:variable name="grantpubs" select="document('nhmrc_grantpubs_2023.xml')"/> <!-- I don't have one of these until I update the API call in trove_harvest_2022_requires_API_update.xsl -->

    <xsl:template match="/root">
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="registryObjects"
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
            <xsl:attribute name="xsi:schemaLocation">http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="row">

        <xsl:variable name="grantId">
            <xsl:value-of select="APP_ID"/>
        </xsl:variable>
        <xsl:if test="$grantId != ''">
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
                    <xsl:variable name="subTitle" select="normalize-space(Grant_Type)"/>
                    <xsl:variable name="mainTitle" select="normalize-space(Grant_Title)"/>
                    <!--                    <xsl:variable name="bothBlank" select="subTitle='' and mainTitle=''"/>-->
                    <xsl:variable name="bothSame" select="$subTitle = $mainTitle"/>
                    <xsl:variable name="mainUseless" select="$mainTitle = ''"/>
                    <xsl:variable name="subUseless" select="$subTitle = ''"/>
                    <xsl:choose>
                        <!-- if both titles are blank or meaningless then make the primary name a concatenation of the funding scheme sub_type and the grant ID -->
                        <xsl:when test="$mainUseless and $subUseless">
                            <xsl:variable name="noTitle"
                                select="concat(normalize-space(Sub_Type), concat(' - Grant ID:', $grantId))"/>
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
                    <xsl:element name="relatedObject">
                        <xsl:element name="key"
                            >http://dx.doi.org/10.13039/501100000925</xsl:element>
                        <xsl:element name="relation">
                            <xsl:attribute name="type">isFundedBy</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                    <xsl:text>&#xA;</xsl:text>

                    <!-- administering institution -->

                    <!-- This section uses a lookup table 'nhmrc_admin_institutions.xml'  generated by another stylesheet 
                       'nhmrc_extract_institutional_keys.xsl' 
                    which extracts unique values of Administering Organisation from the NHMRC grant data source and uses
                    the getRIFCS API to find the matching party record in RDA. After looking up the organisation in the table,
                    the key is used to add this party as a related object with relation 'isAdministeredBy'. -->

                    <xsl:variable name="admin_inst" select="Admin_Institution"/>
                    <xsl:variable name="inst_key"
                        select="$AdminInstitutions/institutions/institution[name = $admin_inst]/key"/>
                    <xsl:if test="$inst_key">
                        <xsl:element name="relatedObject">
                            <xsl:element name="key">
                                <xsl:value-of select="$inst_key"/>
                            </xsl:element>
                            <xsl:element name="relation">
                                <xsl:attribute name="type">isManagedBy</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$inst_key = ''">
                        <xsl:message>
                            <xsl:text>Unmatched admin organisation </xsl:text>
                            <xsl:value-of select="$admin_inst"/>
                        </xsl:message>
                    </xsl:if>


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
                        <xsl:element name="subject">
                            <xsl:attribute name="type">local</xsl:attribute>
                            <xsl:value-of select="$subjectArea"/>
                        </xsl:element>
                    </xsl:if>
                    
                    <xsl:if test="Fields_of_Research != ''">
                        <xsl:variable name="subjectArea" select="Fields_of_Research"/>
                        <xsl:element name="subject">
                            <xsl:attribute name="type">anzsrc-for</xsl:attribute>
                            <xsl:value-of select="$subjectArea"/>
                        </xsl:element>
                    </xsl:if>

                    <xsl:if test="Keywords != '' and Keywords != 'NULL'">
                        <xsl:variable name="keyword" select="Keywords"/>
                        <xsl:element name="subject">
                            <xsl:attribute name="type">local</xsl:attribute>
                            <xsl:value-of select="$keyword"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>

                    <!-- Descriptions -->
                    <!-- brief -->
                    <xsl:if test="Media_Summary != '' and Media_Summary != 'NULL'">
                        <xsl:element name="description">
                            <xsl:attribute name="type">brief</xsl:attribute>
                            <xsl:value-of select="normalize-space(Media_Summary)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    <!-- Funding Amount -->
                    <xsl:if test="Funding_Commitment != ''">
                        <xsl:element name="description">
                            <xsl:attribute name="type">fundingAmount</xsl:attribute>
                            <xsl:value-of select="concat(Funding_Commitment, '.00')"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>

                    <!-- Funding Scheme -->
                    <xsl:variable name="mainScheme" select="normalize-space(Funding_Type)"/>
                    <xsl:variable name="subScheme" select="normalize-space(Funding_Subtype)"/>

                    <xsl:if test="$mainScheme != ''">
                        <xsl:element name="description">
                            <xsl:attribute name="type">fundingScheme</xsl:attribute>
                            <xsl:value-of select="$mainScheme"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$subScheme != ''">
                        <xsl:element name="description">
                            <xsl:attribute name="type">notes</xsl:attribute>
                            <xsl:value-of select="$subScheme"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>



                    <!-- Existence Dates -->
                    <xsl:if test="Year_Grant_Start != ''">
                        <xsl:element name="existenceDates">
                            <xsl:element name="startDate">
                                <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                <xsl:value-of select="Year_Grant_Start"/>
                            </xsl:element>
                            <xsl:if test="END_YR">
                                <xsl:element name="endDate">
                                    <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                    <xsl:value-of select="Year_Grant_End"/>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>

                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    
                    
                    <!-- related publications -->
                    <xsl:variable name="pubinfo"
                        select="$grantpubs/troveGrants/grantPubInfo[grantKey = $key]"/>
                    <xsl:if test="$pubinfo">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:copy-of select="$pubinfo/relatedInfo"/>
                        
                    </xsl:if>
                    
                </xsl:element>
                <!-- activity -->
            </xsl:element>
            <!-- registryObject -->
        </xsl:if>

    </xsl:template>


    <xsl:template match="*"/>

</xsl:stylesheet>
