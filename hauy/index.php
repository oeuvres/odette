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
    <title>Odette (odt ► TEI), Hauy</title>
    <link rel="preconnect" href="https://fonts.gstatic.com"/>
    <link href="https://fonts.googleapis.com/css2?family=Lato&amp;display=swap" rel="stylesheet"/>
    <style>
* {
  box-sizing: border-box;
}
header {
  background: #ffffff;
}
body {
  margin: 0;
  background: #f7f7f7;
  color: #26458a;
  font-family: Lato, Helvetica, sans-serif;
}
footer,
header {
  text-align: center;
}
footer,
header nav {
  height: 90px;
  background: #26458a;
  color: #fff;
  font-weight: bold;
}

header nav {
  display: flex;
  align-items: center;
  justify-content: center;

}

footer a,
header nav a {
  color: #fff;
  border: none;
  text-decoration: none;
}

main,
div.sep {
  width: 67%;
  margin: 0 auto;
}
div.sep {
  text-align: center;
  align-items: center;
  -webkit-box-align: center;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 90px;
}
div.sep > div {
  display: inline-block;
  margin: 0 10px;
}
div.sep:before,
div.sep:after {
    display: block;
    content: "";
    border-bottom: 0;
    -webkit-box-flex: 1;
    -ms-flex-positive: 1;
    flex-grow: 1;
    border-top: 1.9px solid #fff;
}
    </style>
  </head>
  <body>
    <div id="center">
      <header id="header">
        <a href="https://obtic.sorbonne-universite.fr/"><img width="368px" src="obtic.svg"/></a>
        <nav>
        <a href="https://www.avh.asso.fr/">Association Valentin Haüy</a>
        </nav>
      </header>
      <main>


    <?php
  if (isset($_REQUEST['format'])) $format=$_REQUEST['format'];
  else $format="tei";
    ?>
        <form class="gris" enctype="multipart/form-data" method="POST" name="odt" action="index.php">
          <input type="hidden" name="post" value="post"/>
          <input type="hidden" name="model" value="<?php echo basename(dirname(__FILE__)) ?>"/>
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
          
      </main>
      <footer>
        <div class="sep">
          <div>
            <a href="https://obtic.sorbonne-universite.fr/"><img align="middle" width="50px" src="otc.svg"/></a>
          </div>
        </div>
      </footer>
    </div>
  </body>
</html>
