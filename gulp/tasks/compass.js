var gulp       = require('gulp');
var notify     = require('gulp-notify');
var compass    = require('gulp-compass');
var path       = require('path');


module.exports = function() {
    return gulp.src('www/assets/scss/*.scss')
        .pipe(compass({
            css: 'www/build/css',
            image: 'www/assets/images',
            relative: true,
            sass: 'www/assets/scss'
        }))
        .on('error', notify.onError({
            message: "<%= error.message %>",
            title: "SASS Error"
        }));
};