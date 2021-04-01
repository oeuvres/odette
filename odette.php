<?php // encoding="UTF-8"
/**
 * <h1>OpenDocument text transform</h1>
 *
 * LGPL  http://www.gnu.org/licenses/lgpl.html
 * © 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL
 * © 2012 Frederic.Glorieux@fictif.org
 * © 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
 * © 2007 Frederic.Glorieux@fictif.org
 * © 2006 Frederic.Glorieux@fictif.org et ajlsm.com
 *
 * Pilot to work with OpenOffice Text files. Steps:
 *
 * <ul>
 *   <li>unzip odt</li>
 *   <li><a href="odtNorm.xsl">normalisation of some odt oddities</a> (XSL)</li>
 *   <li><a href="odt2tei.xsl">structuration of visual formatting</a> (XSL)</li>
 *   <li><a href="tei.sed">typographical normalisation</a> (regex)</li>
 *   <li><a href="teiPost.xsl">some semantic interpretations (ex: index)</a> (XSL)</li>
 * </ul>
 *
 */


set_time_limit(-1);
// register global if not called in Omeka context
if (!function_exists('_log')) {
  function _log($message, $priority=null) {
    if (defined('STDERR')) {
      fwrite(STDERR, $message."\n");
      return;
    }
  }
}
// included file, do nothing
if (isset($_SERVER['SCRIPT_FILENAME']) && basename($_SERVER['SCRIPT_FILENAME']) != basename(__FILE__));
else if (isset($_SERVER['ORIG_SCRIPT_FILENAME']) && realpath($_SERVER['ORIG_SCRIPT_FILENAME']) != realpath(__FILE__));
// direct command line call, work
else if (php_sapi_name() == "cli") Odette::cli();
// direct http call, work
else Odette::doPost();



/**
 * OpenDocumentText vers TEI.
 */
class Odette {
  /** keep original odt FilePath for a file context */
  private $srcfile;
  /** FileName without extension for generated contents */
  private $destname;
  /** un log */
  private $log;
  /** A dom document to load an XSL */
  private $xsl;
  /** Current dom document on which work is done by methods */
  private $doc;
  /** Current  */
  private $proc;
  /** Array of messages */
  private $message;

  /**
   * Constructor, instanciations
   */
  function __construct($odtfile)
  {
    $this->srcfile=$odtfile;
    $pathinfo=pathinfo($odtfile);
    $this->xsl = new DOMDocument("1.0", "UTF-8");
    // register functions ?
    $this->proc = new XSLTProcessor();
    // load odt as xml doc
    $this->odtx();
  }
  /**
   * Format loaded dom
   */
  public function format($format='tei', $model=null)
  {
    if ($format=='odtx');
    else if ($format=='tei') {
      $this->tei($model);
    }
    else if ($format == 'html') {
      // format html from a clean TEI
      $this->tei();
      // find a transfo pack for tei to html
      $xsl=dirname(__FILE__).'/tei2html.xsl';
      if (!file_exists($xsl)) $xsl=dirname(dirname(__FILE__)).'/Teinte/tei2html.xsl';
      if (!file_exists($xsl)) $xsl="http://oeuvres.github.io/Teinte/tei2html.xsl";
      $this->transform($xsl, $pars);
    }
    else {
      return;
      echo 'Format $format not yet supported. Please create a ticket to ask for a new feature : <a href="http://github.com/oeuvres/Odette/issues">OBVIL GitHub project</a> ';
      exit;
    }
    $this->doc->formatOutput=true;
    $this->doc->substituteEntities=true;
    // $this->doc->normalize(); // no, will not allow &gt;
  }

  /**
   * Save result to file, in desired format
   */
  public function save($destfile, $format=null, $model=null)
  {
    $pathinfo=pathinfo($destfile);
    // used by the tei formatter for mediadir (ex: pictures extracted from odt)
    $this->destname=$pathinfo['filename'];
    if ($format=='odtx') {
      $this->pictures(dirname($destfile).'/Pictures');
    }
    else {
      $this->pictures(dirname($destfile).'/'.$this->destname.'-img/');
    }
    if (!$format) $format = 'tei';
    $this->format($format, $model);
    $this->doc->save($destfile);
  }

