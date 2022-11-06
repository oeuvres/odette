<?xml version="1.0" encoding="UTF-8"?>
<!--
Normalisation finale après Odette.
-->
<xsl:transform exclude-result-prefixes="tei" version="1.1" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:template match="node()|@*" name="copy">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:emph">
    <hi rend="italic">
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <!-- Couper les espaces vides -->
  <xsl:template match="tei:space[@unit='line'][@quantity='1']"/>
</xsl:transform>
