module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-gh-pages'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    deployDir: 'deploy'
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
          base: '<%= deployDir %>'
    uglify:
      deploy:
        src: [
          'src/vendor/phaser.js'
          'src/js/*.js'
        ]
        dest: '<%= deployDir %>/<%= pkg.name %>.js'
    copy:
      assets:
        cwd: 'src/assets'
        src: '**'
        dest: '<%= deployDir %>/assets'
        expand: true
    'gh-pages':
      options:
        base: 'deploy'
      src: '**'

  grunt.registerTask 'default', ['coffee', 'uglify', 'copy:assets', 'connect:deploy', 'watch:empty']
  grunt.registerTask 'dev', ['coffee', 'connect:dev', 'watch:coffee']
  grunt.registerTask 'gh', ['coffee', 'uglify', 'copy:assets', 'gh-pages']
