<?php

namespace Pikd\Model;

class User {
    private $connection;
    private $data = [];
    private $email;

    public function __construct($db_conn, $email) {
        $this->connection = $db_conn;
        $this->email = $email;

        $sql = 'SELECT customer_id,
                    email,
                    password,
                    last_login,
                    persist_code,
                    reset_password_code,
                    first_name,
                    last_name,
                    created_at,
                    updated_at from customers
                    where email = :email';

        $result = $this->connection->fetchOne($sql, ['email' => $email]);
        if ($result === false) {
            // No user found
            $this->data = [];
        } else {
            $this->data = $result;
        }
    }

    public static function createUser($db_conn, $user_data) {
        $sql = 'SELECT * from customers where email = :email';
        $result = $db_conn->fetchOne($sql, ['email' => $user_data['email']]);

        if ($result === false) {
            $sql = 'INSERT INTO customers (email, password, created_at, updated_at, last_login) VALUES
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
                . ' WHERE email = :email';

        $data = array_merge($data, [
            'email'      => $this->email,
            'updated_at' => \Pikd\Util::timestamp()
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
