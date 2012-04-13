xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace nt = "http://www.w3.org/ns/formats/N-Triples";

import module namespace ntdp = "http://www.w3.org/TR/rdf-interfaces/NTriplesDataParser"
	at "/lib/rdf-interfaces/NTriplesDataParser.xqy";


let $doc as element(nt:RDF) := 
<nt:RDF xmlns:nt="http://www.w3.org/ns/formats/N-Triples"><![CDATA[<http://example.org/resource17> <http://example.org/property> "\u20AC" .]]></nt:RDF>
return
	ntdp:parse(string($doc), (), (), (), ())