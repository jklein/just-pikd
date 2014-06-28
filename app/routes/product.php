<?php

// An example page that just shows a few products
$app->get('/products', function() use ($app) {
    $conn = $app->connections->getRead('product');

    // Get categories
    $categories = $conn->fetchAll('SELECT category_id, category_name from categories');

    foreach ($categories as $category) {
        $template_vars['categories'][] = [
            'name' => $category['category_name'],
            'link' => \Pikd\Controller\Categories::getLink($category['category_id']),
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
            'link' => \Pikd\Controller\Products::getLink($product['product_id'], $product['name']),
            'category' => $product['category_name'],
        ];
    }

    $app->render('products.twig', $template_vars);
});