xquery version "1.0-ml" encoding "utf-8";

import module namespace sem = "http://marklogic.com/semantic" at 
		"lib/semantic.xqy"; 

declare namespace dc 	= "http://purl.org/dc/elements/1.1/";
declare namespace rdf 	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare default function namespace "http://www.w3.org/2005/xpath-functions";


let $result as item()? := xdmp:xslt-invoke('resources/xslt/lib/normalise-rdf-xml.xsl', <rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<rdf:Description rdf:about="http://example.org/book/book3">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">1999-07-08</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
	<rdf:Description rdf:about="http://example.org/book/book7">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2001-07-21</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
	<rdf:Description rdf:about="http://example.org/book/book2">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">1998-07-02</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
	<rdf:Description rdf:about="http://example.org/book/book5">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2003-06-21</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
	<rdf:Description rdf:about="http://example.org/book/book4">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2000-07-08</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
	<rdf:Description rdf:about="http://example.org/book/book6">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2005-07-16</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
	<rdf:Description rdf:about="http://example.org/book/book1">
		<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</dc:date>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
	</rdf:Description>
</rdf:RDF>)

return
	$result

	