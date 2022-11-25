<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * MIT License https://opensource.org/licenses/mit-license.php
 * Copyright (c) 2022 frederic.Glorieux@fictif.org
 * Copyright (c) 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 Frederic.Glorieux@fictif.org
 * Copyright (c) 2010 Frederic.Glorieux@fictif.org
 *                    & École nationale des chartes
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Oeuvres\Kit\{File,I18n};
use Exception;

Route::init();

class Route {
    /** root directory of the app when outside site */
    private static $lib_dir;
    /** Href to app resources */
    private static $lib_href;
    /** Home dir where is the index.php answering */
    private static $home_dir;
    /** Home href for routing */
    private static $home_href;
    /** Default php template */
    private static $templates = array();
    /** An html file to include as main */
    private static $main_inc;
    /** A file to include */
    private static $main_contents;
    /** Path relative to the root app */
    private static $url_request;
    /** Split of url parts */
    static $url_parts;
    /** The resource to deliver */
    private static $resource;
    /** Has a routage been done ? */
    static $routed;

    /**
     * Initialisation of static vatriables, done one time on initial loading 
     * cf. Route::init()
     */
    public static function init()
    {
        // suppose path like lib/php/Oeuvres/Kit/Route.php
        self::$lib_dir = dirname(__DIR__, 3). DIRECTORY_SEPARATOR ;
        $url_request = filter_var($_SERVER['REQUEST_URI'], FILTER_SANITIZE_URL);
        $url_request = strtok($url_request, '?'); // old
        // maybe not robust, this should interpret path relative to the webapp
        // domain.com/subdir/verbatim/path/perso -> /path/perso
        $url_prefix = rtrim(dirname($_SERVER['PHP_SELF']), '/\\');
        if ($url_prefix && strpos($url_request, $url_prefix) !== FALSE) {
            $url_request = substr($url_request, strlen($url_prefix));
        }
        self::$url_request = $url_request;
        self::$url_parts = explode('/', ltrim($url_request, '/'));
        // quite robust on most server, wor directory is the answering index.php
        self::$home_dir = getcwd();
        self::$home_href = str_repeat('../', count(self::$url_parts) - 1);
        // get relative path from index.php caller to the root of app to calculate href for resources in this folder
        self::$lib_href = self::$home_href . Filesys::relpath(
            dirname($_SERVER['SCRIPT_FILENAME']), 
            self::$lib_dir
        );
    }

    /**
     * Relative path to the root of the website for href links in templates
     * (where is the initial index.php caller)
     * Set by init()
     */
    static public function home_href(): string
    {
        return self::$home_href;
    }

    /**
     * Absolute file path of the website.
     * Set by init()
     */
    static public function home_dir(): string
    {
        return self::$home_dir;
    }

    /**
     * Relative path to the root of the library containing this Route.php,
     * usually home_href() = lib_href(),
     * but it could be interesting to share this library and
     * resources (ex: css, js…) among different sites.
     * For href links in templates.
     * Set by init()
     */
    static public function lib_href(): string
    {
        return self::$lib_href;
    }

    /**
     * Absolute file path of the library
     * Set by init()
     */
    static public function lib_dir(): string
    {
        return self::$lib_dir;
    }

    /**
     * Return the path requested
     */
    static public function url_request(): string
    {
        return self::$url_request;
    }

    /**
     * Return the last calculated path for resource (maybe ueful for debug)
     */
    static public function resource(): ?string
    {
        return self::$resource;
    }

