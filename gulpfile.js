// Include gulp
var gulp = require('./gulp')([
    'compass',
    'minify',
    'fonts',
    'browserify',
    'rename',
    //'jshint',
    //'concat',
    //'uglify',
    'watch'
]);

gulp.task('build', ['compass', 'minify', 'fonts', 'browserify', 'rename']);
gulp.task('default', ['build', 'watch']);