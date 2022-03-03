<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:import href="ISO19115-3_DIF.xsl"/>
    
    <xsl:param name="default_units_depth" select="'Metres'"/>
    <xsl:param name="default_units_altitude" select="'Metres'"/>
    <xsl:param name="default_discipline_name" select="'EARTH SCIENCE'"/>
    <xsl:param name="default_data_centre_short_name" select="'AU/IMAS'"/>
    <xsl:param name="default_data_centre_long_name" select="'Institute for Marine and Antarctic Studies (IMAS)'"/>
    <xsl:param name="default_data_centre_url" select="'https://www.imas.utas.edu.au'"/>
    <xsl:param name="default_data_centre_personnel_role" select="'DATA CENTER CONTACT'"/>
    <xsl:param name="default_data_centre_personnel_first_name" select="'Data Manager'"/>
    <xsl:param name="default_data_centre_personnel_last_name" select="'IMAS'"/>
    <xsl:param name="default_data_centre_personnel_email" select="'IMAS.DataManager@utas.edu.au'"/>
    <xsl:param name="default_originating_metadata_node" select="'IMAS'"/>
    <xsl:param name="default_IDN_Node_sequence" select="'AMD/AU', 'CEOS', 'AMD', 'ACE/CRC'"/>
    <xsl:param name="default_metadata_name" select="'CEOS IDN DIF'"/>
    <xsl:param name="default_metadata_version" select="'VERSION 9.9.3'"/>
      
</xsl:stylesheet>
