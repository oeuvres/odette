<?xml version="1.0" encoding="UTF-8"?>
<!--
Normalisation finale d’une lettre de Delacroix. Par défaut, tout est recopié, les modifications se font à la volée.
-->
<xsl:transform exclude-result-prefixes="tei" version="1.1" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" method="xml"/>
  <!-- Par défaut, tout copier -->
  <xsl:template match="node()|@*" name="copy">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <!-- Éléments optionnels du header -->
  <xsl:template match="
      tei:teiHeader//tei:seriesStmt/tei:title[@type='sub'][starts-with(., '{') and contains(., '}')]
    | tei:teiHeader//tei:editionStmt/tei:respStmt[tei:name = 'corrections']
    | tei:teiHeader//tei:physDesc/tei:accMat[starts-with(., '{') and contains(., '}')]
    | tei:teiHeader//tei:history[tei:provenance[starts-with(., '{') and contains(., '}')]]
    | tei:teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository[. = '{cotefonds}']
    | tei:teiHeader//tei:listBibl[tei:bibl[starts-with(., '{') and contains(., '}')]]
    | //tei:correspAction[@type='sent']/tei:placeName[starts-with(., '{') and contains(., '}')]
    | //tei:correspAction[@type='sent']/tei:date[starts-with(@when, '{') and contains(@when, '}')]
    | //tei:correspAction[@type='received'][tei:persName[starts-with(@key, '{') and contains(@key, '}')]]
    | //tei:correspContext[tei:ref[@type='replyTo'][starts-with(@target, '{') and contains(@target, '}')]]
    "/>
  <xsl:template match="tei:hi[@rend='u']">
    <emph>
      <xsl:apply-templates/>
    </emph>
  </xsl:template>
  <xsl:template match="tei:body/tei:quote[@rend='framed']">
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::tei:quote[@rend='framed'])">
        <opener>
          <xsl:apply-templates/>
        </opener>
      </xsl:when>
      <xsl:when test="not(following-sibling::tei:quote[@rend='framed'])">
        <closer>
          <xsl:apply-templates/>
        </closer>
      </xsl:when>
      <xsl:otherwise>
        <figure>
          <xsl:apply-templates/>
        </figure>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:measure[@type='page']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="count(/tei:TEI/tei:text/tei:body//tei:pb)"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
