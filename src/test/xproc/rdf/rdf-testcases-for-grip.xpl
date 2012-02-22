<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
		xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:http="http://www.w3.org/Protocols/rfc2616"
		xmlns:nt="http://www.w3.org/ns/formats/N-Triples"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		exclude-inline-prefixes="#all"
		name="rdf-test-cases">
	
	<p:documentation>RDF Test Cases (Latest Approved) round-tripped through GRIP.</p:documentation>
	<p:input port="source">
		<p:document href="latest_Approved/Manifest.rdf"/>
	</p:input>
	<p:output port="result"/>
	<p:option name="TEST_URI" required="false" select="''"/>
	
	<p:import href="../../resources/xproc/lib-gsp.xpl"/>
	<p:import href="../../resources/xproc/library-1.0.xpl"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	
	
	
	<!-- Iterate over the tests in the manifest document. ================== -->
	
	<p:for-each>
		<!-- <p:iteration-source select="/rdf:RDF/node()[ends-with(local-name(), 'ParserTest')][test:status eq 'APPROVED']"/> -->
		<p:iteration-source select="/rdf:RDF/test:PositiveParserTest[test:status eq 'APPROVED']"/>
		
		
		
		
		<!-- Identify required tests and resolve URIs. ====================  -->
		
		<p:variable name="testURI" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		<p:variable name="testBaseURI" select="string-join((reverse(subsequence(reverse(tokenize($testURI, '/')), 3)), ''), '/')"/>
		<p:variable name="testName" select="substring-before(substring-after($testURI, $testBaseURI), '.rdf')"/>
		
		<p:string-replace match="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about" 
				replace="substring-after(., 'http://www.w3.org/2000/10/rdf-tests/rdfcore/')"/>
		<p:make-absolute-uris base-uri="./latest_Approved/" 
				match="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		
		<p:string-replace match="/test:*/test:outputDocument/test:NT-Document/@rdf:about" 
				replace="substring-after(., 'http://www.w3.org/2000/10/rdf-tests/rdfcore/')"/>
		<p:make-absolute-uris base-uri="./latest_Approved/" 
				match="/test:*/test:outputDocument/test:NT-Document/@rdf:about"/>
		
		
		
		
		<!-- === Get and prepare the expected result. ====================== -->
		
		<p:identity name="test-case"/>
		
		<p:load name="source">
			<p:with-option name="href" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		</p:load>
		
		<p:add-attribute match="/c:request" attribute-name="href">
			<p:input port="source">
				<p:inline exclude-inline-prefixes="#all"><c:request method="GET" override-content-type="text/plain"/></p:inline>
			</p:input>
			<p:with-option name="attribute-value" select="/test:*/test:outputDocument/test:NT-Document/@rdf:about">
				<p:pipe port="result" step="test-case"/>
			</p:with-option>
		</p:add-attribute>
		
		<p:http-request media-type="text/plain" encoding="ASCII"/>
		
		<p:rename match="/c:body" new-name="nt:RDF"/>
		
		<p:xslt>
			<p:documentation>Transform the test's expected result into TriX.</p:documentation>
			<p:input port="stylesheet">
				<p:document href="../../../main/xquery/app/resources/xslt/lib/ntriples-to-trix.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			<p:with-param name="GRAPH_URI" select="$testURI"/>
		</p:xslt>
		<p:xslt>
			<p:documentation>Convert to Canonical TriX.</p:documentation>
			<p:input port="stylesheet">
				<p:document href="../../../main/xquery/app/resources/xslt/lib/canonical-trix.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
		</p:xslt>
		<p:identity name="expected"/>
		
		
		
		
		<!-- === Get and process the test. ================================= -->
		
		<gsp:add-graph name="insert" uri="http://localhost:8005/graphs" 
				content-type="application/rdf+xml">
			<p:documentation>Load the source test graph into GRIP.</p:documentation>
			<p:with-option name="graph" select="$testURI"/>
		</gsp:add-graph>
		
		<cx:message>
			<p:with-option name="message" select="concat('[XProc] Insert:   ', $testURI, ' - ', /http:response/@status)"/>
		</cx:message>
		
		<p:choose>
			<p:when test="/http:response/@status eq '500'">
				<p:identity/>
			</p:when>
			<p:otherwise>
				<gsp:retrieve-graph name="retrieve" uri="http://localhost:8005/graphs" 
						media-type="application/xml">
					<p:documentation>Retrieve the test graph as TriX for comparison.</p:documentation>
					<p:with-option name="graph" select="$testURI"/>
				</gsp:retrieve-graph>
		
				<cx:message>
					<p:with-option name="message" select="concat('[XProc] Retrieve: ', $testURI, ' - ', /http:response/@status)"/>
				</cx:message>
				
				<p:filter select="/http:response/http:body/trix:trix"/>
				
				<p:xslt>
					<p:documentation>Convert to Canonical TriX.</p:documentation>
					<p:input port="stylesheet">
						<p:document href="../../../main/xquery/app/resources/xslt/lib/canonical-trix.xsl"/>
					</p:input>
					<p:input port="parameters">
						<p:empty/>
					</p:input>
				</p:xslt>
			</p:otherwise>
		</p:choose>
		
		<p:identity name="actual"/>
		
		
		
		
		<!-- === Compare expected with actual results. ===================== -->
		
		<p:wrap-sequence wrapper="c:result">
			<p:input port="source">
				<p:pipe port="result" step="expected"/>
			</p:input>
		</p:wrap-sequence>
		<p:insert name="expected-and-actual" match="/c:result" position="last-child">
			<p:input port="insertion">
				<p:pipe port="result" step="actual"/>
			</p:input>
		</p:insert>
		
		<p:try>
			<p:group>
				<p:compare fail-if-not-equal="true">
					<p:input port="source" select="/c:result/trix:trix[1]"/>
					<p:input port="alternate" select="/c:result/trix:trix[2]"/>
				</p:compare>
				
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:test success="true"/></p:inline>
					</p:input>
				</p:identity>
				<p:add-attribute match="/c:*" attribute-name="uri">
					<p:with-option name="attribute-value" select="$testName"/>
				</p:add-attribute>
			</p:group>
			<p:catch>
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:test success="false">Unknown</c:test></p:inline>
					</p:input>
				</p:identity>
				<p:add-attribute match="/c:*" attribute-name="uri">
					<p:with-option name="attribute-value" select="$testName"/>
				</p:add-attribute>
			</p:catch>
		</p:try>
		
		<p:identity name="result"/>
		
		
		
		
		<!-- === Store the test result with the expected result. =========== -->
		
		<p:choose>
			<p:when test="not(xs:boolean(/c:test/@success))">
				<p:store encoding="UTF-8" indent="true" media-type="application/xml" method="xml">
					<p:input port="source">
						<p:pipe port="result" step="expected-and-actual"/>
					</p:input>
					<p:with-option name="href" select="concat('./grip/', $testName, '.xml')"/>
				</p:store>
			</p:when>
			<p:otherwise>
				<p:sink/>
			</p:otherwise>
		</p:choose>
		
		
		<p:identity>
			<p:input port="source">
				<p:pipe port="result" step="result"/>
			</p:input>
		</p:identity>
	</p:for-each>
	
	
	
	
	<!-- === Generate a report document. =================================== -->
	
	<p:wrap-sequence wrapper="c:results"/>
	<p:add-attribute match="/c:results" attribute-name="successes">
		<p:with-option name="attribute-value" select="count(/c:results/c:test[xs:boolean(@success) = true()])"/>
	</p:add-attribute>
	<p:add-attribute match="/c:results" attribute-name="success-rate">
		<p:with-option name="attribute-value" select="concat(string((count(/c:results/c:test[xs:boolean(@success) = true()]) div count(/c:results/c:test)) * 100), '%')"/>
	</p:add-attribute>
	
	<p:identity name="report"/>
	
	
	
	
	<!-- Re-save the previous report for comparing with the new one. ======= -->
	
	<p:try>
		<p:group>
			<p:load href="./grip/results.xml"/>
	
			<p:store encoding="UTF-8" indent="true" media-type="application/xml" method="xml"
					href="./grip/previous-results.xml"/>
		</p:group>
		<p:catch>
			<p:sink/>
		</p:catch>
	</p:try>
	
	
	
	
	
	<!-- === Output the new report. ======================================== -->
	
	<p:identity>
		<p:input port="source">
			<p:pipe port="result" step="report"/>
		</p:input>
	</p:identity>
</p:declare-step>