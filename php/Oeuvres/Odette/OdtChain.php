<?php // encoding="UTF-8"
/**
 * Part of Odette https://github.com/oeuvres/odette
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 * Copyright (c) 2021 Frederic.Glorieux@fictif.org
 * Copyright (c) 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 Frederic.Glorieux@fictif.org
 * © 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
 * © 2007 Frederic.Glorieux@fictif.org
 * © 2006 Frederic.Glorieux@fictif.org et ajlsm.com
 */

/**
 * <h1>OpenDocument text transform</h1>
 *
 * LGPL  http://www.gnu.org/licenses/lgpl.html
 * © 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL
 * © 2012 Frederic.Glorieux@fictif.org
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

declare(strict_types=1);

namespace Oeuvres\Odette;

use Exception, DOMDocument, ZipArchive;
use Psr\Log\{LoggerInterface, LoggerAwareInterface, LogLevel, NullLogger};
use Oeuvres\Kit\{File, LoggerCli, Web, Xml};


/**
 * OpenDocumentText for TEI.
 */
class OdtChain implements LoggerAwareInterface
{
    /** available formats */
    private static $formats = array(
        "tei" => ".xml",
        "odtx" => ".odt.xml",
        "html" => ".html",
    );
    /** Somewhere to log in  */
    private $logger;
    /** keep original odt FilePath for a file context */
    private $odt_file;
    /** FileName without extension for generated contents */
    private $name;
    /** Current dom document on which work is done by methods */
    private $dom;
    /** debug mode */
    private $debug;
    /**
     * Get available formats for this exporter
     */
    public static function formats():array
    {
        return self::$formats;
    }

    public static function home():string
    {
        return dirname(__DIR__, 3).'/';
    }

    /**
     * Constructor, instanciations
     */
    function __construct(string $odt_file, ?LoggerInterface $logger = null)
    {
        if (!extension_loaded("zip")) {
            throw new Exception('PHP zip extension required. Check your php.ini');
        }
        File::readable($odt_file);

        if ($logger == null) $logger = new NullLogger();
        $this->setLogger($logger);
        $this->odt_file = $odt_file;
        // load odt as xml doc
        $this->odtx();
    }

    public function setLogger(LoggerInterface $logger)
    {
        $this->logger = $logger;
    }

    /**
     * instanciate a dom document from an odt zip
     */
    public function odtx()
    {
        $zip = new ZipArchive();
        if (!($zip->open($this->odt_file) === TRUE)) {
            throw new Exception ($this->odt_file . ' seems not a valid zip archive');
        }
        // concat XML files sxtracted, without XML prolog
        $xml = '<?xml version="1.0" encoding="UTF-8"?>
<office:document xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0">
';
        $content = $zip->getFromName('meta.xml');
        $xml .= substr($content, strpos($content, "\n"));
        $content = $zip->getFromName('styles.xml');
        $xml .= substr($content, strpos($content, "\n"));
        $content = $zip->getFromName('content.xml');
        $xml .= substr($content, strpos($content, "\n"));
        $xml .= '
</office:document>';
        $zip->close();
        // some indent
        $xml = preg_replace(
            array("@<(/?table:|office:|text:h |/?text:list |text:list-item|text:p )@"),
            array("\n<$1"),
            $xml
        );
        $this->dom = Xml::loadXml($xml);

    }


    /**
     * Format loaded dom
     */
    public function format(?string $format = 'tei', ?string $tmpl_dir = null)
    {
        if ($format == 'odtx');
        else if ($format == 'tei') {
            $this->tei($tmpl_dir);
        } 
        else if ($format == 'html') {
            // format html from a clean TEI
            $this->tei($tmpl_dir);
            // find a transfo pack for tei to html
            $pars = array(
                'xslbase' => null,
                'theme' => 'https://oeuvres.github.io/teinte/theme/',
                // 'theme' => '../../teinte/', // dev
            );
            $xsl = dirname(self::home()) . '/teinte/xsl/tei_html.xsl';
            if (!is_readable($xsl)) {
                $xsl = "https://oeuvres.github.io/teinte/xsl/tei_html.xsl";
            }
            $this->dom = Xml::transformToDoc(
                $xsl,
                $this->dom,
                $pars
            );
        } 
        else {
            throw new Exception('Format $format not yet supported. Please create a ticket to ask for a new feature: <a href="https://github.com/oeuvres/odette/issues">GitHub oeuvres/odette</a> ');
        }
        $this->dom->formatOutput = true;
        $this->dom->substituteEntities = true;
        // $this->dom->normalize(); // no, will not allow &gt;
    }

