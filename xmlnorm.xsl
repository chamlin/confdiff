<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:db="http://marklogic.com/xdmp/database"
    xmlns:xmlnorm="http://marklogic.com/support/xmlnorm" exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:param name="debug" select="false()"/>


    <xsl:variable name="parent-local-qnames" as="xs:QName+">
        <xsl:sequence
            select="
                for $s in ('range-element-index', 'range-element-attribute-index', 'element-word-lexicon', 'phrase-around', 'phrase-through', 'element-word-query-through')
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
                <xsl:choose>
                    <xsl:when test="$e/*">
                        <xsl:value-of
                            select="concat(string($e/db:namespace-uri), '=', string($e/db:prefix))"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string(node-name($e))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="node-name($e) = $parent-local-qnames">
                <xsl:value-of
                    select="
                        concat(string($e/db:parent-namespace-uri), ':', string($e/db:parent-localname), '/', string($e/db:namespace-uri), ':', string($e/db:localname),
                        '=', string($e/db:scalar-type), '+', string($e/db:collation))"
                />
            </xsl:when>
            <xsl:when
                test="node-name($e) = QName('http://marklogic.com/xdmp/database', 'range-path-index')">
                <xsl:value-of
                    select="concat(string($e/db:path-expression), '+', string($e/db:collation), '+', string($e/db:type))"
                />
            </xsl:when>
            <xsl:when test="node-name($e) = QName('http://marklogic.com/xdmp/database', 'field')">
                <xsl:value-of select="string($e/db:field-name)"/>
            </xsl:when>
            <xsl:when
                test="node-name($e) = QName('http://marklogic.com/xdmp/database', 'tokenizer-override')">
                <xsl:value-of select="string($e/db:character)"/>
            </xsl:when>
            <xsl:when
                test="node-name($e) = QName('http://marklogic.com/xdmp/database', 'range-field-index')">
                <xsl:value-of select="string($e/db:field-name)"/>
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

    <xsl:template match="element()" name="element-processor">
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
                <xsl:if test="$debug">
                    <sortkey>
                        <xsl:value-of select="xmlnorm:sortkey(.)"/>
                    </sortkey>
                </xsl:if>
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
