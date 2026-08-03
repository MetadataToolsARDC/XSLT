<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="schemadotorg2rif_updated"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--xsl:import href="schemadotorg2rif.xsl"/-->
    <xsl:import href="schemadotorg2rif_updated.xsl"/>
    
    <xsl:param name="originatingSource" select="'Australian Research Data Commons'"/>
    <xsl:variable name="group" select="'Australian Research Data Commons'"/>
    <xsl:param name="groupAcronym" select="'ARDC'"/> 
    <xsl:param name="prefixKeyWithGroup" select="false()"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects {$xsd_url}">
            
            <!-- Not we are specifically excluding the following:
                Record with id https://raid.org/10.71821/418be95a
                Any Record indicated as partOf the above Record (with id https://raid.org/10.71821/418be95a)
                
                This is because IMAS UTAS provide there own records and we don't want to include them
                until we have de-duplication processing in RDA -->
            <xsl:apply-templates select="//dataset[(lower-case(type) = 'researchproject') and ((id != 'https://raid.org/10.71821/418be95a') and count(isPartOf[id = 'https://raid.org/10.71821/418be95a']) = 0)]"/>
            <xsl:apply-templates select="//dataset/member[id = 'https://vocabulary.raid.org/organisation.role.schema/182']/member[(lower-case(type) = 'person') or (lower-case(type) = 'organization')]" mode="party_record"/>
            
            <!--xsl:apply-templates select="//data"/-->
            <!--xsl:apply-templates select="//dataset/producer" mode="activity"/-->
            <!--xsl:apply-templates select="//includedInDataCatalog" mode="catalog"/-->
            <!--xsl:apply-templates select="//publisher | //funder | //contributor | //provider" mode="party"/-->
        </registryObjects>
    </xsl:template>
    
    <!-- RDA currently needs a Party record rather than just ROR for Managing Organisation of an Activity, 
         otherwise we get an undefined index error, so create a Party record for now, for each organisation
         that is related with 'isManagedBy' 
         Post ReWrite we can remove these - or decide whether to retrieve them from ROR API instead -->
    <xsl:template match="member" mode="party_record">
        <registryObject group="{$group}">
             <key>
                 <xsl:value-of select="id[contains(., ror.org)][1]"/>
             </key>
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
           <party type="group">
               
               <identifier type="url">
                   <xsl:value-of select="id[contains(., ror.org)][1]"/>
               </identifier>
               <name type="primary">
                   <namePart>
                       <xsl:value-of select="name"/>
                   </namePart>
               </name>
           </party>
         </registryObject>
    </xsl:template>
    
    
    <xsl:template match="alternateName">
        <xsl:element name="name">
            <xsl:attribute name="type">
                <xsl:text>alternative</xsl:text>
            </xsl:attribute>
            <xsl:element name="namePart">
                <xsl:choose>
                    <xsl:when test="contains(., 'localhost:8080')">
                        <xsl:value-of select="replace(normalize-space(.), 'localhost:8080', 'raid.org')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- Override of RAiD vocabuarly mapping -->
    <xsl:template match="id" mode="organisationRelationshipMapping">
        
        <xsl:if test="contains(., 'https://vocabulary.raid.org/organisation.role.schema/182')">
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>isManagedBy</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
        <xsl:if test="contains(., 'https://vocabulary.raid.org/organisation.role.schema/186')">
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>isFundedBy</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="id" mode="personRelationshipMapping">
        
        <xsl:if test="contains(., 'https://vocabulary.raid.org/contributor.position.schema/307')">
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>hasPrincipalInvestigator</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
      
    </xsl:template>
    
    
    <xsl:template name="resultFromXPATH" as="node()*">
        <xsl:param name="xpathString" as="xs:string"/>
        
        <xsl:message select="concat('RAiD top level resultFromXPATH:', $xpathString)"/>
        
        <xsl:variable name="resultNodes" as="node()*">
            <xsl:evaluate xpath="$xpathString" as="node()*" context-item="."/>
        </xsl:variable>
        
        <xsl:for-each select="$resultNodes">
            
            <xsl:if test="(string-length(url) > 0) or ((string-length(value) > 0) and not(ends-with(value, ':')))">
                
                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:variable name="sourceType" select="normalize-space(propertyID)"/>
                        <xsl:choose>
                            <xsl:when test="string-length($sourceType) > 0">
                                <xsl:choose>
                                    <xsl:when test="contains($sourceType, '/')">
                                        <xsl:variable name="index" select="count(tokenize($sourceType, '/'))" as="xs:integer"/>
                                        <xsl:value-of select="tokenize($sourceType, '/')[$index]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$sourceType"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="string-length(url) > 0">
                            <xsl:apply-templates select="url/text()"/>
                        </xsl:when>
                        <xsl:when test="(string-length(value) > 0) and not(ends-with(value, ':'))">
                            <xsl:choose>
                                <xsl:when test="contains(value, 'localhost:8080')">
                                    <xsl:value-of select="replace(normalize-space(value), 'localhost:8080', 'raid.org')"/>
                                </xsl:when>
                                 <xsl:otherwise>
                                     <xsl:value-of select="normalize-space(value)"/>
                                 </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
