<?php

// Soumission en post, lancer la transformation
if (isset($_POST['post'])) {
  include(dirname(dirname(__FILE__)).'/odette.php');
  Odette::doPost();
  exit;
}
?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Odette (odt ► TEI), Delacroix</title>
    <link rel="stylesheet" type="text/css" href="delacroix.css" />
  </head>
  <body>
    <div id="center">
    <header id="header">
      <a href="http://www.correspondance-delacroix.fr/"><img src="logo.png" alt="Correspondances d’Eugène Delacroix"></a>
      <i class="tab">Odette (odt ► TEI)</i>
    </header>
    <div id="contenu">
      <p>Correspondance de Delacroix, conversion des lettres éditées en traitement de textes vers XML/TEI</p>
    
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
    ?>
    <form class="gris" enctype="multipart/form-data" method="POST" name="odt" action="index.php">
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
    <p class="byline">par <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a></p>
      </div>
    </div>
  </body>
</html>
