<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
    xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs xsi xsl mdb mri mco cit">
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Integrated Marine Observing System'"/>
    <xsl:param name="global_acronym" select="'IMOS'"/>
    <xsl:param name="global_baseURI" select="'catalogue-imos.aodn.org.au'"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/search?uuid='"/>
    <xsl:param name="global_group" select="'Integrated Marine Observing System'"/>
    <xsl:param name="global_publisherName" select="'Integrated Marine Observing System'"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <registryObjects 
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:apply-templates select="//mdb:MD_Metadata" mode="process"/>
        </registryObjects>
        
    </xsl:template>
   
    
    <!-- IMOS have requested that a dataset be indicated as 'open' access if it has licence Creative Commons Attribution
            so this template overrides the core function in ISO19115-3_To)_RIFCS.xsl -->
    
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject_rights_access">
        
        <xsl:if test="(count(mri:resourceConstraints/mco:MD_LegalConstraints/mco:reference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource/cit:linkage[contains(lower-case(.), 'creativecommons.org/licenses/by/')]) > 0) or
                      (count(mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints[matches(lower-case(.), 'creative commons attribution \d')]) > 0)">
                
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
     
    </xsl:template>
    
    
      
</xsl:stylesheet>
