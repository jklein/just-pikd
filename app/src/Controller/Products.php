<?php

namespace Pikd\Controller;

class Products {

    // Stub
    public static function getLink($product_id, $product_name) {
        return '/products/' . $product_id . '/' . urlencode($product_name);
    }
}