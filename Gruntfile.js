module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      build: {
        src: '<%= bower_concat.all.dest %>',
        dest: 'assets/javascripts/vendor.min.js'
      }
    },
    bower_concat: {
      all: {
        dest: 'build/_bower.js',
        cssDest: 'build/_bower.css',
        dependencies: {
          'parallax': 'jquery'
        },
        //exclude: ['parallax'],
        mainFiles: {
          'parallax': ['deploy/jquery.parallax.js']
        }
      }
    }
  });

  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-bower-concat');


  // Default task(s).
  grunt.registerTask('default', ['bower_concat', 'uglify']);

};