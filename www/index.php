<?php
require '../app/vendor/autoload.php';

session_cache_limiter(false);
session_start();

$app = new \Slim\Slim([
    'view' => new \Slim\Views\Twig(),
]);

// Set globally available data on the app object
$app->connections = \Pikd\DB::getConnections();
$app->config = \Pikd\Config::getConfiguration();

if (!empty($_SESSION['email'])) {
    $app->user = new \Pikd\Model\User($app->connections->getWrite('customer'), $_SESSION['email']);
} else {
    $app->user = null;
}

$view = $app->view();
$view->setTemplatesDirectory(__DIR__ . '/../app/templates');
$view->parserOptions = array(
    'debug' => true,
);

$view->parserExtensions = array(
    new \Slim\Views\TwigExtension(),
    new Twig_Extension_Debug(),
);

// Set globally available data on the view
$view->appendData([
    'logged_in' => !empty($_SESSION['email']),
    'config'    => $app->config,
]);

$app->get('/', function () use ($app) {
    $controller = new \Pikd\Controller\Base();
    $app->render('index.twig', $controller->template_vars);
});

require '../app/routes/auth.php';
require '../app/routes/util.php';
require '../app/routes/product.php';
require '../app/routes/cart.php';

$app->run();
