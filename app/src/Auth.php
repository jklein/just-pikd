<?php
namespace Pikd;

use Respect\Validation\Validator as v;

class Auth {

    public static function register($params) {
        $valid = false;
        $messages = self::validateFormParams($params);

        if (empty($messages)) {
            $user_data = array(
                'first_name' => $params['first_name'],
                'last_name'  => $params['last_name'],
                'email'      => $params['email'],
                'password'   => password_hash($params['password'], PASSWORD_BCRYPT),
                'created_at' => time(),
                'last_login' => time(),
            );

            $result = self::createUser(\Pikd\Persistence::get_database_object(), $user_data);
            if ($result) {
                $valid = true;
                $messages[] = 'Successfully registered!';
            } else {
                $messages[] = 'A user with that email address already exists!';
            }
        }

        return array(
            'valid'     => $valid,
            'messages'  => $messages,
        );
    }

    public static function update($params) {
        $valid = false;
        $messages = self::validateFormParams($params);

        if (empty($messages)) {
            $user_data = array(
                'id' => $_SESSION['id'],
                'first_name' => $params['first_name'],
                'last_name'  => $params['last_name'],
                'email'      => $params['email'],
                'password'   => password_hash($params['password'], PASSWORD_BCRYPT),
                'last_login' => time(),
            );

            $result = self::updateUser(\Pikd\Persistence::get_database_object(), $user_data);
            if ($result) {
                $valid = true;
                $messages[] = 'Successfully updated your information!';
                $_SESSION = array_merge($_SESSION, $user_data);
            } else {
                $messages[] = 'There is no user with that email address!';
            }
        }

        return array(
            'valid'     => $valid,
            'messages'  => $messages,
        );
    }

    private static function validateFormParams($params) {
        $messages = array();

        if (!v::string()->notEmpty()->email()->validate($params['email'])) {
            $messages[] = 'A valid email is required';
        }

        if (!v::string()->notEmpty()->validate($params['password'])) {
            $messages[] = 'Password is required';
        }

        if (v::string()->notEmpty()->validate($params['password'])
            !== v::string()->notEmpty()->validate($params['repeat_password'])
        ) {
            $messages[] = 'Passwords must match';
        }

        if (!v::string()->notEmpty()->validate($params['first_name'])
            || !v::string()->notEmpty()->validate($params['last_name'])
        ) {
            $messages[] = 'First and last name are required';
        }

        return $messages;
    }

    public static function createUser($dbcon, $user_data) {
        // First see if a user exists with this email address:
        $user = Persistence::get_user($dbcon, $user_data['email']);
        if (!empty($user)) {
            return false;
        } else {
            return Persistence::insert('Pikd_user', $user_data, $dbcon);
        }
    }

    private static function updateUser($dbcon, $user_data) {
        // First see if a user exists with this email address:
        $user = Persistence::get_user($dbcon, $user_data['email']);
        if (empty($user)) {
            return false;
        } else {
            return Persistence::update('Pikd_user', $user_data, $dbcon);
        }
    }

    public static function authenticate($dbcon, $email, $password) {
        $valid = false;
        $messages = array();

        if (!v::string()->notEmpty()->email()->validate($email)) {
            $messages[] = 'A valid email is required';
        }

        if (!v::string()->notEmpty()->validate($password)) {
            $messages[] = 'Password is required';
        }

        if (empty($messages)) {
            // We have valid input, check the password
            $user = Persistence::get_user($dbcon, $email);
            if (password_verify($password, $user['password'])) {
                $valid = true;
                $_SESSION = array_merge($_SESSION, $user);
                $messages[] = 'You have been logged in successfully!';
            } elseif (empty($messages)) {
                $messages[] = 'Incorrect email or password';
            }
        }

        return array(
            'valid'     => $valid,
            'messages'  => $messages,
        );
    }
}
