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
		marcador.aumentar()
		if(marcador.masQue(5) && pantalla.pelotas().size() < 2){
			pantalla.siguienteNivel()
		}
		if(marcador.masQue(10)){
			pantalla.ganar(self)
		}
	}
	method cambiarDireccionV(parametro){}
		
}

class Marcador{
	var property puntos = 0
	const property position
	method text() = puntos.toString()
	method aumentar()
	{
		puntos++
	}
	method masQue(puntaje) = puntos >= puntaje
}


class Pelota{
	var property position = game.center()
	var movHorizontal = 0
	var movVertical = 0
	var velocidad = 10
	var property nombreOnTick
	const angulo = new Range(start = 1, end = 2)
	method moverse() {
		position = position.up(movVertical).right(movHorizontal)
		if(position.x() == 0 || position.x() == game.width()-1){
			self.cambiarDireccionH()
		}
		if(position.y() < 0){
			self.gol()
			pantalla.gol(1)
		}
		if(position.y() > game.height()){
			self.gol()
			pantalla.gol(2)
		}
	}
	method image() = "pelota.png"
	
	method gol()
	{
		game.removeTickEvent(nombreOnTick)
		if(0.randomUpTo(1).between(0,0.25))
		{
			game.removeVisual(self)
			game.addVisual(new PelotaDorada(pelotareemplazada = self, nombreOnTick = nombreOnTick))
		}
		else
		{
			self.desplazamiento()
		}
	}
	method desplazamiento() {
		
		position = game.center()
		movVertical = [1,-1].anyOne()
		movHorizontal = [1,-1].anyOne()
		velocidad = 10
		game.onTick(5000/velocidad,nombreOnTick,{self.moverse()})
		
	}

	
	method cambiarDireccionH(){
			movHorizontal *= -1
	}
	method cambiarDireccionV(numero){
		movVertical = numero
		game.removeTickEvent(nombreOnTick)
		velocidad+= 3
		game.onTick(5000/velocidad,nombreOnTick,{self.moverse()})
	}
}

class PelotaDorada inherits Pelota{
	var pelotareemplazada
	
	method initialize()
	{
		self.desplazamiento()
	}
	override method  moverse() {
		position = position.up(movVertical).right(movHorizontal)
		if(position.x() == 0 || position.x() == game.width()-1){
			self.cambiarDireccionH()
		}
		if(position.y() < 0){
			self.volverANormalidad()
			pantalla.gol(1)
			pantalla.gol(1)
			pantalla.gol(1)
		}
		if(position.y() > game.height()){
			self.volverANormalidad()
			pantalla.gol(2)
			pantalla.gol(2)
			pantalla.gol(2)
		}
	}
	
	method volverANormalidad()
	{
			game.removeTickEvent(nombreOnTick)
			game.removeVisual(self)
			game.addVisual(pelotareemplazada)
			pelotareemplazada.desplazamiento()
	}
	
	override method  image() = "pelotaDorada.png"
	
}

object ganador{
	var property image
	method position() = game.center().left(4)
}

object enter{
	method image() = "enter.png"
	
	method position() = game.center().left(4)
	
	method comenzar(){
		pantalla.pelotas().first().desplazamiento()
		game.removeVisual(self)
	}
}

object pantalla {
	var property pelotas = [new Pelota(nombreOnTick = "moverPelotita1")]
	const jugador1 = new Jugador(teclaDerecha = keyboard.d(),teclaIzquierda = keyboard.a(), position = game.center().down(1), marcador = new Marcador(position = game.center().up(5).left(2)))
	const jugador2 = new Jugador( teclaDerecha = keyboard.right(),teclaIzquierda = keyboard.left(), position = game.center().up(9),marcador = new Marcador(position = game.center().up(3).left(2)))
	var alguienGano = false
	
	method iniciar(){
		self.configuracionBasica()
		self.agregarVisuales()
		self.programarTeclas()
		self.collides()
		//pelotas.first().desplazamiento()
		}
		
	
	method configuracionBasica() {
		game.width(15)
		game.height(12)
		game.title("Juego")
	}
	
	method agregarVisuales() {
		game.boardGround("fondo.png")
		game.addVisual(jugador1)
		game.addVisual(jugador2)
		pelotas.forEach{pelota=>
		 game.addVisual(pelota)
		}
		game.addVisual(jugador1.marcador())
		game.addVisual(jugador2.marcador())
		jugador1.partes().forEach({x=> game.addVisual(x)})
		jugador2.partes().forEach({x=> game.addVisual(x)})
		game.addVisual(enter)
		}
		
 
	method programarTeclas() {
		jugador1.teclaDerecha().onPressDo{jugador1.derecha()} 
		jugador1.teclaIzquierda().onPressDo{jugador1.izquierda()} 
		jugador2.teclaDerecha().onPressDo{jugador2.derecha()} 
		jugador2.teclaIzquierda().onPressDo{jugador2.izquierda()}
		keyboard.enter().onPressDo{enter.comenzar()}
		
	}
	method gol(jugador)
	{
		if(jugador == 1)
		{
			jugador1.gol()
		}
		else{jugador2.gol()}
	}
	method collides()
	{		
			jugador1.partes().forEach({x=> game.onCollideDo(x,{p=>p.cambiarDireccionV(1)})})
			jugador2.partes().forEach({x=> game.onCollideDo(x,{p=>p.cambiarDireccionV(-1)})})
	}
	
	method siguienteNivel()
	{
		pelotas.add(new Pelota(nombreOnTick = "moverPelotita2"))
		pelotas.get(1).desplazamiento()
		game.addVisual(pelotas.get(1))
	}
	method ganar(jugador)
	{
		
		if(alguienGano.negate())
		{
		game.allVisuals().forEach{visual => game.removeVisual(visual)}
		game.removeTickEvent("moverPelotita2")
		game.removeTickEvent("moverPelotita1")
		if(jugador == jugador1)
		{
			ganador.image("winner-1.png")
		}
		if(jugador == jugador2)
		{
			ganador.image("winner-2.png")
		}
		game.addVisual(ganador)
		game.schedule(4000,{game.stop()})
		}
		alguienGano = true
	}
}
