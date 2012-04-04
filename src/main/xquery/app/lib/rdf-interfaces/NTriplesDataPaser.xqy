xquery version "1.0-ml" encoding "utf-8";

(:
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:~
 : Function library that implements common functions for the W3C's RDF 
 : Interface.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace ntdp = "http://www.w3.org/TR/rdf-interfaces/NTriplesParser";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";




(:~
 : A function, which when called will serialize the given Graph and return the 
 : resulting serialization.
 : @param 
 : @return New Graph.
 :)
declare function ntdp:parse() 
	as element(graph)
{
	(:xdmp:xslt-invoke('xslt/graph-to-rdf-xml.xsl', document {$contextGraph})/*:)
};

