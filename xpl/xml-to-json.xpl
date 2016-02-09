<?xml version="1.0" encoding="UTF-8"?>
<!-- execute an XSLT transformation from the PHP scrape XML model into the deposition model required by the Zenodo API -->

<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>


	<p:processor name="oxf:unsafe-xslt">
		<p:input name="params" href="#params"/>				
		<p:input name="data" href="aggregate('content', #data, #config)"/>		
		<p:input name="config" href="../xslt/xml-to-json.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>	
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
