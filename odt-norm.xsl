<?xml version="1.0" encoding="UTF-8"?>
<!--
Clean Open Document Text xml of some oddities
all work should be kept in odt namespaces

Apache licence http://www.apache.org/licenses/LICENSE-2.0

© 2020 Frederic.Glorieux@fictif.org et Opteos
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org 
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes

-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"


  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
  xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
  xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
  xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
  xmlns:ooo="http://openoffice.org/2004/office"
  xmlns:ooow="http://openoffice.org/2004/writer"
  xmlns:oooc="http://openoffice.org/2004/calc"
  xmlns:dom="http://www.w3.org/2001/xml-events"
  xmlns:xforms="http://www.w3.org/2002/xforms"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
  xmlns:rpt="http://openoffice.org/2005/report"
  xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2"
  xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#"
  xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"

  xmlns:exslt="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:php="http://php.net/xsl"
  extension-element-prefixes="date exslt php"

  exclude-result-prefixes="tei
  office style text table draw fo xlink dc meta number svg chart dr3d math form script ooo ooow oooc dom xforms xsd xsi config rpt of rdfa field"
>
  <xsl:output encoding="UTF-8" indent="no" method="xml"/>
  <!-- Shall we infer title from content ? -->
  <xsl:variable name="h" select="boolean(//text:h)"/>
  <!-- has been useful for indent with saxon
  <xsl:strip-space elements="*"/>
  -->
  <!-- key on styles -->
  <xsl:key name="style" match="style:style|text:list-style" use="@style:name"/>
  <!-- Delete empty headings (could break sectionning) -->
  <xsl:template match="text:h">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Restore some lost heading -->
  <xsl:template match="text:p">
    <xsl:variable name="styleName">
      <xsl:call-template name="styleName"/>
    </xsl:variable>
    <!-- style name, may be set by caller -->
    <xsl:variable name="style-name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>
    <!-- handle on the style -->
    <xsl:variable name="style" select="key('style', $style-name)"/>
    <!-- Style redéfiniassant un niveau de titre  -->
    <xsl:variable name="outline">
      <xsl:choose>
        <xsl:when test="$style/@style:default-outline-level">
          <xsl:value-of select="$style/@style:default-outline-level"/>
        </xsl:when>
        <!-- auto style, get parent -->
        <xsl:when test="$style/@style:parent-style-name">
          <xsl:value-of select="key('style', $style/@style:parent-style-name)/@style:default-outline-level"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- Hidden headings -->
      <xsl:when test="$outline != ''">
        <text:h>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="text:outline-level">
            <xsl:value-of select="$outline"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </text:h>
      </xsl:when>
      <!-- empty title, strip -->
      <xsl:when test="starts-with($styleName, 'Heading_20_') and normalize-space(.)=''"/>
      <!-- A specific thing form "Classiques des sciences sociales" http://classiques.uqac.ca/ -->
      <xsl:when test="normalize-space(.) = '@'"/>
      <xsl:when test="starts-with(normalize-space(.), 'Retour à la table des matières')"/> 
      <xsl:when test="starts-with(normalize-space(.), 'Retour à la table des planches')"/> 
      <xsl:when test="starts-with(normalize-space(.), 'Retour au Sommaire')"/> 
      <!-- empty, do not add it like a title -->
      <xsl:when test=".=''">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <!-- Hidden headings -->
      <xsl:when test="starts-with($styleName, 'Heading_20_')">
        <text:h>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="text:outline-level">
            <xsl:value-of select="substring-after($styleName, 'Heading_20_')"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </text:h>
      </xsl:when>
      <!-- Already titles, shall we infer ? -->
      <xsl:when test="$h">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="contains($styleName, 'itre_20_1')">
        <text:h text:outline-level="1">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </text:h>
      </xsl:when>
      <xsl:when test="contains($styleName, 'itre_20_2')">
        <text:h text:outline-level="2">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </text:h>
      </xsl:when>
      <xsl:when test="contains($styleName, 'itre_20_3')">
        <text:h text:outline-level="3">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </text:h>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Find a semantic class name  -->
  <xsl:template name="styleName">
    <!-- style name, may be set by caller -->
    <xsl:param name="style-name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>
    <!-- handle on the style -->
    <xsl:variable name="style" select="key('style', $style-name)"/>
    <!-- autostyle ? -->
    <xsl:variable name="l" select="substring($style-name, 1, 1)"/>
    <xsl:variable name="styleAuto" select="boolean( ( $l = 'T' or $l = 'P') and translate(substring($style-name, 2), '1234567890', '') = '')"/>
    <!-- obtenir le nom d'un style sémantique, malgré les dérives automatiques  -->
    <xsl:variable name="styleName">
      <xsl:choose>
        <!-- not auto style, take it -->
        <xsl:when test="not($styleAuto)">
          <xsl:value-of select="$style-name"/>
        </xsl:when>
        <!-- auto style, get parent -->
        <xsl:when test="$style/@style:parent-style-name">
          <xsl:value-of select="$style/@style:parent-style-name"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$styleName"/>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
