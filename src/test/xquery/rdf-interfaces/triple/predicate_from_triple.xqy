xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/Triple.xqy";

let $triple as element() := 
<triple>
	<uri>http://example.org/book/book3</uri>
	<uri>http://purl.org/dc/elements/1.1/title</uri>
	<plainLiteral>Harry Potter and the Prisoner Of Azkaban</plainLiteral>
</triple>

return
	deep-equal(triple:predicate($triple), <uri>http://purl.org/dc/elements/1.1/title</uri>)