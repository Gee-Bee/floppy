state =
  init: ->
    text = "Phaser Version #{Phaser.VERSION} works!"
    style = { font: "24px Arial", fill: "#fff", align: "center" }
    t = game.add.text this.world.centerX, this.world.centerY, text, style
    t.anchor.setTo 0.5, 0.5
  preload: ->
  create: ->
  update: ->

game = new Phaser.Game 800, 480, Phaser.AUTO, 'game', state
