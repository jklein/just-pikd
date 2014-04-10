// Include gulp
var gulp = require('gulp');

// Include Our Plugins
var jshint = require('gulp-jshint');
var sass   = require('gulp-sass');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');

// Set some paths
var assets_dir = 'www/assets';
var build_dir = 'www/assets/build';

// Lint Task
gulp.task('lint', function() {
    return gulp.src(assets_dir + '/js/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});

// Compile Our Sass
gulp.task('sass', function() {
    return gulp.src(assets_dir + '/scss/*.scss')
        .pipe(sass())
        .pipe(gulp.dest(build_dir + '/css'));
});

// Concatenate & Minify JS
gulp.task('scripts', function() {
    return gulp.src(assets_dir + '/js/*.js')
        .pipe(concat('all.js'))
        .pipe(gulp.dest(build_dir + '/js'))
        .pipe(rename('all.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest(build_dir + '/js'));
});

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch(assets_dir + '/js/*.js', ['lint', 'scripts']);
    gulp.watch(assets_dir + '/scss/*.scss', ['sass']);
});

// Default Task
gulp.task('default', ['lint', 'sass', 'scripts', 'watch']);