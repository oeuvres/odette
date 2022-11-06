<?php
// Soumission en post
if (isset($_POST['post'])) {
  include_once(dirname(__DIR__, 2) . '/php/autoload.php');
  Oeuvres\Odette\OdtChain::doPost(
    @$_POST['format'],
    isset($_POST['download']),
    __DIR__, // tmpl_dir
  );
  exit(0);
}
?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Odette (odt ▶ TEI), Rougemont</title>
    <link rel="stylesheet" media="all" onload="this.media='all'" href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital@0;1&amp;family=Fira+Sans:ital,wght@0,300;0,400;0,500;1,300;1,400;1,500&amp;display=swap">
    <style>
body,
html {
  width: 100%;
  margin: 0;
  padding: 0;
  background: #fff;
  color: #000;
}

a {
  color: #cf1308;
}

body {
  font-family: 'Fira Sans', 'Open Sans', 'Roboto', sans-serif-light, sans-serif;
}

h1 {
  font-family: 'EB Garamond', serif;
}

#header {
  position: relative;
  width: 100%;
  padding: 0;
  /* box-shadow: 0px 10px 10px #fff; */
}

#header_ban {
  position: relative;
  height: 240px;
  padding: 0;
  margin: 0;
  color: #fff;
}

#header_ban>picture {
  position: absolute;
}

#header_ban>picture>img {
  height: 240px;
}

#header_ban>picture>img {
  width: 100%;
}

#header_row {
  position: relative;
  display: flex;
  width: 100%;
}
#header_row {
  background-image: url('ddr_portrait.png');
  background-size: 140px;
  background-repeat: no-repeat;
  background-position: -10px -10px;
}

.container,
#center {
  width: 967px;
  margin-left: auto;
  margin-right: auto;
  position: relative;
  text-align: left;
  min-height: 650px;
  _height: 650px;
}

#portrait {
  height: 200px;
  position: relative;
  display: inline-block;
  width: auto;
  max-width: 500px;
  min-width: 270px;
}

#portrait a {
  display: inline-block;
}

#portrait img {
  width: 250px;
  padding-top: 10px;
}

#moto {
  display: block;
  position: absolute;
  top: 60px;
  left: 120px;
  line-height: 1.2;
  color: #000;
  font-size: 14px;
}


.tab {
  color: #FFFFFF;
  display: inline-block;
  border-bottom: solid 4px #FFFFFF;
  font-family: Georgia , Arial, Helvetica, sans-serif;
  font-style: italic;
}

#main {
  padding: 15px 40px;
}

form.gris {
  background: linear-gradient(0deg, #fefefe 0%, #ccc 100%);
  padding: 10px 50px 20px 50px;
}

.byline {
  text-align: right;
}
    </style>
  </head>
  <body>
    <header id="header" class="top accueil">
      <div id="header_ban">
        <picture>
          <source srcset="header_ban.webp" type="image/webp">
          <img src="header_ban.png" alt="Denis de Rougemont, l’œuvre complète en ligne">
        </picture>
        <div class="container" id="header_container">
          <div id="header_row">
            <div id="portrait">
              <a href="https://www.unige.ch/rougemont">
                <img class="signature" src="ddr-signature.svg" alt="Denis de Rougemont, signature">
              </a>
              <div id="moto">
                Denis de Rougemont,
                <br>l’intégrale en ligne
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
    <div id="center">
    <div id="contenu">
      <h1>Odette (odt ▶ TEI), Rougemont</h1>
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
