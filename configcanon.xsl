<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:db="http://marklogic.com/xdmp/database"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:template match="db:path-namespaces">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of select="concat(string(namespace-uri), '=', string(prefix))"/>
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="db:databases">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of select="db:database-name"/>
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="db:range-element-indexes|db:range-element-attribute-indexes|db:element-word-lexicons|db:phrase-arounds|db:phrase-throughs|db:element-word-query-throughs">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of
                        select="
                            concat(string(parent-namespace-uri), ':', string(parent-localname), '/', string(namespace-uri), ':', string(localname),
                            '=', string(scalar-type), '+', string(collation))"
                    />
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="db:backup-id | db:database-id | db:forest-id | db:schema-database | db:security-database | db:triggers-database">
        <xsl:element name="{node-name(.)}">999</xsl:element>
    </xsl:template>


    <xsl:template match="db:range-path-indexes">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of
                        select="concat(string(path-expression), '+', string(collation), '+', string(type))"
                    />
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="element()">
        <xsl:choose>
            <xsl:when test="exists(./*)">
                <xsl:copy>
                    <xsl:for-each select="./*">
                        <xsl:sort>
                            <xsl:value-of select="node-name()"/>
                        </xsl:sort>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@* | text() | processing-instruction() | comment()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
