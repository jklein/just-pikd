<?php

namespace Pikd\Controller;

class Product {

    private $is_active = false;
    private $id;
    private $dbconn;
    private $template_vars;

    public function __construct($conn, $id) {
        $this->dbconn = $conn;
        $this->id = $id;

        $this->assignTemplateVars();
    }

    private function assignTemplateVars() {
        $sql = 'SELECT * from products where product_id = :id';
        $bind = ['id' => $this->id];
        $product = $this->dbconn->fetchOne($sql, $bind);

        if (!empty($product)) {
            foreach ($product as $key => $value) {
                $this->$key = $value;
            }
            $this->template_vars = $product;
            $this->is_active = true;
        }
    }

    public function getTemplateVars() {
        return $this->template_vars;
    }

    public function isActive() {
        return $this->is_active;
    }

    // Stub
    public static function getLink($product_id, $product_name) {
        return '/products/' . $product_id . '/' . urlencode($product_name);
    }
}