    /**
     * Try a route with GET method 
     */
    public static function get($route, $resource, $pars=null)
    {
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            self::route($route, $resource, $pars);
        }
    }

    /**
     * Try a route with POST method 
     */
    public static function post($route, $resource, $pars=null)
    {
        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            self::route($route, $resource, $pars);
        }
    }

    /**
     * Try a route
     */
    public static function route(
        string $route, 
        string $resource, 
        ?array $pars=null, 
        ?string $tmpl_key=''
    ):bool {
        // the catchall
        if ($route == "/404") {
            http_response_code(404);
        }
        // check route as a regex
        else if (!self::match($route)) {
            return false;
        }
        // rewrite file destination according to $route url
        preg_match('@'.$route.'@', self::$url_request, $route_match);
        $resource = self::replace($resource, $route_match);
        if (!Filesys::isabs($resource)) {
            // resolve links from welcome page
            $resource = self::$home_dir . $resource;
        }
        // file not found, let chain continue
        if (!file_exists($resource)) {
            self::$resource = $resource;
            return false;
        }
        // modyfy parameters according to route
        if ($pars != null) {
            foreach($pars as $key => $value) {
                $pars[$key] = urldecode(self::replace($value, $route_match));
            }
            $_REQUEST = array_merge($_REQUEST, $pars);
            $_GET = array_merge($_GET, $pars);
        }

        $ext = pathinfo($resource, PATHINFO_EXTENSION);
        // should be routed
        self::$routed = true;
        self::$resource = $resource;

        $tmpl_php = null;
        // default, no template registred, no temple requested, OK
        if ($tmpl_key === '' && count(self::$templates) < 1) {
        }
        // default, no template requested, send first if one exists
        else if ($tmpl_key === '') {
            $tmpl_php = self::$templates[array_key_first(self::$templates)];
        }
        // explitly no template requested
        else if ($tmpl_key === null) {
        }
        else {
            if (count(self::$templates) < 1) {
                throw new Exception(
                    "Developement error.
No templates registred, template '$tmpl_key' not found.
Use Route::template('tmpl_my.php', '$tmpl_key');"
                );
                exit();
            }
            if (!isset(self::$templates[$tmpl_key])) {
                throw new Exception(
                    "Developement error.
Template '$tmpl_key' not found.
Use Route::template('tmpl_my.php', '$tmpl_key');"
                );
                exit();
            }
            $tmpl_php = self::$templates[$tmpl_key];
        }
        // if no template requested include flow
        if ($tmpl_php == null) {
            include_once($resource);
            exit();            
        }
        // html to include in template
        if ($ext == 'html' || $ext == 'htm') {
            self::$main_inc = $resource;
        }
        // supposed to be php 
        else {
            // capture content if it is php direct
            ob_start();
            include_once($resource);
            self::$main_contents = ob_get_contents();
            ob_end_clean();
        }
        // now everything should be OK to render page
        // include the template
        // template should call at least Route::main() to display something 
        include_once($tmpl_php);
        exit();            
    }

    /**
     * Check if a route match url
     */
    public static function match($route):bool
    {
        $route_parts = explode('/', ltrim($route, '/'));
        // too long url
        if (count($route_parts) != count(self::$url_parts)) {
            return false;
        }
        // test if path is matching
        for ($i = 0; $i < count($route_parts); $i++) {
            // escape ^and $ ?
            $search = '/^'.$route_parts[$i].'$/';
            if(!preg_match($search, self::$url_parts[$i])) {
                return false;
            }
        }
        return true;
    }

    /**
     * Populate a page with content
     */
    public static function main(): void
    {
        echo Route::$main_contents;
        if (function_exists('main')) {
            call_user_func('main');
        }
        // a content to include here 
        else if (Route::$main_inc) {
            include_once(Route::$main_inc);
        }
    }

    /**
     * Display a <title> for the page 
     */
    public static function title($default=null): string
    {
        if (function_exists('title')) {
            $title = call_user_func('title');
            if ($title) return $title;
        }
        if ($default) {
            return $default;
        }
        return I18n::_('title');
    }

    /**
     * Display metadata for a page
     */
    public static function meta($default=null): string
    {
        if (function_exists('meta')) {
            $meta = call_user_func('meta');
            if ($meta) return $meta;
        }
        if ($default) {
            return $default;
        }
        return "<title>" . I18n::_('title') . "</title>";
    }

    /**
     * Draw an html tab for a navigation with test if selected 
     */
    public static function tab($href, $text)
    {
        $page = self::$url_parts[0];
        $selected = '';
        if ($page == $href) {
            $selected = " selected";
        }
        if(!$href) {
            $href = '.';
        }
        return '<a class="tab'. $selected . '"'
        . ' href="'. self::home_href(). $href . '"' 
        . '>' . $text . '</a>';
    }

    /**
     * Append a template
     */
    static public function template(
        string $tmpl_php,
        ?string $key=null
    ):void
    {
        if (!Filesys::readable($tmpl_php)) {
            // will send exceptions if template is not readable
            return;
        } 
        else if ($key !== null && $key !== '') {
            self::$templates[$key] = $tmpl_php;
        } 
        else {
            self::$templates[] = $tmpl_php;
        }
    }

    /**
     * Replace $n by $values[$n]
     */
    static public function replace($pattern, $values)
    {
        if (!$values && !count($values)) {
            return $pattern;
        }
        $ret = preg_replace_callback(
            '@\$(\d+)@',
            function ($var_match) use ($values) {
                $n = $var_match[1];
                if (!isset($values[$n])) {
                    return $var_match[0];
                }
                // ensure no slash, to dangerous
                $filename = $values[$n]; 
                $filename = preg_replace('@\.\.|/|\\\\@', '', $filename);
                return $filename;
            },
            $pattern
        );
        return $ret;
    }

}
