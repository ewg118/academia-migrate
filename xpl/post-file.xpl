<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- url params -->
				<xsl:param name="name" select="/request/parameters/parameter[name='name']/value"/>
				<xsl:param name="access_token" select="/request/parameters/parameter[name='access_token']/value"/>
				<xsl:param name="id" select="/request/parameters/parameter[name='id']/value"/>
				<xsl:param name="file" select="/request/parameters/parameter[name='file']/value"/>
				<xsl:param name="env" select="/request/parameters/parameter[name='env']/value"/>
				
				<xsl:variable name="post-file.php_url">http://localhost/cgi-bin/post-file.php</xsl:variable>
				
				<xsl:variable name="service" select="concat($post-file.php_url, '?name=', encode-for-uri($name), '&amp;access_token=', $access_token, '&amp;id=', $id, '&amp;file=', encode-for-uri($file)), '&amp;env=', $env">
					
				</xsl:variable>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<mode>text</mode>
						<content-type>application/json</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	
</p:config>
