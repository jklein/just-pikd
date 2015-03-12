<?php
/**
 * Controller Interface
 *
 * @author      A Computer
 * @copyright   (c) 2015 G2G Market, Inc
 ********************************** 80 Columns *********************************
 */

namespace Pikd\Interfaces;

interface Controller {

    public static function handleGet($app);
    public static function handlePost($app);

}