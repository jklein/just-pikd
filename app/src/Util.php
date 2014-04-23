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
    public static function debug($variable) {
        echo '<pre>';
        if (is_array($variable)) {
            print_r($variable);
        } else {
            var_dump($variable);
        }
        echo '</pre>';
    }
}
