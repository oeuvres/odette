<?php
// le code pilotant la transformation
include(dirname(__FILE__).'/Odt2tei.php');

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
    <link rel="stylesheet" type="text/css" href="https://obvil.github.io/theme/obvil.css" />
  </head>
  <body>
    <div id="center">
      <header id="header">
        <h1>
          <a href="../">Développements</a>
        </h1>
        <a class="logo" href="//obvil.paris-sorbonne.fr/developpements/"><img class="logo" src="//svn.code.sf.net/p/obvil/code/theme/img/logo-obvil.png" alt="OBVIL"></a>
      </header>
      <div id="contenu">

    <h1>Odette, convertissez vos textes bureautiques (odt) en <a href="//www.tei-c.org/release/doc/tei-p5-doc/fr/html/REF-ELEMENTS.html">TEI</a></h1>
    <p class="byline">par <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a></p>
    <!--
    <ul>
      <li>Parcourir : chercher un fichier OpenOffice odt sur votre poste</li>
      <li>Voir : montrer le XML produit</li>
      <li>Télécharger : enregistrer le produit sur son poste</li>
    </ul>
    -->


    <?php
  if (isset($_REQUEST['format'])) $format=$_REQUEST['format'];
  else $format="tei";
  /*
        — <label title="OpenDocument Text xml"><input name="format" type="radio" value="ngml" <?php if($format == 'ngml') echo ' checked="checked"'; ?>/> NGML </label>

        — <label title="HTML (Diple)"><input name="format" type="radio" value="html" <?php if($format == 'html') echo ' checked="checked"'; ?>/> HTML </label>
  */
    ?>
    <form enctype="multipart/form-data" method="POST" name="odt" action="index.php">
      <input type="hidden" name="post" value="post"/>
      <div style="margin: 50px 0 20px;">
        <b>1. Fichier odt</b> :
        <input type="file" size="70" name="odt" accept="application/vnd.oasis.opendocument.text"/><!-- ne sort pas ds chrome -->
      </div>

      <div style="margin: 20px 0 20px;">
        <b>2. Format d'export</b> :
            <label title="TEI"><input name="format" type="radio" value="tei" <?php if($format == 'tei') echo ' checked="checked"'; ?>/> tei</label>
          — <label title="OpenDocument Text xml"><input name="format" type="radio" value="odtx" <?php if($format == 'odtx') echo ' checked="checked"'; ?>/> xml odt</label>
          — <label title="OpenDocument Text xml"><input name="format" type="radio" value="html" <?php if($format == 'html') echo ' checked="checked"'; ?>/> html</label>
          <!--
          | <label title="Indiquer le mot clé d'un autre format">Autres formats <input name="local" size="10"/></label>
         -->
      </div>

      <div style="margin: 20px 0 40px;">
        <b>3. Résultat</b> :
        <input type="submit" name="view"  value="Voir"/> ou
          <input type="submit" name="download" onclick="this.form" value="Télécharger"/>
      </div>
    </form>
    <p>Pour plus d’explications : <a href="//resultats.hypotheses.org/267">Glorieux, 2015. <i>Le traitement de textes pour produire des documents structurés (XML/TEI)</i></a>. N'hésitez pas à m’<a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">envoyer</a> vos cas épineux.</p>
      </div>
    </div>
  </body>
</html>
