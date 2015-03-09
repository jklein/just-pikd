<?php

namespace Pikd\Model;

class Product {

    private $dbconn;
    private $sku;

    public function __construct($conn, $sku) {
        $this->dbconn = $conn;
        $this->sku = $sku;
    }

    public function getData() {
        $sql = 'SELECT * from products 
                    join products_stores on pr_sku = sku
                    join categories on pr_cat_id = cat_id
                    where store_id = 1
                    and pr_sku = :sku';

        $bind = ['sku' => $this->sku];
        return $this->dbconn->fetchOne($sql, $bind);
    }

    // This should not get called in production 
    public static function getRandomProducts($conn, $num) {
        // TODO: Need to pull the store ID from somewhere real
        $sql = 'SELECT * from products 
                    join products_stores on pr_sku = sku
                    join categories on pr_cat_id = cat_id
                    where store_id = 1
                    order by random()
                    limit :num';

        return $conn->fetchAll($sql, ['num' => $num]);
    }
}