  /**
   * Get xml in the desired format
   */
  public function saveXML($format, $model)
  {
    $this->format($format, $model);
    $xml = $this->doc->saveXML();
    if ($format == "fragment") {
      $xml = preg_replace('@<\?xml version="1.0" encoding="UTF-8"\?>|</?fragment([^>]+)?>@', '', $xml);
      $xml = trim($xml);
    }
    return $xml;
  }
  /**
   * Images extraction
   */
  private function pictures($destdir)
  {
    $zip = new ZipArchive();
    $zip->open($this->srcfile);
    $entries=array();
    for($i = $zip->numFiles -1; $i >= 0 ; $i--) {
      if (strpos($zip->getNameIndex($i), 'Pictures/') !== 0 && strpos($zip->getNameIndex($i), 'media/') !== 0) continue;
      $entries[]=$zip->getNameIndex($i);
    }
    if (!count($entries)) return false;
    $destdir=rtrim($destdir, '/').'/';
    if (!is_dir($destdir)) mkdir($destdir, 0775, true);
    @chmod($dest, 0775);  // let @, if www-data is not owner but allowed to write
    foreach($entries as $entry) file_put_contents($destdir.basename($entry), $zip->getFromName($entry));
  }
  /**
   * instanciate a dom document from the zip
   */
  public function odtx() {
    if (!extension_loaded("zip")) {
      echo '<p class="error">PHP zip extension required</p>';
      return;
    }
    $zip = new ZipArchive();
    if (!($zip->open($this->srcfile)===TRUE)) {
      echo '<p class="error">'.$this->srcfile.' not found.</p>';
      return false;
    }
    // suppress xml prolog in extracted files
    $xml='<?xml version="1.0" encoding="UTF-8"?>
<office:document xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0">
';
    $content=$zip->getFromName('meta.xml');
    $xml .= substr($content, strpos($content, "\n"));
    $content = $zip->getFromName('styles.xml');
    $xml .= substr($content, strpos($content, "\n"));
    $content = $zip->getFromName('content.xml');
    $xml .= substr($content, strpos($content, "\n"));
    $xml .='
</office:document>';
    // load doc
    // some indent
    $xml = preg_replace(
      array("@<(/?table:|office:|text:h |/?text:list |text:list-item|text:p )@"),
      array("\n<$1"),
      $xml
    );
    
    $this->loadXML($xml);

    $zip->close();
  }
  /**
   * Output TEI
   */
  private function tei($model=null)
  {
    $pars=array();
    $pars['filename'] = $this->destname;
    $pars['mediadir'] = $this->destname.'-img/';
    $pars['output'] = "body";
    // some normalisation of oddities
    $start = microtime(true);
    $this->transform(dirname(__FILE__).'/odt-norm.xsl');

    // odt > tei
    $this->transform(dirname(__FILE__).'/odt2tei.xsl', $pars);
    
    $this->doc->preserveWhiteSpace = true;
    $this->doc->formatOutput = false; // after multiple tests, keep it
    $this->doc->substituteEntities=true;
    
    $xml=$this->doc->saveXML();

    // regularisation of tags segments, ex: spaces tagged as italic
    $preg=self::sed_preg(file_get_contents(dirname(__FILE__).'/tei.sed'));
    $xml = preg_replace($preg[0], $preg[1], $xml);
    
    $model_xml = realpath(dirname(__FILE__)."/models/".$model."/".$model.".xml");

    if (!file_exists($model_xml)) {
      fwrite(STDERR, "Model \"$model\" not found, use \"default\" instead.\n");
      $model_xml = realpath(dirname(__FILE__)."/models/default/default.xml");
    }
    if (!file_exists($model_xml)) throw new Exception("XML TEI model not found:".$model_xml);
    $pars=array();
    $pars['model'] = $model_xml;
    
    $this->loadXML($xml);
    // TEI regularisations and model fusion
    $this->transform(dirname(__FILE__).'/tei-post.xsl', $pars);
    // specific normalisations ?
    $model_xsl = realpath(dirname(__FILE__)."/models/".$model."/".$model.".xsl");
    if (file_exists($model_xsl)) {
      $this->transform($model_xsl);
    }
  }

  /**
   * Build a search/replace regexp table from a sed script
   */
  public static function sed_preg($script)
  {
    $search = array();
    $replace=array();
    $lines=explode("\n", $script);
    $lines=array_filter($lines, 'trim');
    foreach($lines as $l){
      if ($l[0] != 's') continue;
      $delim = $l[1];
      list($a, $re, $rep, $flags)=explode($delim, $l);
      $mod = 'u';
      if (strpos($flags, 'i') !== FALSE) $mod .= "i"; // ignore case ?
      $search[]=$delim.$re.$delim.$mod;
      $replace[]=preg_replace('/\\\\([0-9]+)/', '\\$$1', $rep);
    }
    return array($search, $replace);
  }


