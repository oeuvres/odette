<?php
// Soumission en post
if (isset($_POST['post'])) {
  include_once(dirname(__DIR__) . '/php/autoload.php');
  Oeuvres\Odette\OdtChain::doPost(
    @$_POST['format'],
    isset($_POST['download']),
    basename(__DIR__) // template
  );
  exit(0);
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
        <a href="http://www.correspondance-delacroix.fr/" style="padding-left: 10px;"><img src="logo.png" alt="Correspondances d’Eugène Delacroix"></a>
        <i class="tab">Odette (odt ► TEI)</i>
      </header>
      <main>


    <?php
  if (isset($_REQUEST['format'])) $format=$_REQUEST['format'];
  else $format="tei";
    ?>
        <form class="gris" enctype="multipart/form-data" method="POST" name="odt" action="index.php">
          <p>Correspondance de Delacroix, conversion des lettres éditées en traitement de textes vers XML/TEI</p>
          <input type="hidden" name="post" value="post"/>
          <input type="hidden" name="template" value="<?php echo basename(dirname(__FILE__)) ?>"/>
          <div style="margin: 50px 0 20px;">
            <b>1. Fichier odt</b> :
            <input type="file" size="70" name="odt" accept="application/vnd.oasis.opendocument.text"/><!-- ne sort pas ds chrome -->
          </div>

          <div style="margin: 20px 0 20px;">
            <b>2. Format d'export</b> :
                <label title="TEI"><input name="format" type="radio" value="tei" <?php if($format == 'tei') echo ' checked="checked"'; ?>/> tei</label>
              — <label title="OpenDocument Text xml"><input name="format" type="radio" value="html" <?php if($format == 'html') echo ' checked="checked"'; ?>/> html</label>
          </div>

          <div style="margin: 20px 0 40px;">
            <b>3. Résultat</b> :
            <input type="submit" name="view"  value="Voir"/> ou
              <input type="submit" name="download" onclick="this.form" value="Télécharger"/>
          </div>
          <?php
          $odt = glob(dirname(__FILE__)."/*.odt");
          $count = count($odt);
          if ($count) {
            if ($count > 1) $mess = "Exemples de documents";
            else $mess = "Exemple de document";
            echo "<b>".$mess."</b>\n";
            echo "<ul>\n";
            foreach ($odt as $file) {
              $basename = basename($file);
              echo "<li><a href=\"".$basename."\">".$basename."</a></li>\n";
            }
            echo "</ul>\n";
          }
           ?>
          
          <p class="byline">Modèle XML : <a onmouseover="this.href='mailto'+'\x3A'+'gaellelafage'+'\x40'+'gmail.com'" href="#">Gaëlle Lafage</a></p>
          <p class="byline">Développement : <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a></p>
        </form>
      </main>
    </div>
  </body>
</html>
