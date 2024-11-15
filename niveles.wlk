
import wollok.game.*
import pantallas.*
import extras.*
import players.*
import config.*

class Nivel {
  var property map
  var property multiplayer = false
  const property players = #{player1,player2,player3,player4}
  var property objetosEnMapa = 74
  var property ganador = null
  var property ultimoEnMorir = null
  const visuals = #{ player1, player2, player3, player4,
      caraPlayer1, caraPlayer2, caraPlayer3, caraPlayer4,
      vidaPlayer1, vidaPlayer2, vidaPlayer3, vidaPlayer4,
      bombasPlayer1, bombasPlayer2, bombasPlayer3, bombasPlayer4,
      puntajePlayer1, puntajePlayer2, puntajePlayer3, puntajePlayer4}

  method iniciar(modo) {
    game.addVisual(tableroPiso)
    game.addVisual(tableroPuntajes)

    self.multiplayer(modo)
    self.constructorMapa()

    //* Players y display
    visuals.forEach({ cosa => game.addVisual(cosa) })

    config.configurarTeclas()
    config.configurarColisiones()
  }

  method seMurio(player) {
    players.remove(player)
  }

  method seMurio_player1() = !players.contains(player1)
  method seMurio_player2() = !players.contains(player2)
  method seMurieron_players() = self.seMurio_player1() && self.seMurio_player2()
  method seMurieronTodos() = players.size() == 1

  method sinBombas() = players.all({ player => player.bombas() == 0 })

  method restarObj() {
    objetosEnMapa -= 1
  }
  method reiniciarPlayers() {
    player1.reiniciar(game.at(7,1))
    player2.reiniciar(game.at(21,1))
    player3.reiniciar(game.at(7,13))
    player4.reiniciar(game.at(21,13))
    players.clear()
    players.add(player1)
    players.add(player2)
    players.add(player3)
    players.add(player4)
    objetosEnMapa = 74
  }

  method termina() {
    if (self.multiplayer()) {
        if (self.seMurieron_players()) self.pierden(perdedor_multiplayer)
        else if (objetosEnMapa.equals(0)) self.ganaSinObjetos()
        else if (self.seMurieronTodos()) self.lastStanding() 
        else if (self.sinBombas()) self.ganaSinBombas()
    } else {
        if (self.seMurio_player1()) self.pierden(perdedor_singleplayer)
        else if (objetosEnMapa.equals(0)) self.ganaSinObjetos()
        else if (self.seMurieronTodos()) self.lastStanding()
        else if (self.sinBombas()) self.ganaSinBombas()
    } // si no es multijugador 
  }
  method lastStanding() {
    ganador = players.asList().first()
    game.clear()
    game.addVisual(ganadorOverlay)
    keyboard.enter().onPressDo({ 
      game.clear()
      config.reiniciarJuego() 
    })
  }
  method ganaSinBombas() {
    ganador = players.max({ player => player.puntaje() })
    game.clear()
    game.addVisual(ganadorOverlay_sinBombas) 
    keyboard.enter().onPressDo({ config.reiniciarJuego() })
  }
  method ganaSinObjetos() {
    ganador = players.max({ player => player.puntaje() })
    game.clear()
    game.addVisual(ganadorOverlay)
    keyboard.enter().onPressDo({ config.reiniciarJuego() })
  }
  method pierden(modoDeJuego) {
    game.clear()
    game.addVisual(modoDeJuego)
    keyboard.enter().onPressDo({ config.reiniciarJuego() })
  }

  // CONSTRUCTOR
