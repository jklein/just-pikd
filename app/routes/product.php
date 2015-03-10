<?php

namespace Pikd;

$app->get('/products/:sku(/:product_name)', function($sku, $name = '') use ($app) {
    if (!\Pikd\Util::isValidSku($sku)) {
        $app->redirect('/404');
    }

    $conn = $app->connections->getRead('product');
    $product = new Controller\Product($conn, $app->so_id, $app->config, $sku);

    if ($product->isActive()) {
        $template_vars = $product->getTemplateVars();

        $app->render('product', $template_vars);
    } else {
        $app->redirect('/404');
    }
});