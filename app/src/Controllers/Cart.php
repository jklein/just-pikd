<?php

namespace Pikd\Controllers;

class Cart {

    private $products = [];
    private $cu_id = null;

    public function __construct($db, $cu_id, $so_id) {
        $this->db = $db;
        $this->cu_id = $cu_id;
        $this->so_id = $so_id;
    }

    public function getProducts() {
        $this->order = new \Pikd\Model\Order($this->db, $this->cu_id, $this->so_id, \Pikd\Model\Order::STATUS_BASKET);
        $this->order_product = new \Pikd\Model\OrderProduct($this->db, $this->order->or_id);

        $this->products = $this->order_product->getAllProducts();
        return $this->products;
    }

    public function getTotalPriceInCents(){
        $total = 0;
        foreach ($this->products as $p) {
            $total += $p['op_list_cost'] * $p['op_qty'];
        }

        return $total;
    }
}