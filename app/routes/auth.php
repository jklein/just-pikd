<?php
$app->post('/register', function() use ($app) {
    $form_data = array(
        'email'    => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
        'password' => $app->request()->post('password'),
    );

    $db_conn = $app->connections->getWrite('customer');
    $auth = new \Pikd\Controller\Auth($db_conn);
    $registration = $auth->register($form_data);

    if ($registration['valid']) {
        $app->flash('success', $registration['messages']);
        $app->redirect('/account');
    } else {
        $app->flash('danger', $registration['messages']);
        $app->redirect('/');
    }
});

$app->post('/login', function() use ($app) {
    $db_conn = $app->connections->getWrite('customer');
    $auth = new \Pikd\Controller\Auth($db_conn);

    $params = array(
        'email'     => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
        'password'  => $app->request()->post('password'),
    );

    $login = $auth->authenticate($params['email'], $params['password']);
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
    $page_data['title'] = sprintf("%s | Pikd", 'Account');

    // @TODO - Need a login check here
    // $app->ensureLoggedIn() or something


    if ($app->request()->isPost()) {
        $db_conn = $app->connections->getWrite('customer');
        $auth = new \Pikd\Controller\Auth($db_conn, $app->user);

        // They could be updating information about themself, or they could be
        // changing their password
        if ($app->request()->post('change_password')) {
            $form_data = array(
                'old_password'    => $app->request()->post('old_password'),
                'new_password'    => $app->request()->post('new_password'),
                'repeat_password' => $app->request()->post('repeat_password'),
            );
            $update = $auth->updatePassword($form_data);
        } else {
            $form_data = array(
                'first_name' => filter_var($app->request()->post('first_name'), FILTER_SANITIZE_STRING),
                'last_name'  => filter_var($app->request()->post('last_name'), FILTER_SANITIZE_STRING),
                'email'      => filter_var($app->request()->post('email'), FILTER_VALIDATE_EMAIL),
            );
            $update = $auth->updateInfo($form_data);
        }

        if ($update['valid']) {
            $app->flashNow('success', $update['messages']);
        } else {
            $app->flashNow('danger', $update['messages']);
        }
    }

    $page_data['user'] = $app->user->getUserData();

    $app->render('account.twig', $page_data);
})->via('GET', 'POST');
