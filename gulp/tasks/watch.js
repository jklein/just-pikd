var gulp       = require('gulp');
var livereload = require('gulp-livereload');

module.exports = function(){
    gulp.watch('www/assets/js/**/*', ['browserify']);
    gulp.watch('www/assets/scss/**', ['compass']);
    livereload();
};