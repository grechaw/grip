<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:err="http://www.marklogic.com/rig/error"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:import href="normalise-rdf-xml.xsl"/>
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<xsl:param name="GRAPH_URI" as="xs:string" select="'#default'"/>
	
	
	<!-- Transforms RDF/XML into TriX. -->
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<!-- Root. -->
	<xsl:template match="rdf:RDF">
		<!-- Normalise the RDF/XML to make it easier to transform into TriX. -->
		<xsl:variable name="normalisedRDF" as="element(rdf:RDF)">
			<xsl:apply-imports/>
		</xsl:variable>
		
		<trix>
			<xsl:for-each select="namespace::*">
				<xsl:copy-of select="."/>
			</xsl:for-each>
			<xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema#</xsl:namespace>
			<graph>
				<uri><xsl:value-of select="$GRAPH_URI"/></uri>
				<xsl:apply-templates select="$normalisedRDF/*" mode="descriptions"/>
			</graph>
		</trix>
	</xsl:template>
	
	
	<!-- Transform Typed Node Element into a full rdf:Descriptions using the 
		 rdf:type property then carry on transforming.
	<xsl:template match="*[name() ne 'rdf:Description']" mode="descriptions">
		<xsl:variable name="rdfDescription">
			<rdf:Description>
				<xsl:copy-of select="@*"/>
				 <rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
				<xsl:copy-of select="*"/>
			</rdf:Description>
		</xsl:variable>
		
		<xsl:apply-templates select="$rdfDescription" mode="descriptions"/>
	</xsl:template> -->
	
	
	<!-- Subjects without an explicit node reference (blank nodes). -->
	<xsl:template match="rdf:Description[not(@*)]" mode="descriptions">
		<xsl:apply-templates select="*" mode="id">
			<xsl:with-param name="generatedId" as="xs:string" select="generate-id()" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!-- Subjects with a URI (absolute or relative). -->
	<xsl:template match="rdf:Description[@rdf:about | @rdf:ID]" mode="descriptions">
		<xsl:apply-templates select="*" mode="resource"/>
	</xsl:template>
	
	
	<!-- Subjects with an ID. -->
	<xsl:template match="rdf:Description[@rdf:nodeID]" mode="descriptions">
		<xsl:apply-templates select="*" mode="id"/>
	</xsl:template>
	
	
	
	
	<!-- Triple. -->
	<xsl:template match="*" mode="resource id" priority="2">
		<triple>
			<xsl:next-match/>
		</triple>
	</xsl:template>
	
	
	<!-- Subjects. -->
	<xsl:template match="*" mode="resource" priority="1">
		<uri><xsl:value-of select="../@rdf:about"/></uri>
		<xsl:call-template name="predicate"/>
		<xsl:next-match/>
	</xsl:template>
	
	
	<!-- Blank Nodes -->
	<xsl:template match="*" mode="id" priority="1">
		<xsl:param name="generatedId" as="xs:string?" tunnel="yes"/>
		
		<id><xsl:value-of select="(../@rdf:nodeID, $generatedId)[1]"/></id>
		<xsl:call-template name="predicate"/>
		<xsl:next-match/>
	</xsl:template>
	
	
	<!-- Predicates. -->
	<xsl:template name="predicate">
		<uri><xsl:value-of select="concat(namespace-uri(), local-name())"/></uri>
	</xsl:template>
	
	
	<!-- ID Objects. -->
	<xsl:template match="*[@rdf:nodeID]" mode="resource id">
		<id><xsl:value-of select="@rdf:nodeID"/></id>
	</xsl:template>
	
	
	<!-- Resource Objects. -->
	<xsl:template match="*[@rdf:resource]" mode="resource id">
		<uri><xsl:value-of select="@rdf:resource"/></uri>
	</xsl:template>
	
	
	<!-- Typed Literal Objects. -->
	<xsl:template match="*[@rdf:datatype]" mode="resource id">
		<typedLiteral datatype="{@rdf:datatype}">
			<xsl:copy-of select="@xml:lang"/>
			<xsl:value-of select="string(.)"/>
		</typedLiteral>
	</xsl:template>
	
	
	<!-- Plain Literals Objects. -->
	<xsl:template match="*" mode="resource id">
		<plainLiteral>
			<xsl:copy-of select="@xml:lang"/>
			<xsl:value-of select="string(.)"/>
		</plainLiteral>
	</xsl:template>
	
</xsl:transform>