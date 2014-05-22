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

    public static function updatePassword($db_conn, $params) {
        $valid = false;
        $messages = self::validateUpdatePassword($params);

        if (empty($messages)) {
            $user_data = array(
                'customer_id'  => $_SESSION['customer_id'],
                'email'        => $_SESSION['email'],
                'new_password' => password_hash($params['new_password'], PASSWORD_BCRYPT),
                'last_login'   => \Pikd\Util::timestamp(),
                'updated_at'   => \Pikd\Util::timestamp(),
            );

            $result = self::updateUser($db_conn, $user_data);
            if ($result) {
                $valid = true;
                $messages[] = 'Successfully updated your password!';
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

    private static function updateUser($db_conn, $user_data) {
        // First see if a user exists with this email address:
        $user = \Pikd\Model\User::getUser($db_conn, $user_data['email']);
        if (empty($user)) {
            return false;
        } else {
            return \Pikd\Model\User::updatePassword($db_conn, $user_data);
        }
    }

    public static function authenticate($db_conn, $email, $password) {
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
            $user = \Pikd\Model\User::getUser($db_conn, $email);
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
