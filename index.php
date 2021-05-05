<?php
// le code pilotant la transformation
include(dirname(__FILE__).'/odette.php');

// Soumission en post
if (isset($_POST['post'])) {
  Odette_Odt2tei::doPost();
  exit;
}
?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Odette : Open Document Text &gt; XML/TEI</title>
  </head>
  <body>

    <h1>Odette, convertissez vos textes bureautiques (odt) en <a href="//www.tei-c.org/release/doc/tei-p5-doc/fr/html/REF-ELEMENTS.html">TEI</a></h1>
    
    <p>Sur cette machine, plusieurs projets ont installé un modèle de document :</p>
    <ul>
        <?php
    foreach(glob(dirname(__FILE__)."/*", GLOB_ONLYDIR) as $dir) {
      $basename = basename($dir);
      if ($basename[0] == '.' || $basename[0] == '_') continue;
      echo "<li><a href=\"".$basename."/\">".$basename."</a></li>\n";
    }
     ?>
    </ul>

    <p>Pour plus d’explications : <a href="//resultats.hypotheses.org/267">Glorieux, 2015. <i>Le traitement de textes pour produire des documents structurés (XML/TEI)</i></a>.</p> <p>Renseignements, <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a>.</p>


  </body>
</html>
