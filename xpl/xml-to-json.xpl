<?xml version="1.0" encoding="UTF-8"?>
<!-- execute an XSLT transformation from the PHP scrape XML model into the deposition model required by the Zenodo API -->

<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<!-- create deposition -->
	<p:processor name="oxf:unsafe-xslt">			
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../xslt/xml-to-json.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>	
</p:config>
