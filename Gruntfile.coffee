module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        expand: true
        flatten: true
        cwd: "#{__dirname}/src/coffee"
        src: '**/*.coffee'
        dest: 'src/js'
        ext: '.js'
    watch:
      coffee:
        files: 'src/coffee/*.coffee'
        tasks: ['coffee:compile']
        options:
          livereload: true
      empty:
        files: []
    connect:
      dev:
        options:
          base: 'src'
      deploy:
        options:
          base: 'deploy'
    uglify:
      deploy:
        src: [
          'src/vendor/phaser.js'
          'src/js/*.js'
        ]
        dest: 'deploy/<%= pkg.name %>.js'

  grunt.registerTask 'default', ['coffee', 'uglify', 'connect:deploy', 'watch:empty']
  grunt.registerTask 'dev', ['coffee', 'connect:dev', 'watch:coffee']
