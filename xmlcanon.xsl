<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://marklogic.com/xdmp/database"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    >
    
    <xsl:output indent="yes"/>
    
    <xsl:variable name="separate-database-files" select="true()"/>
    
    <xsl:template match="db:path-namespaces">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of select="concat(string(db:namespace-uri), '=', string(db:prefix))"/>
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="/db:databases">
        <xsl:choose>
            <xsl:when test="$separate-database-files">
                <xsl:for-each select="db:database">
                    <xsl:variable name="dbname" select="string(db:database-name)"/>
                    <xsl:result-document href="{concat ($dbname, '-db-canon.xml')}" method="xml">
                        <xsl:element name="{node-name(.)}">
                            <xsl:for-each select="./*">
                                <xsl:sort>
                                    <xsl:value-of select="db:database-name"/>
                                </xsl:sort>
                                <xsl:for-each select="@*">
                                    <xsl:sort>
                                        <xsl:value-of select="local-name(.)"/>
                                    </xsl:sort>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                                <xsl:for-each select="./*">
                                    <xsl:sort>
                                        <xsl:value-of select="local-name(.)"/>
                                    </xsl:sort>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:result-document>   
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:for-each select="@*">
                        <xsl:sort>
                            <xsl:value-of select="local-name(.)"/>
                        </xsl:sort>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:for-each select="./db:database">
                        <xsl:sort>
                            <xsl:value-of select="db:database-name"/>
                        </xsl:sort>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="db:range-element-indexes|db:range-element-attribute-indexes|db:element-word-lexicons|db:phrase-arounds|db:phrase-throughs|db:element-word-query-throughs">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of
                        select="
                        concat(string(db:parent-namespace-uri), ':', string(db:parent-localname), '/', string(db:namespace-uri), ':', string(db:localname),
                        '=', string(db:scalar-type), '+', string(db:collation))"
                    />
                </xsl:sort>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template
        match="db:backup-id | db:database-id | db:forest-id | db:schema-database | db:security-database | db:triggers-database">
        <xsl:copy><xsl:value-of select="999"/></xsl:copy>
        <!--<xsl:element name="{node-name(.)}"><xsl:value-of select="string(node-name(.))"/></xsl:element>-->
    </xsl:template>
    
    
    <xsl:template match="db:range-path-indexes">
        <xsl:copy>
            <xsl:for-each select="./*">
                <xsl:sort>
                    <xsl:value-of
                        select="concat(string(db:path-expression), '+', string(db:collation), '+', string(db:type))"
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
            <xsl:apply-templates select="@* | node() | text()"/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>
