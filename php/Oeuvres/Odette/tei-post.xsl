<?xml version="1.0" encoding="UTF-8"?>
<!--
Post processing of odt_tei

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2021 frederic.glorieux@fictif.org et Optéos
© 2015 frederic.glorieux@fictif.org et LABEX OBVIL

// dangerous in re

# underline, maybe not a title, say it
s#<title>#<title rend="u">#g
# small caps, maybe not a name
s#<name>#<name rend="sc">#g
# letter spacing
s#<phr>#<phr rend="ls">#g
# definition list
s#<dl>#<list type="gloss">#g
s#</dl>#</list>#g

# end normalisation of non conformant tags
s#<(b|i|sub|sup|strong)([ /][^>]*)?>#<hi rend="\1"\2>#g
s#</(b|i|sub|sup|strong)>#</hi>#g
s#<(bg|color|font|mark)_([^>/]+)([ /][^>]*)?>#<hi rend="\1" n="\2"\3>#g
s#</(bg|color|font|mark)_[^>]+>#</hi>#g

-->
<xsl:transform  version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei"
  >
  <xsl:output encoding="UTF-8" indent="no" method="xml"/>
  <xsl:param name="template"/>
  <xsl:variable name="tei" select="document($template)"/>
  <xsl:variable name="lf" select="'&#10;'"/>
  <xsl:variable name="ABC">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖŒÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ,:; ?()/\ ._-{}[]</xsl:variable>
  <xsl:variable name="abc">abcdefghijklmnopqrstuvwxyzaaaaaaeeeeeiiiidnoooooœuuuuybbaaaaaaaceeeeiiiionooooouuuuyyb</xsl:variable>
  <xsl:variable name="body" select="/*"/>
  <xsl:variable name="meta" select="/*/tei:index/tei:term"/>
  <!-- start  -->
  <xsl:template match="/">
    <xsl:apply-templates mode="model" select="$tei"/>
  </xsl:template>
  <xsl:template match="tei:body" mode="model">
    <xsl:for-each select="$body">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>
  <!-- Copy model -->
  <xsl:template match="node()|@*" mode="model">
    <xsl:copy>
      <xsl:apply-templates mode="model" select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <!-- Copy <body> -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Meta element -->
  <xsl:template match="*[not(*)][text()][starts-with(., '{')][contains(., '}')][normalize-space(substring-after(., '}')) = '']" mode="model">
    <xsl:variable name="key" select="translate(., $ABC, $abc)"/>
    <xsl:choose>
      <xsl:when test="$meta[@type = $key]">
        <xsl:variable name="el" select="."/>
        <xsl:for-each select="$meta[@type = $key]">
          <xsl:if test="position() !=1">
            <xsl:value-of select="$lf"/>
          </xsl:if>
          <xsl:element name="{name($el)}">
            <xsl:copy-of select="$el/@*"/>
            <xsl:choose>
              <xsl:when test="normalize-space(.) != ''">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:when test="normalize-space(@key) != ''">
                <xsl:value-of select="normalize-space(@key)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$el"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- value in attribute (should be unique) -->
  <xsl:template match="@*[starts-with(., '{') and contains(., '}') and normalize-space(substring-after(., '}')) = '']" mode="model">
    <xsl:variable name="key" select="translate(., $ABC, $abc)"/>
    <xsl:attribute name="{name()}">
      <xsl:choose>
        <xsl:when test="normalize-space($meta[@type = $key]) != ''">
          <xsl:variable name="value">
            <xsl:apply-templates select="$meta[@type = $key]"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($value)"/>
        </xsl:when>
        <xsl:when test="normalize-space($meta[@type = $key]/@key) != ''">
          <xsl:value-of select="normalize-space($meta[@type = $key]/@key)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  <!-- Strip meta -->
  <xsl:template match="/*/tei:index"/>
  <!-- typo inlines -->
  <xsl:template match="tei:b | tei:strong | tei:sup | tei:sc | tei:u">
    <hi>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="rend">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <xsl:template match="tei:i">
    <emph>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </emph>
  </xsl:template>
  <xsl:template match="tei:author">
    <xsl:choose>
      <xsl:when test="ancestor::tei:analytic|ancestor::tei:bibl|ancestor::tei:editionStmt|ancestor::tei:monogr|ancestor::tei:msItem|ancestor::tei:msItemStruct|ancestor::tei:titleStmt">
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <name>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="type">
            <xsl:value-of select="local-name()"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </name>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- sub chars may be page number in some conventions -->
  <xsl:template match="tei:sub">
    <xsl:choose>
      <!-- Specific to "Classiques des Sciences Sociales", original page number -->
      <xsl:when test="translate(., ' .0123456789IVXLC', '')='p'">
        <xsl:variable name="n" select="normalize-space(translate(., ' .p', ''))"/>
        <pb ana="src" n="{$n}">
          <xsl:attribute name="xml:id">
            <xsl:text>p</xsl:text>
            <xsl:value-of select="$n"/>
          </xsl:attribute>
        </pb>
      </xsl:when>
      <xsl:otherwise>
        <hi>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="rend">
            <xsl:value-of select="local-name()"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:phr">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="rend">ls</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <!-- Page number -->
  <xsl:template match="tei:pb[text()]">
    <xsl:variable name="n" select="translate(., '[]p.  ', '')"/>
    <!--  Marc : J'ajoute l'espace insécable  -->
    <xsl:choose>
      <xsl:when test="number($n) &gt; 0">
        <pb n="{$n}">
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="concat('p', $n)"/>
          </xsl:attribute>
        </pb>
      </xsl:when>
      <xsl:otherwise>
        <pb n="{normalize-space(translate(., '[]', ''))}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Auto numbering, especially page-break-before generated by ABBYY -->
  <xsl:template match="tei:pb[not(text())][not(@n)]">
    <pb>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="n">
        <xsl:variable name="n">
          <xsl:number level="any"/>
        </xsl:variable>
        <xsl:value-of select="$n +1"/>
      </xsl:attribute>
    </pb>
  </xsl:template>
  <!-- Notes candidates -->
  <xsl:template match="tei:ref[translate(., '[]()1234567890', '')=''][starts-with(@target, '#Footnote')]">
    <xsl:variable name="id" select="id(substring-after(@target, '#'))"/>
    <note>
      <xsl:choose>
        <xsl:when test="not($id)">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="local-name($id) = 'anchor'">
          <xsl:copy-of select="$id/parent::*/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$id/node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </note>
  </xsl:template>
  <xsl:template match="tei:ref[starts-with(., 'p.') or starts-with(., '[p.')]">
    <pb>
      <xsl:attribute name="n">
        <xsl:value-of select="translate(normalize-space(.), '[]', '')"/>
      </xsl:attribute>
      <xsl:attribute name="facs">
        <xsl:value-of select="normalize-space(@target)"/>
      </xsl:attribute>
    </pb>
  </xsl:template>
  <!-- 
    Blocks, try to put inline rendering informations at block level ?
  
  -->
  <xsl:template match=" OBSOLETE ">
    <xsl:variable name="text">
      <xsl:for-each select="text()">
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="mixed" select="normalize-space($text)"/>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="normalize-space($text)!=''"/>
        <xsl:when test="count(*)&gt;1"/>
        <xsl:when test="tei:anchor | tei:cb | tei:note | tei:ref | tei:pb | tei:quote"/>
        <xsl:when test="tei:hi/@rend | tei:seg/@rend">
          <xsl:value-of select="*/@rend"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name(*)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="next" select="local-name(following-sibling::*[1])"/>
    <xsl:variable name="prev" select="local-name(preceding-sibling::*[1])"/>
    <xsl:choose>
      <!-- bugs ?
      <xsl:when test="tei:pb and count(*)=1 and $mixed=''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="tei:figure and count(*)=1 and $mixed=''">
        <xsl:apply-templates/>
      </xsl:when>
      -->
      <!-- Do not output unuseful spacing empty paras, start or end of section, before or after some grouping  -->
      <xsl:when test=".='' and not(*) and ($next='' or $prev='' or $next='figure' or $prev='figure' or $next='head' or $prev='head' or $next='item' or $prev='item' or $next='list' or $prev='list' or $next='quote' or $prev='quote' )"/>
      <!-- This should be done for things like
      <p>
        <hi rend="i">…</i>
      </p>
      to have 
      <p rend="i">…</p>
      -->
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*[name() != 'rend']"/>
          <xsl:variable name="rend">
            <!-- No rend for empty paras -->
            <xsl:if test=". != ''">
              <xsl:value-of select="@rend"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$style='name'">sc</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$style"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="normalize-space($rend)!=''">
            <xsl:attribute name="rend">
              <xsl:value-of select="normalize-space($rend)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <!-- normal content, go on -->
            <xsl:when test="$style=''">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="*/node()"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- ensure mixed content -->
          <xsl:if test="not(text()[normalize-space(.)!='']) and .!=''">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- verse fragment -->
  <xsl:template match="tei:l">
    <xsl:copy>
      <xsl:copy-of select="@*[name() != 'type']"/>
      <xsl:if test="@type and @type!='part'">
        <xsl:copy-of select="@type"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@n and @n=''">
          <xsl:variable name="n">
            <!-- quite slow
              <xsl:number count="tei:l[@n='']" level="any"/>
              in hope this one will not produce problem
              -->
            <xsl:number count="*[@n='']" level="any"/>
          </xsl:variable>
          <xsl:attribute name="n">
            <xsl:value-of select="$n"/>
          </xsl:attribute>
          <xsl:attribute name="xml:id">
            <xsl:text>l</xsl:text>
            <xsl:value-of select="$n"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@n">
          <xsl:copy-of select="@n"/>
        </xsl:when>
      </xsl:choose>
      <xsl:variable name="next" select="following::tei:l[1]"/>
      <xsl:choose>
        <xsl:when test="not(@type = 'part') and $next/@type = 'part'">
          <xsl:attribute name="part">I</xsl:attribute>
        </xsl:when>
        <xsl:when test="@type = 'part' and not($next/@type)">
          <xsl:attribute name="part">F</xsl:attribute>
        </xsl:when>
        <xsl:when test="@type = 'part'">
          <xsl:attribute name="part">M</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <!-- Generic -->
  <xsl:template match="*[starts-with(local-name(), 'bg_') or starts-with(local-name(), 'mark_') or starts-with(local-name(), 'color_')]">
    <hi>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="rend">
        <xsl:variable name="rend">
          <xsl:value-of select="@rend"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="local-name()"/>
          <xsl:if test="following-sibling::*[1][local-name()='note']">
            <xsl:text> note</xsl:text>
          </xsl:if>
        </xsl:variable>
        <xsl:value-of select="normalize-space($rend)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <!-- Index marks inside segments -->
  <xsl:template match="tei:hi[count(tei:term[@rend='index'][not(text())] )=1]">
    <term>
      <xsl:copy-of select="tei:term/@*"/>
      <xsl:apply-templates select="node()[local-name() != 'term']"/>
    </term>
  </xsl:template>
  <xsl:template match="tei:dl">
    <list>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="type">gloss</xsl:attribute>
      <xsl:apply-templates/>
    </list>
  </xsl:template>
  <xsl:template match="tei:dialogue">
    <list>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="type">dialogue</xsl:attribute>
      <xsl:apply-templates/>
    </list>
  </xsl:template>
  <!-- tag page number in index item -->
  <xsl:template match="tei:div[@type='index']">
    <list type="index">
      <xsl:for-each select="*">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:for-each select="node()">
            <xsl:choose>
              <xsl:when test="self::text()">
                <xsl:call-template name="tag-page"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>
    </list>
  </xsl:template>
  <xsl:template name="tag-page">
    <!-- "Aliermont, Forêt et pays : 10, 55 ; 212, 213." -->
    <xsl:param name="text" select="."/>
    <!-- "Aliermont  Forêt et pays   10  55   212  213"  -->
    <xsl:param name="norm" select="translate($text, ' ,;.', '    ')"/>
    <xsl:choose>
      <!-- text=" ; "  norm="   " -->
      <xsl:when test="normalize-space($norm)=''">
        <xsl:value-of select="$text"/>
      </xsl:when>
      <xsl:when test="contains($norm, ' ')">
        <!-- "pays : 10 ; 212" 
                  |$pos
                  –––$length ? no way found for good calculation with normalize-space()
        -->
        <xsl:variable name="pos" select="string-length(substring-before($norm, ' '))+1"/>
        <xsl:call-template name="tag-page">
          <xsl:with-param name="text" select="substring($text, 1, $pos - 1)"/>
        </xsl:call-template>
        <xsl:value-of select="substring($text, $pos, 1)"/>
        <xsl:call-template name="tag-page">
          <xsl:with-param name="text" select="substring($text, $pos +1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="translate($text, '1234567890', '')=''">
        <ref target="#p{$text}">
          <xsl:value-of select="$text"/>
        </ref>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Put inside <sp>, output next, stop on <speaker> -->
  <xsl:template name="sp">
    <xsl:choose>
      <xsl:when test="self::tei:p [. = '']">
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:call-template name="sp"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="local-name()='speaker'"/>
      <xsl:otherwise>
        <xsl:value-of select="$lf"/>
        <xsl:apply-templates select="."/>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:call-template name="sp"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--  -->
  <xsl:template match="tei:div">
    <xsl:variable name="head" select="translate(normalize-space(tei:head), $ABC, $abc)"/>
    <xsl:choose>
      <!-- False section  -->
      <xsl:when test="normalize-space(.)=''"/>
      <!-- Theatre to group in <sp> -->
      <xsl:when test="tei:speaker">
        <xsl:copy>
          <xsl:copy-of select="tei:head[1]/tei:anchor[1]/@xml:id"/>
          <xsl:copy-of select="@*"/>
          <xsl:if test="starts-with($head, 'scene')">
            <xsl:attribute name="type">scene</xsl:attribute>
          </xsl:if>
          <xsl:if test="starts-with($head, 'act')">
            <xsl:attribute name="type">act</xsl:attribute>
          </xsl:if>
          <xsl:if test="tei:head/@type">
            <xsl:attribute name="type">
              <xsl:value-of select="tei:head/@type"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:variable name="first" select="generate-id(tei:speaker[1])"/>
          <xsl:apply-templates select="*[following-sibling::*[generate-id()=$first]]"/>
          <xsl:for-each select="tei:speaker">
            <sp>
              <xsl:attribute name="who">
                <!-- No note -->
                <xsl:variable name="text" select="text()"/>
                <xsl:variable name="who">
                  <xsl:choose>
                    <xsl:when test="contains($text, ',')">
                      <xsl:value-of select="substring-before(., ',')"/>
                    </xsl:when>
                    <xsl:when test="contains($text, '.')">
                      <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$text"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="translate(normalize-space($who),$ABC ,$abc)"/>
              </xsl:attribute>
              <xsl:copy-of select="tei:anchor[1]/@xml:id"/>
              <xsl:apply-templates select="."/>
              <xsl:for-each select="following-sibling::*[1]">
                <xsl:call-template name="sp"/>
              </xsl:for-each>
            </sp>
          </xsl:for-each>
        </xsl:copy>
      </xsl:when>
      <!-- False section produced by error in head level -->
      <xsl:when test="parent::tei:body and count(../tei:div) = 1">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="normalize-space(tei:head) = 'Table des matières'"/>
      <xsl:when test="contains(normalize-space(tei:head), '[skip]')"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <!-- explicit id override <anchor xml:id="ddr193010burg"/> -->
          <xsl:variable name="divid" select="tei:head/tei:id"/>
          <xsl:if test="$divid">
            <xsl:attribute name="xml:id">
              <xsl:value-of select="normalize-space(translate($divid, '[]', ''))"/>
            </xsl:attribute>
          </xsl:if>
          <!-- ?? section à spliter ? -->
          <xsl:if test="tei:head[1]/@type">
            <xsl:attribute name="type">
              <xsl:value-of select="tei:head/@type"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="tei:head[1]/tei:anchor[1]/@xml:id"/>
          <xsl:apply-templates select="@*"/>
          <!-- Non, trop de problèmes
          <xsl:if test="starts-with($head, 'chapter') or starts-with($head, 'chapitre')">
            <xsl:attribute name="type">chapter</xsl:attribute>
          </xsl:if>
            -->
          <!--
          <xsl:attribute name="subtype">
            <xsl:text>level</xsl:text>
            <xsl:value-of select="count(ancestor-or-self::tei:div)"/>
          </xsl:attribute>
          -->
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:div/tei:head/tei:id"/>
  <xsl:template match="tei:p">
    <xsl:variable name="mixed" select="text()[normalize-space(.) != '']"/>
    <xsl:choose>
      <xsl:when test="not($mixed) and count(*) = 1 and tei:pb">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:notep">
    <note>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Notes with a generated id -->
  <xsl:template match="tei:note">
    <xsl:variable name="prev" select="local-name(preceding-sibling::*[1])"/>
    <xsl:copy>
      <!-- auto id -->
      <xsl:attribute name="xml:id">
        <xsl:choose>
          <xsl:when test="@resp">
            <xsl:choose>
              <xsl:when test="@resp = 'author'">fn</xsl:when>
              <xsl:when test="@resp = 'editor'">fned</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@resp"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="resp" select="@resp"/>
            <xsl:number level="any" count="tei:note[@resp=$resp]" from="/*/tei:text/tei:body"/>
          </xsl:when>
          <xsl:when test="@place">
            <xsl:choose>
              <xsl:when test="@place = 'foot'">fn</xsl:when>
              <xsl:when test="@place = 'bottom'">fn</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@place"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="place" select="@place"/>
            <xsl:number level="any" count="tei:note[@place=$place]" from="/*/tei:text/tei:body"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>fn</xsl:text>
            <xsl:number level="any" count="tei:note" from="/*/tei:text/tei:body"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <!-- figure with a generated id -->
  <xsl:template match="tei:figure">
    <xsl:variable name="prev" select="local-name(preceding-sibling::*[1])"/>
    <xsl:copy>
      <!-- auto id -->
      <xsl:attribute name="xml:id">
        <xsl:text>fig</xsl:text>
        <xsl:choose>
          <xsl:when test="@type">
            <xsl:variable name="type" select="@type"/>
            <xsl:number level="any" count="tei:figure[@type=$type]" from="/*/tei:text/tei:body"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number level="any" count="tei:figure" from="/*/tei:text/tei:body"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <!-- first -->
      <xsl:for-each select="node()">
        <xsl:choose>
          <xsl:when test="self::tei:graphic">
            <xsl:value-of select="$lf"/>
            <xsl:text>  </xsl:text>
            <xsl:apply-templates select="."/>
          </xsl:when>
          <xsl:when test="self::tei:ref[starts-with(., 'http')]">
            <xsl:value-of select="$lf"/>
            <xsl:text>  </xsl:text>
            <graphic url="{normalize-space(.)}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:variable name="head">
        <xsl:for-each select="node()">
          <xsl:choose>
            <xsl:when test="self::tei:lb"/>
            <xsl:when test="self::tei:graphic"/>
            <xsl:when test="self::tei:ref[starts-with(., 'http')]"/>
            <xsl:otherwise>
              <xsl:apply-templates select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="$head != ''">
        <xsl:value-of select="$lf"/>
        <xsl:text>  </xsl:text>
        <head>
          <xsl:copy-of select="$head"/>
        </head>
      </xsl:if>
      <xsl:value-of select="$lf"/>
    </xsl:copy>
  </xsl:template>
  <!-- Wash some inline typo in headings -->
  <xsl:template match="tei:head">
    <xsl:copy>
      <xsl:copy-of select="@*[local-name() != 'type']"/>
      <xsl:if test="@type='sub'">
        <xsl:copy-of select="@type"/>
      </xsl:if>
      <xsl:variable name="text">
        <xsl:for-each select="text()">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="num">1234567890.-—–§  </xsl:variable>
      <xsl:choose>
        <!--
        <head>1. <hi rend="i"></hi></head>
        -->
        <xsl:when test="translate(normalize-space($text), $num, '')=''">
          <xsl:for-each select="node()">
            <xsl:choose>
              <xsl:when test="self::tei:space">
                <xsl:text> </xsl:text>
              </xsl:when>
              <!-- element -->
              <xsl:when test="self::*">
                <xsl:apply-templates select="."/>
              </xsl:when>
              <!-- space in tag -->
              <xsl:when test="normalize-space(.)=''">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="translate(normalize-space($text), $num, '')=''">
                <num>
                  <xsl:value-of select="."/>
                </num>
              </xsl:when>
              <!-- should be text -->
              <xsl:otherwise>
                <xsl:copy-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:head/tei:space"/>
  <!-- Should I wash some anchors ? -->
  <xsl:template match="tei:anchor">
    <xsl:choose>
      <xsl:when test="parent::tei:speaker"/>
      <xsl:when test="parent::tei:head"/>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- biblio -->
  <xsl:template match="tei:bibl/tei:i">
    <title>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  <!-- teiHeader -->
  <xsl:template match="/tei:TEI/tei:text/*[1]/tei:index">
    <xsl:variable name="terms" select="tei:term[not(contains($metakeys, concat(',', @type, ',')))]"/>
    <xsl:if test="count($terms) &gt; 1">
      <index>
        <xsl:copy-of select="$terms"/>
      </index>
    </xsl:if>
  </xsl:template>
  <xsl:template match="node()" mode="metakeys">
    <xsl:apply-templates mode="metakeys" select="node()|@*"/>
  </xsl:template>
  <xsl:template match="text()|@*" mode="metakeys">
    <xsl:choose>
      <xsl:when test="starts-with(., '{') and contains(., '}') and normalize-space(substring-after(., '}')) = ''">
        <xsl:value-of select="translate(., $ABC, $abc)"/>
        <xsl:text>,</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!--
  <xsl:template match="tei:teiHeader">
    <xsl:variable name="terms" select="/tei:TEI/tei:text/*[1]/tei:index/tei:term"/>
    <teiHeader>
      <fileDesc>
        <xsl:choose>
          <xsl:when test="$terms[@type='title' or @type='titre']">
            <titleStmt>
              <xsl:for-each select="$terms[@type='title' or @type='titre']">
                <title>
                  <xsl:apply-templates/>
                </title>
              </xsl:for-each>
              <xsl:for-each select="$terms[@type='auteur' or @type='author' or @type='creator']">
                <author>
                  <xsl:apply-templates/>
                </author>
              </xsl:for-each>
              <xsl:for-each select="$terms[@type='editor' or @type='contributor'  or @type='translator']">
                <editor>
                  <xsl:if test="@type = 'translator'">
                    <xsl:attribute name="role">translator</xsl:attribute>
                  </xsl:if>
                  <xsl:apply-templates/>
                </editor>
              </xsl:for-each>
            </titleStmt>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="tei:fileDesc/tei:titleStmt"/>
          </xsl:otherwise>
        </xsl:choose>
        <editionStmt>
          <xsl:choose>
            <xsl:when test="$terms[@type='edition']">
              <xsl:for-each select="$terms[@type='edition']">
                <edition>
                  <xsl:apply-templates/>
                </edition>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:fileDesc/tei:editionStmt/tei:edition"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="tei:fileDesc/tei:editionStmt/tei:*[local-name() != 'edition']"/>
          <xsl:for-each select="$terms[@type='copyeditor' or @type='sr' or @type='secretairederedaction']">
            <respStmt>
              <xsl:choose>
                <xsl:when test="tei:ref">
                  <xsl:for-each select="tei:ref">
                    <name ref="{@target}">
                      <xsl:apply-templates/>
                    </name>
                  </xsl:for-each>
                  <resp>
                    <xsl:variable name="resp">
                      <xsl:apply-templates select="node()[name() != 'ref']"/>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space(translate($resp, '()', ''))"/>
                  </resp>
                </xsl:when>
                <xsl:when test="contains(., '(')">
                  <name>
                    <xsl:value-of select="substring-before(., '(')"/>
                  </name>
                  <resp>
                    <xsl:value-of select="translate(substring-after(., '('), '()', '')"/>
                  </resp>
                </xsl:when>
                <xsl:otherwise>
                  <name>
                    <xsl:apply-templates/>
                  </name>
                </xsl:otherwise>
              </xsl:choose>
            </respStmt>
          </xsl:for-each>
        </editionStmt>
        <publicationStmt>
          <xsl:choose>
            <xsl:when test="$terms[@type='publisher']">
              <xsl:for-each select="$terms[@type='publisher']">
                <publisher>
                  <xsl:apply-templates/>
                </publisher>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:authority | tei:fileDesc/tei:publicationStmt/tei:distributor | tei:fileDesc/tei:publicationStmt/tei:publisher | tei:fileDesc/tei:publicationStmt/tei:pubPlace"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="$terms[@type='issued' or @type='publie']">
              <xsl:for-each select="$terms[@type='issued' or @type='publie']">
                <date>
                  <xsl:apply-templates/>
                </date>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:date"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:for-each select="$terms[@type='idno']">
            <idno>
              <xsl:apply-templates/>
            </idno>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="$terms[@type='licence' or @type='license']">
              <availability status="restricted">
                <xsl:for-each select="$terms[@type='licence' or @type='license']">
                  <licence>
                    <xsl:choose>
                      <xsl:when test="tei:ref and not(text()[normalize-space(.) != ''])">
                        <xsl:attribute name="target">
                          <xsl:value-of select="tei:ref/@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="*/node()"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select="tei:ref[1]/@target"/>
                        <xsl:apply-templates/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </licence>
                </xsl:for-each>
              </availability>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:availability"/>
            </xsl:otherwise>
          </xsl:choose>
        </publicationStmt>
        <xsl:apply-templates select="tei:fileDesc/tei:seriesStmt | tei:fileDesc/tei:notesStmt"/>
        <sourceDesc>
          <xsl:choose>
            <xsl:when test="$terms[@type='source' or @type='bibl']">
              <xsl:for-each select="$terms[@type='source' or @type='bibl']">
                <bibl>
                  <xsl:apply-templates/>
                </bibl>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:fileDesc/tei:sourceDesc/*"/>
            </xsl:otherwise>
          </xsl:choose>
        </sourceDesc>
      </fileDesc>
      <profileDesc>
        <xsl:choose>
          <xsl:when test="$terms[@type='created' or @type='creation' or @type='date']">
            <creation>
              <xsl:for-each select="$terms[@type='created' or @type='creation' or @type='date']">
                <date>
                  <xsl:choose>
                    <xsl:when test="translate(., '0123456789- ', '') = ''">
                      <xsl:attribute name="when">
                        <xsl:value-of select="normalize-space(.)"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates/>
                    </xsl:otherwise>
                  </xsl:choose>
                </date>
              </xsl:for-each>
            </creation>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="tei:profileDesc/tei:creation"/>
          </xsl:otherwise>
        </xsl:choose>
        <langUsage>
          <xsl:choose>
            <xsl:when test="$terms[@type='language']">
              <language>
                <xsl:value-of select="normalize-space($terms[@type='language'])"/>
              </language>
            </xsl:when>
            <xsl:when test="tei:profileDesc/tei:langUsage/tei:language">
              <xsl:apply-templates select="tei:profileDesc/tei:langUsage/tei:language"/>
            </xsl:when>
            <xsl:otherwise>
              <language ident="{/*/@xml:lang}"/>
            </xsl:otherwise>
          </xsl:choose>
        </langUsage>
        <xsl:if test="$terms[@type='keyword' or @type='subject' or @type='sujet']">
          <textClass>
            <keywords>
              <xsl:for-each select="$terms[@type='keyword' or @type='subject' or @type='sujet']">
                <term type="subject">
                  <xsl:value-of select="normalize-space(.)"/>
                </term>
              </xsl:for-each>
            </keywords>
          </textClass>
        </xsl:if>
      </profileDesc>
    </teiHeader>
  </xsl:template>
  -->
</xsl:transform>
