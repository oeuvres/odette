<?xml version="1.0" encoding="UTF-8"?>
<!--

<h1>(Open Document Text) odt &gt; TEI  (<a href="./odt_tei.xsl">odt_tei.xsl</a>)</h1>

<p>Vous qui entrez, laissez toute espérance ! (de comprendre)</p>

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2005 ajlsm.com (Cybertheses)
© 2007 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@fictif.org 
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL

<p>
Cette transformation prend en entrée du XML OpenDocument (ex : OpenOffice.org LibreOffice),
et produit un TEI générique. L'insistance a porté sur la robustesse du filtre,
afin de réduire les reprises du stylage dans le traitements de textes (ex : styles utilisateur corrompus).
L'outil a été développé pour plusieurs éditions savantes (textes manuscrits, dictionnaires)
sur des fichiers tels qu'envoyés à l'imprimeur (sans modèles de documents, avec peu de stylage).
Il vise à terme la récupération de textes issus de numérisation avec mise en forme.
Le résultat XML est optimisé pour des normalisations ultérieures (regroupements, hiérarchies, de niveau caractères et paragraphes).
Cette transformation peut être branchée directement comme filtre d'export
OpenOffice, mais cet usage n'est pas le plus conseillé. Le processus est parfois
long, et peut échouer sans explication, notamment sur des fichiers importants. On tirera mieux parti de
la sortie en la traitant avec d'autres filtres (expressions régulières, XSLT).
</p>

<p lang="en-FR">
This transformation takes as input the OpenDocument XML (eg OpenOffice.org)
and produces a generic TEI. The emphasis is on the robustness of the filter,
to reduce rework the styling in the word processing (eg, user styles corrupted).
The tool was developped for different scholarly publications (manuscripts, dictionaries)
on files sent to the printing house (without templates, with few styling).
It aims to recover texts from scanning with formatting.
The XML output is optimized for subsequent normalization (grouping, hierarchy, on character and paragraph level).
This transformation can be plugged directly as an export filter in
OpenOffice, but this usage is not the most advisable. The process is sometimes
long, and may fail without explanation, especially on important files.
Best usage of output could be as an input for other filters (regular expressions, XSLT).
</p>


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
  
  xmlns:odette="odt:tei"

  exclude-result-prefixes="tei odette
  office style text table draw fo xlink dc meta number svg chart dr3d math form script ooo ooow oooc dom xforms xsd xsi config rpt of rdfa field"

  xmlns:exslt="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:php="http://php.net/xsl"
  extension-element-prefixes="date exslt php"

>

  <!-- office style text table draw fo xlink dc meta number svg chart dr3d math form script ooo ooow oooc dom xforms xsd xsi -->
  <!-- Nécessaire pour libxml, assure encodage -->
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <!-- clé sur les styles -->
  <xsl:key name="style" match="style:style|text:list-style" use="@style:name"/>
  <xsl:key name="style-auto" match="office:automatic-styles/style:style|office:automatic-styles/text:list-style" use="@style:name"/>
  <xsl:key name="list-style" match="text:list-style" use="@style:name"/>
  <xsl:key name="p-style" match="odette:style[@level='p']" use="@name"/>
  <xsl:key name="c-style" match="odette:style[@level='c']" use="@name"/>
  <!-- Link to a style sheet with style name mapping with elements -->
  <xsl:variable name="sheet" select="document('styles.xml', document(''))"/>
  <!-- the filename processed, set by the caller -->
  <xsl:param name="filename"/>
  <xsl:param name="mediadir"/>
  <xsl:variable name="dc">,author,bibl,created,creation,contributor,copyeditor,creator,date,edition,editor,idno,issued,keyword,licence,license,publie,publisher,secretairederedaction,source,subject,sujet,title,translator,</xsl:variable>
  <xsl:variable name="lf"><xsl:text>
</xsl:text></xsl:variable>
  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="ABC">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖŒÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ,; ?()/\ ._-</xsl:variable>
  <xsl:variable name="abc">abcdefghijklmnopqrstuvwxyzaaaaaaeeeeeiiiidnoooooœuuuuybbaaaaaaaceeeeiiiionooooouuuuyyb</xsl:variable>
  <xsl:variable name="lang">
    <xsl:choose>
      <xsl:when test="//office:meta/dc:language">
        <xsl:value-of select="substring-before(concat(//office:meta/dc:language, '-'), '-')"/>
      </xsl:when>
      <xsl:when test="//style:style[@style:name='Standard']">
        <xsl:value-of select="//style:style[@style:name='Standard']/style:text-properties/@fo:language"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//@fo:language[.!='']"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- Shall we infer title from content ? -->
  <xsl:variable name="h" select="//text:h[1]"/>

  <!-- 
    Be more precise than root, may catch the root of a nodeset() function
  <xsl:template match="/"/>
  -->
  <xsl:template match="office:document">
    <xsl:apply-templates select="office:document-content"/>
  </xsl:template>
  <!-- break here -->
  <xsl:template match="office:scripts | office:font-face-decls | text:sequence-decls | office:forms | office:automatic-styles  | office:settings | office:styles | office:master-styles "/>

  <xsl:template match="office:document-content">
    <xsl:processing-instruction name="xml-stylesheet"> type="text/xsl" href="../Teinte/tei2html.xsl"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model"> href="http://oeuvres.github.io/Teinte/teinte.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <xsl:if test="function-available('date:date-time')">
      <xsl:comment>
        <xsl:text>Odette: </xsl:text>
        <xsl:value-of select="date:date-time()"/>
      </xsl:comment>
    </xsl:if>
    <TEI xml:lang="{$lang}">
      <!-- Pas une bonne idée, trop de renommage
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$filename"/>
      </xsl:attribute>
      -->
      <teiHeader/>
      <xsl:apply-templates select="*"/>
    </TEI>
  </xsl:template>
  <!-- Structure -->
  <xsl:template match="office:meta">
    <teiHeader>
      <xsl:apply-templates select="*"/>
    </teiHeader>
  </xsl:template>
  <!-- Conteneur  -->
  <xsl:template match="office:body">
    <text>
      <xsl:apply-templates select="*"/>
    </text>
  </xsl:template>
  <!-- go throw, sections can break the tree of titles  -->
  <xsl:template match="text:section">
    <xsl:variable name="cols" select="key('style', @text:style-name)/style:columns/@fo:column-count"/>
    <xsl:comment>
      <xsl:text>section=</xsl:text>
      <xsl:value-of select="@text:name"/> 
      <xsl:if test="$cols and number($cols) &gt; 1"> cols=<xsl:value-of select="$cols"/></xsl:if>
    </xsl:comment>
    <xsl:apply-templates/>
    <xsl:comment>/section=<xsl:value-of select="@text:name"/></xsl:comment>
  </xsl:template>
  <!-- A counting template to produce inlines -->
  <xsl:template name="divClose">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="$n &gt; 0">
        <xsl:processing-instruction name="div">/</xsl:processing-instruction>
        <xsl:call-template name="divClose">
          <xsl:with-param name="n" select="$n - 1"/>
        </xsl:call-template>
      </xsl:when>     
    </xsl:choose>
  </xsl:template>
  <xsl:template name="divOpen">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="$n &gt; 0">
        <xsl:processing-instruction name="div"/>
        <xsl:call-template name="divOpen">
          <xsl:with-param name="n" select="$n - 1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- do not keep list items with headings -->
  <xsl:template match="text:list[descendant::text:h] | text:list-item[descendant::text:h]">
      <xsl:apply-templates/>
    <!-- 
    ?? table:table[descendant::text:h] | table:table-row[descendant::text:h] | table:row[descendant::text:h] | table:table-cell[descendant::text:h] | table:cell[descendant::text:h]
    -->
  </xsl:template>
  <!-- flat headings, producing hierarchical division, empty headings should have been washed before, 
    heaedings in notes will break things -->
  <xsl:template match="text:h">
    <xsl:variable name="style" select="key('style', @text:style-name | @class | @draw:style-name | @draw:text-style-name)"/>
    <xsl:variable name="styleName">
      <xsl:call-template name="styleName"/>
    </xsl:variable>
    <xsl:variable name="class">
      <xsl:call-template name="class"/>
    </xsl:variable>
    <xsl:variable name="level" select="@text:outline-level"/>
    
    <!-- Generate markers for div -->

    <!-- close sections previously openened -->
    <xsl:choose>
      <xsl:when test="ancestor::table:table"/>
      <xsl:when test="ancestor::text:note"/>
      <xsl:otherwise>
        <xsl:variable name="prev" select="preceding::text:h[1]/@text:outline-level"/>
        <xsl:if test="$prev">
          <xsl:call-template name="divClose">
            <xsl:with-param name="n" select="1+ $prev - $level"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="divOpen">
          <xsl:with-param name="n" select="1"/>
        </xsl:call-template>
        <xsl:variable name="open">
          <xsl:choose>
            <xsl:when test="$prev">
              <xsl:value-of select="$level - $prev - 1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$level - 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="divOpen">
          <xsl:with-param name="n" select="$open"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Always one -->
    <!-- Sometimes more  -->
    
    <xsl:variable name="xml">
      <!-- Add page break. 
        @style:master-page-name
