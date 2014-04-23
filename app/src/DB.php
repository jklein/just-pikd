<?php
/**
 * A class for connecting to Postgres
 *
 * @author      Jonathan Klein
 * @copyright   (c) 2014 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */

namespace Pikd;

class DB {
    private static $connections = [];
    private $connection;

    public static function getConnection($dbname) {
        if (empty(self::$connections[$dbname])) {
            $host = 'localhost';
            $user = 'postgres';
            $pw = 'justpikd';
            self::$connections[$dbname] = new DB($host, $dbname, $user, $pw);
        }
        return self::$connections[$dbname];
    }

    private function __construct($host, $dbname, $username, $pw) {
        $this->connection = new \PDO("pgsql:dbname=$dbname;host=$host", $username, $pw);
    }

    public function query($sql_string) {
        $ret = [];

        $stmt = $this->connection->prepare($sql_string);
        $stmt->execute();

        while ($row = $stmt->fetch(\PDO::FETCH_ASSOC)) {
            $ret[] = $row;
        }

        return $ret;
    }
}
