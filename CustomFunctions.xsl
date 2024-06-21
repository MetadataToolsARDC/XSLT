<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:custom="http://custom.nowhere.yet"
    exclude-result-prefixes="custom">
    
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
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
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
            <xsl:when test="contains(lower-case($identifier), 'http')">
                <xsl:text>uri</xsl:text>
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
        
        
        <xsl:variable name="swap" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="contains(lower-case($CRC), 'epsg') and (contains(lower-case($CRC), '4326'))">
                    <xsl:copy-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
       <!-- to handle:
            "(lat,long),"
            "(long,lat),"
            "long,lat,elevation long,lat,elevation ..." 
            "lat,long,elevation lat,long,elevation ..." (swap depends on $CRC value)
            "long,lat long,lat" 
            "lat,long lat,long" (swap depends on $CRC value)
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
            
            <xsl:variable name="error" as="xs:boolean*">
                <xsl:choose>
                    <xsl:when test="$swap">
                        <xsl:variable name="proposedLat_sequence" as="xs:double*">
                            <xsl:for-each select="$firstCoords">
                                <xsl:choose>
                                    <xsl:when test="contains(lower-case($CRC), 'epsg') and contains(lower-case($CRC), '3857')">
                                        <xsl:value-of select="xs:double(custom:convertLatCoordFromEPSG3857(.))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="xs:double(.)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:variable>
                        
                        <xsl:choose>
                            <xsl:when test="count($proposedLat_sequence[. &lt; -90]) &gt; 0">
                                <xsl:message select="concat('ERROR: Expected to swap coordinates due to CRC [', $CRC,'] but will not because there is at least one value [',$proposedLat_sequence[xs:double(.) &lt; -90][1], '] that is not correct to use as latitute')"/>
                                <xsl:value-of select="true()"/>
                            </xsl:when>
                            <xsl:when test="count($proposedLat_sequence[. &gt; 90]) &gt; 0">
                                <xsl:message select="concat('ERROR: Expected to swap coordinates due to CRC [', $CRC,'] but will not because there is at least one value [',$proposedLat_sequence[xs:double(.) &gt; 90][1], '] that is not correct to use as latitute')"/>
                                <xsl:value-of select="true()"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
                            
            <xsl:choose>
                <xsl:when test="$swap and (count($error) = 0)">
                    <xsl:for-each select="$secondCoords">
                        <xsl:if test="count($firstCoords) >= position()">
                            <xsl:variable name="index" select="position()" as="xs:integer"/>
                            <xsl:variable name="first" select="normalize-space($firstCoords[$index])"/>
                            <xsl:variable name="second" select="normalize-space(.)"/>
                            <xsl:choose>
                                <xsl:when test="contains(lower-case($CRC), 'epsg') and contains(lower-case($CRC), '3857')">
                                    <xsl:value-of select="concat(custom:convertLongCoordFromEPSG3857($second), ',', custom:convertLatCoordFromEPSG3857($first))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($second, ',', $first)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$firstCoords">
                        <xsl:if test="count($secondCoords) >= position()">
                            <xsl:variable name="index" select="position()" as="xs:integer"/>
                            <xsl:variable name="first" select="normalize-space(.)"/>
                            <xsl:variable name="second" select="normalize-space($secondCoords[$index])"/>
                            <xsl:choose>
                                <xsl:when test="contains(lower-case($CRC), 'epsg') and contains(lower-case($CRC), '3857')">
                                    <xsl:value-of select="concat(custom:convertLongCoordFromEPSG3857($first), ',', custom:convertLatCoordFromEPSG3857($second))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($first, ',', $second)"/>
                                </xsl:otherwise>
                            </xsl:choose>
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
    
    <xsl:function name="custom:convertLatCoordFromEPSG3857" as="xs:double">
        <xsl:param name="latCoordStr" as="xs:string"/>
        
        <xsl:variable name="e" select="xs:double(2.7182818284)" as="xs:double"/> <!-- Approx Euler's value -->
        <xsl:variable name="lat3857" select="xs:double($latCoordStr)" as="xs:double"/>
        
        <xsl:variable name="temp1" select="xs:double($lat3857 div ($global_earthExtent div 180))" as="xs:double"/>
        <xsl:variable name="exponent" select="(math:pi() div 180) * $temp1" as="xs:double"/>
        
        <xsl:variable name="temp2" select="math:atan(math:pow($e, $exponent))" as="xs:double"/>
        <xsl:variable name="temp3" select="$temp2 div (math:pi() div 360)"/>
        <xsl:variable name="lat4326" select="$temp3 - 90 "/>
        
        <xsl:if test="$global_debug"><xsl:message select="concat('Converted lat from [', $latCoordStr, '] to [', $lat4326, ']')"/></xsl:if>
        
        
        <xsl:copy-of select="$lat4326"/>
            
    </xsl:function>
    
    <xsl:function name="custom:convertLongCoordFromEPSG3857" as="xs:double">
        <xsl:param name="longCoordStr" as="xs:string"/>
        
        <xsl:variable name="temp" select="xs:double($longCoordStr)" as="xs:double"/>
        
        <xsl:variable name="long4326" select="($temp*180) div $global_earthExtent"/>
        
        <!--xsl:if test="$global_debug"><xsl:message select="concat('Converted long from [', $longCoordStr, '] to [', $long4326, ']')"/></xsl:if-->
        
        <xsl:copy-of select="$long4326"/>
            
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
    
    <xsl:function name="custom:characterReplace">
        <xsl:param name="input"/>
        <!--xsl:variable name="name" select='replace(.,"&#x00E2;&#x80;&#x99;", "&#8217;")'/-->
        <xsl:variable name="replaceSingleQuote" select='replace($input,"&#x00E2;&#x80;&#x99;", "&#x2019;")'/>
        <xsl:variable name="replaceLeftDoubleQuote" select='replace($replaceSingleQuote, "&#x00E2;&#x80;&#x9c;", "&#x201C;")'/>
        <xsl:variable name="replaceRightDoubleQuote" select='replace($replaceLeftDoubleQuote, "&#x00E2;&#x80;&#x9d;", "&#x201D;")'/>
        <xsl:variable name="replaceNarrowNoBreakSpace" select='replace($replaceRightDoubleQuote, "&#xE2;&#x80;&#xAF;", "&#x202F;")'/>
        <xsl:value-of select="$replaceNarrowNoBreakSpace"/>
    </xsl:function>
    
</xsl:stylesheet>
