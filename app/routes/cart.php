<?php

namespace Pikd;

// Adding a product to cart
$app->post('/cart', function() use ($app) {
    $product_id = (int)$app->request()->post('product_id');

    var_dump($product_id);

    $app->redirect('/cart');
});

$app->get('/cart', function() use ($app) {
    $page_data['title'] = sprintf("%s | Pikd", 'Shopping Cart');

    if ($app->user === null) {
        $app->flash('danger', 'You must be logged in to view this page');
        $app->redirect('/');
    }

    $cart_products = [
        [
            'id' => '1234',
            'name' => 'Test Product 1',
            'image_src' => '/assets/images/dummy/product-cart.jpg',
            'url' => '/products/1234',
            'price' => '$25',
            'qty' => '1',
            'sub_total' => '$25',
        ],

    ];

    $page_data['cart_products'] = $cart_products;

    $app->render('cart.twig', $page_data);
});