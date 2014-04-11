var compass    = require('gulp-compass');
var gulp       = require('gulp');
var livereload = require('gulp-livereload');
var notify     = require('gulp-notify');
var path       = require('path');

module.exports = function() {
    return gulp.src('www/assets/scss/*.scss')
        .pipe(compass({
            config_file: 'config.rb',
            css: 'www/build/css',
            sass: 'www/assets/scss'
        }))
        .on('error', notify.onError({
            message: "<%= error.message %>",
            title: "SASS Error"
        }));
};