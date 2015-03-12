<?php

require '../app/vendor/autoload.php';

$test_mode = isset($argv[1]) && $argv[1] = 'test';

$connections = \Pikd\DB::getConnections();

$product_db = $connections->getRead('product');
$customer_db = $connections->getRead('customer');

$product_tables = [
    'attribute_values',
    'attributes',
    'products_suppliers',
    'stores',
    'brands',
    'categories',
    'images',
    'manufacturers',
    'product_families',
    'products',
    'products_stores',
    'suppliers',
];

$customer_tables = [
    'order_products',
    'address_books',
    'customers',
    'orders',
];

foreach ($product_tables as $table_name) {
    echo 'Making model for table ' . $table_name . PHP_EOL;
    generateModel($product_db, $table_name, $test_mode);
}

foreach ($customer_tables as $table_name) {
    echo 'Making model for table ' . $table_name . PHP_EOL;
    generateModel($customer_db, $table_name, $test_mode);
}

function generateModel($db, $table_name, $test_mode) {
    $sql = 'select column_name from information_schema.columns where table_name = :table_name';
 
    $columns = $db->fetchAll($sql, ['table_name' => $table_name]);

    $model_name = make_class_name($table_name);

    $model = '<?php

namespace Pikd\Models;

class ' . $model_name . ' {

';

    $model .= "\tconst TABLE = '$table_name';\n\n";

    foreach ($columns as $c) {
        $model .= "\t" . 'public $' . $c['column_name'] . ';' . PHP_EOL;
    }

    $model .= '}';

    if ($test_mode) {
        echo $model;
    } else {
        file_put_contents('models/' . $model_name . '.php', $model);
    }
}


function make_class_name($table_name) {
    $name = str_replace(' ', '', ucwords(str_replace('_', ' ', $table_name)));

    if (substr($name, -3) === 'ies') {
        return substr($name, 0, -3) . 'y';
    } else {
        return substr($name, 0, -1);
    }

    
}