case encountered, seems logic, but not fully tested         
      <xsl:if test="$style//@fo:break-before='page' or key('style',$styleName )//@fo:break-before='page' or $style//@style:master-page-name or  key('style',$styleName )//@style:master-page-name"><pb/></xsl:if>
      -->
      <head>
          <xsl:choose>
            <xsl:when test="$class = ''"/>
            <xsl:when test="starts-with($class, 'heading')"/>
            <xsl:when test="starts-with($class, 'titre')"/>
            <xsl:otherwise>
              <xsl:attribute name="type">
                <xsl:value-of select="$class"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        <xsl:variable name="start-value" select="/office:document/office:document-styles/office:styles/text:outline-style[@style:name='Outline']/text:outline-level-style[@text:level='1']/@text:start-value"/>
          <xsl:if test="$start-value">
            <xsl:variable name="n">
              <xsl:number count="text:h[@text:outline-level = $level]" level="any"/>
            </xsl:variable>
            <xsl:attribute name="n">
              <xsl:value-of select="$n - 1 + $start-value"/>
            </xsl:attribute>
          </xsl:if>
        <xsl:call-template name="flow"/>
      </head>
    </xsl:variable>
    <!-- NO BORDER AROUND HEAD -->
    <xsl:copy-of select="$xml"/>
  </xsl:template>
  <xsl:template match="text:page-number">
    <pb n="{.}"/>
  </xsl:template>
  <!-- if office page break are gnificative, it is here -->
  <xsl:template match="text:soft-page-break"/>
  <!-- End of text, do not forget to close open <div> -->
  <xsl:template match="office:text">
    <body>
      <!-- NO !
      <xsl:call-template name="divOpen">
        <xsl:with-param name="n" select="1"/>
      </xsl:call-template>
      -->
      <xsl:apply-templates select="*"/>
      <xsl:variable name="last" select="(.//text:h[not(ancestor::text:note|ancestor::table:table)])[last()]"/>
      <xsl:call-template name="divClose">
        <xsl:with-param name="n" select="$last/@text:outline-level"/>
      </xsl:call-template>
    </body>
  </xsl:template>
  <!-- Section générée -->
  <xsl:template match="text:table-of-content | text:alphabetical-index | text:user-index">
    
    <divGen>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="self::text:table-of-content">toc</xsl:when>
          <xsl:when test="self::text:alphabetical-index">index</xsl:when>
          <xsl:when test="self::text:user-index">index</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="local-name()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </divGen>
  </xsl:template>
  <!--

<p>Paragraphes, le XML est préparé pour des étapes ultérieures de regroupements
(<i>paragraphs and grouping</i>).</p>

<ul>
  <li>Vue
    <blockquote>
<div>Citation</div>
<div><i>Quotations</i></div>
    </blockquote>
  </li>
  <li>odt
<pre>&lt;text:p text:style-name="Quotations">Citation&lt;/text:p>
&lt;text:p text:style-name="P13">Quotations&lt;/text:p></pre>
  </li>
  <li>odt_tei.xsl
<pre>&lt;quote>&lt;p>Citation&lt/p>&lt;/quote>
&lt;quote>&lt;p>Quotations&lt/p>&lt;/quote></pre></li>
  <li><code>s/<\/([^>]+)>\t(\n+)<\1>/$2/g</code></li>
  <li>
<pre>&lt;quote>
  &lt;p>Citation&lt;/p>
  &lt;p>Quotations&lt;/p>
&lt;/quote></pre>
  </li>
</ul>

<p>Regroupements (grouping)</p>
<ul>
  <li>Encadré (<i>border</i>) : &lt;figure></li>
  <li>Texte Préformaté (<i>Preformated Text</i>) : &lt;eg></li>
  <li>Liste de termes (<i>Definition list</i>) : list/(label+,item)+. En-tête de liste (<i>List Heading</i>) : &lt;label> ; Contenu de liste (<i>List Content</i>) : &lt;item></li>
  <li>Citation (<i>Quotations</i>) : &lt;quote> ; </li>
