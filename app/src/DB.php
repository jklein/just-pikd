<?php
/**
 * A class for connecting to Postgres
 *
 * @author      Jonathan Klein
 * @copyright   (c) 2014 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */

namespace Pikd;

use Aura\Sql\ExtendedPdo;
use Aura\Sql\ConnectionLocator;

class DB {

    public static function getConnections() {
        $connections = new ConnectionLocator;

        $connections->setDefault(function () {
            return new ExtendedPdo(
                'pgsql:host=localhost;dbname=product',
                'postgres',
                'justpikd'
            );
        });

        $connections->setRead('customer', function () {
            return new ExtendedPdo(
                'pgsql:host=localhost;dbname=customer',
                'postgres',
                'justpikd'
            );
        });

        return $connections;
    }
}
