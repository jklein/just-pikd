<?php

namespace Pikd\Model;

class Product {

    private $dbconn;
    private $sku;

    public function __construct($conn, $sku, $so_id) {
        $this->dbconn = $conn;
        $this->sku = $sku;
        $this->so_id = $so_id;
    }

    public function getData() {
        $sql = 'SELECT * from products 
                    join products_stores on pr_sku = sku
                    join categories on pr_cat_id = cat_id
                    where store_id = :so_id
                    and pr_sku = :sku';

        $bind = [
            'sku' => $this->sku,
            'so_id' => $this->so_id,
        ];
        return $this->dbconn->fetchOne($sql, $bind);
    }

    // This should not get called in production 
    public static function getRandomProducts($conn, $so_id, $num) {
        $sql = 'SELECT * from products 
                    join products_stores on pr_sku = sku
                    join categories on pr_cat_id = cat_id
                    where store_id = :so_id
                    order by random()
                    limit :num';

        return $conn->fetchAll($sql, ['num' => $num, 'so_id' => $so_id]);
    }
}