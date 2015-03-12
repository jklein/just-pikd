<?php

namespace Pikd\Controller;

class Categories {

    // Stub
    public static function getLink($category_id) {
        return '/browse/' . $category_id;
    }

    public static function getName($conn, $category_id) {
        $sql = 'SELECT category_name from categories where category_id = :id';
        $bind = ['id' => $category_id];
        $result = $conn->fetchOne($sql, $bind);

        return $result['category_name'];
    }
}