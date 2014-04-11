// Include gulp
var gulp = require('./gulp')([
    //'browserify',
    'compass',
    'fonts',
    //'jshint',
    //'concat',
    //'uglify',
    //'rename',
    'watch'
]);

gulp.task('build', ['compass', 'fonts']);
gulp.task('default', ['build', 'watch']);