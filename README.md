# Odette

From text processor odt file, extract all possible information in semantic XML (TEI).

Doc (in French) : http://resultats.hypotheses.org/267

Demo : https://obvil.huma-num.fr/odette/

Maybe used with command line

    usage    : php -f Odt2tei.php "*.odt" dest/?
    "*.odt"  : glob patterns are allowed, but in quotes, to not be expanded by shell "folder/*.odt"
    dest     : optional dest directory

# Styles

The transformation transpose text processor paragraphs (¶) with some direct formatting with semantic, at paragraph level (left, right, center) and character level (italic, small caps…), but most of informaiton is transmitted by user styles. Below a list of styles known and their xml/tei transposition. Unknown styles are kept in a @rend attribute. Styles are here shown normalized as ascii lower case letter, but real life styles may contain capitals, accents, spaces, or punctuation. For example, **quotel** could appears as *&lt,quote.l&gt;* for the user in its word processor (a style used for verses in quotes). 

**ab**
```xml
<ab type="ornament">content</ab>
```
**address**
```xml
<address>
  <addrLine>content</addrLine>
</address>
```
**argument**
```xml
<argument>
  <p>content</p>
</argument>
```
**auteur**
```xml
<byline>content</byline>
```
**author**
```xml
<byline>content</byline>
```
**bibl**
```xml
<bibl>content</bibl>
```
**biblio**
```xml
<bibl>content</bibl>
```
**bibliography**
```xml
<bibl>content</bibl>
```
**bibliographie**
```xml
<bibl>content</bibl>
```
**byline**
```xml
<byline>content</byline>
```
**camera**
```xml
<camera>content</camera>
```
**chant**
```xml
<l type="chant">content</l>
```
**caption**
```xml
<caption>content</caption>
```
**castitem**
```xml
<castList>
  <castItem>content</castItem>
</castList>
```
**castlist**
```xml
<castList>content</castList>
```
**citaepigrafe**
```xml
<epigraph>
  <p>content</p>
</epigraph>
```
**citation**
```xml
<quote>
  <p>content</p>
</quote>
```
**citation1**
```xml
<quote>
  <p>content</p>
</quote>
```
**citation2**
```xml
<quote>
  <p>content</p>
</quote>
```
**citationalinea**
```xml
<quote>
  <p>content</p>
</quote>
```
**citationenvers**
```xml
<quote>
  <l>content</l>
</quote>
```
**citationvers**
```xml
<quote>
  <l>content</l>
</quote>
```
**closer**
```xml
<closer>content</closer>
```
**corpsdetexte**
```xml
<p>content</p>
```
**creator**
```xml
<byline>content</byline>
```
**dateline**
```xml
<dateline>content</dateline>
```
**date**
```xml
<dateline>content</dateline>
```
**def**
```xml
<entryFree>
  <def>content</def>
</entryFree>
```
**desc**
```xml
<desc>content</desc>
```
**dd**
```xml
<dl>
  <item>content</item>
</dl>
```
**dt**
```xml
<dl>
  <label>content</label>
</dl>
```
**docauthor**
```xml
<docAuthor>content</docAuthor>
```
**docimprint**
```xml
<docImprint>content</docImprint>
```
**docdate**
```xml
<docDate>content</docDate>
```
**edbibl**
```xml
<bibl>content</bibl>
```
**eg**
```xml
<eg>content</eg>
```
**epigraph**
```xml
<epigraph>
  <p rend="left, bold…">content</p>
</epigraph>
```
**epigraphl**
```xml
<epigraph>
  <l>content</l>
</epigraph>
```
**endnote**
```xml
<note>content</note>
```
**entry**
```xml
<entry>content</entry>
```
**exemple**
```xml
<entryFree>
  <quote>content</quote>
</entryFree>
```
**footnote**
```xml
<p>content</p>
```
**form**
```xml
<entryFree>
  <form>content</form>
</entryFree>
```
**fw**
```xml
<fw>content</fw>
```
**heading**
```xml
<label type="head">content</label>
```
**headsub**
```xml
<head type="sub">content</head>
```
**headsub1**
```xml
<head type="sub">content</head>
```
**headsub2**
```xml
<head type="sub">content</head>
```
**headsub3**
```xml
<head type="sub">content</head>
```
**headsub4**
```xml
<head type="sub">content</head>
```
**h1sub**
```xml
<head type="sub">content</head>
```
**h2sub**
```xml
<head type="sub">content</head>
```
**h3sub**
```xml
<head type="sub">content</head>
```
**h4sub**
```xml
<head type="sub">content</head>
```
**index**
```xml
<index>
  <item>content</item>
</index>
```
**l**
```xml
<l rend="left, bold…">content</l>
```
**lindent**
```xml
<l rend="indent">content</l>
```
**legende**
```xml
<label>content</label>
```
**ln**
```xml
<l>content</l>
```
**lpart**
```xml
<l type="part">content</l>
```
**label**
```xml
<label>content</label>
```
**labeldateline**
```xml
<label type="dateline">content</label>
```
**labelhead**
```xml
<label type="head">content</label>
```
**labelsalute**
```xml
<label type="salute">content</label>
```
**labelspeaker**
```xml
<label type="speaker">content</label>
```
**line**
```xml
<l>content</l>
```
**listheading**
```xml
<dl>
  <label>content</label>
</dl>
```
**listcontent**
```xml
<dl>
  <item>content</item>
</dl>
```
**listcontents**
```xml
<dl>
  <item>content</item>
</dl>
```
**lg**
```xml
<lg>
  <l>content</l>
</lg>
```
**note**
```xml
<notep>
  <p>content</p>
</notep>
```
**opener**
```xml
<opener>content</opener>
```
**p**
```xml
<p rend="left, bold…">content</p>
```
**pb**
```xml
<pb>content</pb>
```
**pbed**
```xml
<pb type="ed">content</pb>
```
**poem**
```xml
<lg>content</lg>
```
**postscript**
```xml
<postscript>
  <p>content</p>
</postscript>
```
**pre**
```xml
<eg>content</eg>
```
**preformattedtext**
```xml
<eg>content</eg>
```
**ptop**
```xml
<p rend="left, bold…">content</p>
```
**q**
```xml
<q>content</q>
```
**quotations**
```xml
<quote>
  <p>content</p>
</quote>
```
**quote**
```xml
<quote>
  <p rend="left, bold…">content</p>
</quote>
```
**quotedateline**
```xml
<quote>
  <dateline>content</dateline>
</quote>
```
**quotel**
```xml
<quote>
  <l>content</l>
</quote>
```
**quotelindent**
```xml
<quote>
  <l rend="indent">content</l>
</quote>
```
**quotesalute**
```xml
<quote>
  <salute>content</salute>
</quote>
```
**quotesigned**
```xml
<quote>
  <signed>content</signed>
</quote>
```
**quotetop**
```xml
<quote>
  <p rend="left, bold…">content</p>
</quote>
```
**refrain**
```xml
<l rend="refrain">content</l>
```
**role**
```xml
<castItem>
  <role>content</role>
</castItem>
```
**roledesc**
```xml
<castItem>
  <roleDesc>content</roleDesc>
</castItem>
```
**said**
```xml
<said>content</said>
```
**salute**
```xml
<salute>content</salute>
```
**salutation**
```xml
<salute>content</salute>
```
**sender**
```xml
<byline>content</byline>
```
**set**
```xml
<set>
  <p>content</p>
</set>
```
**signed**
```xml
<signed>content</signed>
```
**signature**
```xml
<signed>content</signed>
```
**soustitre**
```xml
<head type="sub">content</head>
```
**speaker**
```xml
<speaker>content</speaker>
```
**stage**
```xml
<stage>content</stage>
```
**stageromain**
```xml
<stage rend="not-i">content</stage>
```
**stageitaliquecourt**
```xml
<stage rend="right">content</stage>
```
**stageitalique**
```xml
<stage>content</stage>
```
**subtitle**
```xml
<head type="sub">content</head>
```
**syl1**
```xml
<l met="syl1">content</l>
```
**syl2**
```xml
<l met="syl2">content</l>
```
**syl3**
```xml
<l met="syl3">content</l>
```
**syl4**
```xml
<l met="syl4">content</l>
```
**syl5**
```xml
<l met="syl5">content</l>
```
**syl6**
```xml
<l met="syl6">content</l>
```
**syl7**
```xml
<l met="syl7">content</l>
```
**syl8**
```xml
<l met="syl8">content</l>
```
**syl9**
```xml
<l met="syl9">content</l>
```
**syl10**
```xml
<l met="syl10">content</l>
```
**syl11**
```xml
<l met="syl11">content</l>
```
**syl12**
```xml
<l met="syl12">content</l>
```
**syl13**
```xml
<l met="syl13">content</l>
```
**syl14**
```xml
<l met="syl14">content</l>
```
**texteenvers**
```xml
<lg>
  <l>content</l>
</lg>
```
**term**
```xml
<index>
  <term>content</term>
</index>
```
**title**
```xml
<head>content</head>
```
**titre**
```xml
<head>content</head>
```
**trailer**
```xml
<trailer>content</trailer>
```
**vers**
```xml
<l>content</l>
```
**versrompu**
```xml
<l type="part">content</l>
```
**xml**
```xml
<eg>content</eg>
```
**xr**
```xml
<entryFree>
  <xr>content</xr>
</entryFree>
```
**abbr**
```xml
character… <abbr>content</abbr> …level
```
**add**
```xml
character… <add>content</add> …level
```
**accentuation**
```xml
character… <emph>content</emph> …level
```
**actor**
```xml
character… <actor>content</actor> …level
```
**author**
```xml
character… <author>content</author> …level
```
**affiliation**
```xml
character… <affiliation>content</affiliation> …level
```
**age**
```xml
character… <age>content</age> …level
```
**appelnotedebasdep**
```xml
character… content …level
```
**bibl**
```xml
character… <bibl>content</bibl> …level
```
**biblcar**
```xml
character… <bibl>content</bibl> …level
```
**bulletsymbols**
```xml
character… <glyph>content</glyph> …level
```
**c**
```xml
character… <c>content</c> …level
```
**caption**
```xml
character… <caption>content</caption> …level
```
**char**
```xml
character… <c>content</c> …level
```
**citation**
```xml
character… <quote>content</quote> …level
```
**citation1**
```xml
character… <quote>content</quote> …level
```
**citationhtml**
```xml
character… <title>content</title> …level
```
**code**
```xml
character… <code>content</code> …level
```
**corr**
```xml
character… <corr>content</corr> …level
```
**c-stage**
```xml
character… <stage>content</stage> …level
```
**date**
```xml
character… <date>content</date> …level
```
**definition**
```xml
character… <gloss>content</gloss> …level
```
**del**
```xml
character… <del>content</del> …level
```
**desc**
```xml
character… <desc>content</desc> …level
```
**description**
```xml
character… <seg ana="description">content</seg> …level
```
**descriptioncar**
```xml
character… <seg ana="description">content</seg> …level
```
**distinct**
```xml
character… <distinct>content</distinct> …level
```
**edautoridad**
```xml
character… <name type="authority">content</name> …level
```
**edcita**
```xml
character… <quote>content</quote> …level
```
**edpolemista**
```xml
character… <name type="polemista">content</name> …level
```
**edtitulodeobra**
```xml
character… <title>content</title> …level
```
**email**
```xml
character… <email>content</email> …level
```
**em**
```xml
character… <emph>content</emph> …level
```
**emph**
```xml
character… <emph>content</emph> …level
```
**emphasis**
```xml
character… <emph>content</emph> …level
```
**example**
```xml
character… <q>content</q> …level
```
**exposant**
```xml
character… <sup>content</sup> …level
```
**foreign**
```xml
character… <foreign>content</foreign> …level
```
**geogname**
```xml
character… <geogName>content</geogName> …level
```
**geographie**
```xml
character… <geogName>content</geogName> …level
```
**gloss**
```xml
character… <gloss>content</gloss> …level
```
**htmlcite**
```xml
character… <title>content</title> …level
```
**id**
```xml
character… <id>content</id> …level
```
**ident**
```xml
character… <ident>content</ident> …level
```
**idno**
```xml
character… <idno>content</idno> …level
```
**italic**
```xml
character… <i>content</i> …level
```
**italic1**
```xml
character… <i>content</i> …level
```
**lieu**
```xml
character… <placeName>content</placeName> …level
```
**linenumbering**
```xml
character… <num>content</num> …level
```
**name**
```xml
character… <name>content</name> …level
```
**num**
```xml
character… <num>content</num> …level
```
**pagenumber**
```xml
character… <num>content</num> …level
```
**pagination**
```xml
character… <pb>content</pb> …level
```
**pagenum**
```xml
character… <pb>content</pb> …level
```
**pagenum1**
```xml
character… <pb>content</pb> …level
```
**pb**
```xml
character… <pb>content</pb> …level
```
**persname**
```xml
character… <persName>content</persName> …level
```
**place**
```xml
character… <placeName>content</placeName> …level
```
**placename**
```xml
character… <placeName>content</placeName> …level
```
**q**
```xml
character… <q>content</q> …level
```
**quote**
```xml
character… <quote>content</quote> …level
```
**quotec**
```xml
character… <quote>content</quote> …level
```
**quotecar**
```xml
character… <quote>content</quote> …level
```
**s**
```xml
character… <s>content</s> …level
```
**seg**
```xml
character… <seg>content</seg> …level
```
**sic**
```xml
character… <sic>content</sic> …level
```
**smcap**
```xml
character… <sc>content</sc> …level
```
**smcap1**
```xml
character… <sc>content</sc> …level
```
**sourcetext**
```xml
character… <code>content</code> …level
```
**speakercar**
```xml
character… <speaker>content</speaker> …level
```
**stage**
```xml
character… <stage>content</stage> …level
```
**stagec**
```xml
character… <stage>content</stage> …level
```
**stagecar**
```xml
character… <stage>content</stage> …level
```
**strongemphasis**
```xml
character… <strong>content</strong> …level
```
**tech**
```xml
character… <tech>content</tech> …level
```
**temps**
```xml
character… <date>content</date> …level
```
**teletype**
```xml
character… <code>content</code> …level
```
**term**
```xml
character… <term>content</term> …level
```
**title**
```xml
character… <title>content</title> …level
```
**title0**
```xml
character… <title>content</title> …level
```
**titlec**
```xml
character… <title>content</title> …level
```
**userentry**
```xml
character… <code>content</code> …level
```
**variable**
```xml
character… <term>content</term> …level
```
