import niveles.*
import pantallas.*
import extras.*

class Player {
  var property position
  const imagen
  const imagen2
  const imagenDead
  var cambioImg = true
  var property largoExplosion = 1
  var property puntaje = 0
  var property vidas = 3
  var property bombas = 10
  var property boolBomba = false
  var property boolPuntosDobles = false
  var property inmortal = false 

  
  method reiniciar(_posicion) {
    position = _posicion
    puntaje = 0
    vidas = 3
    bombas = 10
    largoExplosion = 1
    boolBomba = false
    boolPuntosDobles = false
    inmortal = false
  }
  method esColisionable() = true

  method image() {
    if(!self.tieneVida()) {
      return imagenDead
    } else if(cambioImg) {
      return imagen 
    } else {
      return imagen2
    }
  }
  method cambiarImg() {
      cambioImg = false
      game.schedule(200, {cambioImg = true})
  }

  // COLISIONES
  method limBordes(nuevaPosicion) = nuevaPosicion.x().between(7, 21) && nuevaPosicion.y().between(1, 13)

  method colisiones(nuevaPosicion) = self.esNoColisionable(game.getObjectsIn(nuevaPosicion))
  method esNoColisionable(objSet) = objSet.isEmpty() || !objSet.asList().first().esColisionable() // Puede pasar si el obj NO esColisionable() (!false)
  
  method canMoveHere(nuevaPosicion) = self.limBordes(nuevaPosicion) && self.colisiones(nuevaPosicion) && self.tieneVida()
  
  // ACCIONES 
  method moveTo(nuevaPosicion) {
    if (self.canMoveHere(nuevaPosicion)){
      position = nuevaPosicion
      self.cambiarImg()
    }
	}

  method ponerBomba(posicion) {
    if (self.puedePonerBomba()){
      const bomba = new Bomba(position = posicion, player = self)
      game.addVisual(bomba)
      boolBomba = true
      bombas -= 1
      game.schedule(3000, {
        game.removeVisual(bomba)
        boolBomba = false})
      bomba.explota(largoExplosion)
    } else if(bombas == 0) {
      game.say(self, "No tengo mas bombas!")
    }
  }

  method puedePonerBomba() {
    return bombas > 0 && !self.boolBomba() && self.tieneVida()
  }
  method sumarPuntos(puntos) {
    if(self.boolPuntosDobles()){
      puntaje += puntos * 2  
      game.schedule(10000, {boolPuntosDobles = false })    
    } else {
      puntaje += puntos
    }
  }

  // POWERUPS
  method aumExplosion() {
    if(!self.largoExplosion().equals(3)) largoExplosion += 1
  }

  method vidaMas() {
    if(!self.vidas().equals(3)) vidas += 1
  }

  method puntosDobles() {
    boolPuntosDobles = true
  }
  
  method addBomba() {
    if (bombas < 15) {
      bombas += 1
    }
  }

  // VIDA/MUERTE
  method tieneVida() = self.vidas() > 0

  method seRompe(_player) {
    self.perderVida()
  }

  method perderVida() {
    if(self.tieneVida() && !inmortal) {
      vidas -= 1
      inmortal = true
      game.schedule(1000, {inmortal = false})
    }
    self.muere()
  }

  method muere() {
    if(self.vidas().equals(0)) {
      const muerte = new Muerte(position = self.position().up(1))
      muerte.muere(self)
    }
  }

  method teEncontro(player) {
    game.say(self, "que onda pa")
  }

}

const player1 = new Player(position = game.at(7,1), imagen = "player-1-idle.png", imagen2 = "player-1-run.png", imagenDead = "player-1-dead.png")
const player2 = new Player(position = game.at(21,1), imagen =  "player-2-idle.png", imagen2 = "player-2-run.png", imagenDead = "player-2-dead.png")
const player3 = new Player(position = game.at(7,13), imagen = "player-3-idle.png", imagen2 = "player-3-run.png", imagenDead = "player-3-dead.png")
const player4 = new Player(position = game.at(21,13), imagen = "player-4-idle.png", imagen2 = "player-4-run.png", imagenDead = "player-4-dead.png")
const vidaPlayer1 = new Vidas(position = game.at(1,11), player = player1)
const vidaPlayer2 = new Vidas(position = game.at(1,8), player = player2)
const vidaPlayer3 = new Vidas(position = game.at(1,4), player = player3)
const vidaPlayer4 = new Vidas(position = game.at(1,1), player = player4)
const caraPlayer1 = new CaraPlayer(position = game.at(2,12), player = player1, imagen = "player-1-head.png", imagen2 = "player-1-head-dead.png")
const caraPlayer2 = new CaraPlayer(position = game.at(2,9), player = player2, imagen = "player-2-head.png", imagen2 = "player-2-head-dead.png")
const caraPlayer3 = new CaraPlayer(position = game.at(2,5), player = player3, imagen = "player-3-head.png", imagen2 = "player-3-head-dead.png")
const caraPlayer4 = new CaraPlayer(position = game.at(2,2), player = player4, imagen = "player-4-head.png", imagen2 = "player-4-head-dead.png")
const bombasPlayer1 = new BombasPlayer(position = game.at(3,12), player = player1)
const bombasPlayer2 = new BombasPlayer(position = game.at(3,9), player = player2)
const bombasPlayer3 = new BombasPlayer(position = game.at(3,5), player = player3)
const bombasPlayer4 = new BombasPlayer(position = game.at(3,2), player = player4)
const puntajePlayer1 = new PuntajePlayer(position = game.at(2,13), player = player1)
const puntajePlayer2 = new PuntajePlayer(position = game.at(2,10), player = player2)
const puntajePlayer3 = new PuntajePlayer(position = game.at(2,6), player = player3)
const puntajePlayer4 = new PuntajePlayer(position = game.at(2,3), player = player4)