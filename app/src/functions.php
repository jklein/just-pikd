<?php

function d($variable) {
    echo '<pre>';
    if (is_array($variable)) {
        print_r($variable);
    } else {
        var_dump($variable);
    }
    echo '</pre>';
}