xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/PrefixMap.xqy";

let $prefixMap as item() := map:map()
let $_put := map:put($prefixMap, 'dc', 'http://purl.org/dc/elements/1.1/')
return
	prefixmap:shrink($prefixMap, 'http://purl.org/dc/elements/1.1/title') eq 'dc:title'

