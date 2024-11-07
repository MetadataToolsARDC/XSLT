<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:thread="java.lang.Thread"
    xmlns:local="http://local.to.here"
    version="4.0" >
 <!-- this stylesheet attempt to match all values in the Admin_Institution column from the supplied NHMRC grant data 
     spreadsheet against an organisation record entry in RoR for this institution so that the activity(grant) record can be related 
     to it's managin insitution via a related info identifier
     
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
        <xsl:variable name="foundName_array" select="map:find($jsonMap_getName, 'name')" as="array(*)"/>
        <xsl:choose>
            <xsl:when test="array:size($foundName_array) > 0">
                <xsl:variable name="foundName" select="array:get($foundName_array, 1)" as="item()*"/>
                <xsl:choose>
                    <xsl:when test="lower-case($name) = lower-case($foundName)">
                        <!--xsl:message select="concat('double check succeeded - name: [', $name, '], foundName: [', $foundName, ']')"></xsl:message-->
                        <xsl:copy-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="concat('double check failed - id originally found for name [', $name, '] has now returned different name [', $foundName, ']')"></xsl:message>
                        <xsl:copy-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
           <xsl:otherwise>
               <xsl:message select="concat('double check failed - no name found for id: http://ror.org/', $idPostfix)"></xsl:message>
               <xsl:copy-of select="false()"/>
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
            <xsl:for-each-group select="row" group-by="Admin_Institution">
                <xsl:variable name="admin_inst" select="lower-case(normalize-space(Admin_Institution))"/>
                
                <xsl:if test="string-length($admin_inst) > 0">
                
                    <xsl:variable name="query_getID" select="concat($queryroot_idFromName,'(',encode-for-uri($admin_inst),')')"/>
                    <xsl:message select="concat('query_getID :', $query_getID)"></xsl:message>
                    
                     <xsl:variable name="jsonMap_getID" select="json-doc($query_getID)" as="item()?"/>
                    
                    <xsl:variable name="sleep" select="local:sleep(1000)"/>
                    
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="institution">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="name"><xsl:value-of select="Admin_Institution"/></xsl:element>
                        <xsl:if test="map:size($jsonMap_getID) > 0">
                            
                            <xsl:variable name="foundItems_array" select="map:find($jsonMap_getID, 'items')" as="array(*)"/>
                            <xsl:if test="array:size($foundItems_array) > 0">
                                <xsl:variable name="foundID_array" select="map:find($foundItems_array, 'id')" as="array(*)"/>
                                
                                <xsl:if test="array:size($foundID_array) > 0">
                                    <xsl:variable name="identifier" select="array:get($foundID_array, 1)" as="item()*"/>
                                    
                                    <xsl:if test="(count($identifier) > 0) and contains($identifier, '/')">
                                        
                                        <!-- double check by retrieving org name for this id -->
                                        <xsl:variable name="index" select="count(tokenize($identifier, '/'))"/>
                                        <xsl:if test="$index > 1">
                                            <xsl:variable name="idPostfix" select="tokenize($identifier, '/')[$index]"/>
                                            
                                            <xsl:variable name="sleep" select="local:sleep(1000)"/>
                                            
                                            <xsl:if test="local:doubleCheck(Admin_Institution, $idPostfix)">
                                                <xsl:choose>
                                                    <xsl:when test="$identifier != ''">
                                                        <xsl:text>&#xA;</xsl:text>
                                                        <xsl:element name="identifier">
                                                            <xsl:value-of select="$identifier[1]"/>
                                                        </xsl:element>
                                                     </xsl:when>
                                                     <xsl:otherwise>
                                                        <xsl:message>
                                                            <xsl:text>Unmatched </xsl:text>
                                                            <xsl:value-of select="Admin_Institution"/>
                                                            <xsl:text> - </xsl:text>
                                                            <xsl:value-of select="$query_getID"/>
                                                        </xsl:message>  
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>    
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:element>    
                </xsl:if>
                
            </xsl:for-each-group>
        
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
