<?php

namespace Pikd;

class Config {

    const ENV_PROD = 'production';
    const ENV_DEV = 'development';

    private static $shared = [
        'company_name' => 'Just Pikd',
    ];

    private static $development = [
        'support_email' => 'help-dev@justpikd.com',
        'phone_number' => '1-555-555-5555',
    ];

    private static $production = [
        'support_email' => 'help@justpikd.com',
        'phone_number' => '1-444-444-4444',
    ];

    public static function getConfiguration($environment = self::ENV_PROD) {
        $environment_variables = $environment = self::ENV_PROD ? self::$production : self::$development;

        return array_merge(self::$shared, $environment_variables);
    }
}