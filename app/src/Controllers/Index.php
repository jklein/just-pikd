<?php
/**
 * Index Controller
 *
 * @author      A Computer
 * @copyright   (c) 2015 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */

namespace Pikd\Controllers;

class Index implements \Pikd\Interfaces\Controller {

    public static function handleGet($app) {
        $controller = new \Pikd\Controllers\Base($app->user);

        $conn = $app->connections->getRead('product');
        $products = \Pikd\Model\Product::getRandomProducts($conn, $app->so_id, 8);

        $product_info_for_display = [];
        foreach ($products as $p) {
            $product_info_for_display[] = array_merge($p, [
                "image_url" => \Pikd\Image::product($p['pr_ma_id'], $p['pr_gtin']),
                "list_cost" => \Pikd\Util::formatPrice($p['list_cost']),
                "link"      => \Pikd\Controllers\Product::getLink($p['pr_sku'], $p['pr_name']),
            ]);
        }

        $controller->template_vars['products'] = new \ArrayIterator($product_info_for_display);
        
        $app->render('index', $controller->template_vars);
    }

    public static function handlePost($app) {
        
    }

}