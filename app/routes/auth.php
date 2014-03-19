<?php
// This will need to change, just an example
$app->map('/login', function() use ($app) {
    $page_data['page_title'] = sprintf("%s | Pikd", 'Login');

    if ($app->request()->isPost()) {
        $params = array(
            'email'     => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            'password'  => $app->request()->post('password'),
        );

        $dbcon = \Pikd\Persistence::get_database_object();
        $login = \Pikd\Auth::authenticate($dbcon, $params['email'], $params['password']);
        if ($login['valid']) {
            $app->flash('success', $login['messages']);
            $app->redirect('/');
        } else {
            $app->flashNow('danger', $login['messages']);
        }
    }

    $page_data['post_url'] = "/login";
    $page_data['content'] = "login";
    $app->render('page.php', $page_data);
})->via('GET', 'POST');