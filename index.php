<?php
require 'vendor/autoload.php';

$app = new \Slim\Slim();

$app->get('/hello/:name', function ($name) {
    $controller = new \Pikd\Controller\Base();

    $controller->render();
});

$app->run();