  /**
   * Load xml as dom
   */
  private function loadXML($xml)
  {
    $this->message=array();
    $oldError=set_error_handler(array($this,"err"), E_ALL);
    // if not set here, no indent possible for output
    $this->doc = new DOMDocument("1.0", "UTF-8");
    $this->doc->preserveWhiteSpace = true; // keep white spaces !!! De[ ]Man
    $this->doc->recover=true;
    $this->doc->loadXML($xml, LIBXML_NOENT | LIBXML_NONET | LIBXML_NSCLEAN | LIBXML_NOCDATA | LIBXML_COMPACT);
    restore_error_handler();
    if (count($this->message)) {
      $this->doc->appendChild($this->doc->createComment("Error recovered in loaded XML document \n". implode("\n", $this->message)."\n"));
    }
  }
  /**
   * record errors in a log variable, need to be public to used by loadXML
   */
  public function err($errno, $errstr, $errfile, $errline, $errcontext)
  {
    if(strpos($errstr, "xmlParsePITarget: invalid name prefix 'xml'") !== FALSE) return;
    $this->message[]=$errstr;
  }


  /**
   * Transformation, applied to current doc
   */
  private function transform($xslFile, $pars=null)
  {
    // filePath should be correct, only internal resources are used here
    $this->xsl->load($xslFile);
    $this->proc->importStyleSheet($this->xsl);
    // transpose params
    if($pars && count($pars)) foreach ($pars as $key => $value) $this->proc->setParameter('', $key, $value);
    // we should have no errors here
    $this->doc=$this->proc->transformToDoc($this->doc);
  }

  /**
   *  Apply code to an uploaded File, or to a default file
   */
  public static function doPost($format='', $download=null, $defaultFile=null) {
    if (!isset($defaultFile)) $defaultFile=dirname(__FILE__).'/test.odt';

    do {
      // a file seems uploaded
      if(count($_FILES)) {
        reset($_FILES);
        $tmp=current($_FILES);
        if($tmp['tmp_name']) {
          $file=$tmp['tmp_name'];
          if ($tmp['name']) $filename=substr($tmp['name'], 0, strrpos($tmp['name'], '.'));
          else $filename="odt2tei";
          break;
        }
        else if($tmp['name']){
          echo $tmp['name'],' seems bigger than allowed size for upload in your php.ini : upload_max_filesize=',ini_get('upload_max_filesize'),', post_max_size=',ini_get('post_max_size');
          return false;
        }
      }
      if ($defaultFile) {
        $file=$defaultFile;
        $filename=substr(basename($file), 0, strrpos(basename($file), '.'));
      }
    } while (false);


    if($format);
    else if(isset($_REQUEST['format'])) $format=$_REQUEST['format'];
    else $format="tei";
    if(isset($download));
    else if(isset($_REQUEST['download'])) $download=true;
    else $download=false;

    // headers
    if ($download) {
      if ($format == 'html') {
        header ("Content-Type: text/html; charset=UTF-8");
        $ext="html";
      }
      else {
        header("Content-Type: text/xml");
        $ext='xml';
      }
      header('Content-Disposition: attachment; filename="'.$filename.'.'.$ext.'"');
      header('Content-Description: File Transfer');
      header('Expires: 0');
      header('Cache-Control: ');
      header('Pragma: ');
      flush();
    }
    else if ($format == 'html') header ("Content-Type: text/html; charset=UTF-8");
    // chrome do not like text/xml
    else {
      header ("Content-Type: text/xml;");
    }
    $odt=new Odette($file);
    echo $odt->saveXML($format, $filename);
    exit;
  }
  
