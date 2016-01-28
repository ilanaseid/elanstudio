module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    // Lint definitions
    jshint: {
      files: [
        "app/assets/javascripts/*.js",
        "app/assets/javascripts/**/*.js"],
      options: {
        jshintrc: ".jshintrc"
      }
    },
    clean: {
      pre: [
        'app/assets/images/icons/*.svg',
        'app/assets/images/icons/*.png'
      ], //removes old data
      post: [
        'app/assets/images/icons/*.js',
        'app/assets/images/icons/*.css',
        'app/assets/images/icons/png',
        'app/assets/images/icons/preview.html',
        'app/assets/javascripts/grunticon.loader.js'
      ]
    },
    svgmin: {
      options: {
        plugins: [
          { removeViewBox: false },
          { removeUselessStrokeAndFill: false }
        ]
      },
      dist: {
        files: [{
          expand: true,
          cwd: 'src/assets/images/icons',
          src: ['*.svg'],
          dest: 'app/assets/images/icons'
        }]
      }
    },
    grunticon: {
      foo: {
        files: [{
          expand: true,
          cwd: 'app/assets/images/icons',
          src: ['*.svg'],
          dest: 'app/assets/images/icons'
        }],
        options: {
          pngfolder: 'png',
          pngpath: 'assets/icons/',
          cssprefix: '.',
          customselectors: {
            "*" : [".$1-ia:after"],
          }
        }
      }
    },
    copy: {
      copyCSS: {
        expand: true,
        src: 'app/assets/images/icons/*.css',
        dest: 'app/assets/stylesheets/',
        flatten: true,
        filter: "isFile"
      },
      copyJS: {
        expand: true,
        src: 'app/assets/images/icons/*.js',
        dest: 'app/assets/javascripts/',
        flatten: true,
        filter: "isFile"
      },
      copyPNG: {
        expand: true,
        src: 'app/assets/images/icons/png/*.png',
        dest: 'app/assets/images/icons/',
        flatten: true,
        filter: "isFile"
      }
    }

  });

  // Load the plugins
  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-contrib-jshint");
  grunt.loadNpmTasks('grunt-grunticon');
  grunt.loadNpmTasks('grunt-svgmin');

  // Default task(s).
  grunt.registerTask("default", ["jshint"]);
  grunt.registerTask("svg", ["clean:pre","svgmin","grunticon","copy","clean:post"]);
  grunt.registerTask("svgminn", ["svgmin"]);

};
