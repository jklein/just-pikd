<?php

namespace Pikd\Model;

class User {
    private $connection;
    private $data = [];
    private $email;

    const TABLE_NAME = 'customers';

    public function __construct($db_conn, $email) {
        $this->connection = $db_conn;
        $this->email = $email;

        $sql = 'SELECT cu_id,
                    cu_email,
                    cu_password,
                    cu_last_login,
                    cu_persist_code,
                    cu_reset_password_code,
                    cu_first_name,
                    cu_created_at,
                    cu_updated_at from ' . self::TABLE_NAME . '
                    where cu_email = :email';

        $result = $this->connection->fetchOne($sql, ['email' => $email]);
        if ($result === false) {
            // No user found
            $this->data = [];
        } else {
            $this->data = $result;
        }
    }

    public static function createUser($db_conn, $user_data) {
        $sql = 'SELECT * from ' . self::TABLE_NAME . ' where cu_email = :email';
        $result = $db_conn->fetchOne($sql, ['email' => $user_data['email']]);

        if ($result === false) {
            return \Pikd\DB::insert($dbconn, self::TABLE_NAME, $user_data);
        } else {
            return false;
        }
    }

    public function save($data) {
        $fields_to_update = [];
        foreach ($data as $key => $value) {
            $fields_to_update[] = $key . ' = ' . ':' . $key;
        }

        $sql = 'UPDATE ' . self::TABLE_NAME . ' set '  . implode(',', $fields_to_update)
                . ' WHERE cu_email = :email';

        $data = array_merge($data, [
            'cu_email'      => $this->email,
            'cu_updated_at' => \Pikd\Util::timestamp()
        ]);

        $result = $this->connection->perform($sql, $data);
        if ($result) {
            $_SESSION = array_merge($_SESSION, $data);
            $this->data = array_merge($this->data, $data);
            return true;
        } else {
            return false;
        }

    }

    public function getUserData() {
        return $this->data;
    }
}