</ul>
  -->
  <xsl:template match="text:p">
    <xsl:param name="style-name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>
    <!-- handle on the current style -->
    <xsl:variable name="style" select="key('style', $style-name)"/>
    <!-- automatic style means local styling to output -->
    <xsl:variable name="style-auto" select="key('style-auto', $style-name)"/>
    <!-- Get a normalized class name (no spaces, no capitals…) -->
    <xsl:variable name="classtest">
      <xsl:call-template name="class">
        <xsl:with-param name="string">
          <xsl:call-template name="styleName"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="$classtest = 'listheading'">label</xsl:when>
        <!-- non semantic style names -->
        <xsl:when test="starts-with($classtest, 'notedebasdepage')"/>
        <xsl:when test="starts-with($classtest, 'annotationtext')"/>
        <xsl:when test="starts-with($classtest, 'corpsdutexte')"/>
        <xsl:when test="$classtest = 'textbody'"/>
        <xsl:when test="$classtest = 'bodytext'"/>
        <xsl:when test="$classtest = 'standard'"/>
        <xsl:when test="contains($classtest, 'list')"/>
        <xsl:when test="parent::table:table-cell and $classtest = 'tablecontents'"/>
        <xsl:when test="$classtest ='textformatvorlage'"/>
        <xsl:when test="starts-with($classtest, 'normal')"/>
        <xsl:when test="$classtest = 'footnotetext'"/>
        <!-- Normalize style name -->
        <xsl:otherwise>
          <xsl:value-of select="$classtest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- catch rendering information for non semantic style (supposed to be local styling) -->
    <xsl:variable name="align">
      <xsl:variable name="left" select="translate($style/style:paragraph-properties/@fo:margin-left, 'abcdefghijklmnopqrstuvwxyz ', '')"/>
      <xsl:variable name="style2" select="key('style', $style/@style:parent-style-name)"/>
      <xsl:choose>
        <xsl:when test="not($style-auto)"/>
        <!-- margin-left:0 different from parent style -->
        <xsl:when test="$left &gt; 0.1 and $style2/style:paragraph-properties/@fo:margin-left and not(starts-with($style2/style:paragraph-properties/@fo:margin-left, '0'))">outdent</xsl:when>
        <xsl:when test="$left &gt; 0.1">margin</xsl:when>
        <xsl:when test="$style/style:paragraph-properties/@fo:text-align = 'end'">right</xsl:when>
        <xsl:when test="$style/style:paragraph-properties/@fo:text-align = 'center'">center</xsl:when>
        <xsl:when test="contains($class, 'centr') or  contains($class, 'center')">center</xsl:when>
        <xsl:when test="contains($class, 'droite') or contains($class, 'right')">right</xsl:when>
        <!-- ? add noise or info ? to test
        <xsl:when test="$style/style:paragraph-properties/@fo:text-align = 'start'">left</xsl:when>
        -->
      </xsl:choose>
    </xsl:variable>
    <!-- first line indent -->
    <xsl:variable name="indent">
      <xsl:variable name="n" select="translate($style/style:paragraph-properties/@fo:text-indent, 'abcdefghijklmnopqrstuvwxyz', '')"/>
      <xsl:choose>
        <xsl:when test="$class = 'l'"/>
        <xsl:when test="$class = 'label'"/>
        <xsl:when test="$class = 'quote'"/>
        <xsl:when test="not($style-auto)"/>
        <xsl:when test="not($style/style:paragraph-properties/@fo:text-indent)"/>
        <xsl:when test="$n &lt; -0.1">hanging</xsl:when>
        <!--
        <xsl:when test="$n &gt; 0">indent</xsl:when>
        -->
        <!-- Shall we verify on parent if there is a difference ? -->
        <xsl:when test="$n = 0">noindent</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="font">
      <xsl:choose>
        <xsl:when test="not($style-auto)"/>
        <xsl:when test="$style/style:text-properties/@fo:font-style='italic' or $style/style:text-properties/@style:font-style-complex='italic'">i</xsl:when>
        <xsl:when test="$style/style:text-properties/@fo:font-weight='bold' or $style/style:text-properties/@style:font-weight-complex='bold'">b</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="color">
      <xsl:choose>
        <xsl:when test="not($style-auto)"/>
        <xsl:when test="not($style/style:text-properties/@fo:color)"/>
        <xsl:when test="$style/style:text-properties/@fo:color='#000000'"></xsl:when>
        <xsl:otherwise>
          <xsl:text>color_</xsl:text>
          <xsl:value-of select="substring($style/style:text-properties/@fo:color, 2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bg">
      <xsl:variable name="bgcol" select="$style/style:text-properties/@fo:background-color"/>
      <xsl:choose>
        <xsl:when test="not($style-auto)"/>
        <xsl:when test="not($bgcol)"/>
        <xsl:when test="substring($bgcol, 2) = 'FFFFFF'"/>
        <xsl:when test="substring($bgcol, 2) = 'ffffff'"/>
        <xsl:when test="$bgcol='transparent'"/>
        <xsl:otherwise>
          <xsl:text>bg_</xsl:text>
          <xsl:value-of select="substring($bgcol, 2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="u">
      <xsl:variable name="underline" select="($style/style:text-properties/@style:text-underline-style and $style/style:text-properties/@style:text-underline-style != 'none') or ($style/style:text-properties/@style:text-underline and $style/style:text-properties/@style:text-underline != 'none')"/>
      <xsl:choose>
        <xsl:when test="not($style-auto)"/>
        <xsl:when test="$underline">u</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sc">
      <xsl:choose>
        <xsl:when test="not($style-auto)"/>
        <xsl:when test="$style/style:text-properties/@fo:font-variant = 'small-caps'">sc</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="border">
      <xsl:call-template name="border"/>
    </xsl:variable>
    <xsl:variable name="rend" select="normalize-space(concat($align,' ',$indent,' ',$font,' ',$color,' ',$bg, ' ', $u, ' ', $sc))"/>
    <xsl:variable name="key" select="translate(substring-before(., ':'), $ABC, $abc)"/>
    <xsl:variable name="xml">
      <xsl:choose>
        <xsl:when test=".='' and (text:alphabetical-index-mark | text:alphabetical-index-mark-start | text:user-index-mark)">
            <index>
              <xsl:apply-templates select="text:alphabetical-index-mark | text:alphabetical-index-mark-start | text:user-index-mark"/>
            </index>
         </xsl:when>
        <!-- No style para on first page with form key:value -->
         <xsl:when test="not(preceding-sibling::text:h) and contains($dc, concat(',', $key, ','))">
            <index>
              <term type="{$key}">
                 <xsl:call-template name="flow"/>
              </term>
            </index>
          </xsl:when>
          <xsl:when test="$class = 'term'">
            <xsl:if test=". != ''">
              <index>
                <term>
                  <xsl:if test="contains(., ':')">
                    <xsl:attribute name="type">
                      <xsl:value-of select="$key"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="flow"/>
                </term>
              </index>
            </xsl:if>
          </xsl:when>
        <!-- something to do with a possible semantic class -->
        <xsl:when test="$class != ''">
          <xsl:variable name="mapping" select="$sheet/*/odette:style[@level='p'][@name=$class]"/>
          <xsl:choose>
            <xsl:when test="$mapping[@parent]">
              <xsl:variable name="element" select="normalize-space($mapping/@element)"/>
              <xsl:element name="{$mapping/@parent}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="{$element}" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:call-template name="lang"/>
                  <xsl:choose>
                    <xsl:when test="$mapping/@attribute = 'rend'">
                      <xsl:variable name="rend2">
                        <xsl:value-of select="$mapping/@value"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$rend"/>
                      </xsl:variable>
                      <!-- local rendering of para -->
                      <xsl:if test=" normalize-space($rend2) != ''">
                        <xsl:attribute name="rend">
                          <xsl:value-of select="$rend2"/>
                        </xsl:attribute>
                      </xsl:if>
                    </xsl:when>
                    <xsl:when test="$mapping/@attribute != ''">
                      <xsl:attribute name="{$mapping/@attribute}">
                        <xsl:value-of select="$mapping/@value"/>
                      </xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                  <!-- numbered line -->
                  <xsl:if test="$element = 'l' and ($style/style:paragraph-properties/@text:number-lines='true' or $class='ln') ">
                    <xsl:attribute name="n"/>
                  </xsl:if>
                  <xsl:call-template name="flow"/>
                </xsl:element>
              </xsl:element>
            </xsl:when>
                    <!--  A style known as an element -->
            <xsl:when test="$mapping[@element and @element!='']">
              <xsl:variable name="element" select="normalize-space($mapping/@element)"/>
              <xsl:element name="{$element}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:call-template name="lang"/>
                <xsl:choose>
                  <xsl:when test="$mapping/@attribute = 'rend'">
                    <xsl:variable name="rend2">
                      <xsl:value-of select="$mapping/@value"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="$rend"/>
                    </xsl:variable>
                    <!-- local rendering of para -->
                    <xsl:if test=" normalize-space($rend2) != ''">
                      <xsl:attribute name="rend">
                        <xsl:value-of select="$rend2"/>
                      </xsl:attribute>
                    </xsl:if>
                  </xsl:when>
                  <xsl:when test="$mapping/@attribute != ''">
                    <xsl:attribute name="{$mapping/@attribute}">
                      <xsl:value-of select="$mapping/@value"/>
                    </xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                <!-- numbered line -->
                <xsl:if test="$element = 'l' and ($style/style:paragraph-properties/@text:number-lines='true' or  $class='ln')">
                  <xsl:attribute name="n"/>
                </xsl:if>
                <xsl:if test="$element='eg'">
                  <xsl:value-of select="$lf"/>
                </xsl:if>
                <!-- if verse, tab indentation maybe relevant -->
                <!-- line group where verse are defined by line breaks  -->
                <xsl:if test="$element = 'lg'">
                  <xsl:text>
    </xsl:text>
                  <lb type="lg"/>
                </xsl:if>
                <xsl:call-template name="flow"/>
                <xsl:if test="$element = 'lg'">
                  <xsl:text>
                  </xsl:text>
                </xsl:if>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <p>
                <xsl:if test="$rend!='' or $class!=''">
                  <xsl:attribute name="rend">
                    <xsl:value-of select="normalize-space(concat($class,' ',$rend))"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="lang"/>
                <xsl:call-template name="flow"/>
              </p>
            </xsl:otherwise>
          </xsl:choose>
            
            
        </xsl:when>
        <xsl:otherwise>
          <p>
            <xsl:if test="$rend!='' or $class!=''">
              <xsl:attribute name="rend">
                <xsl:value-of select="normalize-space(concat($class,' ',$rend))"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="lang"/>
            <xsl:call-template name="flow"/>
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
     <xsl:choose>
      <xsl:when test="$class = 'term'">
        <xsl:copy-of select="$xml"/>
      </xsl:when>
      <!-- be careful with empty paras -->
      <xsl:when test="$border != ''">
        <quote rend="border">
          <xsl:copy-of select="$xml"/>
        </quote>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$xml"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template for flow content, especially to deal with mixed content -->
  <xsl:template name="flow">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- titre dans une liste, peut contenir plusieurs paragraphes -->
  <xsl:template match="text:list-header">
    <argument>
      <xsl:apply-templates/>
    </argument>      
  </xsl:template>
  <!--
