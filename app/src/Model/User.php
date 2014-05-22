<?php

namespace Pikd\Model;

class User {
    public static function getUser($db_conn, $email) {
        $sql = 'SELECT customer_id,
                    email,
                    password,
                    permissions,
                    activated,
                    activation_code,
                    activated_at,
                    last_login,
                    persist_code,
                    reset_password_code,
                    first_name,
                    last_name,
                    created_at,
                    updated_at from customers
                    where email = :email';

        $result = $db_conn->fetchOne($sql, ['email' => $email]);

        return $result;
    }

    public static function createUser($db_conn, $user_data) {
        $sql = 'INSERT INTO customers (email, password, created_at, updated_at, last_login) VALUES
                    (:email, :password, :created_at, :updated_at, :last_login)';

        return $db_conn->perform($sql, $user_data);
    }
}
