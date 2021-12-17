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
declare(strict_types=1);

include_once(__DIR__ . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\LoggerCli;
use Oeuvres\Odette\OdtChain;

set_time_limit(-1);
$logger = new LoggerCli(LogLevel::DEBUG);
$logger->info("Odette");
OdtChain::cli($logger);
