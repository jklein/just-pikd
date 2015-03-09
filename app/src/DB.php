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
use Aura\Sql\Profiler;
use Aura\Sql\ConnectionLocator;

class DB {

    // Eventually we should factor out this connection information into a config file
    public static function getConnections() {
        $connections = new ConnectionLocator;

        $connections->setDefault(function () {
            $pdo = new ExtendedPdo(
                'pgsql:host=localhost;dbname=product',
                'postgres',
                'justpikd'
            );
            $pdo->setProfiler(new Profiler);
            $pdo->getProfiler()->setActive(true);

            return $pdo;
        });

        $connections->setRead('product', function () {
            $pdo = new ExtendedPdo(
                'pgsql:host=localhost;dbname=product',
                'postgres',
                'justpikd'
            );
            $pdo->setProfiler(new Profiler);
            $pdo->getProfiler()->setActive(true);

            return $pdo;
        });

        $connections->setWrite('product', function () {
            $pdo = new ExtendedPdo(
                'pgsql:host=localhost;dbname=product',
                'postgres',
                'justpikd'
            );
            $pdo->setProfiler(new Profiler);
            $pdo->getProfiler()->setActive(true);

            return $pdo;
        });


        $connections->setRead('customer', function () {
            $pdo = new ExtendedPdo(
                'pgsql:host=localhost;dbname=customer',
                'postgres',
                'justpikd'
            );
            $pdo->setProfiler(new Profiler);
            $pdo->getProfiler()->setActive(true);

            return $pdo;
        });

        $connections->setWrite('customer', function () {
            $pdo = new ExtendedPdo(
                'pgsql:host=localhost;dbname=customer',
                'postgres',
                'justpikd'
            );
            $pdo->setProfiler(new Profiler);
            $pdo->getProfiler()->setActive(true);

            return $pdo;
        });

        return $connections;
    }
}
