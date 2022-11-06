<?php

/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Exception, InvalidArgumentException, ZipArchive;

/**
 * code convention https://www.php-fig.org/psr/psr-12/
 */

class File
{
    static function normdir($dir)
    {
        $dir = rtrim(trim($dir), "\\/");
        if (!$dir) {
            return "";
        }
        return $dir . DIRECTORY_SEPARATOR;
    }

    /**
     * Check if a file is writable, if it does not exists
     * go to the parent folder to test if it is possible to create.
     */
    public static function writable(string $file, ?string $source = null): bool
    {
        while (!file_exists($file)) { // if not file exists, go up to parents
            $file = dirname($file);
        }
        if (is_link($file)) {
            throw new InvalidArgumentException(
                "\n" . $source . "\n    \"$file\" is a link, maybe dangerous to write in\n"
            );
        }
        if (is_writable($file)) return true;
        if (is_readable($file)) {
            throw new InvalidArgumentException(
                "\n" . $source . "\n    \"$file\" file exists but not writable\n"
            );
        }
        self::readable($file, $source);
        return true;
    }

    /**
     * Is a file path absolute ?
     */
    public static function isabs(string $path): bool
    {
        // true if file exists
        if (realpath($path) == $path) {
            return true;
        }
        // ./* relpath
        if (strlen($path) == 0 || '.' === $path[0]) {
            return false;
        }
        // Windows drive pattern
        if (preg_match('#^[a-zA-Z]:\\\\#', $path)) {
            return true;
        }
        // A path starting with / or \ is absolute
        return ('/' === $path[0] || '\\' === $path[0]);
    }

    /**
     * Get relative path between 2 absolute file path
     */
    public static function relpath(string $from, string $to)
    {
        // some compatibility fixes for Windows paths
        $from = is_dir($from) ? rtrim($from, '\/') . '/' : $from;
        $to   = is_dir($to)   ? rtrim($to, '\/') . '/'   : $to;
        // normalize paths
        $from = preg_replace('@[\\\\/]+@', '/', $from);
        $to   = preg_replace('@[\\\\/]+@', '/', $to);

        $from     = explode('/', $from);
        $to       = explode('/', $to);
        $relpath  = $to;

        foreach ($from as $depth => $dir) {
            // find first non-matching dir
            if ($dir === $to[$depth]) {
                // ignore this directory
                array_shift($relpath);
            } else {
                // get number of remaining dirs to $from
                $remaining = count($from) - $depth;
                if ($remaining > 1) {
                    // add traversals up to first matching dir
                    $padLength = (count($relpath) + $remaining - 1) * -1;
                    $relpath = array_pad($relpath, $padLength, '..');
                    break;
                } else {
                    $relpath[0] =  $relpath[0];
                }
            }
        }
        $href =  implode('/', $relpath);
        // if path with ../
        // we can have things like galenus/../verbatim/verbatim.css
        // is it safe ? let’s try
        $re = '@\w[^/]*/\.\./@';
        while(preg_match($re, $href)) {
            $href = preg_replace($re, '', $href);
        }
        return $href;
    }

    /**
     * Check existence of a file to read,
     * and send informative Exception if it’s not OK.
     */
    public static function readable(string $file, ?string $source = null): bool
    {
        if (is_readable($file)) return true;
        // shall we log here or break by exception ?
        if ($source) $source = "\n" . $source;
        if (is_file($file)) {
            throw new InvalidArgumentException(
                $source . "\n    \"$file\" file exist but not readable \n"
            );
        }
        if (file_exists($file)) {
            throw new InvalidArgumentException(
                $source . "\n    \"$file\" path exits but is not a file\n"
            );
        }
        throw new InvalidArgumentException(
            $source . "\n    \"$file\" file not found\n"
        );
    }
    /**
     * A safe mkdir dealing with rights
     */
    static function mkdir(string $dir): bool
    {
        if (is_dir($dir)) {
            return false;
        }
        if (!mkdir($dir, 0775, true)) {
            throw new Exception("Directory not created: " . $dir);
        }
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
        return true;
    }

    /**
     * Ensure an empty dir with no contents, create it if not exist
     */
    static public function cleandir(string $dir): ?string
    {
        File::writable($dir);
        // attempt to create the folder we want empty
        if (!file_exists($dir)) {
            self::mkdir($dir);
            return realpath($dir);
        }
        self::rmdir($dir, true);
        touch($dir); // change timestamp
        return realpath($dir);
    }

