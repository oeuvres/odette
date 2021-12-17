<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Exception, DOMDocument, XSLTProcessor;
use Psr\Log\LoggerInterface;
use Psr\Log\NullLogger;

/**
 * A set of well configured method for XML manipulation
 * with record of some odd tricks,
 * and xsl parsing cache for repeated transformations.
 * code convention https://www.php-fig.org/psr/psr-12/
 */
Xml::init();
class Xml
{
    /** XSLTProcessors */
    private static $transcache = array();
    /** get a temp dir */
    private static $tmpdir;
    /** libxml options for DOMDocument */
    const LIBXML_OPTIONS = 
          LIBXML_NOENT 
        | LIBXML_NONET 
        | LIBXML_NSCLEAN 
        | LIBXML_NOCDATA
        // | LIBXML_NOWARNING  // no warn for <?xml-model
    ;
    private static LoggerInterface $logger;

    public static function init()
    {
        if (!extension_loaded("xsl")) {
            throw new Exception('PHP xsl extension required. Check your php.ini');
        }
        self::$logger = new NullLogger();
        libxml_use_internal_errors(true); // keep XML error for this process
    }

    public static function setLogger(LoggerInterface $logger)
    {
        self::$logger = $logger;
    }

    /**
     * Get a DOM document with best options from a file path
     */
    public static function load(string $srcFile): ?DOMDocument
    {
        $dom = self::domSkel();
        // $dom->recover=true; // no recover, display errors
        // suspend error reporting, libxml messages are better
        $ret = @$dom->load($srcFile, self::LIBXML_OPTIONS);
        self::logLibxml(libxml_get_errors());
        if (!$ret) return null;
        $dom->documentURI = realpath($srcFile);
        return $dom;
    }

    /**
     * Output the very informative libxml messages by the logger
     */
    public static function logLibxml(array $errors)
    {
        foreach ($errors as $error) {
            $message = "";
            if ($error->file) {
                $message .= $error->file;
            }
            $message .= "  " . ($error->line) . ":" . ($error->column) . " \t";
            $message .= "err:" . $error->code . " — ";
            $message .= trim($error->message);
            /* xslt error could be other than message
            if ($error->code == 1) { // <xsl:message>
                self::$logger->info("<xsl:message> " . trim($error->message));
            } */
            if ($error->level == LIBXML_ERR_WARNING) {
                self::$logger->warning($message);
            }
            else if ($error->level == LIBXML_ERR_ERROR) {
                self::$logger->error($message);
            }
            else if ($error->level ==  LIBXML_ERR_FATAL) {
                self::$logger->critical($message);
            }
        }
        libxml_clear_errors();
    }

    /**
     * Returns a DOM object
     */
    public static function loadXml(string $xml): DOMDocument
    {
        $dom = self::domSkel();
        // suspend error reporting, libxml messages are better
        $ret = $dom->loadXml($xml, self::LIBXML_OPTIONS);
        self::logLibxml(libxml_get_errors());
        // self::$logger->debug('$dom->load()=' . var_export($ret, true));
        // exception ?
        if (!$ret) return null;
        return $dom;
    }


    /**
     * Return an empty dom with options
     */
    private static function domSkel(): DOMDocument
    {
        $dom = new DOMDocument();
        $dom->preserveWhiteSpace = false;
        $dom->formatOutput = true;
        $dom->substituteEntities = true;
        return $dom;
    }

    /**
     * xsl:tranform, result as a dom document
     */
    public static function transformToDoc(
        string $xslfile, 
        DOMDocument $dom, 
        array $pars = null
    ) {
        return self::transform(
            $xslfile,
            $dom,
            null, // local code to say not a a string
            $pars
        );
    }

    /**
     * xsl:tranform, result as an XML string
     */
    public static function transformToXml(
        string $xslfile, 
        DOMDocument $dom, 
        array $pars = null
    ) {
        return self::transform(
            $xslfile,
            $dom,
            "", // local code to say fill the string
            $pars
        );
    }
    /**
     * xsl:tranform, result to a file
     */
    public static function transformToUri(
        string $xslfile, 
        DOMDocument $dom,
        string $uri,
        array $pars = null
    ) {
        return self::transform(
            $xslfile,
            $dom,
            $uri,
            $pars
        );
    }
    