Listes et tables
================
-->
  <!-- liste -->
  <xsl:template match="text:list">
    <xsl:variable name="style-name" select="@text:style-name"/>
    <xsl:variable name="level" select="count(ancestor-or-self::text:list)"/>
    <!-- handle on the style -->
    <xsl:variable name="list-level" select="key('list-style', $style-name)/*[@text:level=$level]"/>
    <!-- Get the style of the item -->
    <xsl:variable name="item-class">
      <xsl:for-each select="text:list-item[1]">
        <xsl:call-template name="class"/>
      </xsl:for-each>
      <xsl:text> </xsl:text>
      <xsl:for-each select="text:list-item[1]/text:p[1]">
        <xsl:call-template name="class"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="bullet" select="$list-level/@text:bullet-char"/>
    <xsl:variable name="list">
      <xsl:choose>
        <!-- Dialogue ? -->
        <xsl:when test="$bullet != '' and contains('-—–', $bullet) and not(*[count(*) > 1])">
          <xsl:for-each select="*">
            <p rend="dialog">
              <xsl:value-of select="$bullet"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="*/node()"/>
            </p>
          </xsl:for-each>
        </xsl:when>
        <!-- listBibl -->
        <xsl:when test="starts-with(normalize-space($item-class), 'Bibl') or starts-with(normalize-space($item-class), 'bibl')">
          <listBibl>
            <xsl:apply-templates select="*"/>
          </listBibl>
        </xsl:when>
        <xsl:otherwise>
          <list>
            <xsl:choose>
              <xsl:when test="local-name($list-level) = 'list-level-style-bullet'">
                <xsl:attribute name="type">ul</xsl:attribute>
              </xsl:when>
              <xsl:when test="local-name($list-level) = 'list-level-style-number'">
                <xsl:attribute name="type">ol</xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="name($list-level)">
              <xsl:variable name="rend" select="$list-level/@text:bullet-char | $list-level/@style:num-format"/>
              <xsl:choose>
                <xsl:when test="translate($rend, '-–—oaI1A', '') = ''">
                  <xsl:attribute name="rend">
                    <xsl:value-of select="($list-level/@text:bullet-char | $list-level/@style:num-format)"/>
                  </xsl:attribute>
                </xsl:when>
                <!-- bug PDF 2 DOC, à ou « utilisé comme puce -->
                <xsl:otherwise>
                  <xsl:value-of select="($list-level/@text:bullet-char | $list-level/@style:num-format)"/>
                  <xsl:text> </xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:apply-templates select="*"/>
            
          </list>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Attraper le premier item pour voir s'il est encadré -->
    <xsl:variable name="stylename" select="*//@text:style-name | *//@class | *//@draw:style-name | *//@draw:text-style-name"></xsl:variable>
    <xsl:variable name="border">
      <xsl:for-each select="text:list-item[1][count(*) = 1]/*[1]">
        <xsl:call-template name="border"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$border != ''">
        <!-- No space before a border, to help future cleaning -->
        <quote rend="border">
          <xsl:copy-of select="$list"/>
        </quote>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="border">
    <!-- nom de style, peut être passé en paramètre -->
    <xsl:param name="style-name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>
    <!-- poignée sur le style à explorer -->
    <xsl:variable name="style" select="key('style', $style-name)"/>
    <!-- Automatic style ? -->
    <xsl:variable name="style-auto" select="key('style-auto', $style-name)"/>
    <xsl:choose>
      <!-- style de bordure annulé -->
      <xsl:when test="contains($style/style:paragraph-properties/@fo:border, 'none')"/>
      <!-- if not style auto, stop -->
      <xsl:when test="not($style-auto)"/>
      <xsl:when test="$style/style:paragraph-properties/@fo:border">
        <xsl:value-of select="$style/style:paragraph-properties/@fo:border"/>
      </xsl:when>
      <!-- if style automatic, test ancestor -->
      <xsl:when test="$style/@style:parent-style-name">
        <xsl:variable name="class" select="key('style', $style/@style:parent-style-name)"/>
        <xsl:if test="not (contains($class/style:paragraph-properties/@fo:border, 'none'))">
          <xsl:value-of select="$class/style:paragraph-properties/@fo:border"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- item de liste -->
  <xsl:template match="text:list-item">
    <xsl:variable name="class">
      <xsl:variable name="value">
        <xsl:call-template name="class"/>
        <xsl:for-each select="*[1]">
          <xsl:text> </xsl:text>
          <xsl:call-template name="class"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space($value)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($class, 'bibl') or starts-with($class, 'Bibl')">
        <bibl>
          <xsl:choose>
            <xsl:when test="count(*) = 1">
              <xsl:apply-templates select="*/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </bibl>
      </xsl:when>
      <xsl:otherwise>
        <item>
          <xsl:choose>
            <xsl:when test="$class='corpsdetexte'"/>
            <xsl:when test="$class='listcontents'"/>
            <xsl:when test="$class='List_20_Contents'"/>
            <xsl:when test="$class='normal'"/>
            <xsl:when test="$class='paragraphedeliste'"/>
            <xsl:when test="$class='textbody'"/>
            <xsl:when test="$class='standard'"/>
            <xsl:when test="$class='Standard'"/>
            <xsl:when test="$class='Text_20_body'"/>
            <xsl:otherwise>
              <xsl:attribute name="rend">
                <xsl:value-of select="$class"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="count(*) = 1">
              <xsl:apply-templates select="*/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- table -->
  <xsl:template match="table:table">
    
    <table>
      <!--
table:name="Tableau1" table:style-name="Tableau1"
-->
      <xsl:apply-templates select="node()"/>
      
    </table>
  </xsl:template>
  <!-- Colonnes, rien -->
  <xsl:template match="table:table-column | table:table-columns"/>
  <!-- Lignes -->
  <xsl:template match="table:table-row | table:row">
    <xsl:param name="role"/>
    
    <row>
      <xsl:if test="$role != ''">
        <xsl:attribute name="role">
          <xsl:value-of select="$role"/>
        </xsl:attribute>
      </xsl:if>
      <!--
      <xsl:apply-templates select="@*"/>
      table:style-name="Tableau1.2"
      -->
      <xsl:apply-templates/>
      
    </row>
  </xsl:template>
  <!-- Cellules -->
  <xsl:template match="table:table-cell | table:cell">
    
    <cell>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="class">
        <!--  pas encore vu de style sémantique
        <xsl:value-of select="@table:style-name"/>
       -->
        <xsl:if test="@table:protected = true()"> protected</xsl:if>
        <xsl:if test="count(descendant::text:p)=1">
          <xsl:variable name="style">
            <xsl:call-template name="class">
              <xsl:with-param name="style-name" select="descendant::text:p/@text:style-name"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="normalize-space($style)=''"/>
            <xsl:when test="$style='Table_20_Contents'"/>
            <xsl:when test="$style='Table_20_Heading'"> label</xsl:when>
            <xsl:otherwise>
              <xsl:text> </xsl:text>
              <xsl:value-of select="$style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:variable>
      <xsl:if test="normalize-space($class) != ''">
        <xsl:attribute name="rend">
          <xsl:value-of select="normalize-space($class)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <!-- cellule vide, vu : des espaces insécables (?) -->
        <xsl:when test="translate(normalize-space(.), ' ', '')= ''"/>
        <!-- Un seul paragraphe -->
        <xsl:when test="count(descendant::text:p)=1">
          <xsl:choose>
            <!-- 
