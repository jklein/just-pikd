<?php

namespace Pikd\Controllers;

class Base {
    public $template_vars;

    public function __construct($user) {
        if (empty($user)) {
            $this->template_vars['name'] = "New User";
        } else {
            $first_name = $user->getUserData()['cu_first_name'];
            if (!empty($first_name)) {
                $this->template_vars['name'] = $first_name;
            } else {
                $this->template_vars['name'] = 'unnamed user';
            }
        }
    }
}
