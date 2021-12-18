<?php
error_reporting(-1);
include_once __DIR__ . '/php/autoload.php';
if (isset($_POST['post'])) {
  // print_r(\Oeuvres\Odette\OdtChain::formats());
  \Oeuvres\Odette\OdtChain::doPost(
    @$_POST['format'],
    isset($_POST['download'])
  );
  exit;
}
?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Odette : Open Document Text &gt; XML/TEI</title>
    <link rel="stylesheet" href="https://oeuvres.github.io/teinte/theme/layout.css"/>
  </head>
  <body class="article">
    <header>
    <h1>Odette: odt ▶ <a href="//www.tei-c.org/release/doc/tei-p5-doc/fr/html/REF-ELEMENTS.html">TEI</a></h1>
    <p>[en] Edit your text corpus in your word processor
      (LibreOffice, Microsoft.Word),
       apply styles abd get them back in XML/TEI with Odette.</p>
    <p>[fr] Éditez votre corpus au traitement de textes (LibreOffice, Microsoft.Word), utilisez une feuille de styles, Odette vous les rendra en XML/TEI.</p>
    </header>
    <?php
  if (isset($_REQUEST['format'])) $format=$_REQUEST['format'];
  else $format="tei";
    ?>
    <form class="gris" enctype="multipart/form-data" method="POST" name="odt" action="index.php">
      <input type="hidden" name="post" value="post"/>
      <input type="hidden" name="model" value="<?php echo basename(dirname(__FILE__)) ?>"/>
      <div style="margin: 50px 0 20px;">
        <b>1. document.odt</b> :
        <input type="file" size="70" name="odt" accept="application/vnd.oasis.opendocument.text"/>
      </div>

      <div style="margin: 20px 0 20px;">
        <b>2. export, format</b> :
            <label title="TEI"><input name="format" type="radio" value="tei" <?php if($format == 'tei') echo ' checked="checked"'; ?>/> tei</label>
          — <label title="OpenDocument Text xml"><input name="format" type="radio" value="html" <?php if($format == 'html') echo ' checked="checked"'; ?>/> html</label>
          <!--
          | <label title="Indiquer le mot clé d'un autre format">Autres formats <input name="local" size="10"/></label>
         -->
      </div>

      <div style="margin: 20px 0 40px;">
        <b>3. result</b> :
        <input type="submit" name="view"  value="👁 look"/> —
          <input type="submit" name="download" onclick="this.form" value="⇓ download"/>
      </div>
    </form>

    <p>[fr] Odette, customisations pour des projets éditoriaux</p>
    <ul>
        <?php
    foreach(glob(dirname(__FILE__)."/*", GLOB_ONLYDIR) as $dir) {
      $basename = basename($dir);
      if ($basename[0] == '.' || $basename[0] == '_') continue;
      if (!is_readable($dir."/".$basename.".xml")) continue;
      echo "<li><a href=\"".$basename."/\">".$basename."</a></li>\n";
    }
     ?>
    </ul>

    <p>Odette est un programme qui enregistre 15 années d’expérience,
    avec des dizaines de projets scientifiques
    (romans, théâtre, correspondances, essais, presse ancienne…), 
    et plusieurs milliers 
    de livres, afin d’extraire du format odt le plus possible de structure
    sémantique en XML/TEI.
    Le code source est totalement libre (<a href="https://github.com/oeuvres/odette">GitHub</a>).</p>
    <p>Le principe consiste à rédiger dans le traitement de texte avec une
    feuille de style adaptée à son projet éditorial et scientifique, et à
    retrouver ses styles sous forme d’éléments XML/TEI. La liste des styles
    supportés est raffraîchie automatiquement sur le
    <a href="https://github.com/oeuvres/odette">README.me</a> du projet.
    Il en résulte une liste d’environ 80 mots clés,
    c’est-à-dire les éléments TEI
    les plus fréquents dans un corpus textuel, ce qui dépasse l’attention
    immédiate d’un éditeur qui se concentre sur le texte. C’est pour cette raison que vous trouverez ci-dessous des projets récents qui ont utilisé
    Odette avec des modèles de documents plus ajustés à un besoin.
    Si vous visitez par exemple le formulaire <a href="delacroix/">Delacroix</a>,
    Odette a été personnalisée pour éditer la correspondance du peintre,
    en ajoutant par exemple une entête &lt;teiHeader&gt; spécifique au projet.
    Si votre projet ne concerne pour l’instant que quelques documents, 
    le plus simple est de prendre le modèle <a href="default/">par défaut<a>, et de corriger soi-même ce qui manque dans le &lt;teiHeader&gt;.
  </p>
    <p>Tous les modèles utilisent le même noyau de 80 styles, les ajustements ne concernent que des post-traitements spécifiques. Tout ce qui a été 
      développé de générique à l’occasion d’un projet a été reversé le tronc
      du code et est disponible dans le modèle <a href="default/">par défaut<a>.
    </p>

    <p>Pour plus d’explications : <a href="//resultats.hypotheses.org/267">Glorieux, 2015. <i>Le traitement de textes pour produire des documents structurés (XML/TEI)</i></a>.</p> <p>Renseignements, <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a>.</p>


  </body>
</html>
