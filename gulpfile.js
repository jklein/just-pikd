// Include gulp
var gulp = require('./gulp')([
    //'browserify',
    'compass',
    //'jshint',
    //'concat',
    //'uglify',
    //'rename',
    'watch'
]);

gulp.task('build', ['compass']);
gulp.task('default', ['build', 'watch']);