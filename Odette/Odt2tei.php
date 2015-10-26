<?php // encoding="UTF-8"
/**
<h1>OpenDocument text transform</h1>

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2006 Frederic.Glorieux@fictif.org et ajlsm.com
© 2007 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@ficitif.org 
© 2013 Frederic.Glorieux@ficitif.org et LABEX OBVIL

<p>
Pilot to work with OpenOffice Text files. Steps:
</p>

<ul>
  <li>unzip odt</li>
  <li><a href="odtNorm.xsl">normalisation of some odt oddities</a> (XSL)</li>
  <li><a href="odt2tei.xsl">structuration of visual formatting</a> (XSL)</li>
  <li><a href="tei.sed">typographical normalisation</a> (regex)</li>
  <li><a href="teiPost.xsl">some semantic interpretations (ex: index)</a> (XSL)</li>
</ul>



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
else if (php_sapi_name() == "cli") Odette_Odt2tei::cli();
// direct http call, work
else Odette_Odt2tei::doPost();



/**

OpenDocumentText vers TEI.
 */
class Odette_Odt2tei {
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
  function __construct($odtfile) {
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
  public function format($format, $pars=array()) {
    if ($format=='odtx');
    else if ($format=='tei') {
      $this->tei();
    }
    else if ($format == 'html') {
      // format html from a clean TEI
      $this->tei();
      // find a transfo pack for tei to html
      $xsl=dirname(__FILE__).'/tei2html.xsl';
      if (!file_exists($xsl)) $xsl=dirname(dirname(__FILE__)).'/Pactei/tei2html.xsl';
      if (!file_exists($xsl)) $xsl="http://svn.code.sf.net/p/obvil/code/Pactei/tei2html.xsl";
      $this->transform($xsl, $pars);
    }
    else {
      return;
      echo "Format $format not yet supported. Please create a ticket to ask for a new feature : <a href=\"http://sourceforge.net/p/obvil/tickets/\">OBVIL SourceForge project</a> ";
      exit;
    }
    $this->doc->formatOutput=true;
    $this->doc->substituteEntities=true;
    // $this->doc->normalize(); // no, will not allow &gt;
  }
  
  /**
   * Save result to file, in desired format
   */
  public function save($destfile, $format=null, $pars=array()) {
    $pathinfo=pathinfo($destfile);
    if (file_exists($destfile) && !isset($pars['force'])) {
      _log("Odette, destination file already exists: $destfile");
    }
    // used by the tei formatter for mediadir (ex: pictures extracted from odt)
    $this->destname=$pathinfo['filename'];
    if ($format=='odtx') {
      $this->pictures(dirname($destfile).'/Pictures');
    }
    else {
      $this->pictures(dirname($destfile).'/'.$this->destname.'-img/');
    }
    if (!$format) $format = 'tei';
    $this->format($format, $pars);
    $this->doc->save($destfile);
  }
  
  /**
   * Get xml in the desired format
   */
  public function saveXML($format, $destfile=null, $pars=array()) {
    $this->destname=pathinfo($destfile, PATHINFO_FILENAME);
    $this->format($format, $pars);
    return $this->doc->saveXML();
  }
  private function pictures($destdir) {
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
    $this->loadXML($xml);
    
    $zip->close();
  }
  /**
   * Output TEI
   */
  private function tei() {
    $pars=array();
    $pars['filename']=$this->destname;
    $pars['mediadir']=$this->destname.'-img/';
    // some normalisation of oddities
    $start = microtime(true);
    $this->transform(dirname(__FILE__).'/odt-norm.xsl');
    // _log("odt-norm: " . (microtime(true) - $start));
    // $this->doc->formatOutput=true;
    // odt > tei
    $start = microtime(true);
    $this->transform(dirname(__FILE__).'/odt2tei.xsl', $pars);
    
    // _log("odt2tei: " . (microtime(true) - $start));
    $start = microtime(true);
    
    // indent here produce too much problems, use only for debug
    $this->doc->formatOutput=true;
    $this->doc->substituteEntities=true;
    $xml=$this->doc->saveXML();

    // regularisation of tags segments, ex: spaces tagged as italic
    $preg=self::sed_preg(file_get_contents(dirname(__FILE__).'/tei.sed'));
    $xml = preg_replace($preg[0], $preg[1], $xml);
    $this->loadXML($xml);
    $this->doc->formatOutput=true;
    
    // _log("tei.sed: " . (microtime(true) - $start)); 2 s./Mo
    $start = microtime(true);
    

    /* 
    echo $xml;
    echo '<!-- ',print_r($this->message, true), ' -->'; // for debug show now xlml errors
    exit;
    */
    
    // header("Connection: Keep-alive");
    // echo 'Mem peak: ', memory_get_peak_usage(), ' true? ', memory_get_peak_usage(true), "\n";
    // print_r($this->message); // for debug show now xlml errors
    // xsl step to put some tei oddities like <hi rend="i"> (instead of <i>)
    $this->transform(dirname(__FILE__).'/tei-post.xsl');
    // echo 'Mem peak: ', memory_get_peak_usage(), ' true? ', memory_get_peak_usage(true), "\n";
    
    // _log("tei-post: " . (microtime(true) - $start));
  }

  /**
   * Build a search/replace regexp table from a sed script
   */
  public static function sed_preg($script) {
    $search=array();
    $replace=array();
    $lines=explode("\n", $script);
    $lines=array_filter($lines, 'trim');
    foreach($lines as $l){
      if ($l[0] != 's') continue;
      list($a,$s,$r)=explode($l[1], $l);
      $search[]=$l[1].$s.$l[1].'u';
      $replace[]=preg_replace('/\\\\([0-9]+)/', '\\$$1', $r);
    }
    return array($search, $replace);
  }


  /**
   * Load xml as dom
   */
  private function loadXML($xml) {
    $this->message=array();
    $oldError=set_error_handler(array($this,"err"), E_ALL);
    // if not set here, no indent possible for output
    $this->doc = new DOMDocument("1.0", "UTF-8");
    $this->doc->preserveWhiteSpace = false;
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
  public function err( $errno, $errstr, $errfile, $errline, $errcontext) {
    if(strpos($errstr, "xmlParsePITarget: invalid name prefix 'xml'") !== FALSE) return;
    $this->message[]=$errstr;
  }

  
  /**
   * Transformation, applied to current doc
   */
  private function transform($xslFile, $pars=null) {
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
    $odt=new Odette_Odt2tei($file);
    echo $odt->saveXML($format, $filename);
    exit;
  }
  /**
   * Apply code from Cli
   */
  public static function cli() {
    $formats='odtx|tei|html';
    array_shift($_SERVER['argv']); // shift first arg, the script filepath
    if (!count($_SERVER['argv'])) exit('
    usage    : php -f Odt.php $formats ? src.odt
    format?  : optional dest format, default tei, others may be odtx, html
    src.odt  : glob patterns are allowed, but in quotes, to not be expanded by shell "folder/*.odt"
  ');
    $format="tei";
    while ($arg=array_shift($_SERVER['argv'])) {
      if ($arg[0]=='-') $format=substr($arg,1);
      else if(preg_match("/^($formats)\$/",$arg)) {
        $format=$arg;
      }
      else if(!isset($srcGlob)) {
        $srcGlob=$arg;
      }
      /*
      $destdir=array_shift($_SERVER['argv']);
      if (!$destdir) $destdir='';
      $destdir=rtrim($destdir, '/').'/';
      if (!file_exists($destdir)) mkdir($destdir, 0775, true);
      */
    }
    $ext=".$format";
    if ($ext=='.tei') $ext=".xml";
    $count = 0;
    foreach(glob($srcGlob) as $srcfile) {
      $count++;
      $destfile=dirname($srcfile).'/'.basename($srcfile, ".odt").$ext;
      _log("$count. $srcfile > $destfile");
      if (file_exists($destfile)) {
        _log("  $destfile already exists, it will not be overwritten");
        continue;
      }
      $odt=new Odette_Odt2tei($srcfile);
      $odt->save($destfile, $format);
    }
  }
}


?>