    /**
     * An xslt transformer with cache
     * TOTHINK : deal with errors
     */
    private static function transform(
        string $xslFile, 
        DOMDocument $dom,
        ?string $dst,
        array $pars = null
    ) {
        $key = realpath($xslFile);
        // cache compiled xsl
        if (!isset(self::$transcache[$key])) {
            File::readable($xslFile, __METHOD__."()");
            $trans = new XSLTProcessor();
            $trans->registerPHPFunctions();
            // allow generation of <xsl:document>
            if (defined('XSL_SECPREFS_NONE')) {
                $prefs = constant('XSL_SECPREFS_NONE');
            } 
            else if (defined('XSL_SECPREF_NONE')) {
                $prefs = constant('XSL_SECPREF_NONE');
            }
            else {
                $prefs = 0;
            }

            if(method_exists($trans, 'setSecurityPrefs')) {
                $oldval = $trans->setSecurityPrefs($prefs);
            } /* historic
            else if (method_exists($trans, 'setSecurityPreferences')) {
                $oldval = $trans->setSecurityPreferences($prefs);
            } */
            else {
                ini_set("xsl.security_prefs",  $prefs);
            }
            $xsldom = self::load($xslFile);
            if (!$trans->importStyleSheet($xsldom)) {
                self::logLibxml(libxml_get_errors());
                throw new Exception("XSLT, impossible to compile " . $xslFile."\n");
            }
            self::$transcache[$key] = $trans;
        }
        $trans = self::$transcache[$key];
        // add params
        if(isset($pars) && count($pars)) {
            foreach ($pars as $key => $value) {
                $trans->setParameter("", $key, $value);
            }
        }

        // TODO here, set a good logger for xsl

        // return a DOM document for efficient piping
        if ($dst === null) {
            $ret = $trans->transformToDoc($dom);
        }
        // return XML as a string
        else if ($dst === '') {
            $ret =$trans->transformToXml($dom);
        }
        // write to uri
        else {
            File::mkdir(dirname($dst));
            $trans->transformToUri($dom, $dst);
            $ret = $dst;
        }
        // here we should have XSL message only
        $errors = libxml_get_errors();
        if (count($errors)) self::logLibxml($errors);

        // reset parameters ! or they will kept on next transform if transformer is reused
        if(isset($pars) && count($pars)) {
            foreach ($pars as $key => $value) {
                $trans->removeParameter("", $key);
            }
        }
        return $ret;
    }
    /**
     * Replace tags of html file by spaces,
     * to get text with same offset index of words
     * allowing indexation and highlighting. Keep line breaks for line numbers.
     * Support of some html5 tag to strip not indexable content.
     * 2x faster than a char loop
     */
    static public function detag(string $html):string
    {
        // preg_replace_callback is safer and 2x faster than the /e modifier
        $html = preg_replace_callback(
            array(
                // s flag so that '.' could match \n
                // .*? ungreedy
                '@<!.*?>@s', // exclude doctype and comments
                '@<\?.*?\?>@s', // exclude PI
                '@<(head|header|footer|nav|noindex)[ >].*?</\1>@s', // suppress nav, let <aside> for notes
                '@<(small|tt|a)[^>]*>[0-9]+</\1>@', // line or note of number
                '@<a class="noteref".*?</a>@', // suppress footnote call
                '@<[^>]+>@' // wash tags
            ),
            array(__CLASS__, 'blank'),
            $html
        );
        return $html;
    }
    /**
     * blanking a string, keeping new lines
     */
    private static function blank(string $string):string
    {
        if (is_array($string)) $string = $string[0];
        // if (strpos($string, '<tt class="num')===0) return "_NUM_".str_repeat(" ", strlen($string) - 5);
        return preg_replace("/[^\n]/", " ", $string);
    }

}
