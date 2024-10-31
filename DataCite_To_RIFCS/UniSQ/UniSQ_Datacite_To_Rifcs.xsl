<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:custom="http://custom.nowhere.yet"
    xpath-default-namespace="http://datacite.org/schema/kernel-4"
    exclude-result-prefixes="xsl fn xs xsi custom">
    
    <xsl:import href="DataCite_Kernel4_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of Southern Queensland'"/>
    <xsl:param name="global_group" select="'University of Southern Queensland'"/>
    <xsl:param name="default_group" select="'University of Southern Queensland'"/>
    <xsl:param name="global_acronym" select="'UniSQ'"/>
    <xsl:param name="global_publisherName" select="'University of Southern Queensland'"/>
    <xsl:param name="global_baseURI" select="'https://research.usq.edu.au'"/>
    <xsl:param name="global_path" select="'/item/'"/>
    
    
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_project_identifier_strings" select="'raid'" as="xs:string*"/>
    <xsl:param name="global_create_and_relate_party_missing_identifier" select="false()"/>
    <xsl:param name="global_create_and_relate_activity_missing_identifier" select="false()"/>
    
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    
     
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:for-each select="resource">
                <xsl:apply-templates select="." mode="datacite_4_to_rifcs_collection">
                    <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
                </xsl:apply-templates>
                
                <xsl:apply-templates select="//creator" mode="party_processing"/>
                <xsl:apply-templates select="//contributor" mode="party_processing"/>
                <xsl:apply-templates select="//fundingReference" mode="party_activity_processing"/>
                
            </xsl:for-each>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="creator | contributor" mode="party_processing">
        <xsl:if test="
            (nameIdentifier/text() != '') and
            (true() = $global_create_and_relate_party_missing_identifier)">
            
            <xsl:apply-templates select="." mode="datacite_4_to_rifcs_party">
                <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            </xsl:apply-templates>
            
        </xsl:if>
    </xsl:template>
    
    <!--xsl:template match="fundingReference" mode="party_activity_processing">
        <xsl:if test="
            (boolean(string-length(funderIdentifier))) or
            (true() = $global_create_and_relate_party_missing_identifier)">
            
            <xsl:apply-templates select="." mode="datacite_4_to_rifcs_party">
                <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
            </xsl:apply-templates>
            
        </xsl:if>
        <!-- Don't create grant activities -->
        <!--xsl:choose>
            <xsl:when test="
                (boolean(string-length(awardNumber)) or
                boolean(string-length(awardNumber/@awardURI)))">
                <xsl:apply-templates select="." mode="datacite_4_to_rifcs_activity">
                    <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="
                ((true() = $global_create_and_relate_activity_missing_identifier) and
                boolean(string-length(awardTitle)))">
                <xsl:apply-templates select="." mode="datacite_4_to_rifcs_activity">
                    <xsl:with-param name="originatingSource" select="$global_originatingSource"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose-->
        
    <!--/xsl:template>
    
    <!--xsl:template match="relatedIdentifier | relatedItemIdentifier" mode="relation">
        <xsl:variable name="currentNodeText" select="lower-case(.)" as="xs:string"/>
        
        <xsl:message><xsl:text>Relation Override</xsl:text></xsl:message>
        
        <relation>
            <xsl:attribute name="type">
                <xsl:variable name="inferredRelation" as="xs:string*">
                    <xsl:for-each select="tokenize($global_hesanda_identifier_strings, '\|')">
                        <xsl:variable name="testString" select="lower-case(.)" as="xs:string"/>
                        <xsl:if test="boolean(string-length($testString))">
                            <xsl:if
                                test="contains($currentNodeText, $testString)">
                                <xsl:text>references</xsl:text>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:apply-templates select="." mode="relation_core"/>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="boolean(string-length($inferredRelation[1]))">
                        <xsl:value-of select="$inferredRelation[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@relationType"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </relation>
        
    </xsl:template-->
    
    <!--xsl:template match="relatedIdentifier | relatedItemIdentifier" mode="related_item_type">
        <xsl:variable name="currentNodeText" select="lower-case(.)" as="xs:string"/>
        
        <xsl:variable name="inferredType" as="xs:string*">
            <xsl:for-each select="tokenize($global_hesanda_identifier_strings, '\|')">
                <xsl:variable name="testString" select="lower-case(.)" as="xs:string"/>
                <xsl:if test="contains($currentNodeText, $testString)">
                    <xsl:text>publication</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="." mode="related_item_type_core"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="boolean(string-length($inferredType[1]))">
                <xsl:value-of select="$inferredType[1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template-->
    
    
    
</xsl:stylesheet>
