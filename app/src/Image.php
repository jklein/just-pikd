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

    public static function product($domain, $ma_id, $gtin, $size = self::THUMB_SIZE) {
        return $domain . '/g2gcdn/' . $ma_id . '/' . $gtin . '_' . $size . '.jpg';
    }

}