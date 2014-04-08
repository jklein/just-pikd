<?php
require '../app/vendor/autoload.php';

$app = new \Slim\Slim([
    'view' => new \Slim\Views\Twig(),
]);

$view = $app->view();
$view->setTemplatesDirectory('/usr/share/nginx/html/app/templates');
$view->parserOptions = array(
    'debug' => true,
);

$app->get('/', function () use ($app) {
    $controller = new \Pikd\Controller\Base();

    $app->render('index.html', $controller->template_vars);
});

$app->run();