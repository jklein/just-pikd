<?php

use Monolog\Logger;
use Monolog\Handler\StreamHandler;

$app->get('/util/memcached_test', function () use ($app) {
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


$app->get('/util/show_users', function () use ($app) {
    $conn = $app->connections->getRead('customer');
    $results = $conn->fetchAll('SELECT * from customers');
    \Pikd\Util::debug($results);
});

// Test monolog
$app->get('/util/log', function () use ($app) {
    $log = new Logger('PIKD');
    $log->pushHandler(new StreamHandler('/var/log/testlog.log', Logger::WARNING));

    // add records to the log
    $log->addWarning('This is a generic warning');
    $log->addError('This is a generic error');
    $log->addError('This is a generic error with some data', ['some' => 'data']);
});
