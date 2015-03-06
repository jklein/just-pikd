<?php

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use PhpAmqpLib\Connection\AMQPConnection;
use PhpAmqpLib\Message\AMQPMessage;

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

    $app->render('util', $template_vars);
});