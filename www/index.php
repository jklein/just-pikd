<?php
require '../app/vendor/autoload.php';

session_cache_limiter(false);
session_start();

$app = new \Slim\Slim([
    'view' => new \Slim\Mustache\Mustache()
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
    'pragmas' => [Mustache_Engine::PRAGMA_BLOCKS],
);


// Set globally available data on the view
$view->appendData([
    'logged_in'      => !empty($_SESSION['email']),
    'config'         => $app->config,
    'year'           => date("Y"),
]);

$app->get('/', function () use ($app) {
    $controller = new \Pikd\Controller\Base();

    $app->flashNow('info', 'An info message');
    $app->flashNow('default', 'A default message');
    $app->flashNow('dark', 'A dark message');
    $app->flashNow('success', 'A success message');
    $app->flashNow('danger', 'A danger message');
    $app->flashNow('warning', explode(' ', 'array of warning messages'));

    $app->render('index', $controller->template_vars);
});

$app->get('/mustache_test', function () use ($app) {
    $app->render('test_article.mustache', ['name' => 'Jonathan']);
});

require '../app/routes/auth.php';
require '../app/routes/util.php';
require '../app/routes/product.php';
require '../app/routes/cart.php';

$app->run();
