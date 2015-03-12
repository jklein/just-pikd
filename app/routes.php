<?php

namespace Pikd;

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use PhpAmqpLib\Connection\AMQPConnection;
use PhpAmqpLib\Message\AMQPMessage;

$app->post('/register', function() use ($app) {
    $form_data = array(
        'email'    => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
        'password' => $app->request()->post('password'),
    );

    $db_conn = $app->connections->getWrite('customer');
    $auth = new \Pikd\Controller\Auth($db_conn);
    $registration = $auth->register($form_data);

    if ($registration['valid']) {
        $app->flash('success', $registration['messages']);
        $app->redirect('/account');
    } else {
        $app->flash('danger', $registration['messages']);
        $app->redirect('/');
    }
});

$app->post('/login', function() use ($app) {
    $db_conn = $app->connections->getWrite('customer');
    $auth = new \Pikd\Controller\Auth($db_conn);

    $params = array(
        'email'     => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
        'password'  => $app->request()->post('password'),
    );

    $login = $auth->authenticate($params['email'], $params['password']);
    if ($login['valid']) {
        $app->flash('success', $login['messages']);
        $app->redirect('/');
    } else {
        $app->flash('danger', $login['messages']);
        $app->redirect('/');
    }
});

$app->get('/logout', function() use ($app) {
    $_SESSION = array();
    session_destroy();
    session_start(); // This is needed for the flash message
    $app->flash('success', 'You have been successfully logged out');
    $app->redirect('/');
});

$app->map('/account', function() use ($app) {
    $page_data['title'] = sprintf("%s | Pikd", 'Account');

    if ($app->user === null) {
        $app->redirect('/');
    }

    if ($app->request()->isPost()) {
        $db_conn = $app->connections->getWrite('customer');
        $auth = new \Pikd\Controller\Auth($db_conn, $app->user);

        // They could be updating information about themself, or they could be
        // changing their password
        if ($app->request()->post('change_password')) {
            $form_data = array(
                'old_password'    => $app->request()->post('old_password'),
                'new_password'    => $app->request()->post('new_password'),
                'repeat_password' => $app->request()->post('repeat_password'),
            );
            $update = $auth->updatePassword($form_data);
        } else {
            $form_data = array(
                'first_name' => filter_var($app->request()->post('first_name'), FILTER_SANITIZE_STRING),
                'last_name'  => filter_var($app->request()->post('last_name'), FILTER_SANITIZE_STRING),
                'email'      => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            );
            $update = $auth->updateInfo($form_data);
        }

        if ($update['valid']) {
            $app->flashNow('success', $update['messages']);
        } else {
            $app->flashNow('danger', $update['messages']);
        }
    }

    $page_data['user'] = $app->user->getUserData();

    $app->render('account', $page_data);
})->via('GET', 'POST');


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
        'display_price' => \Pikd\Util::formatPrice($total_price),
        'numeric_price' => $total_price,
        'num_products'       => count($cart_products),
    ];

    $app->render('cart', $page_data);
});

// Checking out
$app->post('/checkout', function() use ($app) {
    \Stripe\Stripe::setApiKey($app->config['stripe']['secret_api_key']);

    // Get the credit card details submitted by the form
    $token = $app->request()->post('stripeToken');

    // Create the charge on Stripe's servers - this will charge the user's card
    $charge = \Stripe\Charge::create(array(
      "amount" => $app->request()->post('amount'), // amount in cents, again
      "currency" => "usd",
      "card" => $token,
      "description" => $app->request()->post('stripeEmail'))
    );

    $app->flash('success', 'Order Placed!');
    $app->redirect('/'); 
});

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

$app->get('/util/testall', function () use ($app) {
    // Memcached
    $memcached = new \Pikd\Cache\Memcached();

    $tmp_object = new stdClass;
    $tmp_object->str_attr = 'test';
    $tmp_object->int_attr = 123;
    $memcached->set('key2', $tmp_object, 10);
    $template_vars['memcached_string'] = $memcached->get('key2')->str_attr;
    $template_vars['memcached_int'] = $memcached->get('key2')->int_attr;

    // Database
    $conn = $app->connections->getRead('customer');
    $template_vars['users'] = $conn->fetchAll('SELECT * from customers limit 1');
    d($template_vars['users']);

    // Monolog
    $log = new Logger('PIKD');
    $log->pushHandler(new StreamHandler('/var/log/testlog.log', Logger::WARNING));

    // add records to the log
    $log->addWarning('This is a generic warning');
    $log->addError('This is a generic error');
    $log->addError('This is a generic error with some data', ['some' => 'data']);

    $app->flashNow('info', 'An info message');
    $app->flashNow('default', 'A default message');
    $app->flashNow('dark', 'A dark message');
    $app->flashNow('success', 'A success message');
    $app->flashNow('danger', 'A danger message');
    $app->flashNow('warning', explode(' ', 'array of warning messages'));

    
    $app->render('util', $template_vars);
});