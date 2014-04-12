// Include gulp
var gulp = require('./gulp')([
    'compass',
    'minify',
    'fonts',
    'browserify',
    //'jshint',
    //'concat',
    //'uglify',
    //'rename',
    'watch'
]);

gulp.task('build', ['compass', 'minify', 'fonts', 'browserify']);
gulp.task('default', ['build', 'watch']);