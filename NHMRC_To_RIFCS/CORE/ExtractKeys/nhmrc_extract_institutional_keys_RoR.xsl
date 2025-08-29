<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:fn="https://www.w3.org/TR/xpath-functions-31/"
    xmlns:thread="java.lang.Thread"
    xmlns:local="http://local.to.here"
    version="3.0" >
    <!-- This stylesheet attempts to match all values in the Admin_Institution|Administering_Institution column from the supplied NHMRC grant data 
     spreadsheet against an organisation record entry in RoR for this institution so that the activity(grant) record can be related 
     to its managing insitution via a related info identifier
     
     The output is an xml document listing the institutions with their name as used by the NHMRC and the corresponding identifier 
     for their organisation record in RDA. This is used as a lookup table by the main transformation -  NHMRC grant row to RIF-CS record
  -->
    
    <xsl:output method="xml"/>
    
    <xsl:variable name="queryroot_idFromName" select="'https://api.ror.org/v2/organizations?query='"/>
    <xsl:variable name="queryroot_nameFromID" select="'https://api.ror.org/organizations/'"/>
    
     <xsl:function name="local:doubleCheck" as="xs:boolean">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="idPostfix" as="xs:string"/>
        
        <xsl:variable name="query_getName" select="concat($queryroot_nameFromID, $idPostfix)"/>
        <xsl:message select="concat('query_getName :', $query_getName)"></xsl:message>
        
        <xsl:variable name="jsonMap_getName" select="json-doc($query_getName)" as="item()?"/>
        <xsl:variable name="namesArray" select="$jsonMap_getName?names"/>
        <xsl:variable name="foundName_array" select="array{$namesArray?*?value}" as="array(*)"/>
         
         <xsl:variable name="results" as="xs:boolean*">
            <xsl:for-each select="array:flatten($foundName_array)">
                <xsl:variable name="foundName" select="."/>
                    <xsl:if test="lower-case($name) = lower-case($foundName)">
                        <xsl:message select="concat('double check - name sought: [', $name, '] matches name found: [', $foundName, ']')"/>
                        <xsl:copy-of select="true()"/>
                    </xsl:if>
            </xsl:for-each>
         </xsl:variable>
         
         <xsl:choose>
            <xsl:when test="count($results) > 0">
                <xsl:message select="concat('double check succeeded - found name matching ', $name)"/>
                <xsl:copy-of select="true()"/>
            </xsl:when>
             <xsl:otherwise>
                <xsl:copy-of select="false()"/>
                <xsl:message select="concat('double check failed - no name found for id: http://ror.org/', $idPostfix, ' that matches ', $name)"></xsl:message>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:function>
    
    <xsl:function name="local:sleep">
        <xsl:param name="milliseconds"/>
        
        <xsl:choose>
            <xsl:when test="function-available('thread:sleep')">
                <xsl:value-of select="thread:sleep($milliseconds)"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Function thread:sleep not available</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
   
    <xsl:template match="/root">
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="institutions">                           
            <xsl:for-each-group select="row" group-by="Admin_Institution | Administering_Institution">
                <xsl:variable name="admin_inst" select="current-grouping-key()"/>
                
                <xsl:message select="concat('Finding RoR for Institution: ', $admin_inst)"></xsl:message>
              
                
                <xsl:if test="string-length($admin_inst) > 0">
                
                    <xsl:variable name="query_getID" select="concat($queryroot_idFromName,'(',encode-for-uri($admin_inst),')')"/>
                    <xsl:message select="concat('query_getID :', $query_getID)"></xsl:message>
                    
                     <xsl:variable name="jsonMap_getID" select="json-doc($query_getID)" as="item()?"/>
                    
                    <xsl:variable name="sleep" select="local:sleep(1000)"/>
                    
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="institution">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="name"><xsl:value-of select="$admin_inst"/></xsl:element>
                        <xsl:choose>
                            <xsl:when test="map:size($jsonMap_getID) > 0">
                              <xsl:variable name="foundItems_array" select="map:find($jsonMap_getID, 'items')" as="array(*)"/>
                                <xsl:if test="array:size($foundItems_array) > 0">
                                    <xsl:variable name="foundID_array" select="map:find($foundItems_array, 'id')" as="array(*)"/>
                                    
                                    <xsl:choose>
                                         <xsl:when test="array:size($foundID_array) > 0">
                                             <xsl:variable name="identifier" select="array:get($foundID_array, 1)" as="item()*"/>
                                             
                                             <xsl:if test="(count($identifier) > 0) and contains($identifier, '/')">
                                                 
                                                 <xsl:variable name="index" select="count(tokenize($identifier, '/'))"/>
                                                 <xsl:if test="$index > 1">
                                                     <xsl:variable name="idPostfix" select="tokenize($identifier, '/')[$index]"/>
                                                     
                                                     <xsl:variable name="sleep" select="local:sleep(1000)"/>
                                                     <xsl:choose>
                                                         <xsl:when test="$identifier and local:doubleCheck($admin_inst, $idPostfix)">
                                                             <xsl:text>&#xA;</xsl:text>
                                                             <xsl:element name="identifier">
                                                                 <xsl:value-of select="$identifier[1]"/>
                                                             </xsl:element>
                                                         </xsl:when>
                                                         <xsl:otherwise>
                                                             <xsl:text>&#xA;</xsl:text>
                                                             <xsl:element name="identifier"></xsl:element>
                                                         </xsl:otherwise>
                                                     </xsl:choose>
                                                   
                                                 </xsl:if>
                                             </xsl:if>
                                         </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>&#xA;</xsl:text>
                                            <xsl:element name="identifier"></xsl:element>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#xA;</xsl:text>
                                <xsl:element name="identifier"></xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:element>    
                </xsl:if>
                
            </xsl:for-each-group>
        
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