    /**
     * Recursive deletion of a directory
     * If $keep = true, base directory is kept with its acl
     */
    static private function rmdir(string $dir, bool $keep = false)
    {
        // nothing to delete, go away
        if (!file_exists($dir)) {
            return false;
        }
        if (is_file($dir)) {
            throw new Exception("\"$dir\" is a file, not a directory to remove");
        }

        if (!($handle = opendir($dir))) {
            throw new Exception("\"$dir\" impossible to open for remove");
        }
        while (false !== ($entry = readdir($handle))) {
            if ($entry == "." || $entry == "..") {
                continue;
            }
            $path = $dir . DIRECTORY_SEPARATOR . $entry;
            if (is_link($path) || is_file($path)) {
                if (!unlink($path)) {
                    throw new Exception("\"$path\" impossible to delete");
                }
            } else if (is_dir($path)) {
                self::rmdir($path);
            } else {
                throw new Exception("\"$path\" what’s that? Not file nor dir");
            }
        }
        closedir($handle);
        if (!$keep) {
            rmdir($dir);
        }
    }


    /**
     * Recursive copy of folder
     */
    public static function rcopy(
        string $srcDir,
        string $dstDir
    ) {
        $srcDir = rtrim($srcDir, "/\\") . DIRECTORY_SEPARATOR;
        $dstDir = rtrim($dstDir, "/\\") . DIRECTORY_SEPARATOR;
        self::mkdir($dstDir);
        $dir = opendir($srcDir);
        while (false !== ($srcName = readdir($dir))) {
            if ($srcName[0] == '.') {
                continue;
            }
            $srcFile = $srcDir . $srcName;
            if (is_dir($srcFile)) {
                self::rcopy($srcFile, $dstDir . $srcName);
            } else {
                copy($srcFile, $dstDir . $srcName);
            }
        }
        closedir($dir);
    }

    /**
     * Zip folder to a zip file
     */
    static public function zip(
        string $zipFile,
        string $srcDir
    ) {
        $zip = new ZipArchive();
        if (!file_exists($zipFile)) {
            $zip->open($zipFile, ZIPARCHIVE::CREATE);
        } else {
            $zip->open($zipFile);
        }
        self::zipDir($zip, $srcDir);
        $zip->close();
    }


    /**
     * The recursive method to zip dir
     * start with files (especially for mimetype epub)
     */
    static private function zipDir(
        object $zip,
        string $srcDir,
        string $entryDir = ""
    ) {
        $srcDir = rtrim($srcDir, "/\\") . '/';
        // files
        foreach (array_filter(glob($srcDir . '/*'), 'is_file') as $srcPath) {
            $srcName = basename($srcPath);
            if ($srcName == '.' || $srcName == '..') continue;
            $entryPath = $entryDir . $srcName;
            $zip->addFile($srcPath, $entryPath);
        }
        // dirs
        foreach (glob($srcDir . '/*', GLOB_ONLYDIR) as $srcPath) {
            $srcName = basename($srcPath);
            if ($srcName == '.' || $srcName == '..') continue;
            $entryPath = $entryDir . $srcName;
            $zip->addEmptyDir($entryPath);
            self::zipDir($zip, $srcPath, $entryPath);
        }
    }

    /**
     * Is file path absolute ?
     */
    static function isPathAbs($path)
    {
        if (!$path) return false;
        if ($path[0] === DIRECTORY_SEPARATOR || preg_match('~\A[A-Z]:(?![^/\\\\])~i', $path) > 0) return true;
        return false;
    }

    /**
     * Build a map from tsv file where first col is the key.
     */
    static function tsv_map($tsvfile, $sep = "\t")
    {
        $ret = array();
        $handle = fopen($tsvfile, "r");
        $l = 0;
        while (($data = fgetcsv($handle, 0, $sep)) !== FALSE) {
            $l++;
            if (!$data || !count($data) || !$data[0]) {
                continue; // empty lines
            }
            /* Log ?
            if (isset($ret[$data[0]])) {
                echo $tsvfile,'#',$l,' not unique key:', $data[0], "\n";
            }
            */
            if (!isset($data[1])) {  // shall we log for user
                continue;
            }

            $ret[$data[0]] = stripslashes($data[1]);
        }
        fclose($handle);
        return $ret;
    }
}
