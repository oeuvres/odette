<?php
// Soumission en post
if (isset($_POST['post'])) {
  include_once(dirname(__DIR__, 2) . '/php/autoload.php');
  Oeuvres\Odette\OdtChain::doPost(
    @$_POST['format'],
    isset($_POST['download']),
    __DIR__, // tmpl_dir
  );
  exit;
}
?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Odette (odt ▶ TEI)</title>
    <style>
body, html {
  width: 100%;
  margin: 0;
}


body {
  padding-top: 15px;
  padding-bottom: 15px;
  font-family: Arial, Helvetica,sans-serif;
}

#center {
  width: 967px;
  margin-left: auto;
  margin-right: auto;
  position: relative;
  text-align: left;
  min-height: 650px;
  _height: 650px;
}


#main {
  padding: 15px 40px;
}

form.gris {
  background-color: rgba(33, 33, 33, 0.3);
  padding: 10px 50px 20px 50px;
}

.byline {
  text-align: right;
}
    </style>
  </head>
  <body>
    <div id="center">
    <header id="header">
      Odette (odt ▶ TEI)
    </header>
    <div id="contenu">
      
    <?php
  if (isset($_REQUEST['format'])) $format=$_REQUEST['format'];
  else $format="tei";
    ?>
    <form class="gris" enctype="multipart/form-data" method="POST" name="odt" action="index.php">
      <input type="hidden" name="post" value="post"/>
      <input type="hidden" name="model" value="<?php echo basename(dirname(__FILE__)) ?>"/>
      <div style="margin: 50px 0 20px;">
        <b>1. Fichier odt</b> :
        <input type="file" size="70" name="odt" accept="application/vnd.oasis.opendocument.text"/>
      </div>

      <div style="margin: 20px 0 20px;">
        <b>2. Format d'export</b> :
            <label title="TEI"><input name="format" type="radio" value="tei" <?php if($format == 'tei') echo ' checked="checked"'; ?>/> tei</label>
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

    <p class="byline">Développement <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a></p>
      </div>
    </div>
  </body>
</html>
