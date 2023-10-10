import wollok.game.*

object jugador1{
	const marcador = new Marcador()
	var property position = game.center().down(5)
	method image() = "player.png"
	method derecha() {
		if(position.x() < game.width()-1){
		position = position.right(1)
		}
	}
	method izquierda() {
		if(position.x() > 0){
		position = position.left(1)
		}
	}
	method gol()
	{
		marcador.puntos(marcador.puntos() +1)
		pelota.initialize()
	}
}

object jugador2{
	const marcador = new Marcador()
	var property  position = game.center().up(5)
	method image() = "player.png"
	
	method derecha() {
		if(position.x() < game.width()-1){
		position = position.right(1)
		}
	}
	method izquierda() {
		if(position.x() > 0){
		position = position.left(1)
		}
	}
	method gol(){
		marcador.puntos(marcador.puntos() +1)
		pelota.initialize()
	}
}

class Marcador{
	var property puntos = 0
	//var position
	method text() = puntos.toString()
}

object pelota{
	var property position
	var movHorizontal
	var movVertical
	method moverse() {
		position = position.up(movVertical).right(movHorizontal)
		if(position.x() == 0 || position.x() == game.width()-1){
			self.cambiarDireccionH()
		}
		if(position.y() < jugador1.position().y()){
		jugador2.gol()
		}
		if(position.y() > jugador2.position().y()){
		jugador1.gol()
		}
	}
	method initialize(){
		position = game.center()
		movVertical = [1,-1].anyOne()
		movHorizontal = [1,-1].anyOne()
	}
	method image() = "pelota.png"
	
	
	method desplazamiento() {
		
		self.initialize()
		game.onTick(1000,"moverPelotita",{self.moverse()})
		game.onCollideDo(jugador1,{p=>self.cambiarDireccionV()})
		game.onCollideDo(jugador2,{p=>self.cambiarDireccionV()})
		
	}

	
	method cambiarDireccionH(){
		movHorizontal *= -1
	}
	method cambiarDireccionV(){
		movVertical *= -1
	}
}



object pantalla {
	
	method iniciar(){
		self.configuracionBasica()
		self.agregarVisuales()
		self.programarTeclas()
		pelota.desplazamiento()
		
	}
	
	method configuracionBasica() {
		game.width(15)
		game.height(12)
		game.title("Juego")
//		game.cellSize(40)
//		game.boardGround("imagenDeFondo.jpg")
	}
	
	method agregarVisuales() {
		game.addVisual(jugador1)
		game.addVisual(jugador2)
		game.addVisual(pelota)
		}
 
	method programarTeclas() {
		keyboard.right().onPressDo{jugador1.derecha()} 
		keyboard.left().onPressDo{jugador1.izquierda()} 
		keyboard.d().onPressDo{jugador2.derecha()} 
		keyboard.a().onPressDo{jugador2.izquierda()}
		
	}
	
}