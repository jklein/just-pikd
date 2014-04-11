var gulp       = require('gulp');

module.exports = function(){
    gulp.src('www/assets/scss/sass-bootstrap/fonts/*')
    .pipe(gulp.dest('www/build/css/sass-bootstrap/fonts/'));
};