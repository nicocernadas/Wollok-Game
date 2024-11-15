import niveles.*
import players.*
import pantallas.*
import config.*

// DATOS DE PLAYERS
class Muerte {
  var property position
  method image() = "skull.png"

  method muere(player) {
    game.schedule(1000,{ game.addVisual(self)})
    game.schedule(3000, {
      game.removeVisual(player) 
      game.removeVisual(self) 
      nivel1.seMurio(player)
      nivel1.termina() // Lo llama para ver si termina o no
    })
  }

  method esColisionable() = false
  method seRompe(player) = false
  method teEncontro(player) = null
}

class Vidas {
  var property position
  const player
  method image() = "HealthBar-" + player.vidas() + ".png"
}
class CaraPlayer {
  var property position
  const player
  const imagen
  const imagen2
  method image() = if(player.tieneVida()) imagen else imagen2
}
class BombasPlayer {
  var property position
  const property player

  method image() = "nb" + player.bombas() +".png"
}
class PuntajePlayer {
  var property position
  const property player
  const texto = {"          PUNTAJE: " + player.puntaje()}

  method image() = "puntaje-bg.png"
  method text() = texto.apply()
  method textColor() = "FFFFFFFF"
}

// OBJETO BOMBA
class Bomba {
  var property position
  var property player

  method image() = "bomb.png"
  method explota(largoExplosion) {
    const explosion = new Explosion(position = self.position().down(largoExplosion).left(largoExplosion), largo = largoExplosion, player = player)

    game.schedule(3000, {
        game.addVisual(explosion)
        explosion.colisiones()
        game.onTick(200, "danio", {explosion.colisiones()})
    })

    game.schedule(4000, {
      game.removeVisual(explosion)
      game.removeTickEvent("danio")
    })
  }
  method esColisionable() = true
  method teEncontro(_player) = true // No hace nada
  method seRompe(_player) = true // No hace nada
}

class Explosion {
  var property position
  var property player
  var property largo 
  const property indexLargos = []

  method image() = "explosion" + self.largo() + ".png"
  method seRompe(jugador) = false
  method esColisionable() = false

  method teEncontro(_player) { self.colisiones() }

  method indexLargos() {
    if(self.largo() == 1){
      return [1]
    } else if (self.largo() == 2){
      return [1,2]
    }else {
      return [1,2,3]
    }
  }

  method centro() = self.position().up(self.largo()).right(self.largo())

  method colisiones() {
    var objetos = []

    objetos = game.getObjectsIn(self.centro())
    self.romperObjetos(objetos)

    objetos = self.indexLargos().flatMap({ opLargo => game.getObjectsIn(self.centro().left(opLargo))})
    self.romperObjetos(objetos)

    objetos = self.indexLargos().flatMap({ opLargo => game.getObjectsIn(self.centro().right(opLargo))})
    self.romperObjetos(objetos)

    objetos = self.indexLargos().flatMap({ opLargo => game.getObjectsIn(self.centro().up(opLargo))})
    self.romperObjetos(objetos)

    objetos = self.indexLargos().flatMap({ opLargo => game.getObjectsIn(self.centro().down(opLargo))})
    self.romperObjetos(objetos)
  
  }

  method romperObjetos(objetos) {
    if (!objetos.isEmpty()) {
      objetos.forEach({obj => obj.seRompe(player)})
      objetos.clear()
    }
  }

}

// OBJETOS COLISIONES
class ObjetoNoSolido {
  var property position
  var property puntos
  var property bonuses = #{new AumentoExplosion(position = self.position()),new VidaMas(position = self.position()), new PuntosDobles(position = self.position()),new BombaMas(position = self.position())} //Esta en class Powerup
  method esColisionable() = true

  method seRompe(player) {
    game.removeVisual(self)
    player.sumarPuntos(self.puntos())
    nivel1.restarObj()
    game.schedule(3000, { nivel1.termina() })  // Lo llama para ver si termina o no
    if (self.dropea()){
      self.addPowerup(bonuses.anyOne())
    }

  }

