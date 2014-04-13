var gulp = require('gulp');

module.exports = function() {
    return gulp.src('./www/assets/js/lib/*.js')
                .pipe(gulp.dest('./www/build/js'));
};