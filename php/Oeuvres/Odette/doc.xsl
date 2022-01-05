<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:odette="odt:tei"
  >
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="/*">
    <div>
      <xsl:apply-templates select="*[@doc = 'true']"/>
    </div>
  </xsl:template>
  <xsl:template match="odette:style">
      <xsl:text>&#10;**</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>**</xsl:text>
      <xsl:text>&#10;```xml</xsl:text>
      <xsl:text>&#10;</xsl:text>
      <xsl:if test="@level = 'c'">character… </xsl:if>
      <xsl:choose>
        <xsl:when test="@parent">
          <xsl:element name="{@parent}">
            <xsl:text>&#10;  </xsl:text>
            <xsl:element name="{@element}">
              <xsl:if test="@attribute">
                <xsl:attribute name="{@attribute}">
                  <xsl:value-of select="@value"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="@rend">
                <xsl:attribute name="rend">right italic…</xsl:attribute>
              </xsl:if>
              <xsl:text>content ¶</xsl:text>
            </xsl:element>
            <xsl:text>&#10;</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="{@element}">
            <xsl:if test="@attribute">
              <xsl:attribute name="{@attribute}">
                <xsl:value-of select="@value"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@rend">
              <xsl:attribute name="rend">right italic…</xsl:attribute>
            </xsl:if>
              <xsl:text>content</xsl:text>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@level = 'c'"> …level</xsl:if>
      <xsl:text>&#10;</xsl:text>
      <xsl:text>```</xsl:text>
  </xsl:template>
</xsl:transform>