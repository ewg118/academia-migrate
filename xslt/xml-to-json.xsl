<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<xsl:variable name="json">
			<xsl:if test="descendant::records">[</xsl:if>
			<xsl:for-each select="descendant-or-self::record">
				<xsl:text>{"metadata":{</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>}}</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="descendant::records">]</xsl:if>
		</xsl:variable>
		
		<xsl:value-of select="$json"/>
		
	</xsl:template>

	<xsl:template match="keywords[keyword]">
		<xsl:text>"keywords":[</xsl:text>
		<xsl:for-each select="keyword[string-length(.) &gt; 0]">
			<xsl:text>"</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="creators">
		<xsl:text>"creators":[</xsl:text>
		<xsl:for-each select="creator">
			<xsl:text>{"name":"</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
			<xsl:if test="@affiliation">
				<xsl:text>,"affiliation":"</xsl:text>
				<xsl:value-of select="@affiliation"/>
				<xsl:text>"</xsl:text>
			</xsl:if>
			<xsl:text>}</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>]</xsl:text>
		<xsl:if test="following-sibling::*">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- recast url as identifier -->
	<!--<xsl:template match="url">
		<xsl:text>"related_identifiers":[{"relation":"isAlternateIdentifier","identifier":"</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"}],</xsl:text>
	</xsl:template>-->
	
	<!-- ignore the following -->
	<xsl:template match="id|publication_day|publication_month|publication_year|url"/>
	
	<!-- call templates for simple elements, ignoring some from initial scrape model -->
	<xsl:template match="*[not(self::id|self::url|self::publication_day|self::publication_month|self::publication_year)][not(child::*)]">
		<xsl:variable name="val" select="replace(., '&#x022;', '\\&#x022;')"/>
		
		<xsl:text>"</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>":</xsl:text>
		<xsl:choose>
			<xsl:when test=". castable as xs:integer"><xsl:value-of select="."/></xsl:when>
			<xsl:otherwise>
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$val	"/>
				<xsl:text>"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