  public static function models()
  {
    $glob = glob(dirname(__FILE__)."/models/*", GLOB_ONLYDIR|GLOB_MARK);
    $models = array();
    foreach($glob as $dir)
    {
      $name = basename($dir);
      if (!file_exists($dir.$name.".xml")) continue;
      $models[$name] = $dir;
    }
    return $models;
  }
  
  
  /**
   * Apply code from Cli
   */
  public static function cli() {
    $formats=array(
      "tei"=>".xml",
      "odtx"=>".odt.xml",
      "html"=>".html",
    );
    $models = self::models();
    
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit("
    usage     : php -f odette.php (".implode('|', array_keys($formats)).")? (".implode('|', array_keys($models)).")? destdir/? *.odt

    format?   : optional dest format, default is xml/tei, odtx = xml/odt, html with Teinte
    model?    : a TEI skeleton available for this installation in models/my_model/my_model.xml
    destdir/? : optional destination directory, ending by slash
    *.odt     : glob patterns are allowed, with or without quotes

");

    $format=trim($_SERVER['argv'][0], '- ');
    if(isset($formats[$format])) array_shift($_SERVER['argv']);
    else $format = "tei";

    $model = trim($_SERVER['argv'][0], '- ');
    if(isset($models[$model])) array_shift($_SERVER['argv']);
    else $model = null;
    
    $lastc = substr($_SERVER['argv'][0], -1);
    if ('/' == $lastc || '\\' == $lastc) {
      $destdir = array_shift($_SERVER['argv']);
      $destdir = rtrim($destdir, '/\\').'/';
      if (!file_exists($destdir)) {
        mkdir($destdir, 0775, true);
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
      }
    }
    $ext = $formats[$format];
    $count = 0;
    foreach ($_SERVER['argv'] as $glob) {
      foreach(glob($glob) as $srcfile) {
        $count++;
        if (isset($destdir)) $destfile = $destdir.pathinfo($srcfile,  PATHINFO_FILENAME).$ext;
        else $destfile=dirname($srcfile).'/'.pathinfo($srcfile,  PATHINFO_FILENAME).$ext;
        _log("$count. $srcfile > $destfile");
        if (file_exists($destfile)) {
          _log("  $destfile already exists, it will not be overwritten, can't know if human value added");
          continue;
        }
        $odt=new Odette($srcfile);
        $odt->save($destfile, $format, $model);
      }
    }
  }
}

class Web
{
  /** web parameters */
  static $pars;
  /**
   * Handle repeated parameters values, especially in multiple select.
   * $_REQUEST propose a strange PHP centric interpretation of http protocol, with the bracket keys
   * &lt;select name="var[]">
   *
   * $query : optional, a "query string" ?cl%C3%A9=%C3%A9%C3%A9&param=valeur1&param=&param=valeur2
   * return : Array (
   *   "clé" => array("éé"),
   *   "param" => array("valeur1", "", "valeur2")
   *)
   */
  public static function pars($name = FALSE, $expire = 0, $pattern = null, $default = null, $query = FALSE)
  {
    // store params array extracted from query
    if (!self::$pars) {
      if (!$query) $query = Web::query();
      // populate an array
      self::$pars = array();
      $a = explode('&', $query);
      foreach ($a as $p) {
        if (!$p) continue;
        if (!strpos($p,'=')) continue;
        list($k, $v) = preg_split('/=/', $p);
        $k = urldecode($k);
        $v = urldecode($v);
        // seems ISO, translate accents
        if (preg_match('/[\xC0-\xFD]/', $k+$v)) {
          $k = utf8_encode ($k);
          $v = utf8_encode ($v);
        }
        self::$pars[$k][] = $v;
      }
    }
    // no key requested, return all params, do not store cookies
    if (!$name) return self::$pars;
    // a param is requested, values found
    else if (isset(self::$pars[$name])) $pars = self::$pars[$name];
    // no param for this name
    else $pars = array();


    // no cookie store requested
    if(!$expire);
    // if empty ?, delete cookie
    else if (count($pars)==1 && !$pars[0]) {
      setcookie($name);
    }
    // if a value, set cookie, do not $_COOKIE[$name] = $value
    else if (count($pars)) {
      // if a number
      if ($expire > 60) setcookie($name, serialize($pars), time()+ $expire);
      // session time
      else setcookie($name, serialize($pars));
    }
    // if cookie stored, load it
    else if(isset($_COOKIE[$name])) $pars = unserialize($_COOKIE[$name]);
    // validate
    if ($pattern) {
      $newPars = array();
      foreach($pars as $value) if (preg_match($pattern, $value)) $newPars[] = $value;
      $pars = $newPars;
    }
    // default
    if (count($pars));
    else if (!$default);
    else if (is_array($default)) $pars = $default;
    else $pars = array($default);
    return $pars;
  }
  
    /**
   * build a clean query string from get or post, especially
   * to get multiple params from select
   *
   * query: ?A=1&A=2&A=&B=3
   * return: ?A=1&A=2&B=3
   * $keep=true : keep empty params -> ?A=1&A=2&A=&B=3
   * $exclude=array() : exclude some parameters
   */
  public static function query($keep = false, $exclude = array(), $query = null)
  {
    // query given as param
    if ($query) $query = preg_replace('/&amp;/', '&', $p1);
    // POST
    else if ($_SERVER['REQUEST_METHOD'] == "POST") {
      if (isset($HTTP_RAW_POST_DATA)) $query = $HTTP_RAW_POST_DATA;
      else $query = file_get_contents("php://input");
    }
    // GET
    else $query = $_SERVER['QUERY_STRING'];
    // exclude some params
    if (count($exclude)) $query = preg_replace('/&('.implode('|',$exclude).')=[^&]*/', '', '&'.$query);
    // delete empty params
    if (!$keep) $query = preg_replace(array('/[^&=]+=&/', '/&$/'), array('', ''), $query.'&');
    return $query;
  }
}


?>
