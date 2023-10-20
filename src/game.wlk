import wollok.game.*

class ParteJugador{
	var property position
}

class Jugador
{
	const property partes = [new ParteJugador(position = self.position()),new ParteJugador(position = self.position().right(1)),new ParteJugador(position = self.position().right(2)),new ParteJugador(position = self.position().right(3))]
	const property marcador
	var property position
	const property teclaDerecha
	const property teclaIzquierda
	const pelota
	const number = new Range(start = 1, end = 2).anyOne()
	
	method image() = "player.png"
	method derecha() {
		if(position.x() < game.width()-3){
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
		pelota.desplazamiento(number)
		if(marcador.puntos() >= 5 && pantalla.pelotas().size() < 2){
			self.siguienteNivel()
		}
	}
	
	method siguienteNivel(){
		const nuevaPelota =  new Pelota()
		pantalla.pelotas([pelota, nuevaPelota])
		game.addVisual(nuevaPelota)
		nuevaPelota.desplazamiento(number)
		
	}
}

class Marcador{
	var property puntos = 0
	const property position
	method text() = puntos.toString()
}

class Pelota{
	var property position
	var movHorizontal
	var movVertical
	var velocidad = 10
	method moverse(number) {
		position = position.up(movVertical).right(movHorizontal)
		if(position.x() == 0 || position.x() == game.width()-1){
			self.cambiarDireccionH(number)
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
	
	
	method desplazamiento(number) {
		
		self.initialize()		
		game.onTick(5000/velocidad,"moverPelotita",{self.moverse(number)})
		
	}

	
	method cambiarDireccionH(number){
		movHorizontal *= -number
	}
	method cambiarDireccionV(number){
		movVertical *= -1
		game.removeTickEvent("moverPelotita")
		velocidad+= 3
		game.onTick(5000/velocidad,"moverPelotita",{self.moverse(number)})
	}
}



object pantalla {
	var property pelotas = [new Pelota()]
	const jugador1 = new Jugador(pelota = pelotas.first(),teclaDerecha = keyboard.d(),teclaIzquierda = keyboard.a(), position = game.center().down(1), marcador = new Marcador(position = game.center().up(5).left(2)))
	const jugador2 = new Jugador(pelota = pelotas.first(), teclaDerecha = keyboard.right(),teclaIzquierda = keyboard.left(), position = game.center().up(9),marcador = new Marcador(position = game.center().up(3).left(2)))
	const number = new Range(start = 1, end = 2).anyOne()
	
	method iniciar(){
		self.configuracionBasica()
		self.agregarVisuales()
		self.programarTeclas()
		self.collides()
		pelotas.forEach{pelota=>
		pelota.desplazamiento(number)
		}
		
	}
	
	method configuracionBasica() {
		game.width(15)
		game.height(12)
		game.title("Juego")
	}
	
	method agregarVisuales() {
		game.addVisual(jugador1)
		game.addVisual(jugador2)
		pelotas.forEach{pelota=>
		 game.addVisual(pelota)
		}
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
		pelotas.forEach{pe=>
			jugador1.partes().forEach({x=> game.onCollideDo(x,{p=>pe.cambiarDireccionV(number)})})
			jugador2.partes().forEach({x=> game.onCollideDo(x,{p=>pe.cambiarDireccionV(number)})})
		}

	}
}
