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
        $sql = 'SELECT * from base_products bp
                join products p on bp.product_id = p.product_id
                join images i on i.sku = p.sku
                where bp.product_id = :id
                and rank = 1 and show_on_site = true
                order by image_id
                limit 1';

        $bind = ['id' => $this->id];
        $product = $this->dbconn->fetchOne($sql, $bind);

        if (!empty($product)) {
            foreach ($product as $key => $value) {
                $this->$key = $value;
            }
            $this->template_vars = $product;

            $this->template_vars['image_src'] = \Pikd\Image::product($this->manufacturer_id, $this->image_id);
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