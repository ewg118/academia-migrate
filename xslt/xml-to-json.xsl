<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:strip-space elements="*"/>
	<xsl:output indent="yes"></xsl:output>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="descendant::records">
				<json type="array">
					<xsl:apply-templates select="descendant::record"/>
				</json>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="/record"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="record">
		
		<!-- set element name -->
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="parent::records">_</xsl:when>
				<xsl:otherwise>json</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:element name="{$element}">
			<xsl:attribute name="type">object</xsl:attribute>
			<metadata type="object">
				<xsl:apply-templates/>
			</metadata>
		</xsl:element>
	</xsl:template>

	<xsl:template match="keywords[keyword]">
		<keywords type="array">
			<xsl:for-each select="keyword[string-length(.) &gt; 0]">
				<_>
					<xsl:value-of select="."/>
				</_>
			</xsl:for-each>
		</keywords>
	</xsl:template>

	<xsl:template match="creators">
		<creators type="array">
			<xsl:for-each select="creator">
				<_ type="object">
					<name>
						<xsl:value-of select="."/>
					</name>
					<xsl:if test="@affiliation">
						<affiliation>
							<xsl:value-of select="@affiliation"/>
						</affiliation>
					</xsl:if>
				</_>
			</xsl:for-each>
		</creators>
	</xsl:template>

	<!-- recast url as identifier -->
	<!--<xsl:template match="url">
		<xsl:text>"related_identifiers":[{"relation":"isAlternateIdentifier","identifier":"</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"}],</xsl:text>
	</xsl:template>-->

	<!-- ignore the following -->
	<xsl:template match="id|publication_day|publication_month|publication_year|url|file|publication_date_valid"/>

	<!-- call templates for simple elements, ignoring some from initial scrape model -->
	<xsl:template
		match="*[not(self::id|self::url|self::publication_day|self::publication_month|self::publication_year|self::file|self::publication_date_valid)][not(child::*)][string-length(normalize-space(.)) &gt; 0]">
		<xsl:variable name="val" select="replace(., '&#x022;', '\\&#x022;')"/>

		<xsl:element name="{name()}">
			<xsl:choose>
				<xsl:when test=". castable as xs:integer">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$val"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
