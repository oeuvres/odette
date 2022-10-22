# Galenus personalization

## Word processor operations

* Suppress bold
* Suppress lists
* Style Title level 1 = text/body/div\[@type='edition'\]/div\[@subtype='chapter|book|…'\]
* 
# BAD

## Inside 1 header, use line break if line break is needed (ctrl+enter, ↵); NOT paragraph (enter, ¶), 2 paras = 2 headers

![image](https://user-images.githubusercontent.com/5686231/197334921-3e1f3825-ea6c-4bf2-96ec-21e4e3a24469.png)

M E N O D O T I (with spaces between) is not 1 word, but 8 words

![image](https://user-images.githubusercontent.com/5686231/197335072-84f491ec-46be-4440-be0d-03fe716dafd1.png)

## Specific Galenus, first title is not covering all chapters, style “Title 1” like another chapter.

~~~~
<div type="edition" xml:lang="grc" n="urn:cts:greekLit:tlg0057.tlg001.1st1K-grc1">
  <pb n="1"/>
  <div type="textpart" subtype="chapter" n="1">
  <head>ΓΑΛΗΝΟΥ ΠΑΡΑΦΡΑΣΤΟΥ
    <lb/>ΤΟΥ ΜΗΝΟΔΟΤΟΥ
    <lb/>ΠΡΟΤΡΕΠΤΙΚΟΣ ΛΟΓΟΣ ΕΠΙ ΤΑΣ
    <lb/>ΤΕΧΝΑΣ.</head>
  <p>Εἰ μὲν μηδόλως λόγου μέτεστι τοῖς ἀλόγοις <lb/>ὀνομαζομένοις ζώοις, ἄδηλόν
~~~~

## Verify title Hierarchy

![image](https://user-images.githubusercontent.com/5686231/197335245-932b12bf-2876-4ac6-a90c-6481a19d7455.png)

* forgotten cap 10
* Odd title. « Jam ut inteiligas, et omnia, quorum studio tenentur isti, nihil habere utilitatis, audi rursus, quae dicit, li libet; ». ABBYY or MS.Word bad inference. To correct, apply normal style.
