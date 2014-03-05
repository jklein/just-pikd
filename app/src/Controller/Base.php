<?php

namespace Pikd\Controller;

class Base {
    public $template_vars;

    public function __construct() {
        $this->template_vars = [
            'name' => 'Jonathan',
        ];
    }
}