<table:table-cell table:style-name="Tableau1.B2" office:value-type="string">
  <text:p text:style-name="Table_20_Contents">
    <text:span text:style-name="Police_20_par_20_défaut">
      <text:span text:style-name="T36">La Gelosia</text:span>
    </text:span>
  </text:p>
</table:table-cell>
            -->
            <xsl:when test="count(descendant::text()[normalize-space(.) != '']) = 1">
              <xsl:apply-templates select="descendant::text()[normalize-space(.) != '']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="descendant::text:p/node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
          
        </xsl:otherwise>
      </xsl:choose>
    </cell>
  </xsl:template>
  <xsl:template match="@office:value-type"/>
  <xsl:template match="@office:value"/>
  <xsl:template match="@table:number-columns-spanned">
    <xsl:if test="number(.) &gt; 1">
      <xsl:attribute name="cols">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@table:number-rows-spanned">
    <xsl:if test="number(.) &gt; 1">
      <xsl:attribute name="rows">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@table:style-name | @table:protected">
    <!-- TODO, voir cas réels -->
  </xsl:template>
  <!-- Cellule vide provenant d'une fusion -->
  <xsl:template match="table:covered-table-cell"/>
  <!-- thead -->
  <xsl:template match="table:table-header-rows">
    <xsl:apply-templates>
      <xsl:with-param name="role">label</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>


  <!-- Cadres de texte -->
  <xsl:template match="draw:frame">
    <xsl:choose>
      <xsl:when test="ancestor::draw:frame">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <figure>
          <xsl:apply-templates/>
        </figure>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="draw:text-box">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="draw:plugin">
    <ptr target="{@xlink:href}"/>
  </xsl:template>




  <!--
<h2>Format caractère (<i>char level</i>)</h2>
-->

<!--
<p>
Interpréter les styles et les mises en forme locales en éléments TEI courts
choisis pour faciliter des regroupements ultérieurs.
</p>

<p lang="en-FR">
Interpret the styles and local formatting in TEI short names,
to facilitate subsequent groupings.
</p>

<p>Exemple de regroupement <i>grouping sample</i></p>

<ul>
  <li>Vue : <u>Le <i>Quixotte</i> au <span style="font-variant: small-caps">xix</span><sup>e</sup> siècle</u></li>
  <li>odt xml : &lt;text:span text:style-name="T18">Le &lt;/text:span> &lt;text:span text:style-name="T3">Quixotte&lt;/text:span> &lt;text:span text:style-name="T18"> au &lt;/text:span> &lt;text:span text:style-name="T15">xix&lt;/text:span> &lt;text:span text:style-name="T7">e&lt;/text:span> &lt;text:span text:style-name="T18"> siècle&lt;/text:span></li>
  <li>odt_tei.xsl : &lt;title>Le &lt;/title>&lt;title>&lt;hi>Quixotte&lt;/hi>&lt;/title>&lt;title> au &lt;/title>&lt;title>&lt;num>xix&lt;/num>&lt;/title>&lt;title>ᵉ&lt;/title>&lt;title> siècle&lt;/title></li>
  <li>s/&lt;\/([^>]+)>( *)&lt;\1>/$2/</li>
  <li>&lt;title>Le &lt;hi>Quixotte&lt;/hi> au &lt;num>xix&lt;/num>ᵉ siècle&lt;/title></li>
</ul>

<p>Ordre d'imbrication des éléments générés (<i>nesting order of elements</i>)</p>

<ul>
  <li><span style="background-color:#FFFFCC">Surlignage (<i>hilite</i>)</span> : &lt;mark_{code-couleur}> </li>
  <li>Style : &lt;{style}></li>
  <li><span style="color:red">Couleur (<i>color</i>)</span> : &lt;color_{code-couleur}></li>
  <li><u>Souligné (<i>underline</i>)</u> : &lt;title> </li>
  <li><b>gras (<i>bold</i>)</b> : &lt;b> (<i>cf.</i> <a href="http://dev.w3.org/html5/spec/Overview.html#the-b-element">&lt;html5:b></a> : <i> keywords</i>)</li>
  <li><span style="letter-spacing:0.2ex">Lettres espacées (<i>letter spacing</i>)</span> : &lt;phr> (expressions)</li>
  <li><i>Italique (<i>italic</i>)</i> : &lt;hi></li>
  <li><span style="font-variant: small-caps">Petites capitales (<i>Small-Caps</i>)</span> : &lt;name>, &lt;num> (chiffres, notamment romains)</li>
  <li><sup>Exposant <i>superscript</i></sup> et <sub>indice <i>subscript</i></sub> : unicode, &lt;hi rend="sup">, &lt;hi rend="sub"></li>
