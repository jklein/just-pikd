var gulp        = require('gulp');
var minifyCSS   = require('gulp-minify-css');

module.exports = function(){
    return gulp.src('www/build/css/*.css')
                .pipe(minifyCSS())
                .pipe(gulp.dest('www/build/css/'));
};