<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" version="2.0">

    <xsl:output method="xml"/>

    <!-- transformation of investigator list from NHMRC source data spreadhseet to RIF-CS party records -->


    <xsl:template match="/root">
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="registryObjects" xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
            <xsl:attribute name="xsi:schemaLocation">http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:attribute>
            <xsl:for-each-group select="row" group-by="individual_id">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:variable name="key" select="current-grouping-key()"/>
                <xsl:if test="$key != ''">
                    <xsl:element name="registryObject">
                        <xsl:attribute name="group">National Health and Medical Research Council</xsl:attribute>
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="key">
                            <xsl:value-of select="concat('nhmrc.gov.au/person/', $key)"/>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="originatingSource">nhmrc.gov.au</xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="party">
                            <xsl:attribute name="type">person</xsl:attribute>
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:element name="name">
                                <xsl:attribute name="type">primary</xsl:attribute>
                                <xsl:element  name="namePart">
                                    <xsl:value-of select="name_full"/>
                                </xsl:element>
                            </xsl:element>
                            <xsl:text>&#xA;</xsl:text>
                      <!-- related grants -->
                        <xsl:for-each select="current-group()">
                            <xsl:element name="relatedObject">
                                <xsl:element name="key">
                                    <xsl:value-of
                                        select="concat('http://purl.org/au-research/grants/nhmrc/', grant_id)"
                                    />
                                </xsl:element>
                                <xsl:choose>
                                    <xsl:when test="grant_role = 'CIA'">
                                        <xsl:element name="relation">
                                            <xsl:attribute name="type"
                                                >isPrincipalInvestigator</xsl:attribute>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:element name="relation">
                                            <xsl:attribute name="type"
                                                >isParticipantIn</xsl:attribute>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:for-each>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:element>                    
                    <xsl:text>&#xA;</xsl:text>
                        <!-- end element registryObject -->
                </xsl:if>
            </xsl:for-each-group>
        </xsl:element>
        <xsl:text>&#xA;</xsl:text>
        <!-- end element registryObjects -->
    </xsl:template>




    <xsl:template match="*"/>


</xsl:stylesheet>
