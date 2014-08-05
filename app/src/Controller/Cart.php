<?php

namespace Pikd\Controller;

class Cart {

    private $products = [];
    private $user_id = null;

    public function __construct($user_id) {
        $this->user_id = $user_id;
    }

    public function getProducts() {
        $product_id = '1543';
        $product_name = 'Some Awesome Product';

        $this->products = [
            [
                'id' => $product_id,
                'name' => $product_name,
                'image_src' => '/assets/images/dummy/product-cart.jpg',
                'url' => Product::getLink($product_id, $product_name),
                'price' => 25,
                'qty' => 1,
                'sub_total' => '$25',
            ],
            [
                'id' => $product_id,
                'name' => $product_name,
                'image_src' => '/assets/images/dummy/product-cart.jpg',
                'url' => Product::getLink($product_id, $product_name),
                'price' => 25,
                'qty' => 1,
                'sub_total' => '$25',
            ],
        ];

        return $this->products;
    }

    public function getTotalPriceInCents(){
        $total = 0;
        foreach ($this->products as $product) {
            $total += $product['price'] * $product['qty'];
        }

        return $total * 100;
    }
}