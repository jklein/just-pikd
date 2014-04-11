var compass    = require('gulp-compass');
var gulp       = require('gulp');
var livereload = require('gulp-livereload');
var notify     = require('gulp-notify');
var path       = require('path');

// Set some paths
var assets_dir = 'www/assets';
var build_dir = 'www/assets/build';

module.exports = function() {
    return gulp.src(assets_dir + '/scss/*.scss')
        .pipe(compass({
            config_file: 'compass.rb',
            css: 'build',
            sass: 'www/assets/scss'
        }))
        .on('error', notify.onError({
            message: "<%= error.message %>",
            title: "SASS Error"
        }));
};