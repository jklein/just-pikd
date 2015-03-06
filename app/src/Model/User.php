<?php

namespace Pikd\Model;

class User {
    private $connection;
    private $data = [];
    private $email;

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
                    cu_updated_at from customers
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
        $sql = 'SELECT * from customers where cu_email = :email';
        $result = $db_conn->fetchOne($sql, ['email' => $user_data['email']]);

        if ($result === false) {
            $sql = 'INSERT INTO customers (cu_email, cu_password, cu_created_at, cu_updated_at, cu_last_login) VALUES
                    (:email, :password, :created_at, :updated_at, :last_login)';
            return $db_conn->perform($sql, $user_data);
        } else {
            return false;
        }
    }

    public function save($data) {
        $fields_to_update = [];
        foreach ($data as $key => $value) {
            $fields_to_update[] = $key . ' = ' . ':' . $key;
        }

        $sql = 'UPDATE customers set '  . implode(',', $fields_to_update)
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
