xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/RDFNode.xqy";

let $triple as element() := 
<triple>
	<id>A1</id>
	<uri>http://www.w3.org/2001/vcard-rdf/3.0#Family</uri>
	<plainLiteral>Rowling</plainLiteral>
</triple>
let $expectedResult as xs:string := '_:A1'

return
	rdfnode:value-of(<id>A1</id>) instance of xs:string