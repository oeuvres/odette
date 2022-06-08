<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0"
  
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  
  exclude-result-prefixes="draw style text"
  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  >
  <xsl:variable name="ABC">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖŒÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ,:; ?()/\ ._-{}[]</xsl:variable>
  <xsl:variable name="abc">abcdefghijklmnopqrstuvwxyzaaaaaaeeeeeiiiidnoooooœuuuuybbaaaaaaaceeeeiiiionooooouuuuyyb</xsl:variable>
  <!-- Find the best semantic name for an automatic style name -->
  <xsl:template name="styleName">
    <!-- nom de style, peut être passé en paramètre -->
    <xsl:param name="name" select="@class | @draw:style-name | @draw:text-style-name | @text:style-name"/>
    <!-- poignée sur le style à explorer -->
    <xsl:variable name="style" select="key('style', $name)"/>
    <!-- nom de style automatique -->
    <xsl:variable name="style-auto" select="key('style-auto', $name)"/>
    <!-- obtenir le nom d'un style sémantique, malgré les dérives automatiques  -->
    <xsl:variable name="styleName">
      <xsl:choose>
        <!-- probablement pas un style automatique -->
        <xsl:when test="not($style-auto)">
          <xsl:value-of select="$name"/>
        </xsl:when>
        <!-- style automatique, prendre le parent -->
        <xsl:when test="$style/@style:parent-style-name">
          <xsl:value-of select="$style/@style:parent-style-name"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="normalize-space($styleName)"/>
  </xsl:template>
  <!-- Build a CSS class name from an odt style name -->
  <xsl:template name="class">
    <xsl:param name="string">
      <xsl:call-template name="styleName"/>
    </xsl:param>
    <xsl:variable name="class">
      <xsl:call-template name="_loop">
        <xsl:with-param name="string" select="$string"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="translate($class, $ABC, $abc)"/>
  </xsl:template>
  <xsl:template name="_loop">
    <!-- _3c_ : '<',  _3e_ : '>', _2c_ : ',', _20_ : ' ' -->
    <xsl:param name="string"/>
    
    <xsl:variable name="hexa">_20_21_22_23_24_25_26_27_28_29_2a_2b_2c_2d_2e_2f_3a_3b_3c_3d_3e_3f_40_5b_5c_5d_5e_5f_60_7b_7c_7d_7e_7f_</xsl:variable>
    <xsl:variable name="pos" select="string-length( substring-before($string, '_')) + 1"/>
    <xsl:choose>
      <xsl:when test="not(contains($string, '_'))">
        <xsl:value-of select="$string"/>
        <!-- break -->
      </xsl:when>
      <!-- Something like  blah_blah_blah or blah_XX_blah -->
      <xsl:when test="not(contains($hexa, substring($string, $pos, 4)))">
        <xsl:value-of select="substring-before($string, '_')"/>
        <xsl:text>_</xsl:text>
        <xsl:call-template name="_loop">
          <xsl:with-param name="string" select="substring-after($string, '_')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Should be blah_20_blah -->
      <xsl:otherwise>
        <xsl:value-of select="substring-before($string, '_')"/>
        <xsl:call-template name="_loop">
          <xsl:with-param name="string" select="substring($string, $pos+4)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>