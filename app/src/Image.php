<?php
/**
 * Functions for generating image paths
 *
 * @author      Jonathan Klein
 * @copyright   (c) 2014 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */
namespace Pikd;

class Image {

    const THUMB_SIZE = "200x200";
    const FULL_SIZE = "600x600";

    const DOMAIN = 'https://s3.amazonaws.com';

    public static function product($ma_id, $gtin, $size = self::THUMB_SIZE) {
        return self::DOMAIN . '/g2gcdn/' . $ma_id . '/' . $gtin . '_' . $size . '.jpg';
    }

    public static function productFromSKU($db, $sku, $size = self::THUMB_SIZE) {
        $sql = 'SELECT pr_ma_id, pr_gtin from products where pr_sku = :pr_sku';

        $result = $db->fetchOne($sql, ['pr_sku' => $sku]);

        return self::product($result['pr_ma_id'], $result['pr_gtin']);
    }
}