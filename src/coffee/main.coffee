SPEED = 200
GRAVITY = 900
JET = 420

state =
  init: ->
    text = "Phaser Version #{Phaser.VERSION} works!"
    style = { font: "24px Arial", fill: "#fff", align: "center" }
    t = game.add.text this.world.centerX, this.world.centerY, text, style
    t.anchor.setTo 0.5, 0.5
  preload: ->
    # this == game
    this.load.image 'wall', '/assets/wall.png'
    this.load.image 'background', '/assets/background-texture.png'
    this.load.spritesheet 'player', 'assets/player.png', 48, 48
  create: ->
    this.physics.startSystem Phaser.Physics.ARCADE
    this.physics.arcade.gravity.y = GRAVITY

    this.background = this.add.tileSprite 0, 0, this.world.width, this.world.height, 'background'
    this.player = this.add.sprite 0, 0, 'player'

    this.player.animations.add 'fly', [0,1,2], 10, true
    this.physics.arcade.enableBody this.player
    this.player.body.collideWorldBounds = true

    this.scoreText = @add.text @world.centerX, @world.height/5, '',
      { size: '32px', fill: '#FFF', align: 'center' }
    this.scoreText.setText "TOUCH TO\nSTART GAME"
    this.scoreText.anchor.setTo 0.5, 0.5

    @input.onDown.add @jet, @
    this.reset()
  update: ->
    if @gameStarted
      if @player.body.velocity.y > -20
        @player.frame = 3
      else
        @player.animations.play 'fly'
      unless @gameOver
        @setGameOver() if @player.body.bottom >= @world.bounds.bottom
    else
      @player.y = @world.centerY + 8 * Math.cos(@time.now/200)

  reset: ->
    this.gameStarted = false
    this.gameOver = false
    this.score = 0

    this.background.autoScroll -SPEED * 0.8, 0
    this.player.body.allowGravity = false
    this.player.reset this.world.width/4, this.world.centerY
    this.player.animations.play 'fly'

  start: ->
    @player.body.allowGravity = true
    @scoreText.setText "SCORE\n#{@score}"
    @gameStarted = true

  jet: ->
    @start() unless @gameStarted
    if not @gameOver
      @player.body.velocity.y = -JET
    else if @time.now > @timeOver + 400
      @reset()

  setGameOver: ->
    @gameOver = true
    @scoreText.setText "FINAL SCORE\n#{@score}\n\nTOUCH TO\nTRY AGAIN"
    @background.autoScroll 0, 0
    @timeOver = this.time.now

game = new Phaser.Game 800, 480, Phaser.AUTO, 'game', state
