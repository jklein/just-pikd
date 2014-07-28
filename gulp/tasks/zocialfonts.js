var gulp = require('gulp');

module.exports = function(){
    return gulp.src('www/assets/fonts/zocial/css/*')
                .pipe(gulp.dest('www/build/fonts/zocial/'));
};