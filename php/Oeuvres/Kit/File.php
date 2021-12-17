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
     * go to the parent folder to test if it is writable.
     */
    public static function writable(string $file, ?string $source = null):bool
    {
        while (!file_exists($file)) { // if not file exists, go up to parents
            $file = dirname($file);
        }
        if (is_writable($file)) return true;
        if (is_readable($file)) {
            throw new InvalidArgumentException(
                "\n".$source."\n    \"\033[91m$file\033[0m\" file exists but not writable\n"
            );
        }
        self::readable($file, $source);
        return true;
    }


    /**
     * Check existence of a file to read,
     * and send informative Exception if it’s not OK.
     */
    public static function readable(string $file, ?string $source = null):bool
    {
        if (is_readable($file)) return true;
        // shall we log here or break by exception ?
        if ($source) $source = "\n" . $source;
        if (is_file($file)) {
            throw new InvalidArgumentException(
                $source."\n    \"\033[91m$file\033[0m\" file exist but not readable \n"
            );
        }
        if (file_exists($file)) {
            throw new InvalidArgumentException(
                $source."\n    \"\033[91m$file\033[0m\" path exits but is not a file\n"
            );
        }
        throw new InvalidArgumentException(
            $source."\n    \"\033[91m$file\033[0m\" file not found\n"
        );
    }
    /**
     * A safe mkdir dealing with rights
     */
    static function mkdir(string $dir):bool
    {
        if (is_dir($dir)) {
            return false;
        }
        if (!mkdir($dir, 0775, true)) {
            throw new Exception("Directory not created: ".$dir);
        }
        @chmod($dir, 0775);  // let @, if www-data is not owner but allowed to write
        return true;
    }

    /**
     * Delete all files in a directory, create it if not exist
     */
    static public function cleandir(string $dir, ?int $depth = 0)
    {
        if (is_file($dir)) {
            return unlink($dir);
        }
        // attempt to create the folder we want empty
        if (!$depth && !file_exists($dir)) {
            self::mkdir($dir);
            return;
        }
        // should be dir here
        if (is_dir($dir)) {
            $handle=opendir($dir);
            while (false !== ($entry = readdir($handle))) {
                if ($entry == "." || $entry == "..") {
                    continue;
                }
                self::cleandir($dir.'/'.$entry, $depth+1);
            }
            closedir($handle);
            // do not delete the root dir
            if ($depth > 0) {
                rmdir($dir);
            }
            // timestamp newDir
            else {
                touch($dir);
            }
            return;
        }
    }


    /**
     * Recursive deletion of a directory
     * If $keep = true, keep directory with its acl
     */
    static function rmdir(string $dir, bool $keep = false) {
        $dir = rtrim($dir, "/\\").DIRECTORY_SEPARATOR;
        if (!is_dir($dir)) {
            return $dir; // maybe deleted
        }
        if (!($handle = opendir($dir))) {
            throw new Exception("Read impossible " . $dir);
        }
        while(false !== ($filename = readdir($handle))) {
            if ($filename == "." || $filename == "..") {
                continue;
            }
            $file = $dir.$filename;
            if (is_link($file)) {
                throw new Exception("Delete a link? ".$file);
            }
            else if (is_dir($file)) {
                self::rmdir($file);
            }
            else {
                unlink($file);
            }
        }
        closedir($handle);
        if (!$keep) {
            rmdir($dir);
        }
        return $dir;
    }


    /**
     * Recursive copy of folder
     */
    public static function rcopy(
        string $srcDir, 
        string $dstDir
    ) {
        $srcDir = rtrim($srcDir, "/\\").DIRECTORY_SEPARATOR;
        $dstDir = rtrim($dstDir, "/\\").DIRECTORY_SEPARATOR;
        self::mkdir($dstDir);
        $dir = opendir($srcDir);
        while(false !== ($srcName = readdir($dir))) {
            if ($srcName[0] == '.') {
                continue;
            }
            $srcFile = $srcDir.$srcName;
            if (is_dir($srcFile)) {
                self::rcopy($srcFile, $dstDir.$srcName);
            }
            else {
                copy($srcFile, $dstDir.$srcName);
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
        }
        else {
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
     * Build a map from tsv file where first col is the key.
     */
    static function tsvhash($tsvfile, $sep="\t")
    {
        $ret = array();
        $handle = fopen($tsvfile, "r");
        $l = 1;
        while (($data = fgetcsv($handle, 0, $sep)) !== FALSE) {
            if (!$data || !count($data)) {
                continue;
            }
            if (isset($ret[$data[0]])) {
                echo $tsvfile,'#',$l,' not unique key:', $data[0], "\n";
            }
            $ret[$data[0]] = $data;
        }
        return $ret;
    }

}
