<?php
require '../app/vendor/autoload.php';

session_cache_limiter(false);
session_start();

$app = new \Slim\Slim([
    'view' => new \Slim\Views\Twig(),
]);

$view = $app->view();
$view->setTemplatesDirectory(__DIR__ . '/../app/templates');
$view->parserOptions = array(
    'debug' => true,
);

$view->parserExtensions = array(
    new \Slim\Views\TwigExtension(),
    new Twig_Extension_Debug(),
);

$app->get('/', function () use ($app) {
    $controller = new \Pikd\Controller\Base();

    $app->flashNow('info', ['test', 'test 2']);
    $app->flashNow('warning', 'test warning');
    $app->flashNow('danger', ['test danger', 'test danger 2']);
    $app->render('index.twig', $controller->template_vars);
});

require '../app/routes/auth.php';

$app->run();
