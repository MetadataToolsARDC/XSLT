<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:custom="http://custom.nowhere.yet"
    exclude-result-prefixes="custom fn math srv xs">
    
    <xsl:param name="global_debug" select="false()"/>
    <!-- Approx coordinate extent of earth - See Geodetic Reference System 1980 - "global" haha, coz "earth"-->
    <xsl:param name="global_earthExtent" select="2 * math:pi() * 6378137 div 2.0"  as="xs:double"/>  
    
    <xsl:function name="custom:sequenceContains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="str" as="xs:string"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="contains(lower-case(.), lower-case($str))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:strContainsSequenceSubset" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:param name="sequence" as="xs:string*"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="contains(lower-case($str), lower-case(.))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:sequenceContainsExact" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="str" as="xs:string"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="(lower-case(.) = lower-case($str))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:getIdentifierType" as="xs:string">
        <xsl:param name="identifierInput" as="xs:string"/>
        
        <xsl:variable name="identifier" select="fn:normalize-space($identifierInput)" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'ror')">
                <xsl:text>ror</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'raid')">
                <xsl:text>raid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with($identifier, '10.')"> <!-- in case it doesn't contain doi.org -->
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(lower-case($identifier), 'arc')">
                <xsl:text>arc</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(lower-case($identifier), 'http')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'uuid')">
                <xsl:text>global</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>local</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:getIdentifierTypeFromNameSpace" as="xs:string">
        <xsl:param name="identifierInput" as="xs:string"/>
        
        <xsl:variable name="identifier" select="fn:normalize-space($identifierInput)" as="xs:string"/>
      
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'ror')">
                <xsl:text>ror</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'raid')">
                <xsl:text>raid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with($identifier, '10.')"> <!-- in case it doesn't contain doi.org -->
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(lower-case($identifier), 'arc')">
                <xsl:text>arc</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'uuid')">
                <xsl:text>global</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>local</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:getDOIFromString_sequence" as="xs:string*">
        <xsl:param name="fullString" as="xs:string"/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="contains(lower-case($fullString), 'doi:')">
                    <xsl:analyze-string select="$fullString" regex="((DOI:)|(doi:))+(\d.[^\s&lt;]*)">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(0)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:analyze-string select="$fullString" regex="(http(s?):)(//[^#\s&lt;]*)">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(0)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($result)) > 0">
                <xsl:copy-of select="normalize-space($result)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
   
    
    <xsl:function name="custom:getDomainFromURL" as="xs:string">
        <xsl:param name="url"/>
        <!--xsl:value-of select="substring-before(':', (substring-before('/', (substring-after('://', $url)))))"/-->
        <xsl:choose>
            <xsl:when test="contains($url, '://')">
                <xsl:variable name="prefix" select="substring-before($url, '://')"/>
                <xsl:variable name="remaining" select="substring-after($url, '://')"/>
                <xsl:variable name="domainAndPerhapsPort">
                    <xsl:choose>
                        <xsl:when test="contains($remaining, '/')">
                            <xsl:value-of select="substring-before($remaining, '/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$remaining"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($domainAndPerhapsPort, ':')">
                        <xsl:value-of select="concat($prefix, '://', substring-before($domainAndPerhapsPort, ':'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($prefix, '://', $domainAndPerhapsPort)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('http://', $url)"/>
            </xsl:otherwise>
        </xsl:choose>
        <!--xsl:value-of select="substring-before(substring-before((substring-after($url, '://')), '/'), ':')"/-->
    </xsl:function>
    
    <xsl:function name="custom:formatCoordinates" as="xs:string">
        <xsl:param name="coordinates" as="xs:string"/>
        <xsl:param name="CRC_sequence" as="xs:string*"/>
        
        <xsl:variable name="CRC" as="xs:string">
            <xsl:choose>
                <xsl:when test="count($CRC_sequence) > 0">
                    <xsl:copy-of select="$CRC_sequence[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="string('')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        
       <!-- to handle:
            "(lat,long),"
            "(long,lat),"
            "long,lat,elevation long,lat,elevation ..." 
            "lat,long,elevation lat,long,elevation ..." 
            "long,lat long,lat" 
            "lat,long lat,long" 
            "long lat long lat" 
            
            First, separate into sequence each item between a space (and the last item)
        -->
        
        <!--xsl:variable name="coordinatePairOrTrioSequence" as="xs:string*">
            <xsl:choose>
                <xsl:when test="not(contains($coordinates, ','))">
                    <xsl:choose>
                        <xsl:when test="matches($coordinates, '\s+')">
                            <xsl:for-each select="tokenize($coordinates, '\s+')">
                                <xsl:value-of select="."/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="matches($coordinates, '\s+')">
                    <xsl:for-each select="tokenize($coordinates, '\s+')">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="contains($coordinates, '\),\(')">
                    <xsl:for-each select="tokenize($coordinates, '\),\(')">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$coordinates"/> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable--> 
        
        <xsl:variable name="firstCoords" as="xs:string*">
            <xsl:choose>
                <xsl:when test="contains($coordinates,',')">
                    <xsl:analyze-string select="$coordinates" regex="(-*\d+\.*\d*),\s*(-*\d+\.*\d*)">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                         </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:analyze-string select="$coordinates" regex="(-*\d+\.*\d*)\s(-*\d+\.*\d*)">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="secondCoords" as="xs:string*">
            <xsl:choose>
                <xsl:when test="contains($coordinates,',')">
                    <xsl:analyze-string select="$coordinates" regex="(-*\d+\.*\d*),\s*(-*\d+\.*\d*)">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:analyze-string select="$coordinates" regex="(-*\d+\.*\d*)\s(-*\d+\.*\d*)">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('firstCoords ', string-join(for $i in $firstCoords return $i, ' '))"/>
            <xsl:message select="concat('secondCoords ', string-join(for $i in $secondCoords return $i, ' '))"/>
        </xsl:if>
        
       
        <xsl:variable name="coordinatePair_sequence" as="xs:string*">
            
            <xsl:choose>
                <xsl:when test="custom:swapOrder($CRC)">
                    <xsl:for-each select="$secondCoords">
                        <xsl:if test="count($firstCoords) >= position()">
                            <xsl:variable name="index" select="position()" as="xs:integer"/>
                            <xsl:variable name="first" select="normalize-space(.)"/>
                            <xsl:variable name="second" select="normalize-space($firstCoords[$index])"/>
                            <xsl:value-of select="concat($first, ',', $second)"/>
                        </xsl:if>
                    </xsl:for-each> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$firstCoords">
                        <xsl:if test="count($secondCoords) >= position()">
                            <xsl:variable name="index" select="position()" as="xs:integer"/>
                            <xsl:variable name="first" select="normalize-space(.)"/>
                            <xsl:variable name="second" select="normalize-space($secondCoords[$index])"/>
                            <xsl:value-of select="concat($first, ',', $second)"/>
                        </xsl:if>
                    </xsl:for-each> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('count(longCoords) ', count($firstCoords))"/>
            <xsl:message select="concat('count(latCoords) ', count($secondCoords))"/>
            <xsl:message select="concat('count(coordinatePair_sequence) ', count($coordinatePair_sequence))"/>
        </xsl:if>
        
        <xsl:choose>    
            <xsl:when test="count($coordinatePair_sequence) > 0"> 
                <xsl:if test="$global_debug"><xsl:message select="concat('finalstring ', string-join(for $i in $coordinatePair_sequence return $i, ' '))"/></xsl:if>
                <xsl:value-of select="string-join(for $i in $coordinatePair_sequence return $i, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$coordinates"/> 
            </xsl:otherwise>
        </xsl:choose>
            
        
        
    </xsl:function>
    
   
    <xsl:function name="custom:swapOrder" as="xs:boolean">
        <xsl:param name="CRC" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="
                contains(lower-case($CRC), 'epsg:4326') or
                contains(lower-case($CRC), 'epsg:28354') or
                contains(lower-case($CRC), 'epsg:3308') or
                contains(lower-case($CRC), 'epsg:3395') or
                contains(lower-case($CRC), 'epsg:3577') or
                contains(lower-case($CRC), 'epsg:4283') or
                contains(lower-case($CRC), 'epsg:4326') or
                contains(lower-case($CRC), 'epsg:7844') or
                contains(lower-case($CRC), 'epsg:7854') or
                contains(lower-case($CRC), 'epsg:8058')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:function>
    
    <xsl:function name="custom:formatName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="contains($name, ', ')">
                <xsl:value-of select="concat(normalize-space(substring-after(substring-before($name, '.'), ',')), ' ', normalize-space(substring-before($name, ',')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:registryObjectKeyFromString" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
        <xsl:variable name="buffer" select="string-join(for $n in fn:string-to-codepoints($input) return string($n), '')"/>
        <xsl:choose>
            <xsl:when test="string-length($buffer) &gt; 50">
                <xsl:value-of select="substring($buffer, string-length($buffer)-50, 50)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$buffer"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:getDOI_FromString" as="xs:string*">
        <xsl:param name="fullString"/>
        <!-- set fullURL true if you want https://dx.doi.org/10.4225/72/5705AB92DB429 or as false
            if 10.4225/72/5705AB92DB429 is required -->
        <xsl:param name="fullURL" as="xs:boolean"/> 
        <xsl:if test="$global_debug"><xsl:message select="concat('Attempting to extract doi from : ', $fullString)"/></xsl:if>
        
        <xsl:choose>
            <xsl:when test="contains(lower-case($fullString), 'doi:')">
                <xsl:analyze-string select="$fullString" regex="((DOI:)|(doi:))(\s?)+(\d.[^\s&lt;]*)">
                    <xsl:matching-substring>
                        <xsl:variable name="extractedDOI" select="normalize-space(substring-after(regex-group(0), ':'))"/>
                        <xsl:choose>
                            <xsl:when test="$fullURL">
                                <xsl:if test="$global_debug"><xsl:message select="concat('Returning doi: [', 'https://doi.org/', $extractedDOI, ']')"/></xsl:if>
                                <xsl:value-of select="concat('http://doi.org/', $extractedDOI)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$global_debug"><xsl:message select="concat('Returning doi: [', $extractedDOI, ']')"/></xsl:if>
                                <xsl:value-of select="$extractedDOI"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="contains(lower-case($fullString), 'doi.org/')">
                <xsl:analyze-string select="$fullString" regex="(http(s?):)(//)([^\s]*)(doi.org/)([^\s&lt;]*)">
                    <xsl:matching-substring>
                        <xsl:variable name="extractedDOI" select="normalize-space(regex-group(0))"/>
                        <xsl:choose>
                            <xsl:when test="$fullURL">
                                <xsl:if test="$global_debug"><xsl:message select="concat('Returning doi: [', $extractedDOI, ']')"/></xsl:if>
                                <xsl:value-of select="$extractedDOI"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$global_debug"><xsl:message select="concat('Returning doi: [', substring-after($extractedDOI, 'doi.org/'), ']')"/></xsl:if>
                                <xsl:value-of select="substring-after($extractedDOI, 'doi.org/')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:getHandle_FromString" as="xs:string*">
        <xsl:param name="fullString"/>
        <xsl:if test="$global_debug"><xsl:message select="concat('Attempting to extract handle from : ', $fullString)"/></xsl:if>
        
        <xsl:if test="contains(lower-case($fullString), 'handle')">
            <xsl:analyze-string select="$fullString" regex="(http(s?):)(//)([^\s]*)(handle)([^\s&lt;]*)">
                <xsl:matching-substring>
                    <xsl:choose>
                        <xsl:when test="ends-with(regex-group(0), '.')">
                            <xsl:if test="$global_debug"><xsl:message select="concat('Extracted handle: [', substring(regex-group(0), 0, string-length(regex-group(0))), ']')"/></xsl:if>
                            <xsl:value-of select="regex-group(0)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$global_debug"><xsl:message select="concat('Extracted handle: [', regex-group(0), ']')"/></xsl:if>
                            <xsl:value-of select="regex-group(0)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!-- ============================================================
     SHARED HELPERS from claude.ai - hopefully they work and cover everything
     ============================================================ -->
  
    <xsl:function name="custom:hexToInt" as="xs:integer">
        <xsl:param name="hex" as="xs:string"/>
        <xsl:sequence select="
            if (string-length($hex) = 0)
            then 0
            else custom:hexToInt(substring($hex, 1, string-length($hex) - 1)) * 16
            + index-of(('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'),
            lower-case(substring($hex, string-length($hex))))[1] - 1
            "/>
    </xsl:function>
    
    <!-- Decodes NUMERIC character references only (&#226; / &#xE2; etc.),
     unwrapping repeated &amp;-escaping first. Needed for mojibake repair. -->
    <xsl:function name="custom:decodeNumericEntities" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="unwrapped" as="xs:string">
            <xsl:iterate select="1 to 5">
                <xsl:param name="current" as="xs:string" select="$text"/>
                <xsl:on-completion select="$current"/>
                <xsl:next-iteration>
                    <xsl:with-param name="current"
                        select="replace($current, '&amp;amp;(#x?[0-9a-fA-F]+;)', '&amp;$1')"/>
                </xsl:next-iteration>
            </xsl:iterate>
        </xsl:variable>
        <xsl:variable name="pieces" as="xs:string*">
            <xsl:analyze-string select="$unwrapped" regex="&amp;#(x[0-9a-fA-F]+|[0-9]+);">
                <xsl:matching-substring>
                    <xsl:variable name="ref" select="regex-group(1)"/>
                    <xsl:value-of select="
                        codepoints-to-string(
                        if (starts-with($ref, 'x'))
                        then custom:hexToInt(substring($ref, 2))
                        else xs:integer($ref)
                        )"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($pieces, '')"/>
    </xsl:function>
    
    <!-- Decodes NAMED entities relevant to markup (lt, gt, amp, quot, apos,
     nbsp), unwrapping repeated &amp;-escaping first. Only used where HTML
     is actually being processed. -->
    <xsl:function name="custom:decodeNamedEntities" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="unwrapped" as="xs:string">
            <xsl:iterate select="1 to 5">
                <xsl:param name="current" as="xs:string" select="$text"/>
                <xsl:on-completion select="$current"/>
                <xsl:next-iteration>
                    <xsl:with-param name="current"
                        select="replace($current, '&amp;amp;(lt|gt|amp|quot|apos|nbsp);', '&amp;$1;')"/>
                </xsl:next-iteration>
            </xsl:iterate>
        </xsl:variable>
        <xsl:variable name="pieces" as="xs:string*">
            <xsl:analyze-string select="$unwrapped" regex="&amp;(lt|gt|amp|quot|apos|nbsp);">
                <xsl:matching-substring>
                    <xsl:variable name="ref" select="regex-group(1)"/>
                    <xsl:choose>
                        <xsl:when test="$ref = 'lt'">&lt;</xsl:when>
                        <xsl:when test="$ref = 'gt'">&gt;</xsl:when>
                        <xsl:when test="$ref = 'amp'">&amp;</xsl:when>
                        <xsl:when test="$ref = 'quot'">&quot;</xsl:when>
                        <xsl:when test="$ref = 'apos'">&apos;</xsl:when>
                        <xsl:when test="$ref = 'nbsp'"><xsl:text>&#160;</xsl:text></xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($pieces, '')"/>
    </xsl:function>
    
    <!-- Repairs UTF-8-misread-as-Latin-1 mojibake generally, by reconstructing
     the real character from the raw byte values, rather than relying on
     a fixed table of known-corrupted sequences. Covers both 2-byte UTF-8
     sequences (e.g. accented letters: Ã¶ -> ö, Ã± -> ñ, Ã¸ -> ø) and
     3-byte sequences (e.g. smart punctuation: â€™ -> ’, â€“ -> –).
     This subsumes the old hardcoded punctuation table — same results
     for known cases, plus correct results for any character we hadn't
     explicitly enumerated (e.g. author names with diacritics). -->
    <xsl:function name="custom:repairMojibake" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="pieces" as="xs:string*">
            <xsl:analyze-string select="$text"
                regex="[&#xE0;-&#xEF;][&#x80;-&#xBF;][&#x80;-&#xBF;]|[&#xC2;-&#xDF;][&#x80;-&#xBF;]">
                <xsl:matching-substring>
                    <xsl:variable name="cps" select="string-to-codepoints(.)"/>
                    <xsl:value-of select="
                        codepoints-to-string(
                        if (string-length(.) = 3)
                        then (($cps[1] - 224) * 4096) + (($cps[2] - 128) * 64) + ($cps[3] - 128)
                        else (($cps[1] - 192) * 64) + ($cps[2] - 128)
                        )"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($pieces, '')"/>
    </xsl:function>
    
    <!-- Converts literal backslash-escaped break characters (\n, \t) — as
     opposed to real control characters, which normaliseLineEndings
     already handles — into their real equivalents. The real tab this
     produces gets collapsed to a single space by tidyLines' per-line
     normalize-space, consistent with how all other whitespace is
     handled throughout this pipeline. -->
    <xsl:function name="custom:normaliseLiteralEscapes" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:sequence select="replace(replace($text, '\\n', '&#10;'), '\\t', '&#9;')"/>
    </xsl:function>
    
    <!-- Trims/collapses whitespace on each line, then rejoins using the
     XML-friendly literal marker &#10; instead of a real line-feed, so
     serializers/renderers can't silently collapse or strip it. -->
    <xsl:function name="custom:tidyLines" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:sequence select="
            string-join(
            for $line in tokenize($text, '&#10;')
            return normalize-space($line),
            '&amp;#10;')"/>
    </xsl:function>
    
    <!-- Folds every line-break representation we know of down to a single
     internal LF, so downstream steps only ever have one form to deal
     with. Literal backslash-n text is handled separately by the caller,
     since it isn't a real control character.
     Note: vertical tab (U+000B) and form feed (U+000C) are deliberately
     NOT included here — both are illegal anywhere in a well-formed XML
     document (XML 1.0 §2.2 Char production), so they can never legally
     appear in text parsed out of XML input in the first place. Including
     even a character reference to them in this stylesheet is itself a
     fatal XML well-formedness error, since the stylesheet is XML too. -->
    <xsl:function name="custom:normaliseLineEndings" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:sequence select="
            replace(
            replace($text, '&#13;&#10;', '&#10;'),
            '[&#13;&#x2028;&#x2029;]', '&#10;')
            "/>
    </xsl:function>
    
    
    <!-- ============================================================
     FUNCTION 1 — mojibake + break normalisation only
     ============================================================ -->
    <xsl:function name="custom:cleanTextPreserveHTML" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        
        <xsl:variable name="normalised" as="xs:string"
            select="custom:normaliseLineEndings($text)"/>
        <xsl:variable name="withLiteralBreaks" as="xs:string"
            select="custom:normaliseLiteralEscapes($normalised)"/>
        <xsl:variable name="repaired" as="xs:string"
            select="custom:repairMojibake(custom:decodeNumericEntities($withLiteralBreaks))"/>
        
        <xsl:sequence select="custom:tidyLines($repaired)"/>
    </xsl:function>
    
    
    <!-- ============================================================
     FUNCTION 2 — everything Function 1 does, plus HTML handling:
     <br> variants become a line break, everything else is stripped
     ============================================================ -->
    <xsl:function name="custom:cleanAndStripHtml" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        
        <xsl:variable name="normalised" as="xs:string"
            select="custom:normaliseLineEndings($text)"/>
        <xsl:variable name="withLiteralBreaks" as="xs:string"
            select="custom:normaliseLiteralEscapes($normalised)"/>
        <xsl:variable name="repaired" as="xs:string"
            select="custom:repairMojibake(custom:decodeNumericEntities($withLiteralBreaks))"/>
        
        <xsl:variable name="realTags" as="xs:string"
            select="custom:decodeNamedEntities($repaired)"/>
        
        <xsl:variable name="withBreaks" as="xs:string"
            select="replace($realTags, '&lt;br(&gt;|[\s/][^&gt;]*&gt;)', '&#10;', 'i')"/>
        
        <xsl:variable name="stripped" as="xs:string"
            select="replace($withBreaks, '&lt;/?[a-zA-Z][a-zA-Z0-9]*(\s[^&lt;&gt;]*)?/?&gt;', '')"/>
        
        <xsl:sequence select="custom:tidyLines($stripped)"/>
    </xsl:function>
    
    
    <!-- ============================================================
     CALL SITE HELPER — writes a cleaned string out safely.
     Splits on the literal &#10; marker: real content segments are
     emitted with NORMAL escaping (so any genuine & or < in the
     source text — e.g. "Lance & Kachel" — is correctly re-escaped
     back to &amp;), while only the marker itself is written raw via
     disable-output-escaping, since we know exactly what it contains.
     A blanket disable-output-escaping over the whole string is unsafe:
     it also suppresses escaping of any real ampersand in the content,
     producing invalid, non-well-formed output.
     ============================================================ -->
    <xsl:template name="custom:writeCleanedText">
        <xsl:param name="value" as="xs:string"/>
        <xsl:for-each select="tokenize($value, '&amp;#10;')">
            <xsl:if test="position() > 1">
                <xsl:text disable-output-escaping="yes">&amp;#10;</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>
    
  
</xsl:stylesheet>