    /**
     * Save result to file, in desired format
     */
    public function save($dst_file, $format=null, $tmpl_dir=null)
    {
        $dstInfo = pathinfo($dst_file);
        // used by the tei formatter for mediadir (ex: pictures extracted from odt)
        $this->name = $dstInfo['filename'];
        if ($format == 'odtx') {
            $this->pictures(dirname($dst_file) . '/Pictures');
        } else {
            $this->pictures(dirname($dst_file) . '/' . $this->name . '-img/');
        }
        if (!$format) $format = 'tei';
        $this->format($format, $tmpl_dir);
        File::mkdir(dirname($dst_file));
        $this->dom->save($dst_file);
    }
    /**
     * Images extraction
     */
    private function pictures($dst_dir)
    {
        $dst_dir = rtrim($dst_dir, '/') . '/';
        $zip = new ZipArchive();
        $zip->open($this->odt_file);
        $entries = array();
        for ($i = $zip->numFiles - 1; $i >= 0; $i--) {
            if (strpos($zip->getNameIndex($i), 'Pictures/') !== 0 && strpos($zip->getNameIndex($i), 'media/') !== 0) continue;
            $entries[] = $zip->getNameIndex($i);
        }
        if (!count($entries)) return false;
        File::cleandir($dst_dir);
        foreach ($entries as $entry) file_put_contents($dst_dir . basename($entry), $zip->getFromName($entry));
    }
    /**
     * Output TEI
     */
    private function tei(?string $tmpl_dir=null)
    {
        $start = microtime(true);
        $tmpl_xml = null;
        $tmpl_xsl = null;
        $tmpl_sed = null;
        do {
            if ($tmpl_dir === null) break;
            $tmpl_dir = realpath($tmpl_dir);
            if (!$tmpl_dir) break;
            $tmpl_dir = $tmpl_dir . DIRECTORY_SEPARATOR;
            $tmpl_name = basename($tmpl_dir);
            $tmpl_xml = $tmpl_dir . $tmpl_name . ".xml";
            // Exception if template not available or silently go out ?
            if (!is_readable($tmpl_xml)) $tmpl_xml = null;
            $tmpl_xsl = $tmpl_dir . $tmpl_name . ".xsl";
            if (!is_readable($tmpl_xsl)) $tmpl_xsl = null;
            $tmpl_sed = $tmpl_dir . $tmpl_name . ".sed";
            if (!is_readable($tmpl_sed)) $tmpl_sed = null; 
        } while(false);
        if (!$tmpl_xml) $tmpl_xml = __DIR__. "/default.xml";
        // some normalisation of oddities
        $this->dom = Xml::transformToDoc(
            dirname(__FILE__) . '/odt-norm.xsl', 
            $this->dom
        );
        // odt > tei
        $this->dom = Xml::transformToDoc(
            __DIR__ . '/odt2tei.xsl',
            $this->dom,
            array('media_dir' => $this->name . '-img/')
        );

        $this->dom->preserveWhiteSpace = true;
        $this->dom->formatOutput = false; // after multiple tests, keep it
        $this->dom->substituteEntities = true;

        // regularisation of tags segments, ex: spaces tagged as italic
        $xml = $this->dom->saveXML();
        $preg = self::sed_preg(file_get_contents(__DIR__ . '/tei.sed'));
        $xml = preg_replace($preg[0], $preg[1], $xml);
        $this->dom->loadXML($xml);

        // normalize windows path for xsltproc
        $tmpl_xml = "file:///" . str_replace(DIRECTORY_SEPARATOR, "/", $tmpl_xml);

        // TEI regularisations and model fusion
        $this->dom = Xml::transformToDoc(
            __DIR__ . '/tei-post.xsl',
            $this->dom,
            array("template" => $tmpl_xml)
        );
        // apply regex for this template, may break xml
        if ($tmpl_sed) {
            $xml = $this->dom->saveXML();
            $preg = self::sed_preg(file_get_contents($tmpl_sed));
            $xml = preg_replace($preg[0], $preg[1], $xml);
            $this->dom->loadXML($xml);
        }
        // last custom transformation 
        if ($tmpl_xsl) {
            $this->dom = Xml::transformToDoc(
                $tmpl_xsl,
                $this->dom,
                array(
                    'filename' => $this->name,
                )
            );
        }
    }

    /**
     * Build a search/replace regexp table from a sed script
     */
    public static function sed_preg($script)
    {
        $search = array();
        $replace = array();
        $lines = explode("\n", $script);
        $lines = array_filter($lines, 'trim');
        foreach ($lines as $l) {
            if ($l[0] != 's') continue;
            $delim = $l[1];
            list($a, $re, $rep, $flags) = explode($delim, $l);
            $mod = 'u';
            if (strpos($flags, 'i') !== FALSE) $mod .= "i"; // ignore case ?
            $search[] = $delim . $re . $delim . $mod;
            $replace[] = preg_replace(
                array('/\\\\([0-9]+)/', '/\\\\n/', '/\\\\t/'), 
                array('\\$$1', "\n" ,"\t"), 
                $rep
            );
        }
        return array($search, $replace);
    }

