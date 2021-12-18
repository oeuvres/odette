<?php
spl_autoload_register(function ($class) {
    $slash = DIRECTORY_SEPARATOR;
    $file = __DIR__ . $slash . str_replace('\\', $slash, $class).'.php';
    if (file_exists($file)) {
        include_once $file;
        return true;
    }
    else throw new Exception("Impossible to load " . $file);
});
