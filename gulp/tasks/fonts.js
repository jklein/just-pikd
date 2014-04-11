var gulp = require('gulp');

module.exports = function(){
    return gulp.src('www/assets/scss/sass-bootstrap/fonts/*')
                .pipe(gulp.dest('www/build/css/sass-bootstrap/fonts/'));
};