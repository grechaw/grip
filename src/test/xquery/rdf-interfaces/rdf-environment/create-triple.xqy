xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/rdf-interfaces/RDFEnvironment.xqy";

let $rdfEnvironment as element(rdf-environment) := 
<rdf-environment>
	<prefix-map/>
	<term-map/>
</rdf-environment>
return
	rdfenv:create-triple($rdfEnvironment, 
		<uri>http://example.org/book/book1</uri>,
		<uri>http://purl.org/dc/elements/1.1/title</uri>,
		<plainLiteral xml:lang="en-GB">Harry Potter and the Philosopher's Stone</plainLiteral>
	) instance of element(triple)

