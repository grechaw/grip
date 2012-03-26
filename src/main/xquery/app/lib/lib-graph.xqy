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
 : Function library that implements the W3C's RDF Interface: Graph.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"; 

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/lib-triple.xqy";

import module namespace sem = "http://marklogic.com/semantic"
	at "/lib/semantic.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";




(:~
 : An array of actions to run when a Triple is added to the graph, each new 
 : triple is passed to the run method of each TripleAction in the array.
 : @param $contextGraph 
 : @return 
 :)
declare function graph:actions($contextGraph as element(trix:graph)) 
	as item()*
{
	()
}; 


(:~
 : Adds the specified triple to the graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function graph:add($contextGraph as element(trix:graph), $triple as element(trix:triple)) 
	as element(trix:graph)
{
	let $graphURI as xs:string := string($contextGraph/trix:uri)
	let $subject as xs:string := triple:subject($triple)
	let $predicate as xs:string := triple:predicate($triple)
	let $object as item()* := triple:object($triple)
	let $insert := 
		xdmp:document-insert(
			sem:uri-for-tuple($subject, $predicate, graph:object-to-string($object), $graphURI),
			element t {
				( element s {
					( typeswitch ($triple/*[1])
						case $sub as element(trix:id) 
							return $subject
						default 
							return $subject ) },
				element p {$predicate},
				element o {
					(: Add the language annotation if present. :)
					( $triple/*[3]/@xml:lang,
					(: 
					 : When the subject is a URI reference mark it as such with 
					 : xs:anyURI, otherwise copy the datatype, if any.
					 :)
					( typeswitch ($triple/*[3]) 
						case element(trix:uri) 
							return ( attribute datatype {'http://www.w3.org/2001/XMLSchema#anyURI'}, $object )
						case element(trix:id) 
							return $object
						default 
							return ( $triple/*[3]/@datatype, $object ) ) )},
				element c {$graphURI} )
	    	},
	    	(),
	    	($graphURI)
	    )
	return
		(: Need to add any new naspaces that don't allready exist in the graph document. :)
		$contextGraph
};


(:~
 : Takes a possible sequence of nodes (element and text()) and serialises them
 : to a string.
 : @param $items items to be serialised as a string.
 : @return xs:string
 :)
declare private function graph:object-to-string($items as item()*) 
	as xs:string 
{
	xdmp:quote(<item>{$items}</item>)
}; 


(:~
 : Imports the graph in to this graph. 
 : @param $contextGraph 
 : @param $graph 
 : @return the graph instance it was called on.
 :)
declare function graph:add-all($contextGraph as element(trix:graph), $graph as element(trix:graph)) 
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : Adds a new TripleAction to the sequence of actions, if the run argument is 
 : specified as true() then each Triple in the Graph must be passed to the 
 : TripleAction before this method returns.
 : @param $contextGraph 
 : @param $action 
 : @param $run  
 : @return the graph instance it was called on.
 :)
declare function graph:add-action($contextGraph as element(trix:graph), $action as item(), $run as xs:boolean) 
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : Adds a new TripleAction to the sequence of actions, if the run argument is 
 : specified as true() then each Triple in the Graph must be passed to the 
 : TripleAction before this method returns.
 : @param $contextGraph 
 : @param $action 
 : @return the graph instance it was called on.
 :)
declare function graph:add-action($contextGraph as element(trix:graph), $action as item()) 
	as element(trix:graph)
{
	graph:add-action($contextGraph, $action, false())
};


(:~
 : Universal quantification method, tests whether every Triple in the Graph 
 : passes the test implemented by the provided TripleFilter. 
 : @param $contextGraph 
 : @param $callback the TripleFilter to test each Triple in the Graph against. 
 : @return false() when the first Triple is found that does not pass the test.
 :)
declare function graph:every($contextGraph as element(trix:graph), $callback as item()) 
	as xs:boolean
{
	(: This'll test all triples before returning.
	not(false() eq (
		for $triple in graph:to-array($contextGraph)
		return
			xdmp:apply($callback, ($triple))
	)):)
	
	(: Whereas this'll return on the first test that returns false(). :)
	graph:assert(graph:to-array($contextGraph), $callback, false())
};


(:~
 : Creates a new Graph with all the Triples which pass the test implemented by 
 : the provided TripleFilter. 
 : @param $contextGraph 
 : @param $filter the TripleFilter to test each Triple in the Graph against. 
 : @return false() when the first Triple is found that does not pass the test.
 :)
declare function graph:filter($contextGraph as element(trix:graph), $filter as item()) 
	as element()
{
	let $filteredTiples as element(trix:triple)* := 
		for $triple in graph:to-array($contextGraph)
		where xdmp:apply($filter, ($triple))
		return
			$triple
	return
		element {name($contextGraph)} {
			$contextGraph/namespace::*,
			$contextGraph/@*,
			<uri xmlns="http://www.w3.org/2004/03/trix/trix-1/"/>,
			$filteredTiples
		}
};


(:~
 : Executes the provided TripleCallback once on each Triple in the Graph. 
 : @param $contextGraph 
 : @param $callback the TripleCallback to execute for each Triple. 
 : @return an empty sequence
 :)
declare function graph:for-each($contextGraph as element(trix:graph), $callback as item()) 
	as empty-sequence()
{
	for $triple in graph:to-array($contextGraph)
	return
		xdmp:apply($callback, ($triple))
};


(:~
 : A non-negative integer that specifies the number of Triples in the set.
 : @param $contextGraph 
 : @return unsigned long
 :)
declare function graph:length($contextGraph as element(trix:graph)) 
	as xs:unsignedLong 
{
	xdmp:estimate(collection(string($contextGraph/trix:uri)))
}; 


(:~
 : This method returns a new Graph which is comprised of all those triples in 
 : the current instance which match the given arguments, that is, for each 
 : triple in this graph, it is included in the output graph, if:
 : * calling triple.subject.equals with the specified subject as an argument 
 :   returns true, or the subject argument is null, AND
 : * calling triple.predicate.equals with the specified predicate as an 
 :   argument returns true, or the predicate argument is null, AND
 : * calling triple.object.equals with the specified object as an argument 
 :   returns true, or the object argument is null
 : This method implements AND functionality, so only triples matching all of 
 : the given non-null arguments will be included in the result.
 : Note, this method always returns a new Graph, even if that Graph contains no 
 : Triples.
 : Note, Graphs represent Sets of Triples, the order is arbitrary, so this 
 : method may result in differing results when called repeatedly with a limit.
 : @param $contextGraph 
 : @param $subject The subject value to match against, may be null.
 : @param $predicate The predicate value to match against, may be null.
 : @param $object The object value to match against, may be null.
 : @param $limit An optional limit to the amount of triples returned, if 0 is 
 :               passed or the argument is set to null then all matching triples 
 :               will be contained in the resulting graph.
 : @return a new Graph.
 :)
declare function graph:match($contextGraph as element(trix:graph), 
		$subject as item()?, $predicate as item()?, $object as item()?, 
				$limit as xs:unsignedLong) 
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : This method returns a new Graph which is comprised of all those triples in 
 : the current instance which match the given arguments.
 : @param $contextGraph 
 : @param $subject The subject value to match against, may be null.
 : @param $predicate The predicate value to match against, may be null.
 : @param $object The object value to match against, may be null.
 : @return a new Graph.
 :)
declare function graph:match($contextGraph as element(trix:graph), 
		$subject as item()?, $predicate as item()?, $object as item()?) 
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : Returns a new Graph which is a concatenation of this graph and the graph given as an argument.
 : @param $contextGraph 
 : @param $graph 
 : @return the graph instance it was called on.
 :)
declare function graph:merge($contextGraph as element(trix:graph), $graph as element(trix:graph)) 
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : Removes the specified Triple from the graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function graph:remove($contextGraph as element(trix:graph), $triple as element(trix:triple)) 
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : This method removes those triples in the current instance which match the 
 : given arguments, that is, for each triple in this graph, it is removed, if:
 : * calling triple.subject.equals with the specified subject as an argument 
 :   returns true, or the subject argument is null, AND
 : * calling triple.predicate.equals with the specified predicate as an 
 :   argument returns true, or the predicate argument is null, AND
 : * calling triple.object.equals with the specified object as an argument 
 :   returns true, or the object argument is null
 : @param $contextGraph 
 : @param $subject The subject value to match against, may be null.
 : @param $predicate The predicate value to match against, may be null.
 : @param $object The object value to match against, may be null.
 : @return a new Graph.
 :)
declare function graph:remove-matches($contextGraph as element(trix:graph), 
		$subject as item()?, $predicate as item()?, $object as item()?)
	as element(trix:graph)
{
	$contextGraph
};


(:~
 : Existential quantification method, tests whether some Triple in the Graph 
 : passes the test implemented by the provided TripleFilter.
 : @param $contextGraph 
 : @param $callback the TripleFilter to test each Triple in the Graph against. 
 : @return true() when the first Triple is found that passes the test.
 :)
declare function graph:some($contextGraph as element(trix:graph), $callback as item()) 
	as xs:boolean 
{
	graph:assert(graph:to-array($contextGraph), $callback, true())
};


(:~
 : Returns the set of Triples within the Graph as a host language native 
 : sequence, for example an XPath 2.0 sequence.
 : @param $contextGraph 
 : @return sequence of trix:triple elements.
 :)
declare function graph:to-array($contextGraph as element(trix:graph)) 
	as element(trix:triple)*
{
	let $graph as element() := 
		<graph xmlns="">{
			$contextGraph/namespace::*,
			<uri>{string($contextGraph/trix:uri)}</uri>,
			collection(string($contextGraph/trix:uri))/*
		}</graph>
	return
		xdmp:xslt-invoke('/resources/xslt/lib/ml-tuples-to-trix.xsl', $graph, ())//trix:triple
};


(:~
 : Recursively apply the callback function to the context Triple.
 : @param $triples a sequence of triples to be tested.
 : @param $callback the function to test against the triples.
 : @param $condition the boolean value that the callback will match in order to 
 : stop processing the sequence.
 : @return if the callback function returns false(), else returns true()
 :)
declare private function graph:assert($triples as element(trix:triple)*, $callback as item(), $condition as xs:boolean)
	as xs:boolean
{
	let $head as element()? := subsequence($triples, 1, 1)
	let $tail as element()* := subsequence($triples, 2)
	return
		if (exists($head)) then 
			if (xdmp:apply($callback, ($head)) ne $condition) then 
				graph:assert($tail, $callback, $condition)
			else
				$condition
		else 
			not($condition)
};
