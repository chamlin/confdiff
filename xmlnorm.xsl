<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:db="http://marklogic.com/xdmp/database"
    xmlns:xmlnorm="http://marklogic.com/support/xmlnorm" exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:variable name="parent-local-qnames" as="xs:QName+">
        <xsl:sequence
            select="
                for $s in ('range-element-indexes', 'range-element-attribute-indexes', 'element-word-lexicons', 'phrase-arounds', 'phrase-throughs', 'element-word-query-throughs')
                return
                    QName('http://marklogic.com/xdmp/database', $s)"
        />
    </xsl:variable>

    <!-- create a sort key for various element types -->
    <xsl:function name="xmlnorm:sortkey" as="xs:string">
        <xsl:param as="element()" name="e"/>
        <xsl:choose>
            <xsl:when
                test="node-name($e) eq QName('http://marklogic.com/xdmp/database', 'database')">
                <xsl:value-of select="string($e/db:database-name)"/>
            </xsl:when>
            <xsl:when
                test="node-name($e) eq QName('http://marklogic.com/xdmp/database', 'path-namespaces')">
                <xsl:value-of select="concat(string($e/namespace-uri), '=', string($e/prefix))"/>
            </xsl:when>
            <xsl:when test="node-name($e) = $parent-local-qnames">
                <xsl:value-of
                    select="
                        concat(string($e/parent-namespace-uri), ':', string($e/parent-localname), '/', string($e/namespace-uri), ':', string($e/localname),
                        '=', string($e/scalar-type), '+', string($e/collation))"
                />
            </xsl:when>
            <xsl:when test="node-name($e) = QName('http://marklogic.com/xdmp/database', 'range-path-indexes')">
                <xsl:value-of
                    select="concat(string($e/path-expression), '+', string($e/collation), '+', string($e/type))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string(node-name($e))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- better for different clusters? -->
    <xsl:template
        match="db:backup-id | db:database-id | db:forest-id | db:schema-database | db:security-database | db:triggers-database">
        <xsl:element name="{node-name(.)}">999</xsl:element>
    </xsl:template>

    <xsl:template match="element()">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:sort>
                    <xsl:value-of select="local-name(.)"/>
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of select="xmlnorm:sortkey(.)"/>
                </xsl:sort>
                <!-- <xsl:value-of select="xmlnorm:sortkey(.)"/> -->
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <!-- is this stuff wacky?  what about mixed content?  doesn't happen in configs? -->
            <xsl:for-each select="./text()">
                <xsl:sort>
                    <xsl:value-of select="string(.)"/>
                </xsl:sort>
                <xsl:copy-of select="normalize-space(.)"/>
            </xsl:for-each>
            <!-- 
            <xsl:for-each select="./(processing-instruction() | comment())">
             
            </xsl:for-each>
            -->
        </xsl:copy>
    </xsl:template>


    <xsl:template match="@* | text() | processing-instruction() | comment()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
