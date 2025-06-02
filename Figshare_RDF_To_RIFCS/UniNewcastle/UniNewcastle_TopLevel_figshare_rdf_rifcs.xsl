<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:bibo="http://purl.org/ontology/bibo/" 
    xmlns:datacite="http://purl.org/spar/datacite/" 
    xmlns:fabio="http://purl.org/spar/fabio/" 
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:literal="http://www.essepuntato.it/2010/06/literalreification/" 
    xmlns:obo="http://purl.obolibrary.org/obo/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#" 
    xmlns:vivo="http://vivoweb.org/ontology/core#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:local="http://local.here.org"
    xmlns:exslt="http://exslt.org/common"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="oai dc bibo datacite fabio foaf literal obo rdf rdfs vcard vivo xs fn local exslt">
    <xsl:import href="figshare_rdf_rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of Newcastle'"/>
    <xsl:param name="global_baseURI" select="'newcastle.edu.au/'"/>
    <xsl:param name="global_group" select="'The University of Newcastle'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects https://researchdata.edu.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
    <!-- Override key creation for University of Newcastle to use Handle if there is one, then next option is Figshare Identifier -->
    
    <xsl:template match="rdf:RDF" mode="collection_key">
        <xsl:param name="oaiFigshareIdentifier" as="xs:string"/>
        
        <key>
            <xsl:choose>
                <xsl:when test="count(*/bibo:handle[string-length(.) > 0]) > 0">
                    <xsl:choose>
                        <xsl:when test="fn:starts-with(*/bibo:handle[string-length(.) > 0][1], 'http')">
                            <xsl:value-of select="*/bibo:handle[string-length(.) > 0][1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('http://hdl.handle.net/', */bibo:handle[string-length(.) > 0][1])"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="count(*/bibo:doi[string-length(.) > 0]) > 0">
                    <xsl:choose>
                        <xsl:when test="fn:starts-with(*/bibo:doi[string-length(.) > 0][1], 'http')">
                            <xsl:value-of select="*/bibo:doi[string-length(.) > 0][1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('http://doi.org/', */bibo:doi[string-length(.) > 0][1])"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($oaiFigshareIdentifier)) return string($n), ''), 0, 50)"/>
                </xsl:otherwise>
            </xsl:choose>
        </key>
    </xsl:template>
    
  
    
</xsl:stylesheet>