</ul>
  -->
  <xsl:template match="text:span">
    <xsl:variable name="style-name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>

    <!-- poignée sur le style à explorer -->
    <xsl:variable name="style" select="key('style', $style-name)"/>
    <!-- nom de style automatique -->
    <xsl:variable name="style-auto" select="key('style-auto', $style-name)"/>
    <!-- Get a good semantic style name -->
    <xsl:variable name="classtest">
      <xsl:call-template name="class">
        <xsl:with-param name="string">
          <xsl:call-template name="styleName"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="class">
      <xsl:choose>
        <!-- non semantic style names -->
        <xsl:when test="$classtest = 'annotationtext' "/>
        <xsl:when test="$classtest = 'bodytextchar' "/>
        <xsl:when test="$classtest = 'caracteresdenotedebasdepage' "/>
        <xsl:when test="$classtest = 'corpsdetextecar' "/>
        <xsl:when test="starts-with ($classtest, 'corpsdutexte') "/>
        <xsl:when test="$classtest = 'defaultparagraphfont' "/>
        <xsl:when test="$classtest = 'footnotereference' "/>
        <xsl:when test="$classtest = 'footnotesymbol' "/>
        <xsl:when test="$classtest = 'footnotetextchar' "/>
        <xsl:when test="$classtest = 'hyperlink' "/>
        <xsl:when test="$classtest = 'mwheadline' "/>
        <xsl:when test=" starts-with($classtest, 'normal') "/>
        <xsl:when test="starts-with ($classtest, 'notedebasdepage') "/>
        <xsl:when test="starts-with($classtest, 'policepardefaut') "/>
        <xsl:when test="$classtest = 'titre1car' "/>
        <xsl:when test="$classtest = 'titre2car' "/>
        <xsl:when test="$classtest = 'titre3car' "/>
        <xsl:when test="$classtest = 'titre4car' "/>
        <xsl:when test="$classtest = 'titolo1carattere' "/>
        <xsl:when test="$classtest = 'titolo2carattere' "/>
        <xsl:when test="$classtest = 'titolo3carattere' "/>
        <xsl:when test="$classtest = 'titolo4carattere' "/>
        <xsl:when test="starts-with($classtest, 'ww') "/>
        <!-- Normalize style name -->
        <xsl:otherwise>
          <xsl:value-of select="$classtest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="text-position" select="$style/style:text-properties/@style:text-position"/>
    <xsl:variable name="position">
      <xsl:choose>
        <!-- No <sup> for note ref -->
        <xsl:when test="not(text()[normalize-space(.) != ''])"/>
        <xsl:when test="contains($text-position, 'sub') or starts-with($text-position, '-')">sub</xsl:when>
        <xsl:when test="starts-with($text-position,'0%')"/>
        <!-- style:text-position="33% 100%"  -->
        <xsl:when test="contains($text-position, 'super')">sup</xsl:when>
        <xsl:when test="$text-position !=''">sup</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="mapping" select="$sheet/*/*[@level='c'][@name=$class][1]"/>
    <xsl:choose>
      <!-- no style on spaces  -->
      <xsl:when test="normalize-space(.)='' and not(*)">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$mapping/@element = 'pb'">
        <xsl:element name="{$mapping/@element}" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
      </xsl:when>
      <!-- known style as an element -->
      <xsl:when test="$mapping">
        <!-- Some local typo inside semantic style, like superscript in inline quote -->
        <xsl:variable name="subsup">
          <xsl:choose>
            <xsl:when test="not($style-auto)">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$position = 'sup'">
              <sup>
                <xsl:apply-templates/>
              </sup>
            </xsl:when>
            <!-- no small-caps in superscript, but maybe in italic -->
            <xsl:when test="$style/style:text-properties/@fo:font-variant = 'small-caps'">
              <sc>
                <xsl:apply-templates/>
              </sc>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="i">
          <xsl:choose>
            <xsl:when test="not($style-auto) or starts-with($class, 'title')">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$style/style:text-properties/@fo:font-style='italic' or $style/style:text-properties/@font-style-complex='italic'">
              <i>
                <xsl:call-template name="lang"/>
                <xsl:copy-of select="$subsup"/>
              </i>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$subsup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="background-color" select="$style/style:text-properties/@fo:background-color"/>
        <xsl:variable name="col">
          <xsl:choose>
            <xsl:when test="not($style-auto)">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$background-color != '#ffffff' and $background-color != '#FFFFFF' and starts-with($style/style:text-properties/@fo:background-color, '#')">
              <xsl:element name="bg_{substring-after($background-color, '#')}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="$i"/>
              </xsl:element>
            </xsl:when>
            <xsl:when test="$style/style:text-properties/@fo:color != '#000000'">
              <xsl:element name="color_{substring-after( $style/style:text-properties/@fo:color, '#')}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="$i"/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$i"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$mapping/@element != ''">
            <xsl:element name="{$mapping/@element}" namespace="http://www.tei-c.org/ns/1.0">
              <xsl:call-template name="lang"/>
              <xsl:if test="$mapping/@attribute != ''">
                <xsl:attribute name="{$mapping/@attribute}">
                  <xsl:value-of select="$mapping/@value"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:copy-of select="$col"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$col"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!--  unknow style, maybe semantic, but consider it is not if superscript or subscript -->
      <xsl:when test="$class != '' and $position=''">
        <seg rend="{$class}">
          <xsl:call-template name="lang"/>
          <xsl:apply-templates/>
        </seg>
      </xsl:when>
      <!-- big test chain for good  -->
      <xsl:otherwise>
        <!-- su^perscript/subscript -->
        <xsl:variable name="subsup">
          <xsl:choose>
            <xsl:when test="$position = 'sup' and translate(., 'ao', '') = ''">
              <xsl:value-of select="translate(., 'ao', 'ªº')"/>
            </xsl:when>
            <xsl:when test="$position != ''">
              <xsl:element name="{$position}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates/>
              </xsl:element>
            </xsl:when>
            <!-- no small-caps in superscript, but maybe in italic -->
            <xsl:when test="$style/style:text-properties/@fo:font-variant = 'small-caps'">
              <xsl:choose>
                <!-- No letters, probably noise -->
                <xsl:when test="translate(., 'aàbcdeéèfghijklmnopqrstuvwxyz', '') = .">
                  <xsl:apply-templates/>
                </xsl:when>
                <!-- Redundant -->
                <xsl:when test="starts-with($class, 'pers')">
                  <xsl:apply-templates/>
                </xsl:when>
                <!-- Roman number -->
                <xsl:when test="translate(., 'ivxlcdm1234567890,-.() ', '') = ''">
                  <num>
                    <xsl:apply-templates/>
                  </num>
                </xsl:when>
                <xsl:otherwise>
                  <sc>
                    <xsl:apply-templates/>
                  </sc>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- bold, italic, small-caps -->
        <xsl:variable name="bi">
          <xsl:choose>
            <!-- bold+italic (ex: bad formated titles) protect to italic, supposed more semantic  -->
            <xsl:when test="($style/style:text-properties/@fo:font-weight='bold' or $style/style:text-properties/@font-weight-complex='bold') and ($style/style:text-properties/@fo:font-style='italic' or $style/style:text-properties/@font-style-complex='italic')">
              <b>
                <xsl:call-template name="lang"/>
                <i>
                  <xsl:copy-of select="$subsup"/>
                </i>
              </b>
            </xsl:when>
            <xsl:when test="$style/style:text-properties/@fo:font-style='italic' or $style/style:text-properties/@font-style-complex='italic'">
              <i>
                <xsl:call-template name="lang"/>
                <xsl:copy-of select="$subsup"/>
              </i>
            </xsl:when>
            <xsl:when test="$style/style:text-properties/@fo:font-weight='bold' or $style/style:text-properties/@font-weight-complex='bold'">
              <b>
                <xsl:call-template name="lang"/>
                <xsl:copy-of select="$subsup"/>
              </b>
            </xsl:when>
            <!-- lettres espacées -->
            <xsl:when test="$style/style:text-properties/@fo:letter-spacing != '' and $style/style:text-properties/@fo:letter-spacing != 'normal'
and (number(translate($style/style:text-properties/@fo:letter-spacing, 'abcdefghijklmnopqrstuvwxyz', '')) &gt; 0.03 )
">
              <phr>
                <xsl:call-template name="lang"/>
                <xsl:copy-of select="$subsup"/>
              </phr>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$subsup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- underline may group italic, superscript and small-caps -->
        <xsl:variable name="u">
          <xsl:choose>
            <xsl:when test="$style/style:text-properties/@style:text-line-through-style and $style/style:text-properties/@style:text-line-through-style != 'none'">
              <del>
                <xsl:copy-of select="$bi"/>
              </del>
            </xsl:when>
            <xsl:when test="ancestor::text:a">
              <xsl:copy-of select="$bi"/>
            </xsl:when>
            <xsl:when test="($style/style:text-properties/@style:text-underline-style and $style/style:text-properties/@style:text-underline-style != 'none') or ($style/style:text-properties/@style:text-underline and $style/style:text-properties/@style:text-underline != 'none') ">
              <u>
                <xsl:attribute name="rend">
                  <xsl:value-of select="$style/style:text-properties/@style:text-underline-style"/>
                </xsl:attribute>
                <xsl:variable name="color" select="$style/style:text-properties/@style:text-underline-color"/>
                <xsl:choose>
                  <!-- style:text-underline-color="font-color" -->
                  <xsl:when test="not($color)"/>
                  <xsl:when test="$color = 'font-color'"/>
                  <xsl:when test="starts-with($color, '#')">
                    <xsl:attribute name="n">
                      <xsl:value-of select="substring($color, 2)"/>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="n">
                      <xsl:value-of select="$color"/>
                    </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:copy-of select="$bi"/>
              </u>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$bi"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Couleurs, notamment pour surlignements enveloppant -->
        <xsl:choose>
          <!-- pas de style de couleur dans les liens -->
          <xsl:when test="ancestor::text:a or ancestor::text:h">
            <xsl:copy-of select="$u"/>
          </xsl:when>
          <xsl:when test="$style/style:text-properties/@fo:background-color != '#FFFFFF' and $style/style:text-properties/@fo:background-color != '#ffffff' and $style/style:text-properties/@fo:background-color != 'transparent'">
            <xsl:element name="bg_{substring-after( $style/style:text-properties/@fo:background-color, '#')}" namespace="http://www.tei-c.org/ns/1.0">
              <xsl:copy-of select="$u"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="$style/style:text-properties/@fo:color != '#000000'">
            <xsl:element name="color_{substring-after( $style/style:text-properties/@fo:color, '#')}" namespace="http://www.tei-c.org/ns/1.0">
              <xsl:copy-of select="$u"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$u"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Spacing -->
  <xsl:template match="text:s">
    <xsl:choose>
      <!-- space at start of a note -->
      <xsl:when test="preceding-sibling::*[1][self::text:tab]"/>
      <xsl:when test="parent::text:note and not(preceding-sibling::node()[1])"/>
      <xsl:when test="../../text:note and not(../preceding-sibling::node()[1])"/>
      <!-- Bad rule
      <xsl:when test="not(preceding-sibling::node()[normalize-space(.) != ''])"/>
      -->
      <xsl:when test="@text:c">
        <space>
          <xsl:value-of select="substring(
