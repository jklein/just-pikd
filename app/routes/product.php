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
    $products = $conn->fetchAll('SELECT * from base_products bp
                join products p on bp.product_id = p.product_id
                limit 10');

    d($products);

    foreach ($products as $product) {
        $template_vars['products'][] = [
            'name'      => ucwords(strtolower($product['name'])),
            'list_cost' => $product['list_cost'],
            'id'        => $product['product_id'],
            'link'      => Controller\Product::getLink($product['product_id'], $product['name']),
            'image_src' => \Pikd\Image::product($product['manufacturer_id'], $product['default_image_id']),
            'category'  => Controller\Categories::getName($conn, $product['category_id']),
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
        d($template_vars);

        $app->render('product.twig', $template_vars);
    } else {
        $app->redirect('/404');
    }
});

$app->get('/images/:id', function($id) use ($app) {
    // Shows all of the images we have for a given product
    $conn = $app->connections->getRead('product');

    $sql = 'SELECT manufacturer_id, image_id from base_products bp
            join products p on bp.product_id = p.product_id
            join images i on i.sku = p.sku
            where bp.product_id = :id
            and rank = 1 and show_on_site = true
            order by image_id';

    $bind = ['id' => $id];
    $image_ids = $conn->fetchAll($sql, $bind);

    $image_srcs = [];
    foreach ($image_ids as $image_id) {
        $image_srcs[] = \Pikd\Image::product($image_id['manufacturer_id'], $image_id['image_id']);
    }

    $template_vars['image_srcs'] = $image_srcs;
    $app->render('images.twig', $template_vars);
});



