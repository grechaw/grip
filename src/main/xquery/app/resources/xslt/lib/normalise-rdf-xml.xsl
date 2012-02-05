<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:err="http://www.marklogic.com/rdf/error"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/rdf+xml" method="xml"/>
	
	
	<!-- Normalises RDF/XML into some form of canonical representation. -->
	
	<xsl:param name="BASE_URI" as="xs:string" select="base-uri(/*)"/>
	
	
	<!-- Document root. -->
	<xsl:template match="/" priority="2">
		<xsl:apply-templates select="*" mode="rdf"/>
	</xsl:template>
	
	
	<!-- The RDF root. -->
	<xsl:template match="/rdf:RDF" mode="rdf" priority="1">
		<xsl:copy>
			<xsl:copy-of select="@* except (@xml:base)"/>
			<xsl:apply-templates select="*" mode="rdf:node-elements"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Root element that's not rdf:RDF. -->
	<xsl:template match="/*" mode="rdf">
		<rdf:RDF>
			<xsl:apply-templates select="." mode="rdf:node-elements"/>
		</rdf:RDF>
	</xsl:template>
	
	
	<!-- Node Elements. -->
	<xsl:template match="rdf:Description" mode="rdf:node-elements" priority="1">
		<xsl:copy>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), rdf:generate-node-id-attr(..))[1]"/>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="rdf:property-attributes"/>
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
			<xsl:apply-templates select="*[element()][not(@rdf:parseType = 'Literal')]" mode="rdf:node-element-refs"/>
		</xsl:copy>
		<xsl:apply-templates select="*[element()]" mode="rdf:referred-node-element"/>
	</xsl:template>
	
	
	<!-- Node Elements with no child Node ELements. -->
	<xsl:template match="rdf:Description[not(*)]" mode="rdf:node-elements" priority="2">
		<xsl:copy>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), rdf:generate-node-id-attr(..))[1]"/>
			<xsl:copy-of select="@xml:*"/>
			<xsl:apply-templates select="@* except (@rdf:about, @rdf:ID, @rdf:ID, @xml:*)" mode="rdf:property-attributes"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Other elements in the RDF namespace that aren't rdf:Description. -->
	<xsl:template match="rdf:*" mode="rdf:node-elements">
		<xsl:param name="nodeIDAttr" as="attribute()?">
			<xsl:attribute name="nodeID" select="generate-id(..)"/>
		</xsl:param>
		
		<rdf:Description>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), $nodeIDAttr)[1]"/>
			<xsl:if test="not(../*[@rdf:parseType eq 'Resource'])">
				<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			</xsl:if>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="rdf:property-attributes"/>
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
			<xsl:apply-templates select="*[element()]" mode="rdf:node-element-refs"/>
		</rdf:Description>
		<xsl:apply-templates select="*[element()]" mode="rdf:referred-node-element"/>
	</xsl:template>
	
	
	<!-- Typed Element Nodes. -->
	<!-- <xsl:template match="*[prefix-from-QName(resolve-QName(name(), .)) ne 'rdf']" mode="rdf:node-elements"> -->
	<xsl:template match="*[namespace-uri-from-QName(resolve-QName(name(), .)) ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#']" mode="rdf:node-elements">
		<xsl:param name="nodeIDAttr" as="attribute()?">
			<xsl:attribute name="rdf:nodeID" select="generate-id(..)"/>
		</xsl:param>
		
		<rdf:Description>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), $nodeIDAttr)[1]"/>
			<xsl:if test="not(../*[@rdf:parseType eq 'Resource'])">
				<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			</xsl:if>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="rdf:property-attributes"/>
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
			<xsl:apply-templates select="*[element()]" mode="rdf:node-element-refs"/>
		</rdf:Description>
		<xsl:apply-templates select="*[element()]" mode="rdf:referred-node-element"/>
	</xsl:template>
	
	
	<!-- Expand property attributes into property elements. -->
	<xsl:template match="@rdf:type" mode="rdf:property-attributes">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:attribute name="rdf:resource" select="."/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Expand property attributes into property elements. -->
	<xsl:template match="@*" mode="rdf:property-attributes">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Resource References -->
	<xsl:template match="*[@rdf:resource]" mode="rdf:property-elements" priority="1">
		<xsl:copy>
			<xsl:copy-of select="rdf:resolve-uri-reference(@rdf:resource)"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- XML Literals. -->
	<xsl:template match="*[@rdf:parseType = 'Literal'][element()]" mode="rdf:property-elements" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="rdf:literal-attributes"/>
			<xsl:copy-of select="*"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Typed and Plain Literals -->
	<xsl:template match="*[not(element())]" mode="rdf:property-elements">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="rdf:literal-attributes"/>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Expand datatype references on literals. -->
	<xsl:template match="@rdf:datatype" mode="rdf:literal-attributes">
		<xsl:attribute name="{name()}">
			<xsl:choose>
				<xsl:when test="starts-with(., 'xs:')">
					<xsl:value-of select="concat('http://www.w3.org/2001/XMLSchema#', substring-after(., 'xs:'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	
	<!-- Replicate all other literal attributes (normally just @xml:lang) -->
	<xsl:template match="@*" mode="rdf:literal-attributes">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<!-- Don't automaically descend the tree in this mode. -->
	<xsl:template match="*[*]" mode="rdf:property-elements"/>
	
	
	<!-- Generate reference to a Typed Node Element. -->
	<xsl:template match="*[element()]" mode="rdf:node-element-refs">
		<xsl:copy>
			<xsl:attribute name="rdf:nodeID" select="generate-id()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Special case - what would have been a node-element reference where it 
		 not for the presence of the child rdf:Description. -->
	<xsl:template match="*[rdf:Description]" mode="rdf:node-element-refs" priority="1">
		<xsl:copy>
			<xsl:attribute name="rdf:resource" select="rdf:Description/@rdf:about"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*[@rdf:parseType = 'Resource']" mode="rdf:referred-node-element" priority="1">
		<xsl:apply-templates select="." mode="rdf:node-elements">
			<xsl:with-param name="nodeIDAttr" as="attribute()?">
				<xsl:attribute name="rdf:nodeID" select="generate-id()"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*" mode="rdf:referred-node-element">
		<xsl:apply-templates select="*[element()]" mode="rdf:node-elements"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- Suppress unwanted text nodes. -->
	<xsl:template match="text()" mode="#all"/>
	
	
	<!-- Resolves a relative URI against the xml:base or the Static Base URI 
		 if no @xml:base can be found. -->
	<xsl:function name="rdf:resolve-uri" as="xs:string">
		<xsl:param name="uriAttr" as="attribute()"/>
		<xsl:variable name="baseURI" as="xs:anyURI" select="xs:anyURI(($uriAttr/ancestor-or-self::*[@xml:base][1]/@xml:base, $BASE_URI)[1])"/>
		
		<xsl:choose>
			<!-- Deal with fragment identifiers. -->
			<xsl:when test="$uriAttr instance of attribute(rdf:ID)">
				<xsl:value-of select="resolve-uri(concat('#', string($uriAttr)), $baseURI)"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Ensure that http://example.com is resolved as http://example.com/ -->
				<xsl:choose>
					<xsl:when test="matches($baseURI, '/\w+/?$')">
						<xsl:value-of select="resolve-uri(string($uriAttr), $baseURI)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="resolve-uri(string($uriAttr), concat($baseURI, '/'))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- Process URI references (absolute or relative to an xml:base). -->
	<xsl:function name="rdf:resolve-uri-reference" as="attribute()?">
		<xsl:param name="refAttr" as="attribute()?"/>
		
		<xsl:apply-templates select="$refAttr" mode="rdf:ref-attr"/>
	</xsl:function>
	
	
	<!-- Copy the about attribute. -->
	<xsl:template match="@rdf:about" mode="rdf:ref-attr">
		<xsl:attribute name="rdf:about" select="rdf:resolve-uri(.)"/>
	</xsl:template>
	
	
	<!-- Resolve the relative URI in the ID attribute. -->
	<xsl:template match="@rdf:ID" mode="rdf:ref-attr">
		<xsl:attribute name="rdf:about" select="rdf:resolve-uri(.)"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="@rdf:resource" mode="rdf:ref-attr">
		<xsl:attribute name="rdf:resource" select="rdf:resolve-uri(.)"/>
	</xsl:template>
	
	
	<!-- Generates an rdf:nodeID attribute with ID value with respect to the passed context node. -->
	<xsl:function name="rdf:generate-node-id-attr" as="attribute(rdf:nodeID)">
		<xsl:param name="contextNode" as="node()"/>
		
		<xsl:attribute name="rdf:nodeID" select="generate-id($contextNode)"/>
	</xsl:function>
	
	
	
	
	<!-- === Errors or Unsupported. ======================================================= -->
	
	
	<!-- Throw an exception for invalid/unsupported parse types. -->
	<xsl:template match="*[@rdf:parseType and not(@rdf:parseType = ('Resource', 'Literal'))]" mode="#all" priority="10">
		<xsl:message>[XSLT] <xsl:value-of select="concat('Unsupported Parse Type: ''', @rdf:parseType, '''')"/></xsl:message>
	</xsl:template>
	
	
	<!-- Throw an error if rdf:Bag, rdf:Seq, rdf:Alt, rdf:Statement, rdf:Property or rdf:List are present. -->
	<xsl:template match="rdf:Bag | rdf:Seq | rdf:Alt | rdf:Statement | rdf:List" mode="#all" priority="10">
		<xsl:message>[XSLT] <xsl:value-of select="'Graphs using rdf:Bag, rdf:Seq, rdf:Alt, rdf:Statement, rdf:Property or rdf:List are not, currently, supported.'"/></xsl:message>
	</xsl:template>
	
</xsl:transform>