'                                                                                                  '
        ,1, @text:c - 2)"/>
        </space>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="text:tab">
    <xsl:variable name="tab">
      <xsl:text>    </xsl:text>
    </xsl:variable>
    <xsl:choose>
      <!-- tab at start of a note -->
      <xsl:when test="ancestor::text:note and not(../preceding-sibling::node())"/>
      <xsl:when test="ancestor::text:note and not(preceding-sibling::node())"/>
      <xsl:when test="true()">
        <space rend="tab">
          <xsl:copy-of select="$tab"/>
        </space>
      </xsl:when>
      <xsl:when test="local-name(following-sibling::*[1]) = 'tab'">
        <xsl:copy-of select="$tab"/>
      </xsl:when>
      <xsl:when test="local-name(preceding-sibling::*[1]) = 'tab'">
        <xsl:copy-of select="$tab"/>
      </xsl:when>
      <!-- <text:span text:style-name="T227"><text:tab/></text:span><text:span text:style-name="T228"><text:tab/></text:span> -->
      <xsl:when test="../preceding-sibling::*[1]/text:tab">
        <xsl:copy-of select="$tab"/>
      </xsl:when>
      <xsl:when test="../following-sibling::*[1]/text:tab">
        <xsl:copy-of select="$tab"/>
      </xsl:when>
      <!-- no para  indent, except for verse  -->
      <xsl:when test="not(preceding-sibling::node()[normalize-space(.) != ''])"/>
      <xsl:otherwise>
        <xsl:copy-of select="$tab"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- liens -->
  <xsl:template match="text:a">
    <xsl:choose>
      <!--
Go through unuseful link

<text:a xlink:type="simple" xlink:href="#_ftn3" office:name="_ftnref3">
  <text:span text:style-name="T29">
    <text:note text:id="ftn3" text:note-class="footnote">
      <text:note-citation>3</text:note-citation>
      <text:note-body>
        <text:p text:style-name="P12">Le terme anaphorique étant accordé au singulier, on comprendra que son antécédent est «le public», et non pas «quelques particuliers».</text:p>
      </text:note-body>
    </text:note>
  </text:span>
</text:a>
      -->
      <xsl:when test="descendant::text:note">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <ref>
          <xsl:attribute name="target">
            <xsl:choose>
              <xsl:when test="starts-with(@xlink:href, '#')">
                <xsl:value-of select="translate(@xlink:href, ' ', '_')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@xlink:href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:choose>
            <!-- <seg rend="lienhypertexte"> -->
            <xsl:when test="count(*) = 1 and not(text()[normalize-space(.) != ''])">
              <xsl:apply-templates select="*/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </ref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Images, TODO, trouver le nom de l'image et le message alternatif
<draw:frame draw:style-name="fr2" draw:name="Nom" text:anchor-type="as-char" svg:width="14.97cm" svg:height="6.219cm" draw:z-index="2">
<draw:image xlink:href="Pictures/10000000000006E900000301284AF6AA.png" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/>
<svg:title>Alternative</svg:title>
</draw:frame>

<text:p text:style-name="P33">
          <draw:frame draw:style-name="fr1" draw:name="Cadre3" text:anchor-type="paragraph" svg:width="12.698cm" draw:z-index="2">
            <draw:text-box fo:min-height="9.523cm">
              <text:p text:style-name="Caption"><draw:frame draw:style-name="fr2" draw:name="images3" text:anchor-type="paragraph" svg:x="0.004cm" svg:y="0.002cm" svg:width="12.698cm" style:rel-width="100%" svg:height="9.523cm" style:rel-height="scale" draw:z-index="3"><draw:image xlink:href="../../../../elec/conferences/src/knoch-mund/olgiati.png" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad" draw:filter-name="&lt;Tous les formats&gt;"/></draw:frame>© Mirta Olgiati</text:p>
            </draw:text-box>
          </draw:frame>
        </text:p>
  -->
  <xsl:template match="draw:frame/svg:title | draw:frame/draw:text-box/text:p[draw:frame/draw:image|draw:image]">
    <xsl:apply-templates select="draw:image|draw:frame"/>
    <head>
      <xsl:apply-templates select="node()[local-name() != 'image' and local-name() != 'frame']"/>
    </head>
  </xsl:template>
  <xsl:template match="draw:frame/svg:desc">
    <figDesc>
      <xsl:apply-templates/>
    </figDesc>
  </xsl:template>
  <xsl:template match="draw:image">
    <xsl:variable name="url">
      <xsl:choose>
        <xsl:when test="$mediadir != '' and contains(@xlink:href, 'media/')">
          <xsl:value-of select="$mediadir"/>
          <xsl:value-of select="substring-after(@xlink:href, 'media/')"/>
        </xsl:when>
        <xsl:when test="$mediadir != '' and contains(@xlink:href, 'Pictures/')">
          <xsl:value-of select="$mediadir"/>
          <xsl:value-of select="substring-after(@xlink:href, 'Pictures/')"/>
        </xsl:when>
        <xsl:when test="$mediadir != '' and contains(@xlink:href, $mediadir)">
          <xsl:value-of select="$mediadir"/>
          <xsl:value-of select="substring-after(@xlink:href, $mediadir)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@xlink:href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <graphic url="{$url}"/>
  </xsl:template>

  <!-- Saut de ligne -->
  <xsl:template match="text:line-break">
    <xsl:variable name="class">
      <xsl:for-each select="ancestor::text:p[1]">
        <xsl:call-template name="class"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="type" select="$sheet/*/*[@level='p'][@name=$class][1]/@element"/>
    
    <xsl:choose>
      <!-- line break in titles may cause problems, let's say that people know what they do  -->
      <!--
      <xsl:when test="ancestor::text:h">
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="$class='Subtitle'">
        <xsl:text> </xsl:text>
      </xsl:when>
      -->
      <xsl:when test="$type='lg'">
        <xsl:text>
</xsl:text>
        <lb type="{$type}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>
</xsl:text>
        <lb/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--
Indexation
==========
-->

  <!-- formater une marque d'index, à appeler dans text:alphabetical-index-mark,
  l'attribut protège l'élément d'écrasement dans les processus de simplification -->
  <xsl:template match="text:alphabetical-index-mark | text:alphabetical-index-mark-start | text:user-index-mark">
    <term rend="index">
      <xsl:if test="@text:key1">
        <xsl:attribute name="type">
          <xsl:value-of select="@text:key1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@text:key2">
        <xsl:attribute name="subtype">
          <xsl:value-of select="@text:key2"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="key">
        <xsl:choose>
          <xsl:when test="@text:string-value">
            <xsl:value-of select="@text:string-value"/>
          </xsl:when>
          <xsl:when test="self::text:alphabetical-index-mark-start">
            <xsl:variable name="id" select="@text:id"/>
            <xsl:value-of select="following-sibling::node()[following-sibling::text:alphabetical-index-mark-end[@text:id=$id]]"/>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </term>
  </xsl:template>
  <xsl:template match="text:alphabetical-index-mark-end"/>

  <!--
