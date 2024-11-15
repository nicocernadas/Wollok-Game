import wollok.game.*
import players.*
import pantallas.*
import extras.*
import niveles.*

object config {
  var property juegoEnPausa = false 
  var property enInicio = true
  var property upEnabled = false
  var property downEnabled = true

  method configurarTeclas() {

    // PAUSA
    keyboard.p().onPressDo({
      if (!juegoEnPausa){
        juegoEnPausa = true
        game.addVisual(b_pausa1)
        self.configurarTeclasPausa()
      }
    })
  
    // MOVIMIENTO PLAYER 1:
    // keyboard.c().onPressDo({ if(!juegoEnPausa and !enInicio and player1.tieneVida()) player1.aumExplosion() })
    // keyboard.g().onPressDo({ if(!juegoEnPausa and !enInicio and player1.tieneVida()) player1.addBomba() })
    // keyboard.v().onPressDo({ if(!juegoEnPausa and !enInicio and player1.tieneVida()) player1.vidaMas() })

    keyboard.a().onPressDo({if (!juegoEnPausa and !enInicio) player1.moveTo(player1.position().left(1)) }) 
    keyboard.d().onPressDo({if (!juegoEnPausa and !enInicio) player1.moveTo(player1.position().right(1)) }) 
    keyboard.w().onPressDo({if (!juegoEnPausa and !enInicio)  player1.moveTo(player1.position().up(1)) }) 
    keyboard.s().onPressDo({if (!juegoEnPausa and !enInicio)  player1.moveTo(player1.position().down(1)) }) 
    keyboard.space().onPressDo({ 
      if(!juegoEnPausa and !enInicio) player1.ponerBomba(player1.position()) 
      })

    // MOVIMIENTO PLAYER 2:
    if(nivel1.multiplayer()){
      keyboard.left().onPressDo({if (!juegoEnPausa and !enInicio) player2.moveTo(player2.position().left(1)) })
      keyboard.right().onPressDo({if (!juegoEnPausa and !enInicio) player2.moveTo(player2.position().right(1)) })
      keyboard.up().onPressDo({if (!juegoEnPausa and !enInicio) player2.moveTo(player2.position().up(1)) })
      keyboard.down().onPressDo({if (!juegoEnPausa and !enInicio) player2.moveTo(player2.position().down(1)) })
      keyboard.enter().onPressDo({ 
        if(!juegoEnPausa and !enInicio) player2.ponerBomba(player2.position()) 
      })
    }

    if (!juegoEnPausa and !enInicio) game.onTick(250, "seMueve", {self.random()})
    
    // STOP GAME
    keyboard.backspace().onPressDo({game.stop()})
  }

  method random() {
    const direcciones = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5] // se repiten para que sea menos probable que ponga una bomba
    
    const direccionPlayer2 = direcciones.anyOne()
    const direccionPlayer3 = direcciones.anyOne()
    const direccionPlayer4 = direcciones.anyOne()

    if (!juegoEnPausa and !enInicio) self.movimiento(direccionPlayer2, direccionPlayer3, direccionPlayer4)
  }

  // MOVIMIENTO NPC
  method movimiento(direplayer2, direplayer3, direplayer4) {
    // player2 (sin multiplayer)
    if(!nivel1.multiplayer()) self.movPlayer(player2,direplayer2)
    // player3
    self.movPlayer(player3,direplayer3)
    // player4
    self.movPlayer(player4,direplayer4)
  }

  method movPlayer(npc,direc) {
    if (direc == 1) {
      npc.moveTo(npc.position().down(1))
    } else if (direc == 2) {
      npc.moveTo(npc.position().up(1))
    } else if (direc == 3) {
      npc.moveTo(npc.position().left(1))
    } else if (direc == 4) {
      npc.moveTo(npc.position().right(1))
    } else if (direc == 5) {
      if(!juegoEnPausa and !enInicio) npc.ponerBomba(npc.position()) 
    }
  }

  method configurarColisiones() {
    game.onCollideDo(player1, { algo => algo.teEncontro(player1) })
    game.onCollideDo(player2, { algo => algo.teEncontro(player2) })
    game.onCollideDo(player3, { algo => algo.teEncontro(player3) })
    game.onCollideDo(player4, { algo => algo.teEncontro(player4) })
  }

  // INICIAR JUEGO
  method configurarTeclasInicio() {
    // PARA INICIAR EL JUEGO
    enInicio = true
    keyboard.enter().onPressDo({
      game.removeVisual(botonInicio1)
      game.addVisual(botonInicio2)
      game.schedule(200, {
        game.removeVisual(pantallaInicio)
        game.clear()
        pantallas.modosDeJuego()
        })
      })
  }
  
  method reiniciarJuego() {
    upEnabled = false
    downEnabled = true
    juegoEnPausa = false
    game.clear()
    nivel1.reiniciarPlayers() // Adentro del reinicio empiezan todas las variables de los players devuelta
    game.schedule(100, {pantallas.iniciar()})
  }
  
  method configurarTeclasPausa() {
    var seleccionado = 1

    // REANUDAR JUEGO
    keyboard.up().onPressDo({
      if (juegoEnPausa and upEnabled){
        seleccionado = 1
        upEnabled = false
        downEnabled = true
        self.cambioBoton(b_pausa1, b_pausa2)
        }
      })
    // SALIR A PANTALLA INICIAL
    keyboard.down().onPressDo({
      if (juegoEnPausa and downEnabled) {
        seleccionado = 2
        downEnabled = false
        upEnabled = true  // Permitir la tecla up nuevamente
        self.cambioBoton(b_pausa2, b_pausa1)
      }
    }) 
    
    keyboard.enter().onPressDo({
      if (juegoEnPausa) {
          if (seleccionado == 1) {
            game.schedule(200, {
                game.removeVisual(b_pausa2)
                game.removeVisual(b_pausa1)
            })
            juegoEnPausa = false
            upEnabled = false
            downEnabled = true
          } else if (seleccionado == 2) {
              game.clear()
              self.reiniciarJuego()
          }
      }
    }) 
    }

    method cambioBoton(b1,b2){
      game.addVisual(b1)
      game.removeVisual(b2)
    }
    
    method configurarTeclasModosDeJuegos(){
      // MODOS DE JUEGO
      // UN JUGADOR
      enInicio = false
      keyboard.n().onPressDo({ self.elegirModo(botonUnJugador2,false) })
        // DOS JUGADORES
      keyboard.m().onPressDo({ self.elegirModo(botonDosJugadores2,true) })
    }

  method elegirModo(boton,boolModo) {
    game.addVisual(boton)
    game.schedule(100, {
      game.removeVisual(boton)
      game.clear()
      nivel1.iniciar(boolModo)
    })
  }

}