method construyePared(x, y) {
      const bloque = new Wall (position = game.at(x, y))
      game.addVisual(bloque)
    }

    method construyeSilla(x, y) {
      const bloque = new Silla (position = game.at(x, y))
      game.addVisual(bloque)
    }

    method construyeBotellaRoja(x, y) {
      const bloque = new BotellaRoja (position = game.at(x, y))
      game.addVisual(bloque)
    }

    method construyeBotellaAzul(x, y) {
      const bloque = new BotellaAzul (position = game.at(x, y))
      game.addVisual(bloque)
    }

    method construyeBarril(x, y) {
      const bloque = new Barril (position = game.at(x, y))
      game.addVisual(bloque) 
    }

    // posiciones_y_tipo = [[X, Y], Z]
    // posiciones = [X, Y]
    // tipo = Z (0, 1 o 2. 0 es que no hay nada, 1 es que hay un bloque rompible, 2 que es una pared solida)
    method constructorMapa() {
      self.map().forEach({ posiciones_y_tipo => 
        var tipo = 0
        var posiciones = 0
        tipo = posiciones_y_tipo.get(1)
        posiciones = posiciones_y_tipo.get(0)

        if (tipo == 2) {
              self.construyePared(posiciones.get(0), posiciones.get(1))
          } else if (tipo == 1) {
              // Esto es para que ponga un item cualquiera de los que hay
              const random = 1.randomUpTo(5).truncate(0)
              if (random == 1) {
                  self.construyeSilla(posiciones.get(0), posiciones.get(1))
              } else if (random == 2) {
                  self.construyeBotellaRoja(posiciones.get(0), posiciones.get(1))
              } else if (random == 3) {
                  self.construyeBotellaAzul(posiciones.get(0), posiciones.get(1))
              } else {
                  self.construyeBarril(posiciones.get(0), posiciones.get(1))
              }
      }})
    } 

}

// 7,1 y 21,1
// 7,13 y 21,13
object nivel1 inherits Nivel (map = [
    // Fila 13 (de izquierda a derecha en las columnas)
    [[7, 13], 0], [[8, 13], 0], [[9, 13], 1], [[10, 13], 1], [[11, 13], 0], [[12, 13], 1], [[13, 13], 0], [[14, 13], 1], [[15, 13], 1], [[16, 13], 1], [[17, 13], 0], [[18, 13], 1], [[19, 13], 0], [[20, 13], 0], [[21, 13], 0],
    // Fila 12
    [[7, 12], 0], [[8, 12], 0], [[9, 12], 2], [[10, 12], 0], [[11, 12], 1], [[12, 12], 0], [[13, 12], 2], [[14, 12], 0], [[15, 12], 0], [[16, 12], 1], [[17, 12], 0], [[18, 12], 0], [[19, 12], 2], [[20, 12], 1], [[21, 12], 0],
    // Fila 11
    [[7, 11], 0], [[8, 11], 2], [[9, 11], 1], [[10, 11], 0], [[11, 11], 1], [[12, 11], 1], [[13, 11], 0], [[14, 11], 1], [[15, 11], 1], [[16, 11], 1], [[17, 11], 0], [[18, 11], 1], [[19, 11], 2], [[20, 11], 0], [[21, 11], 1],
    // Fila 10
    [[7, 10], 1], [[8, 10], 1], [[9, 10], 0], [[10, 10], 1], [[11, 10], 0], [[12, 10], 1], [[13, 10], 0], [[14, 10], 2], [[15, 10], 1], [[16, 10], 1], [[17, 10], 0], [[18, 10], 2], [[19, 10], 1], [[20, 10], 1], [[21, 10], 0],
    // Fila 9
    [[7, 9], 0], [[8, 9], 0], [[9, 9], 1], [[10, 9], 2], [[11, 9], 1], [[12, 9], 1], [[13, 9], 0], [[14, 9], 2], [[15, 9], 2], [[16, 9], 0], [[17, 9], 1], [[18, 9], 2], [[19, 9], 0], [[20, 9], 0], [[21, 9], 0],
    // Fila 8
    [[7, 8], 0], [[8, 8], 0], [[9, 8], 0], [[10, 8], 2], [[11, 8], 2], [[12, 8], 1], [[13, 8], 0], [[14, 8], 1], [[15, 8], 0], [[16, 8], 0], [[17, 8], 0], [[18, 8], 1], [[19, 8], 1], [[20, 8], 0], [[21, 8], 1],
    // Fila 7
    [[7, 7], 0], [[8, 7], 0], [[9, 7], 2], [[10, 7], 1], [[11, 7], 1], [[12, 7], 0], [[13, 7], 1], [[14, 7], 2], [[15, 7], 2], [[16, 7], 0], [[17, 7], 0], [[18, 7], 2], [[19, 7], 1], [[20, 7], 0], [[21, 7], 1],
    // Fila 6
    [[7, 6], 2], [[8, 6], 2], [[9, 6], 0], [[10, 6], 0], [[11, 6], 0], [[12, 6], 1], [[13, 6], 1], [[14, 6], 1], [[15, 6], 2], [[16, 6], 0], [[17, 6], 0], [[18, 6], 2], [[19, 6], 0], [[20, 6], 2], [[21, 6], 1],
    // Fila 5
    [[7, 5], 0], [[8, 5], 0], [[9, 5], 0], [[10, 5], 1], [[11, 5], 0], [[12, 5], 1], [[13, 5], 0], [[14, 5], 2], [[15, 5], 1], [[16, 5], 1], [[17, 5], 2], [[18, 5], 2], [[19, 5], 1], [[20, 5], 0], [[21, 5], 1],
    // Fila 4
    [[7, 4], 2], [[8, 4], 1], [[9, 4], 0], [[10, 4], 1], [[11, 4], 2], [[12, 4], 1], [[13, 4], 0], [[14, 4], 1], [[15, 4], 0], [[16, 4], 1], [[17, 4], 0], [[18, 4], 1], [[19, 4], 0], [[20, 4], 0], [[21, 4], 1],
    // Fila 3
    [[7, 3], 1], [[8, 3], 0], [[9, 3], 1], [[10, 3], 1], [[11, 3], 1], [[12, 3], 2], [[13, 3], 0], [[14, 3], 1], [[15, 3], 0], [[16, 3], 0], [[17, 3], 2], [[18, 3], 2], [[19, 3], 1], [[20, 3], 1], [[21, 3], 0],
    // Fila 2
    [[7, 2], 0], [[8, 2], 2], [[9, 2], 0], [[10, 2], 1], [[11, 2], 1], [[12, 2], 1], [[13, 2], 0], [[14, 2], 1], [[15, 2], 1], [[16, 2], 0], [[17, 2], 0], [[18, 2], 0], [[19, 2], 2], [[20, 2], 0], [[21, 2], 1],
    // Fila 1
    [[7, 1], 0], [[8, 1], 0], [[9, 1], 0], [[10, 1], 2], [[11, 1], 0], [[12, 1], 1], [[13, 1], 1], [[14, 1], 0], [[15, 1], 1], [[16, 1], 1], [[17, 1], 0], [[18, 1], 0], [[19, 1], 0], [[20, 1], 0], [[21, 1], 0]
]){
}