Notes
=====
-->
  <!-- passer à travers les appels de note -->
  <xsl:template match="text:span[text:note][count(node())=1]" priority="3">
    <xsl:apply-templates/>
  </xsl:template>
  <!--
  <text:span class="footnote_20_symbol"><text:note text:id="ftn144" text:note-class="footnote"><text:note-citation>144</text:note-citation><text:note-body>
       <text:p fo:text-align="justify" class="standard"><text:span><text:s/>nitebantur] nitebanter.</text:span></text:p></text:note-body></text:note></text:span>
  -->
  <xsl:template match="text:note">
    <note>
      <!-- ne pas garder le n°, généralement automatique -->
      <!--
      <xsl:if test="text:note-citation">
        <xsl:attribute name="n">
          <xsl:value-of select="normalize-space(text:note-citation)"/>
        </xsl:attribute>
      </xsl:if>
      -->
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@text:note-class='footnote'">bottom</xsl:when>
          <xsl:when test="@text:note-class='endnote'">end</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@text:note-class"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="text:note-body"/>
    </note>
  </xsl:template>
  <xsl:template match="text:note-body">
    <xsl:choose>
      <xsl:when test="count(descendant::text:p)=1">
          <!-- 
<text:span text:style-name="Appel_20_note_20_de_20_bas_20_de_20_p.">
  <text:span text:style-name="T21">
    <text:note text:id="ftn32" text:note-class="footnote">
      <text:note-citation>32</text:note-citation>
      <text:note-body>
        <text:p text:style-name="P39">
          <text:span text:style-name="Police_20_par_20_défaut">
            <text:span text:style-name="T23">Per « favola » Grazzini intende la trama, cioè il materiale utilizzato dall’autore per elaborare l’intreccio della commedia.</text:span>
          </text:span>
          <text:span text:style-name="Police_20_par_20_défaut">
            <text:span text:style-name="T10"> </text:span>
          </text:span>
        </text:p>
      </text:note-body>
    </text:note>
  </text:span>
</text:span>

simplfiy by post-process, not here, or bugs
    -->
        <xsl:apply-templates select="text:p/node()"/>
      </xsl:when>    
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- les notes jaunes -->
  <xsl:template match="office:annotation">
    <!--
    <note place="margin" resp="{dc:creator}">
      <xsl:comment>
        <xsl:value-of select="dc:date"/>
      </xsl:comment>
      <xsl:choose>
        <xsl:when test="count(text:*)=1">
          <xsl:apply-templates select="text:*/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="text:*"/>
        </xsl:otherwise>
      </xsl:choose>
    </note>
    -->
    <xsl:comment>
      <xsl:text> </xsl:text>
      <xsl:value-of select="dc:creator"/>
      <xsl:text> : </xsl:text>
      <xsl:value-of select="dc:date"/>
      <xsl:for-each select="text:*">
        <xsl:value-of select="$lf"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:comment>
  </xsl:template>




<!--
Liens et renvois
================
-->
  <!-- des trucs
  <text:bookmark-start text:name="_Toc177196146"/>Préface<text:bookmark-end text:name="_Toc177196146"/>
  <text:bookmark text:name="_toc1604"/>
  -->
  <xsl:template match="text:bookmark-start[starts-with(@text:name, '_Toc')]
  | text:bookmark-end[starts-with(@text:name, '_Toc')]
  | text:bookmark[starts-with(@text:name, '_Toc')]
  | text:bookmark[starts-with(@text:name, 'bookmark')]
  | text:bookmark-start[starts-with(@text:name, 'bookmark')]
  | text:bookmark-end[starts-with(@text:name, 'bookmark')]
  "/>

  <xsl:template match="text:bookmark-end">
    <!-- link to preceding to bookmark-start ? -->
    
  </xsl:template>
  <!-- Ancre -->
  <xsl:template match="text:bookmark | text:bookmark-start">
    <xsl:choose>
      <xsl:when test="contains(@text:name, 'RefHeading')"/>
      <xsl:otherwise>
        <anchor>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="translate(@text:name, ' ', '_')"/>
          </xsl:attribute>
        </anchor>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="text:bookmark-end"/>



  <!-- 
    named templates 
  -->
  <!-- get a linguistic info from styles -->
  <xsl:template name="lang">
    <xsl:param name="style-name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>
    <xsl:variable name="language">
      <xsl:choose>
        <!-- local language -->  
        <xsl:when test="key('style', $style-name)/style:text-properties/@fo:language">
          <xsl:value-of select="key('style', $style-name)/style:text-properties/@fo:language"/>
        </xsl:when>
        <!-- not an auto style stop here -->
        <xsl:when test="not(key('style-auto', $style-name))"/>
        <!-- see parent style if auto style -->
        <xsl:when test="key('style', @style:parent-style-name)/style:text-properties/fo:language">
          <xsl:value-of select="key('style',@style:parent-style-name)/style:text-properties/fo:language"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- if different of global language create anattribute -->
    <xsl:if test="$language and $language != '' and $language != $lang">
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="$language"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <!-- Find the best semantic name for an automatic style name -->
  <xsl:template name="styleName">
    <!-- nom de style, peut être passé en paramètre -->
    <xsl:param name="name" select="@text:style-name | @class | @draw:style-name | @draw:text-style-name"/>
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
      <xsl:call-template name="_20_loop">
        <xsl:with-param name="string" select="$string"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="translate($class, $ABC, $abc)"/>
  </xsl:template>

  <xsl:template name="_20_loop">
    <!-- _3c_ : '<',  _3e_ : '>', _2c_ : ',', _20_ : ' ' -->
    <xsl:param name="string"/>
    <xsl:choose>
      <xsl:when test="contains($string, '_2c_')">
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-before($string, '_2c_')"/>
        </xsl:call-template>
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-after($string, '_2c_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '_2b_')">
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-before($string, '_2b_')"/>
        </xsl:call-template>
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-after($string, '_2b_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '_3c_')">
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-before($string, '_3c_')"/>
        </xsl:call-template>
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-after($string, '_3c_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '_3e_')">
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-before($string, '_3e_')"/>
        </xsl:call-template>
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-after($string, '_3e_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '_5f_')">
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-before($string, '_5f_')"/>
        </xsl:call-template>
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-after($string, '_5f_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '_20_')">
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-before($string, '_20_')"/>
        </xsl:call-template>
        <xsl:call-template name="_20_loop">
          <xsl:with-param name="string" select="substring-after($string, '_20_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select=" $string "/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- name for some color code -->
  <xsl:template name="color">
    <xsl:param name="code"/>
    <xsl:variable name="hex" select="translate($code, 'abcdef', 'ABCDEF')"/>
    <xsl:choose>
      <xsl:when test="$hex = 'FFFFFF'">white</xsl:when>
      <xsl:when test="$hex = 'FF0000'">red</xsl:when>
      <xsl:when test="$hex = '00FF00'">green</xsl:when>
      <xsl:when test="$hex = '0000FF'">blue</xsl:when>
      <xsl:when test="$hex = 'FFFF00'">yellow</xsl:when>
      <xsl:when test="$hex = '00FFFF'">cyan</xsl:when>
      <xsl:when test="$hex = 'FF00FF'">magenta</xsl:when>
      <xsl:when test="$hex = '808080'">gray</xsl:when>
      <xsl:when test="$hex = '000000'">black</xsl:when>
      <xsl:otherwise>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="$hex"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <!-- Default is a copy all to get back what is not matched -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
