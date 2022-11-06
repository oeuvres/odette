<?xml version="1.0" encoding="UTF-8"?>
<!--
Final normalization
-->
<xsl:transform exclude-result-prefixes="tei" version="1.1" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <!-- set by caller -->
  <xsl:param name="filename"/>
  <!-- where to find the greek version -->
  <xsl:param name="grc_dir">https://ctaaffe.github.io/First1KGreek/data/</xsl:param>
  <!-- Build the tlg path -->
  <xsl:param name="grc_file">
    <xsl:value-of select="$grc_dir"/>
    <xsl:value-of select="substring-before($filename, '.')"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring-before(substring-after($filename, '.'), '.')"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring-before($filename, '-lat')"/>
    <xsl:text>-grc</xsl:text>
    <xsl:value-of select="substring-after($filename, '-lat')"/>
    <xsl:text>.xml</xsl:text>
  </xsl:param>
  <!-- load grc -->
  <xsl:variable name="grc" select="document($grc_file)"/>
  <!-- store first page number as global -->
  <xsl:variable name="p1" select="$grc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@from"/>
  <!-- store level 1 div subtype  -->
  <xsl:variable name="subtype1" select="$grc/tei:TEI/tei:text/tei:body/tei:div/tei:div/@subtype"/>
  <xsl:variable name="subtype2" select="$grc/tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:div/@subtype"/>
  <xsl:variable name="subtype3" select="$grc/tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:div/tei:div/@subtype"/>
  <xsl:variable name="subtype4" select="$grc/tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:div/tei:div/tei:div/@subtype"/>
  <xsl:variable name="lf" select="'&#10;'"/>
  <xsl:template match="node()|@*" name="copy">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:idno">
    <xsl:copy>
      <xsl:value-of select="@*"/>
      <xsl:value-of select="$filename"/>
      <xsl:text>.xml</xsl:text>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title">
    <!-- Copy title from greek -->
    <xsl:copy-of select="$grc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
  </xsl:template>
  <xsl:template match="tei:sourceDesc">
    <xsl:copy>
      <xsl:value-of select="@*"/>
      <!-- Process sourceDesc content from greek (things have to be filtered) -->
      <xsl:apply-templates select="$grc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- rewrite the greek link -->
  <xsl:template match="tei:sourceDesc/tei:biblStruct/tei:ref">
    <xsl:variable name="vol" select="normalize-space(../tei:biblScope[@unit='vol'])"/>
    <xsl:variable name="vol_url">
      <xsl:value-of select="substring('00', 1, 2 - string-length($vol))"/>
      <xsl:value-of select="$vol"/>
    </xsl:variable>
    <ref target="https://www.biusante.parisdescartes.fr/histmed/medica/cote?45674x{$vol_url}">BIU Santé, Médica</ref>
  </xsl:template>
  <!-- No Bâle ? -->
  <xsl:template match="tei:biblScope[@unit='ed1vol']"/>
  <!-- body -->
  <xsl:template match="tei:body">
    <body>
      <div n="urn:cts:greekLit:{$filename}" type="edition" xml:lang="lat">
        <pb n="{$p1}"/>
        <xsl:apply-templates/>
      </div>
    </body>
  </xsl:template>
  <!-- put level -->
  <xsl:template match="tei:div">
    <xsl:variable name="level" select="1 + count(ancestor::tei:div)"/>
    <div type="textpart">
      <xsl:attribute name="subtype">
        <xsl:choose>
          <xsl:when test="$level = 1">
            <xsl:value-of select="$subtype1"/>
          </xsl:when>
          <xsl:when test="$level = 2">
            <xsl:value-of select="$subtype2"/>
          </xsl:when>
          <xsl:when test="$level = 3">
            <xsl:value-of select="$subtype3"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$subtype4"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="n">
        <xsl:number/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="tei:pb">
    <pb>
      <xsl:attribute name="n">
        <xsl:value-of select="$p1 + @n - 1"/>
      </xsl:attribute>
    </pb>
  </xsl:template>
  <!-- div/l seen by regex, put inside <lg>, match first -->
  <xsl:template match="tei:div/tei:l">
    <xsl:choose>
      <!-- has a <l> before (with maybe a pb), do nothing -->
      <xsl:when test="name(preceding-sibling::*[not(self::tei:pb)][1]) = 'l'"/>
      <xsl:otherwise>
        <lg>
          <xsl:call-template name="lg-in"/>
          <xsl:value-of select="$lf"/>
        </lg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- copy inside an <l> inside <lg> and following <l> -->
  <xsl:template name="lg-in">
    <xsl:value-of select="$lf"/>
    <xsl:text>  </xsl:text>
    <xsl:copy-of select="."/>
    <xsl:for-each select="following-sibling::*[1]">
      <xsl:choose>
        <xsl:when test="self::tei:l">
          <xsl:call-template name="lg-in"/>
        </xsl:when>
        <xsl:when test="self::tei:pb">
          <xsl:variable name="pb" select="."/>
          <xsl:for-each select="following-sibling::*[1]">
            <xsl:if test="self::tei:l">
              <xsl:apply-templates select="$pb"/>
              <xsl:call-template name="lg-in"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <!-- Para full italic, are verses (lg/l), expect text() and <lb/> only -->
  <xsl:template match="tei:p[tei:hi][count(*)=1][not(text()[normalize-space(.) != ''])]">
    <lg>
      <xsl:for-each select="tei:hi/node()">
        <xsl:choose>
          <xsl:when test="self::tei:lb"/>
          <xsl:when test="self::text() and normalize-space(.) = ''"/>
          <xsl:when test="self::text()">
            <xsl:value-of select="$lf"/>
            <xsl:text>  </xsl:text>
            <l>
              <xsl:value-of select="normalize-space(.)"/>
            </l>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Para in italic, someting else than text() and line-break</xsl:message>
            <xsl:value-of select="$lf"/>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:value-of select="$lf"/>
    </lg>
  </xsl:template>
  <!-- Epidoc specific -->
  <xsl:template match="tei:hi[@rend='sup']">
    <hi rend="superscript">
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='sub']">
    <hi rend="subscript">
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <xsl:template match="tei:hi[not(@rend)]">
    <hi rend="italic">
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
</xsl:transform>
