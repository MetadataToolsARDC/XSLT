<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    

    <xsl:import href="Esploro_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of the Sunshine Coast'"/>
    <xsl:param name="global_baseURI" select="'epubs.usc.edu.au'"/>
    <xsl:param name="global_group" select="'University of the Sunshine Coast'"/>
    <xsl:param name="global_publisherName" select="'University of the Sunshine Coast'"/>
    <xsl:param name="global_acronym" select="'USC'"/>
    <xsl:param name="global_oaiIdPrefix" select="'oai:alma.61USC_INST:'"/>
    

</xsl:stylesheet>
    
