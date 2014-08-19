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

    const FULL_SIZE = 1;

    public static function product($manu_id, $image_id, $size = self::FULL_SIZE) {

        return "https://s3.amazonaws.com/g2gcdn/$manu_id/$image_id.jpg";
    }

}