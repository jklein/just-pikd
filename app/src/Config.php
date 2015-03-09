<?php

namespace Pikd;

class Config {

    const ENV_PROD = 'production';
    const ENV_DEV = 'development';

    private static $shared = [
        'company_name' => 'Just Pikd',
        'image_domain' => 'https://s3.amazonaws.com',
    ];

    private static $development = [
        'support_email' => 'help-dev@justpikd.com',
        'phone_number' => '1-555-555-5555',
        'stripe' => [
            'public_api_key' => 'pk_test_KegQTWJyXb8TnGwtu7CTcv6Y',
            'secret_api_key' => 'sk_test_UwC9jEWOLr4MzFPsYDJLHOR4', // This isn't actually the prod one
            'logo' => '', // TODO: Create this
            'site_name' => 'Just Pikd',
        ],
    ];

    private static $production = [
        'support_email' => 'help@justpikd.com',
        'phone_number' => '1-444-444-4444',
        'stripe' => [
            'public_api_key' => 'pk_test_KegQTWJyXb8TnGwtu7CTcv6Y',
            'secret_api_key' => 'sk_test_UwC9jEWOLr4MzFPsYDJLHOR4', // This isn't actually the prod one
            'logo' => '', // TODO: Create this
            'site_name' => 'Just Pikd',
        ],
    ];

    public static function getConfiguration($environment = self::ENV_PROD) {
        $environment_variables = $environment = self::ENV_PROD ? self::$production : self::$development;

        return array_merge(self::$shared, $environment_variables);
    }
}