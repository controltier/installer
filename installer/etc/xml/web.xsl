<?xml version="1.0" encoding="UTF-8"?>
<!--
This stylesheet converts a web.xml file to java properties of the roles that a certain
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="http://xml.apache.org/xalan/java">
<xsl:param name="user"/>
<xsl:param name="password"/>
<xsl:output method="text"/>
<xsl:template match="/">
<xsl:apply-templates select="web-app"/>
</xsl:template>
<xsl:template match="web-app">
<xsl:apply-templates select="servlet"/>
</xsl:template>
<xsl:template match="servlet">
<xsl:apply-templates select="init-param"/>
</xsl:template>
<xsl:template match="init-param">
#
<xsl:value-of select="param-name"/>=<xsl:value-of select="param-value"/>
#
</xsl:template>
</xsl:stylesheet>