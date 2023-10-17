import wollok.game.*

class ParteJugador{
	var property position
//	method image() = "transparente.jpg"
}

class Jugador
{
	const property partes = [new ParteJugador(position = self.position()),new ParteJugador(position = self.position().right(1)),new ParteJugador(position = self.position().right(2)),new ParteJugador(position = self.position().right(3))]
	const property marcador
	var property position
	const property teclaDerecha
	const property teclaIzquierda
	method image() = "player.png"
	method derecha() {
		if(position.x() < game.width()-1){
		position = position.right(1)
		partes.forEach({x=> x.position(x.position().right(1))})
		}
	}
	method izquierda() {
		if(position.x() > 0){
		position = position.left(1)
		partes.forEach({x=> x.position(x.position().left(1))})
		}
	}
	method gol()
	{
		marcador.puntos(marcador.puntos() +1)
		pelota.desplazamiento()
	}
}

class Marcador{
	var property puntos = 0
	const property position
	method text() = puntos.toString()
}

object pelota{
	var property position
	var movHorizontal
	var movVertical
	var velocidad = 10
	method moverse() {
		position = position.up(movVertical).right(movHorizontal)
		if(position.x() == 0 || position.x() == game.width()-1){
			self.cambiarDireccionH()
		}
		if(position.y() < 0){
		pantalla.gol(1)
		game.removeTickEvent("moverPelotita")
		}
		if(position.y() > game.height()){
		pantalla.gol(2)
		game.removeTickEvent("moverPelotita")
		}
	}
	method initialize(){
		position = game.center()
		movVertical = [1,-1].anyOne()
		movHorizontal = [1,-1].anyOne()
		velocidad = 10
	}
	method image() = "pelota.png"
	
	
	method desplazamiento() {
		
		self.initialize()
		
		game.onTick(5000/velocidad,"moverPelotita",{self.moverse()})
		
	}

	
	method cambiarDireccionH(){
		movHorizontal *= -1
	}
	method cambiarDireccionV(){
		movVertical *= -1
		game.removeTickEvent("moverPelotita")
		velocidad+= 3
		game.onTick(5000/velocidad,"moverPelotita",{self.moverse()})
	}
}



object pantalla {
	const jugador1 = new Jugador(teclaDerecha = keyboard.d(),teclaIzquierda = keyboard.a(), position = game.center().down(1), marcador = new Marcador(position = game.center().up(5).left(2)))
	const jugador2 = new Jugador(teclaDerecha = keyboard.right(),teclaIzquierda = keyboard.left(), position = game.center().up(9),marcador = new Marcador(position = game.center().up(3).left(2)))
//	const parte11 = new ParteJugador(parteIzquierda = jugador1)
//	const parte12 = new ParteJugador(parteIzquierda = parte11)
//	const parte13 = new ParteJugador(parteIzquierda = parte12)
//	const parte21 = new ParteJugador(parteIzquierda = jugador2)
//	const parte23 = new ParteJugador(parteIzquierda = parte22)
	method iniciar(){
		self.configuracionBasica()
		self.agregarVisuales()
		self.programarTeclas()
		self.collides()
		pelota.desplazamiento()
		
	}
	
	method configuracionBasica() {
		game.width(15)
		game.height(12)
		game.title("Juego")
//		game.cellSize(10)
//		game.boardGround("imagenDeFondo.jpg")
	}
	
	method agregarVisuales() {
		game.addVisual(jugador1)
		game.addVisual(jugador2)
		game.addVisual(pelota)
		game.addVisual(jugador1.marcador())
		game.addVisual(jugador2.marcador())
		jugador1.partes().forEach({x=> game.addVisual(x)})
		jugador2.partes().forEach({x=> game.addVisual(x)})
		}
 
	method programarTeclas() {
		jugador1.teclaDerecha().onPressDo{jugador1.derecha()} 
		jugador1.teclaIzquierda().onPressDo{jugador1.izquierda()} 
		jugador2.teclaDerecha().onPressDo{jugador2.derecha()} 
		jugador2.teclaIzquierda().onPressDo{jugador2.izquierda()}
		
	}
	method gol(numero)
	{
		if(numero == 1)
		{
			jugador1.gol()
		}
		else{jugador2.gol()}
	}
	method collides()
	{
		jugador1.partes().forEach({x=> game.onCollideDo(x,{p=>pelota.cambiarDireccionV()})})
		jugador2.partes().forEach({x=> game.onCollideDo(x,{p=>pelota.cambiarDireccionV()})})
	}
}
