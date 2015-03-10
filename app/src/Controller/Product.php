<?php

namespace Pikd\Controller;

class Product {

    private $is_active = false;
    private $sku;
    private $dbconn;
    private $template_vars;

    const STATUS_ACTIVE = "Active";

    public function __construct($conn, $so_id, $config, $sku) {
        $this->dbconn = $conn;
        $this->sku = $sku;
        $this->cfg = $config;
        $this->so_id = $so_id;

        $this->assignTemplateVars();
    }

    private function assignTemplateVars() {
        $product = new \Pikd\Model\Product($this->dbconn, $this->sku, $this->so_id);
        $data = $product->getData();

        if (!empty($data)) {
            foreach ($data as $key => $value) {
                $this->$key = $value;
            }
            $this->template_vars = $data;

            $this->template_vars['image_src'] = \Pikd\Image::product($this->cfg['image_domain'], $this->pr_ma_id, $this->pr_gtin, \Pikd\Image::FULL_SIZE);
            $this->template_vars['list_cost'] = \Pikd\Util::formatPrice($this->list_cost);
            $this->template_vars['list_cost_cents'] = $this->list_cost;
            $this->is_active = $this->pr_status === self::STATUS_ACTIVE;
        }
    }

    public function getTemplateVars() {
        return $this->template_vars;
    }

    public function isActive() {
        return $this->is_active;
    }

    // Stub
    public static function getLink($sku, $name) {
        return '/products/' . $sku . '/' . urlencode($name);
    }

     
}