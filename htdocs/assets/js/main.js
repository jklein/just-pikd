require.config({
    urlArgs: "bust=" + (new Date()).getTime(),
    paths: {
        "jquery": "vendor/jquery/dist/jquery.min",
        "underscore": "vendor/underscore/underscore",
        "backbone": "vendor/backbone/backbone"
    },
    baseUrl: "/assets/js",
    waitSeconds: 5
});


require(['jquery', 'underscore', 'backbone'], function(jquery, _, Backbone){
    console.log(jquery);
    console.log(_);
    console.log(Backbone);
});