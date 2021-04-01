<?xml version="1.0" encoding="UTF-8"?>
<!--
Normalisation finale d’une lettre de Delacroix. Par défaut, tout est recopié, les modifications se font à la volée.
-->
<xsl:transform exclude-result-prefixes="tei" version="1.1" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" method="xml"/>
  <!-- Par défaut, tout copier -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='u']">
    <emph>
      <xsl:apply-templates/>
    </emph>
  </xsl:template>
</xsl:transform>
