<?php
namespace Pikd;

use Respect\Validation\Validator as v;

class Auth {

    public static function register($db_conn, $params) {
        $valid = false;
        $messages = self::validateFormParams($params);

        if (empty($messages)) {
            $user_data = array(
                'email'      => $params['email'],
                'password'   => password_hash($params['password'], PASSWORD_BCRYPT),
                'created_at' => \Pikd\Util::timestamp(),
                'updated_at' => \Pikd\Util::timestamp(),
                'last_login' => \Pikd\Util::timestamp(),
            );

            $result = self::createUser($db_conn, $user_data);
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

    public static function updatePassword($params) {
        $valid = false;
        $messages = self::validateUpdatePassword($params);

        if (empty($messages)) {
            $user_data = array(
                'id'         => $_SESSION['id'],
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

    private static function validateUpdatePassword($params) {
        $messages = array();

        if (!v::string()->notEmpty()->validate($params['old_password'])) {
            $messages[] = 'You must provide your current password';
        }

        if (!v::string()->notEmpty()->validate($params['new_password'])) {
            $messages[] = 'A new password is required';
        }

        if (!v::string()->notEmpty()->validate($params['repeat_password'])) {
            $messages[] = 'A repeat password is required';
        }

        if (!v::equals($params['new_password'])->validate($params['repeat_password'])) {
            $messages[] = 'Passwords must match';
        }

        return $messages;
    }

    private static function validateFormParams($params) {
        $messages = array();

        if (!v::string()->notEmpty()->email()->validate($params['email'])) {
            $messages[] = 'A valid email is required';
        }

        if (!v::string()->notEmpty()->validate($params['password'])) {
            $messages[] = 'Password is required';
        }



        return $messages;
    }

    public static function createUser($db_conn, $user_data) {
        // First see if a user exists with this email address:
        $user = \Pikd\Model\User::getUser($db_conn, $user_data['email']);
        if (!empty($user)) {
            return false;
        } else {
            $result = \Pikd\Model\User::createUser($db_conn, $user_data);

            if ($result) { // User is created, log them in
                return self::authenticate($db_conn, $user_data['email'], $user_data['password']);
            } else {
                return false;
            }
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
        $messages = [];

        if (!v::string()->notEmpty()->email()->validate($email)) {
            $messages[] = 'A valid email is required';
        }

        if (!v::string()->notEmpty()->validate($password)) {
            $messages[] = 'Password is required';
        }

        if (empty($messages)) {
            // We have valid input, check the password
            $user = \Pikd\Model\User::getUser($dbcon, $email);
            \Pikd\Util::debug($user);
            if (password_verify($password, $user['password'])) {
                $valid = true;
                $_SESSION = array_merge($_SESSION, $user);
                $messages[] = 'You have been logged in successfully!';
            } elseif (empty($messages)) {
                $messages[] = 'Incorrect email or password';
            }
        }

        return [
            'valid'     => $valid,
            'messages'  => $messages,
        ];
    }
}