    /**
     *  Apply code to an uploaded File, or to a default file
     */
    public static function doPost(
        ?string $format = null, 
        ?bool $download = false,
        ?string $tmpl_dir = null 
    ) {
        if (!array_key_exists($format, self::$formats)) $format = "tei";
        $ext = self::$formats[$format];
        $upload = Web::upload();
        if ($upload && count($upload) && isset($upload['tmp_name'])) {
            $odt_file = $upload['tmp_name'];
            $name = pathinfo($upload['name'], PATHINFO_FILENAME) . $ext;
        }
        else {
            $odt_file = __DIR__ . "/default.odt";
            $name = "odette" . $ext;
        }

        $odt = new OdtChain($odt_file);
        $odt->format($format, $tmpl_dir);
        $xml = $odt->dom->saveXML();

        // headers
        if ($download) {
            if ($format == 'html') {
                header("Content-Type: text/html; charset=UTF-8");
                $ext = "html";
            } else {
                header("Content-Type: text/xml");
                $ext = 'xml';
            }
            header('Content-Disposition: attachment; filename="' . $name . '.' . $ext . '"');
            header('Content-Description: File Transfer');
            header('Expires: 0');
            header('Cache-Control: ');
            header('Pragma: ');
            flush();
        } 
        else {
            if ($format == 'html') {
                header("Content-Type: text/html; charset=UTF-8");
            }
            // chrome do not like text/xml
            else {
                $xml = preg_replace('@<\?xml-stylesheet.*@', '', $xml);
                header("Content-Type: text/plain; charset=UTF-8");
            }
        }
        echo $xml;
        exit;
    }


    /**
     * Apply code from Cli
     */
    public static function cli(?LoggerInterface $logger = null)
    {
        global $argv;
        if ($logger == null) $logger = new LoggerCli(LogLevel::INFO);
        Xml::setLogger($logger);
        $help = '
Transfrom odt files with styles in XML (ex: TEI)

    php odette.php (options)? "../work/*.odt"

PARAMETERS: 1-n files or globs

OPTIONS
-d dst_dir   : destination directory for generated files
-t tmpl_dir  : a specific template directory, known ones';
$templates = "templates/";
$glob = glob(self::home() . "templates/*", GLOB_ONLYDIR | GLOB_MARK);
foreach ($glob as $dir) {
    $help .= "\n    " . File::relpath(getcwd(), $dir);
}
        $help .= '
-f, --force  : force deletion of destination file
-x, --debug  : debug trace transformation steps
-h, --help   : show this help message

--tei        : default, export odt as XML/TEI
--html       : export odt as html
--odtx       : export native odt xml
';

        $shortopts = "";
        $shortopts .= "d:"; // output directory
        $shortopts .= "t:"; // template
        $shortopts .= "f"; // force transformation
        $shortopts .= "x"; // debug trace
        $shortopts .= "h"; // help
        $longopts  = array(
            "debug",
            "force",
            "help",
            "html",
            "odtx",
            "tei",
        );
        $options = getopt($shortopts, $longopts, $ipar);
        if (
               count($argv) < 2 
            || array_key_exists("help", $options) 
            || array_key_exists("h", $options)
        ) {
            exit($help);
        }
        $tmpl_dir = null;
        if (array_key_exists("t", $options)) {
            $tmpl_dir = rtrim($options['t'], '/\\');
            if (!is_dir($tmpl_dir)) {
                $dir = self::home().'templates/'.$tmpl_dir;
                if (is_dir($dir)) {
                    $tmpl_dir = $dir;
                }
                else {
                    exit(
                        "\nTemplate directory not found: \"$tmpl_dir\"\n"
                    );
                }
            }
        }
        $force = array_key_exists("f", $options) || array_key_exists("force", $options);
        $debug = array_key_exists("x", $options) || array_key_exists("debug", $options);
        $dst_dir = null;
        if (array_key_exists('d', $options)) {
            $dst_dir = File::normdir($options['d']);
        }

        $format = "tei";
        foreach (self::$formats as $f => $v) {
            if (!array_key_exists($f, $options)) continue;
            $format = $f;
        }

        $ext = self::$formats[$format];
        $count = 0;
        for ($i = $ipar; $i < count($argv); $i++) {
            $glob = $argv[$i];
            foreach (glob($glob) as $odt_file) {
                $count++;
                $name = pathinfo($odt_file,  PATHINFO_FILENAME);
                if (isset($dst_dir)) {
                    $dst_file = $dst_dir . $name . $ext;
                }
                else {
                    $dst_file = dirname($odt_file) . '/' . $name . $ext;
                }
                $logger->info("$count. $odt_file > $dst_file");
                if (file_exists($dst_file) && !$force) {
                    $logger->warning("OVERWRITE WARNING  $dst_file already exists, it will not be overwritten, can't know if human value was added");
                    continue;
                }
                $odt = new OdtChain($odt_file);
                $odt->save($dst_file, $format, $tmpl_dir);
            }
        }
    }
}
