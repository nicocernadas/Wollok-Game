import wollok.game.*
import config.*
import extras.*

// Inicializar la pantalla de inicio
object pantallas{
  method iniciar(){
    game.addVisual(pantallaInicio)
    game.addVisual(botonInicio1)
    config.configurarTeclasInicio()
  }
  method modosDeJuego() {
    game.addVisual(fondoModoJuego)
    game.addVisual(botonUnJugador)
    game.addVisual(botonDosJugadores)
    config.configurarTeclasModosDeJuegos()
  }
}
