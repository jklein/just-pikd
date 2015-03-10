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

    public static function insert($db, $table, $data) {
        $sql = 'INSERT INTO ' . $table . '(' . implode(',', array_keys($data)) . ')
                VALUES (:' . implode(',:', array_keys($data)) . ')';

        return $db->perform($sql, $data);
    }

    public static function update($db, $table, $data, $where) {
        $sql = 'UPDATE ' . $table . ' SET ';

        $values = [];
        foreach ($data as $key => $value) {
            $values[] = $key . ' = :' . $key;
        }

        $sql .= implode(',', $values) . ' WHERE ' . self::buildWhereClause($where); 
        return $db->fetchAffected($sql, $data);
    }

    public static function upsert($db, $table, $data, $where) {
        $affected_rows = self::update($db, $table, $data, $where);

        if ($affected_rows === 0) {
            return self::insert($db, $table, $data);
        }
    }

    public static function fetchAll($db, $table, $where) {
        $sql = 'SELECT * FROM ' . $table . ' WHERE ' . self::buildWhereClause($where);

        return $db->fetchAll($sql, $where);
    }

    private static function buildWhereClause($where_array) {
        $w = [];
        foreach ($where_array as $key => $value) {
            $w[] = $key . ' = ' . ':' . $key;
        }

        return implode(' AND ', $w);
    }
}
