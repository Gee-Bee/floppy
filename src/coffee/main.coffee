SPEED = 200
GRAVITY = 900
JET = 420
OPENING = 200
SPAWN_RATE = 1.25

state =

  init: ->
    text = "Phaser Version #{Phaser.VERSION} works!"
    style = { font: "24px Arial", fill: "#fff", align: "center" }
    t = game.add.text @world.centerX, @world.centerY, text, style
    t.anchor.setTo 0.5, 0.5

  preload: ->
    # this == game
    @load.image 'wall', '/assets/wall.png'
    @load.image 'background', '/assets/background-texture.png'
    @load.spritesheet 'player', '/assets/player.png', 48, 48
    @load.audio 'jet', '/assets/jet.wav'
    @load.audio 'score', '/assets/score.wav'
    @load.audio 'hurt', '/assets/hurt.wav'

  create: ->
    @physics.startSystem Phaser.Physics.ARCADE
    @physics.arcade.gravity.y = GRAVITY

    @background = @add.tileSprite 0, 0, @world.width, @world.height, 'background'
    @walls = @add.group()
    @player = @add.sprite 0, 0, 'player'
    @jetSnd = @add.audio 'jet'
    @scoreSnd = @add.audio 'score'
    @hurtSnd = @add.audio 'hurt'

    @player.animations.add 'fly', [0,1,2], 10, true
    @physics.arcade.enableBody @player
    @player.body.collideWorldBounds = true

    @scoreText = @add.text @world.centerX, @world.height/5, '',
      { size: '32px', fill: '#FFF', align: 'center' }
    @scoreText.setText "TOUCH TO\nSTART GAME"
    @scoreText.anchor.setTo 0.5, 0.5

    @input.onDown.add @jet, @
    @reset()

  update: ->
    if @gameStarted
      if @player.body.velocity.y > -20
        @player.frame = 3
      else
        @player.animations.play 'fly'
      unless @gameOver
        (@setGameOver(); return) if @player.body.bottom >= @world.bounds.bottom
        @physics.arcade.collide @player, @walls, @setGameOver, null, @
        @walls.forEachAlive (wall) ->
          switch
            when wall.x + wall.width < game.world.bounds.left then wall.kill()
            when !wall.scored and wall.x <= state.player.x then state.addScore(wall)
          wall.kill() if wall.x + wall.width < game.world.bounds.left

    else
      @player.y = @world.centerY + 8 * Math.cos(@time.now/200)

  reset: ->
    @gameStarted = false
    @gameOver = false
    @score = 0
    @walls.removeAll()

    @background.autoScroll -SPEED * 0.8, 0
    @player.body.allowGravity = false
    @player.reset @world.width/4, @world.centerY
    @player.animations.play 'fly'

  start: ->
    @player.body.allowGravity = true
    @scoreText.setText "SCORE\n#{@score}"
    @gameStarted = true
    @wallTimer = @game.time.events.loop Phaser.Timer.SECOND * SPAWN_RATE, @spawnWalls, @
    @wallTimer.timer.start()

  jet: ->
    @start() unless @gameStarted
    if not @gameOver
      @player.body.velocity.y = -JET
      @jetSnd.play()
    else if @time.now > @timeOver + 400
      @reset()

  setGameOver: ->
    @player.body.velocity.x = 0
    @hurtSnd.play()
    @gameOver = true
    @scoreText.setText "FINAL SCORE\n#{@score}\n\nTOUCH TO\nTRY AGAIN"
    @background.autoScroll 0, 0
    @timeOver = @time.now
    @walls.forEachAlive (wall) ->
      wall.body.velocity.x = wall.body.velocity.y = 0
    @wallTimer.timer.stop()

  spawnWall: (y, flipped) ->
    wall = @walls.create game.width, y + (if flipped then -OPENING else OPENING) / 2, 'wall'
    @physics.arcade.enableBody wall
    wall.body.allowGravity = false
    wall.body.immovable = true
    wall.body.velocity.x = -SPEED
    wall.scored = false
    if flipped
      wall.scale.y = -1
      wall.body.offset.y = -wall.body.height
    wall

  spawnWalls: ->
    wallY = @rnd.integerInRange game.height * 0.3, game.height * 0.7
    botWall = @spawnWall wallY
    topWall = @spawnWall wallY, true

  addScore: (wall) ->
    wall.scored = true
    @score += 0.5
    @scoreSnd.play()
    @scoreText.setText "SCORE\n#{@score}"


game = new Phaser.Game 480, 800, Phaser.AUTO, 'game', state
