<?php

if (!defined('APPLICATION_PATH')) {
    define('APPLICATION_PATH', realpath(dirname(__DIR__)));
}

return [
    'slim' => array(
        'debug' => false,
        'templates.path' => APPLICATION_PATH . '/htdocs/templates',
    ),
];