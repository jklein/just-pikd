var gulp       = require('gulp');
var browserify = require('browserify');
var source     = require('vinyl-source-stream');
var livereload = require('gulp-livereload');
var notify     = require("gulp-notify");

module.exports = function() {
    return browserify('./www/assets/js/main.js')
        .bundle({debug: true})
        .on('error', notify.onError({
            message: "<%= error.message %>",
            title: "JavaScript Error"
        }))
        .pipe(source('bundle.js'))
        .pipe(gulp.dest('./www/build/js'))
        .pipe(livereload());
};