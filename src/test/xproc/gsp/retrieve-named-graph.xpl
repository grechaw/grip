<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:http="http://www.w3.org/Protocols/rfc2616"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/ns/xproc/test"
		xml:base="../../../"
		exclude-inline-prefixes="#all"
	 	version="1.0">
	
	<p:output port="result"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	<p:import href="test/resources/xproc/lib-gsp.xpl"/>
	<p:import href="test/resources/xproc/test.xpl"/>
	
	
	<gsp:retrieve-graph uri="http://localhost:8005/graphs" graph="http://www.books.com/harry-potter"/>
	
	<test:validate-with-schematron assert-valid="false">
		<p:input port="schema">
			<p:document href="test/resources/schemas/successful-response.sch"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</test:validate-with-schematron>
</p:declare-step>