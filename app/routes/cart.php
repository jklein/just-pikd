<?php

namespace Pikd;

// Adding a product to cart
$app->post('/cart', function() use ($app) {
    if ($app->user === null) {
        $app->flash('danger', 'You must be logged in to view this page');
        $app->redirect('/');
    }

    $pr_sku     = $app->request()->post('pr_sku');
    $pr_name    = $app->request()->post('pr_name');
    $list_cost  = $app->request()->post('list_cost');
    $ma_name    = $app->request()->post('ma_name');
    $qty        = $app->request()->post('qty');

    // Customer info
    $cu_id = $app->user->getUserData()['cu_id'];

    $db = $app->connections->getWrite('customer');
    $order = new Model\Order($db, $cu_id, $app->so_id, Model\Order::STATUS_BASKET);

    $product_data = [
        'op_or_id'             => $order->or_id,
        'op_pr_sku'            => $pr_sku,
        'op_product_name'      => $pr_name,
        'op_list_cost'         => $list_cost,
        'op_manufacturer_name' => $ma_name,
        'op_qty'               => $qty,
    ];
    $where = [
        'op_or_id'  => $order->or_id, 
        'op_pr_sku' => $pr_sku
    ];

    // TODO - should sum quanities if we add the same product again
    $order_product = new Model\OrderProduct($db, $order->or_id);
    $order_product->upsertProduct($product_data, $where);

    $app->redirect('/cart');
});

$app->get('/cart', function() use ($app) {
    $page_data['title'] = sprintf("%s | Pikd", 'Shopping Cart');

    if ($app->user === null) {
        $app->flash('danger', 'You must be logged in to view this page');
        $app->redirect('/');
    }

    $db = $app->connections->getWrite('customer');
    $product_db = $app->connections->getRead('product');
    $cart = new Controller\Cart($db, $app->user->getUserData()['cu_id'], $app->so_id);
    $cart_products = $cart->getProducts();

    $product_info_for_display = [];
    foreach ($cart_products as $p) {
        $product_info_for_display[] = array_merge($p, [
            "image_url" => \Pikd\Image::productFromSKU($product_db, $p['op_pr_sku']),
            "list_cost" => \Pikd\Util::formatPrice($p['op_list_cost']),
            "link"      => \Pikd\Controller\Product::getLink($p['op_pr_sku'], $p['op_product_name']),
            "sub_total" => \Pikd\Util::formatPrice($p['op_list_cost'] * $p['op_qty']),
        ]);
    }

    $total_price = $cart->getTotalPriceInCents();

    $page_data['cart_products'] = new \ArrayIterator($product_info_for_display);
    $page_data['cart_totals'] = [
        'display_price' => '$' . $total_price,
        'numeric_price' => $total_price,
        'num_products'       => count($cart_products),
    ];

    $app->render('cart', $page_data);
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