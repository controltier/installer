<?xml version="1.0" encoding="UTF-8"?>
<!--
This stylesheet converts a tomcat-users.xml file to java properties of the roles that a certain
user belongs to.  User and password to match are supplied as xsl parameters 'user' and 'password'.
The properties result will contain the single property 'user.roles', with the value of the 'roles' attribute
from the xml file for the appropriate user.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="http://xml.apache.org/xalan/java">
<xsl:param name="user"/>
<xsl:param name="password"/>
<xsl:output method="text"/>
<xsl:template match="user[(@username=$user or @name=$user) and @password=$password]">
user.roles=<xsl:value-of select="@roles"/>
</xsl:template>
</xsl:stylesheet>