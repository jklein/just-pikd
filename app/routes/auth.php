<?php
// TODO: This will need to change, just an example

$app->map('/register', function() use ($app) {
    $page_data['page_title'] = sprintf("%s | TuneUp", 'Create an Account');
    $page_data['content_title'] = 'Create an Account';

    $page_data['post_url'] = "/register";

    if ($app->request()->isPost()) {
        $form_data = array(
            'first_name'        => filter_var($app->request()->post('first_name'), FILTER_SANITIZE_STRING),
            'last_name'         => filter_var($app->request()->post('last_name'), FILTER_SANITIZE_STRING),
            'email'             => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            'password'          => $app->request()->post('password'),
            'repeat_password'   => $app->request()->post('repeat_password'),
        );

        $registration = \Pikd\Auth::register($form_data);

        if ($registration['valid']) {
            $app->flash('success', $registration['messages']);
            $app->redirect('/login');
        } else {
            $app->flashNow('danger', $registration['messages']);
        }
        $page_data['user'] = $form_data;
    } else {
        $page_data['user'] = array(
            'first_name' => '',
            'last_name'  => '',
            'email'      => '',
            'password'   => '',
        );
    }

    $app->render('register.twig', $page_data);
})->via('GET', 'POST');

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

$app->get('/logout', function() use ($app) {
    $_SESSION = array();
    session_destroy();
    session_start(); // This is needed for the flash message
    $app->flash('success', 'You have been successfully logged out');
    $app->redirect('/');
});

$app->map('/account', function() use ($app) {
    $page_data['page_title'] = sprintf("%s | Pikd", 'Account');
    $page_data['content_title'] = 'Edit Your Information';

    if ($app->request()->isPost()) {
        $form_data = array(
            'first_name'        => filter_var($app->request()->post('first_name'), FILTER_SANITIZE_STRING),
            'last_name'         => filter_var($app->request()->post('last_name'), FILTER_SANITIZE_STRING),
            'email'             => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            'password'          => $app->request()->post('password'),
            'repeat_password'   => $app->request()->post('repeat_password'),
        );

        $update = \Pikd\Auth::update($form_data);

        if ($update['valid']) {
            $app->flash('success', $update['messages']);
            $app->redirect('/account');
        } else {
            $app->flashNow('danger', $update['messages']);
        }
    }

    //$page_data['user'] = \Pikd\Persistence::get_user($dbcon, $_SESSION['email']);

    $app->render('account.twig', $page_data);
})->via('GET', 'POST');
