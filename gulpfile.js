// Include gulp
var gulp = require('gulp');

// Include Our Plugins
var jshint = require('gulp-jshint');
var sass   = require('gulp-sass');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');

// Lint Task
gulp.task('lint', function() {
    return gulp.src('www/assets/js/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});

// Compile Our Sass
gulp.task('sass', function() {
    return gulp.src('www/assets/scss/*.scss')
        .pipe(sass())
        .pipe(gulp.dest('www/assets/build/css'));
});

// Concatenate & Minify JS
gulp.task('scripts', function() {
    return gulp.src('www/assets/js/*.js')
        .pipe(concat('all.js'))
        .pipe(gulp.dest('www/assets/build/js'))
        .pipe(rename('all.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('www/assets/build/js'));
});

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch('www/assets/js/*.js', ['lint', 'scripts']);
    gulp.watch('www/assets/scss/*.scss', ['sass']);
});

// Default Task
gulp.task('default', ['lint', 'sass', 'scripts', 'watch']);