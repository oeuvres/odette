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

use \DateTime;
use Psr\Log\AbstractLogger;
use Psr\Log\InvalidArgumentException;
use Psr\Log\LogLevel;

/**
 * A PSR-3 compliant logger as light as possible
 * Used for CLI 
 *
 * @see https://www.php-fig.org/psr/psr-3/
 */
class LoggerCli extends AbstractLogger
{
    /** Default prefix for message */
    private $prefix; 

    /** Logging levels */
    private static $levelMapInt;
    /** Logging level by name */
    private static $levelMapString;
    /** Default level of message to output */
    private $verbosity;

    public static function init()
    {
        self::$levelMapInt = array(
            1 => LogLevel::EMERGENCY,
            2 => LogLevel::ALERT,
            3 => LogLevel::CRITICAL,
            4 => LogLevel::ERROR,
            5 => LogLevel::WARNING,
            6 => LogLevel::NOTICE,
            7 => LogLevel::INFO,
            8 => LogLevel::DEBUG,
        );
        self::$levelMapString = array_flip(self::$levelMapInt);
        // ensure timezone ()
        if(ini_get('date.timezone')) {
            date_default_timezone_set(ini_get('date.timezone'));
        }
        else {
            date_default_timezone_set("Europe/Paris");
        }
    }

    public function __construct(
        string $level = LogLevel::ERROR, 
        ?string $prefix = "[{level}] {time} "
    ) {
        self::checkLevel($level);
        $this->verbosity = self::$levelMapString[$level];
        $this->prefix = $prefix;
    }

    private static function checkLevel(string $level)
    {
        if (!isset(self::$levelMapString[$level])) {
            throw new InvalidArgumentException(
                sprintf('Unknown log level "%s"', $level)
            );
        }
    }

    private static function checkLevelInt(int $level)
    {
        if (!isset(self::$levelMapInt[$level])) {
            throw new InvalidArgumentException(
                sprintf('Unknown log level %d', $level)
            );
        }
    }

    /**
     * Get verbosity by string.
     */
    public function getLevel():string
    {
        return self::$levelMapInt[$this->verbosity];
    }

    /**
     * Set verbosity by log level.
     */
    public function setLevel(string $level)
    {
        self::checkLevel($level);
        $this->verbosity = self::$levelMapString[$level];
    }

    /**
     * {@inheritdoc}
     *
     * @return void
     */
    public function log($level, $message, array $context = []): bool
    {
        $this->checkLevel($level);
        $levelInt = self::$levelMapString[$level];
        if ($levelInt > $this->verbosity) return false;
        $out = STDERR;
        if ($levelInt > self::$levelMapString[LogLevel::ERROR]) {
            $out = STDOUT;
        }
        $date = new DateTime();
        $context['level'] = $level;
        $context['datetime'] = $date->format('Y-m-d H:i:s');
        $context['time'] = $date->format('H:i:s');
        fwrite(
            $out, 
            $this->interpolate($this->prefix.$message, $context) . "\n"
        );
        return true;
    }

    /**
     * Interpolates context values into the message placeholders.
     *
     * @author PHP Framework Interoperability Group
     */
    private function interpolate(string $message, array $context): string
    {
        if (\strpos($message, '{') === false) {
            return $message;
        }

        $replacements = [];
        foreach ($context as $key => $val) {
            if (null === $val || is_scalar($val) || (\is_object($val) && \method_exists($val, '__toString'))) {
                $replacements["{{$key}}"] = $val;
            } elseif ($val instanceof \DateTimeInterface) {
                $replacements["{{$key}}"] = $val->format(\DateTime::RFC3339);
            } elseif (\is_object($val)) {
                $replacements["{{$key}}"] = '[object '.\get_class($val).']';
            } else {
                $replacements["{{$key}}"] = '['.\gettype($val).']';
            }
        }

        return strtr($message, $replacements);
    }

    /**
     * TO REWRITE
     * Custom error handler
     */
    static function err(
        $errno, 
        $errstr=null, 
        $errfile=null, 
        $errline=null, 
        $errcontext=null
    ) {
        /** 
        if ($count) { // is an XSLT error or an XSLT message, reformat here
            if(strpos($errstr, 'error')!== false) {
                return false;
            }
            else if ($errno == E_WARNING) {
                $errno = E_USER_WARNING;
            }
        }
        // a debug message in normal mode, do nothing
        if ($errno == E_USER_NOTICE && !self::$debug) {
            return true;
        }
        // ?? not a user message, let work default handler
        // else if ($errno != E_USER_ERROR && $errno != E_USER_WARNING ) return false;

        if (!$errstr && $errno) {
            $errstr = $errno;
        }
        if (is_resource(self::$logger)) {
            fwrite(self::$logger, $errstr."\n");
        }
        else if (is_string(self::$logger) && function_exists(self::$logger)) {
            call_user_func(self::$logger, $errstr);
        } 
        */
    }

}
LoggerCli::init();