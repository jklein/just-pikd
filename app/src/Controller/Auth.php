<?php

namespace Pikd\Controller;

use Respect\Validation\Validator as v;

class Auth {
    public $template_vars;

    private $connection;

    public function __construct(\Aura\Sql\ExtendedPdo $conn, $user = '') {
        $this->connection = $conn;
        $this->user       = $user;
    }

    public function register($params) {
        $valid = false;
        $messages = $this->validateFormParams($params);

        if (empty($messages)) {
            $user_data = array(
                'email'      => $params['email'],
                'password'   => password_hash($params['password'], PASSWORD_BCRYPT),
                'created_at' => \Pikd\Util::timestamp(),
                'updated_at' => \Pikd\Util::timestamp(),
                'last_login' => \Pikd\Util::timestamp(),
            );

            $result = \Pikd\Model\User::createUser($this->connection, $user_data);
            if ($result) {
                $valid = true;
                $messages[] = 'Successfully registered!';

                // Now log the user in
                $this->authenticate($params['email'], $params['password']);
            } else {
                $messages[] = 'A user with that email address already exists!';
            }
        }

        return array(
            'valid'     => $valid,
            'messages'  => $messages,
        );
    }

    private function validateFormParams($params) {
        $messages = [];
        if (!v::string()->notEmpty()->email()->validate($params['email'])) {
            $messages[] = 'A valid email is required';
        }

        if (!v::string()->notEmpty()->validate($params['password'])) {
            $messages[] = 'Password is required';
        }

        return $messages;
    }

    public function authenticate($email, $password) {
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
            $user = new \Pikd\Model\User($this->connection, $email);
            $user_data = $user->getUserData();

            if (empty($user_data)) {
                // We couldn't find the user
                $messages[] = 'User not found';
            } else {
                $user_data = $user->getUserData();
                var_dump($user_data);
                if (password_verify($password, $user_data['password'])) {
                    $valid = true;
                    $_SESSION = array_merge($_SESSION, $user_data);
                    $messages[] = 'You have been logged in successfully!';
                } elseif (empty($messages)) {
                    $messages[] = 'Incorrect email or password';
                }
            }

        }

        return [
            'valid'     => $valid,
            'messages'  => $messages,
        ];
    }

    // @TODO - Make sure that we can't spoof this as a non-logged in user
    public function updatePassword($params) {
        $valid = false;
        $messages = $this->validateUpdatePassword($params);

        if (empty($messages)) {
            $user_data = array(
                'password' => password_hash($params['new_password'], PASSWORD_BCRYPT),
            );

            $result = $this->user->save($user_data);
            if ($result) {
                $valid = true;
                $messages[] = 'Successfully updated your password!';
            } else {
                $messages[] = 'There is no user with that email address!';
            }
        }

        return array(
            'valid'     => $valid,
            'messages'  => $messages,
        );
    }

    private function validateUpdatePassword($params) {
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

    public function updateInfo($params) {
        $valid = false;

        $result = $this->user->save($params);
        if ($result) {
            $valid = true;
            $messages[] = 'Successfully updated your information!';
        } else {
            $messages[] = 'Failed to save your information!';
        }

        return array(
            'valid'     => $valid,
            'messages'  => $messages,
        );
    }
}
