<?xml version="1.0" encoding="UTF-8"?>
<!-- export a basic JSON object to load into the XForms engine to test JSON parsing -->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#data"/>		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output method="text" encoding="UTF-8"/>
				
				<xsl:template match="/">
					<xsl:text>{"test":true}</xsl:text>
				</xsl:template>				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="model"/>	
	</p:processor>
	
	

	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"></p:input>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
	
</p:config>
