var gulp = require('gulp');
var jshint  = require('gulp-jshint');

module.exports = function() {
    return gulp.src(assets_dir + '/js/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
};