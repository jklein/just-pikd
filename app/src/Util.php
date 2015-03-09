<?php
/**
 * Utility functions
 *
 * @author      Jonathan Klein
 * @copyright   (c) 2014 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */
namespace Pikd;

class Util {
    public static function timestamp($date = null) {
        if ($date === null) {
            $date = time();
        }
        return date('Y-m-d h:i:s', $date);
    }

    public static function formatPrice($cents) {
        setlocale(LC_MONETARY, 'en_US');
        return '$' . money_format('%.2n', $cents/100);
    }

    public static function isValidSku($sku) {
        return true;
    }
}
