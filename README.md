# Odette

From text processor odt file, extract all possible information in semantic XML (TEI).

Doc (in French) : http://resultats.hypotheses.org/267

Demo : https://obvil.huma-num.fr/odette/

Maybe used with command line

    usage    : php -f Odt2tei.php "*.odt" dest/?
    "*.odt"  : glob patterns are allowed, but in quotes, to not be expanded by shell "folder/*.odt"
    dest     : optional dest directory

# Styles

The transformation transpose text processor paragraphs (¶) with some direct formatting with semantic, at paragraph level (left, right, center) and character level (italic, small caps…), but most of informaiton is transmitted by user styles. Below a list of styles known and their xml/tei transposition. Unknown styles are kept in a @rend attribute. Styles are here shown normalized as ascii lower case letter, but real life styles may contain capitals, accents, spaces, or punctuation. For example, **quotesalute** could appears as *&lt;Quote, Salute&gt;* for the user in its word processor (a style for a letter in a citation). 

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
**bibl**
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
**closer**
```xml
<closer>content</closer>
```
**dateline**
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
**entry**
```xml
<entry>content</entry>
```
**fw**
```xml
<fw>content</fw>
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
**lg**
```xml
<lg>
  <l>content</l>
</lg>
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
**postscript**
```xml
<postscript>
  <p>content</p>
</postscript>
```
**q**
```xml
<q>content</q>
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
**speaker**
```xml
<speaker>content</speaker>
```
**stage**
```xml
<stage>content</stage>
```
**term**
```xml
<index>
  <term>content</term>
</index>
```
**trailer**
```xml
<trailer>content</trailer>
```
**abbr**
```xml
character… <abbr>content</abbr> …level
```
**add**
```xml
character… <add>content</add> …level
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
**bibl**
```xml
character… <bibl>content</bibl> …level
```
**c**
```xml
character… <c>content</c> …level
```
**code**
```xml
character… <code>content</code> …level
```
**corr**
```xml
character… <corr>content</corr> …level
```
**date**
```xml
character… <date>content</date> …level
```
**del**
```xml
character… <del>content</del> …level
```
**distinct**
```xml
character… <distinct>content</distinct> …level
```
**email**
```xml
character… <email>content</email> …level
```
**emph**
```xml
character… <emph>content</emph> …level
```
**geogname**
```xml
character… <geogName>content</geogName> …level
```
**gloss**
```xml
character… <gloss>content</gloss> …level
```
**name**
```xml
character… <name>content</name> …level
```
**num**
```xml
character… <num>content</num> …level
```
**pb**
```xml
character… <pb>content</pb> …level
```
**persname**
```xml
character… <persName>content</persName> …level
```
**placename**
```xml
character… <placeName>content</placeName> …level
```
**stage**
```xml
character… <stage>content</stage> …level
```
**title**
```xml
character… <title>content</title> …level
```
