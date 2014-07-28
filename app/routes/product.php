<?php

namespace Pikd;

// An example page that just shows a few products
$app->get('/products', function() use ($app) {
    $conn = $app->connections->getRead('product');

    // Get categories
    $categories = $conn->fetchAll('SELECT category_id, category_name from categories');

    foreach ($categories as $category) {
        $template_vars['categories'][] = [
            'name' => $category['category_name'],
            'link' => Controller\Categories::getLink($category['category_id']),
        ];
    }
    
    // Get product data
    $products = $conn->fetchAll('SELECT * from products p join categories c 
        on p.category_id = c.category_id limit 10');

    foreach ($products as $product) {
        $template_vars['products'][] = [
            'name' => ucwords(strtolower($product['name'])),
            'list_cost' => $product['list_cost'],
            'id' => $product['product_id'],
            'link' => Controller\Product::getLink($product['product_id'], $product['name']),
            'category' => $product['category_name'],
        ];
    }

    $app->render('products.twig', $template_vars);
});

$app->get('/products/:id(/:product_name)', function($id, $name = '') use ($app) {
    if (!is_numeric($id)) {
        $app->redirect('/404');
    }

    $conn = $app->connections->getRead('product');
    $product = new Controller\Product($conn, $id);

    if ($product->isActive()) {
        $template_vars = $product->getTemplateVars();
        $template_vars['category_name'] = Controller\Categories::getName($conn, $product->category_id);
        Util::debug($template_vars);

        $app->render('product.twig', $template_vars);
    } else {
        $app->redirect('/404');
    }
});