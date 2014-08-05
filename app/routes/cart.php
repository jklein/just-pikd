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

    $cart = new Controller\Cart($app->user->getUserData()['customer_id']);
    $cart_products = $cart->getProducts();

    $total_price = $cart->getTotalPriceInCents();

    $page_data['cart_products'] = $cart_products;
    $page_data['cart_totals'] = [
        'display_price' => '$' . $total_price,
        'numeric_price' => $total_price,
        'products' => count($cart_products),
    ];

    $app->render('cart.twig', $page_data);
});

// Checking out
$app->post('/checkout', function() use ($app) {
    \Stripe::setApiKey($app->config['stripe']['secret_api_key']);

    // Get the credit card details submitted by the form
    $token = $app->request()->post('stripeToken');

    // Create the charge on Stripe's servers - this will charge the user's card
    try {
        $charge = \Stripe_Charge::create(array(
          "amount" => $app->request()->post('amount'), // amount in cents, again
          "currency" => "usd",
          "card" => $token,
          "description" => $app->request()->post('stripeEmail'))
        );
    } catch(\Stripe_CardError $e) {
      // The card has been declined
    }
});