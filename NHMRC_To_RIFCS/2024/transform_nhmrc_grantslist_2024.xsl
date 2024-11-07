<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" version="2.0">

   <xsl:output method="xml"/>
    
    <xsl:import href="../CORE/transform_nhmrc_grantslist_core.xsl"/>
    
    <xsl:variable name="AdminInstitutions" select="document('nhmrc_admin_institutions_manual_update_ror_id_2024.xml')"/>
    
    
    <xsl:template match="/root">
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="registryObjects"
            xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
            <xsl:attribute name="xsi:schemaLocation">http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd</xsl:attribute>
            <xsl:apply-templates select="row"/>
        </xsl:element>
    </xsl:template>
    
   
</xsl:stylesheet>
