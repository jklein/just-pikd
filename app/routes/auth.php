<?php
$app->map('/register', function() use ($app) {
    $db_conn = $app->connections->getWrite('customer');

    $page_data['title'] = 'Create an Account';
    $page_data['post_url'] = "/register";

    if ($app->request()->isPost()) {
        $form_data = array(
            'email'             => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            'password'          => $app->request()->post('password'),
        );

        $registration = \Pikd\Auth::register($db_conn, $form_data);

        if ($registration['valid']) {
            $app->flash('success', $registration['messages']);
            $app->redirect('/account');
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

$app->post('/login', function() use ($app) {
    $db_conn = $app->connections->getWrite('customer');

    $params = array(
        'email'     => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
        'password'  => $app->request()->post('password'),
    );

    $login = \Pikd\Auth::authenticate($db_conn, $params['email'], $params['password']);
    if ($login['valid']) {
        $app->flash('success', $login['messages']);
        $app->redirect('/');
    } else {
        $app->flash('danger', $login['messages']);
        $app->redirect('/');
    }
});

$app->get('/logout', function() use ($app) {
    $_SESSION = array();
    session_destroy();
    session_start(); // This is needed for the flash message
    $app->flash('success', 'You have been successfully logged out');
    $app->redirect('/');
});

$app->map('/account', function() use ($app) {
    $db_conn = $app->connections->getWrite('customer');

    $page_data['title'] = sprintf("%s | Pikd", 'Account');

    if ($app->request()->isPost()) {
        // They could be updating information about themself, or they could be
        // changing their password
        if ($app->request()->post('change_password')) {
            $form_data = array(
                'old_password'    => $app->request()->post('old_password'),
                'new_password'    => $app->request()->post('new_password'),
                'repeat_password' => $app->request()->post('repeat_password'),
            );
            $update = \Pikd\Auth::updatePassword($form_data);
        } else {
            $form_data = array(
                'first_name' => filter_var($app->request()->post('first_name'), FILTER_SANITIZE_STRING),
                'last_name'  => filter_var($app->request()->post('last_name'), FILTER_SANITIZE_STRING),
                'email'      => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            );
            $update = \Pikd\Auth::updateInfo($form_data);
        }

        if ($update['valid']) {
            $app->flashNow('success', $update['messages']);
        } else {
            $app->flashNow('danger', $update['messages']);
        }
    }

    $page_data['user'] = \Pikd\Model\User::getUser($db_conn, $_SESSION['email']);

    $app->render('account.twig', $page_data);
})->via('GET', 'POST');
