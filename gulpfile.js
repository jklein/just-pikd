// Include gulp
var gulp = require('./gulp')([
    //'browserify',
    'compass',
    'minify',
    'fonts',
    //'jshint',
    //'concat',
    //'uglify',
    //'rename',
    'watch'
]);

gulp.task('build', ['compass', 'minify', 'fonts']);
gulp.task('default', ['build', 'watch']);