// object nivel2 inherits Nivel ( map = [
//     // Fila 14
//     [[14,0], 0], [[14,1], 0], [[14,2], 1], [[14,3], 2], [[14,4], 0], [[14,5], 1], [[14,6], 0], [[14,7], 0], [[14,8], 1], [[14,9], 0], [[14,10], 2], [[14,11], 1], [[14,12], 1], [[14,13], 1], [[14,14], 0],
//     // Fila 13
//     [[13,0], 0], [[13,1], 2], [[13,2], 0], [[13,3], 0], [[13,4], 0], [[13,5], 0], [[13,6], 2], [[13,7], 1], [[13,8], 1], [[13,9], 2], [[13,10], 0], [[13,11], 0], [[13,12], 1], [[13,13], 0], [[13,14], 2],
//     // Fila 12
//     [[12,0], 1], [[12,1], 0], [[12,2], 0], [[12,3], 0], [[12,4], 1], [[12,5], 1], [[12,6], 0], [[12,7], 1], [[12,8], 2], [[12,9], 0], [[12,10], 0], [[12,11], 1], [[12,12], 0], [[12,13], 2], [[12,14], 0],
//     // Fila 11
//     [[11,0], 0], [[11,1], 1], [[11,2], 1], [[11,3], 2], [[11,4], 0], [[11,5], 2], [[11,6], 2], [[11,7], 2], [[11,8], 1], [[11,9], 1], [[11,10], 0], [[11,11], 2], [[11,12], 1], [[11,13], 0], [[11,14], 1],
//     // Fila 10
//     [[10,0], 2], [[10,1], 0], [[10,2], 0], [[10,3], 1], [[10,4], 2], [[10,5], 0], [[10,6], 1], [[10,7], 1], [[10,8], 0], [[10,9], 0], [[10,10], 0], [[10,11], 0], [[10,12], 2], [[10,13], 2], [[10,14], 0],
//     // Fila 9
//     [[9,0], 1], [[9,1], 1], [[9,2], 0], [[9,3], 1], [[9,4], 1], [[9,5], 2], [[9,6], 1], [[9,7], 1], [[9,8], 0], [[9,9], 1], [[9,10], 1], [[9,11], 1], [[9,12], 0], [[9,13], 0], [[9,14], 1],
//     // Fila 8
//     [[8,0], 0], [[8,1], 2], [[8,2], 2], [[8,3], 1], [[8,4], 1], [[8,5], 1], [[8,6], 0], [[8,7], 2], [[8,8], 1], [[8,9], 2], [[8,10], 1], [[8,11], 2], [[8,12], 2], [[8,13], 0], [[8,14], 2],
//     // Fila 7
//     [[7,0], 0], [[7,1], 1], [[7,2], 0], [[7,3], 2], [[7,4], 0], [[7,5], 0], [[7,6], 1], [[7,7], 0], [[7,8], 1], [[7,9], 1], [[7,10], 2], [[7,11], 2], [[7,12], 1], [[7,13], 1], [[7,14], 0],
//     // Fila 6
//     [[6,0], 0], [[6,1], 1], [[6,2], 1], [[6,3], 1], [[6,4], 2], [[6,5], 1], [[6,6], 0], [[6,7], 0], [[6,8], 1], [[6,9], 1], [[6,10], 1], [[6,11], 0], [[6,12], 0], [[6,13], 2], [[6,14], 1],
//     // Fila 5
//     [[5,0], 2], [[5,1], 1], [[5,2], 1], [[5,3], 1], [[5,4], 0], [[5,5], 2], [[5,6], 0], [[5,7], 2], [[5,8], 0], [[5,9], 1], [[5,10], 1], [[5,11], 0], [[5,12], 1], [[5,13], 1], [[5,14], 1],
//     // Fila 4
//     [[4,0], 1], [[4,1], 0], [[4,2], 0], [[4,3], 2], [[4,4], 1], [[4,5], 1], [[4,6], 1], [[4,7], 2], [[4,8], 1], [[4,9], 0], [[4,10], 2], [[4,11], 0], [[4,12], 2], [[4,13], 1], [[4,14], 0],
//     // Fila 3
//     [[3,0], 0], [[3,1], 2], [[3,2], 2], [[3,3], 1], [[3,4], 0], [[3,5], 0], [[3,6], 2], [[3,7], 1], [[3,8], 1], [[3,9], 2], [[3,10], 1], [[3,11], 0], [[3,12], 0], [[3,13], 2], [[3,14], 0],
//     // Fila 2
//     [[2,0], 0], [[2,1], 0], [[2,2], 2], [[2,3], 1], [[2,4], 0], [[2,5], 0], [[2,6], 0], [[2,7], 1], [[2,8], 2], [[2,9], 0], [[2,10], 1], [[2,11], 1], [[2,12], 1], [[2,13], 0], [[2,14], 0],
//     // Fila 1
//     [[1,0], 0], [[1,1], 0], [[1,2], 2], [[1,3], 1], [[1,4], 0], [[1,5], 0], [[1,6], 2], [[1,7], 1], [[1,8], 2], [[1,9], 0], [[1,10], 1], [[1,11], 1], [[1,12], 1], [[1,13], 0], [[1,14], 0],
//     // Fila 0
//     [[0,0], 0], [[0,1], 0], [[0,2], 2], [[0,3], 1], [[0,4], 0], [[0,5], 0], [[0,6], 0], [[0,7], 1], [[0,8], 2], [[0,9], 0], [[0,10], 0], [[0,11], 1], [[0,12], 1], [[0,13], 1], [[0,14], 0]
//     ]){
// }

// object nivel3 inherits Nivel ( map = []){
// }