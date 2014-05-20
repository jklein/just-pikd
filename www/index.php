<?php
require '../app/vendor/autoload.php';

session_cache_limiter(false);
session_start();

$app = new \Slim\Slim([
    'view' => new \Slim\Views\Twig(),
]);

$app->connections = \Pikd\DB::getConnections();

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

    //$app->flashNow('info', ['test', 'test 2']);
    //$app->flashNow('warning', 'test warning');
    //$app->flashNow('danger', ['test danger', 'test danger 2']);
    \Pikd\Util::debug($_SESSION);

    $app->render('index.twig', $controller->template_vars);
});


$app->get('/memcached_test', function () use ($app) {
    $memcached = new \Pikd\Cache\Memcached();

    $tmp_object = new stdClass;
    $tmp_object->str_attr = 'test';
    $tmp_object->int_attr = 123;

    $memcached->set('key2', $tmp_object, 10);
    echo "Store data in the cache (data will expire in 10 seconds)<br/>\n";

    $get_result = $memcached->get('key2');
    echo "Data from the cache:<br/>\n";

    var_dump($get_result);

});


$app->get('/show_users', function () use ($app) {
    $conn = $app->connections->getRead('customer');
    $results = $conn->fetchAll('SELECT * from customers');
    \Pikd\Util::debug($results);
});


require '../app/routes/auth.php';

$app->run();
