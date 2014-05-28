<?php

namespace Pikd;

class Config {

    const ENV_PROD = 'production';
    const ENV_DEV = 'development';

    private static $development = [
        'support_email' => 'help-dev@justpikd.com',
        'phone_number' => '555-555-5555',
    ];

    private static $production = [
        'support_email' => 'help@justpikd.com',
        'phone_number' => '444-444-4444',
    ];

    public static function getConfiguration($environment = self::ENV_PROD) {
        return $environment = self::ENV_PROD ? self::$production : self::$production;
    }
}