  method dropea() {
    const a = 1.randomUpTo(10).truncate(0)
    return a.even()
    // RANDOM PARA VER SI DROPEA O NO
    // SI LA CONDICION ES TRUE, DROPEA.
  }

  method addPowerup(powerup) {
    game.addVisual(powerup)
  }

}

class Barril inherits ObjetoNoSolido(puntos = 50) { method image() = "Barrel.png" }
class BotellaAzul inherits ObjetoNoSolido(puntos = 10) { method image() = "BlueBottle.png" }
class BotellaRoja inherits ObjetoNoSolido(puntos = 15) { method image() = "RedBottle.png" }
class Silla inherits ObjetoNoSolido(puntos = 25) { method image() = "chair.png" }


class Wall {
    var property position
    var property image = 'solid-1.png'
    var property puntos = 0
    
    method esColisionable() = true
    method seRompe(player) = false
}

// POWERUPS
class Powerup {
  var property position

  method esColisionable() = false
  method seRompe(player) = true // No hace nada
}

class AumentoExplosion inherits Powerup {

  method image() = "powerup-exp.png"

  method teEncontro(jugador) {
    jugador.aumExplosion()
    game.removeVisual(self)
  }
}
//---------------
class VidaMas inherits Powerup {

  method image() = "powerup-vida.png"

  method teEncontro(jugador) {
    jugador.vidaMas()
    game.removeVisual(self)
  }
}
//---------------
class PuntosDobles inherits Powerup {

  method image() = "powerup-puntos.png"

  method teEncontro(jugador) {
    jugador.puntosDobles()
    game.removeVisual(self)
  }
}
//---------------
class BombaMas inherits Powerup {

  method image() = "powerup-bomb.png"

  method teEncontro(jugador) {
    jugador.addBomba()
    game.removeVisual(self)
  }
}

// IMÁGENES
object tableroPiso{ 
  const property position = game.at(6,0)
  method image() = "wood-bg-680x600.png"}
object pantallaInicio{ 
  const property position = game.at(0,0)
  method image() = "fondoPantallaInicio.png"}
object tableroPuntajes{
  const property position = game.at(1,0)
  method image() = "wood-bg-160x600.png"}

object botonInicio1{ 
  const property position = game.at(8,5)
  method image() = "botonPressEnter.png"}
object botonInicio2{ 
  const property position = game.at(8,5)
  method image() = "botonPressEnter2.png"}
object b_pausa1{
  const property position = game.at(8,3)
  method image() = "Pausa_Reanudar.png"  
  method seRompe(player) = true
  method teEncontro(player) = true}
  object b_pausa2{
  const property position = game.at(8,3)
  method image() = "Pausa_Salir2.png"  
  method seRompe(player) = true
  method teEncontro(player) = true}
object fondoModoJuego{
  const property position = game.at(0,0)
  method image() = "fondoModoDeJuegos.png"}
object botonUnJugador{
  const property position = game.at(8,4)
  method image() = "boton1Jugador.png"}
object botonDosJugadores{
  const property position = game.at(13,4)
  method image() = "boton2Jugadores.png"}
object botonUnJugador2{
  const property position = game.at(8,4)
  method image() = "boton1Jugador_2.png"}
object botonDosJugadores2{
  const property position = game.at(13,4)
  method image() = "boton2Jugadores_2.png"}

object ganadorOverlay{
  const property position = game.at(7,2)
  method image() {
    return if (nivel1.ganador() == player1) "Ganador_player1.png"
    else "Ganador_player2.png"
  }
}
object perdedor_singleplayer{
  const property position = game.at(7,2)
  method image() = "GameOver_singleplayer.png"
}
object perdedor_multiplayer{
  const property position = game.at(7,2)
  method image() = "perdedor_multiplayer.png"
}
object ganadorOverlay_sinBombas{
  const property position = game.at(7,2)
  method image() {
    return if (nivel1.ganador() == player1) "RivalesSinBombas_player1.png"
    else "RivalesSinBombas_player2.png"
  }
}
