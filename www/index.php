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


/****** DEBUG BAR ******/
// TODO - remove in prod
use DebugBar\StandardDebugBar;
$debugbar = new StandardDebugBar();

// Collectors
$debugbar->addCollector(new DebugBar\Bridge\SlimCollector($app));
$debugbar->addCollector(new DebugBar\DataCollector\ConfigCollector($app->config));

$debugbarRenderer = $debugbar->getJavascriptRenderer();
/****** DEBUG BAR ******/

if (!empty($_SESSION['cu_email'])) {
    $app->user = new \Pikd\Model\User($app->connections->getWrite('customer'), $_SESSION['cu_email']);
} else {
    $app->user = null;
}

// TODO - This should be a real Store ID
$app->so_id = 1;

$view = $app->view();
$view->setTemplatesDirectory(__DIR__ . '/../app/src/Views');
$view->parserOptions = array(
    'pragmas' => [Mustache_Engine::PRAGMA_BLOCKS],
);

// Set globally available data on the view
$view->appendData([
    'logged_in'  => !empty($_SESSION['email']),
    'config'     => $app->config,
    'year'       => date("Y"),
    'debug_head' => $debugbarRenderer->renderHead(),

]);

require '../app/routes.php';

$app->run();

$view_data = $app->view->getData();
unset($view_data['flash']);

$profiles = $app->connections->getRead('product')->getProfiler()->getProfiles();
$debugbar->addCollector(new \Pikd\DataCollector\SQLQueries($profiles));

ksort($view_data);
$debugbar->addCollector(new \Pikd\DataCollector\ViewData($view_data));

echo $debugbarRenderer->render();