import wollok.game.*

class ParteJugador{
	var property position
	method left()
	{
		position = position.left(1)
	}
		method right()
	{
		position = position.right(1)
	}
	method colision(numero)
	{
		game.onCollideDo(self,{p=>p.cambiarDireccionV(numero)})
	}
}

class Jugador
{
	const property partes = [new ParteJugador(position = self.position()),new ParteJugador(position = self.position().right(1)),new ParteJugador(position = self.position().right(2)),new ParteJugador(position = self.position().right(3))]
	const property marcador
	var property position
	const property teclaDerecha
	const property teclaIzquierda
	const direccion
	method image() = "player.png"
	method derecha() {
		if(position.x() < game.width()-3){
		position = position.right(1)
		partes.forEach({x=> x.right()})
		}
	}
	method izquierda() {
		if(position.x() > 0){
		position = position.left(1)
		partes.forEach({x=> x.left()})
		}
	}
	method gol()
	{
		if(marcador.masQue(5) && pantalla.pelotas().size() < 2){
			pantalla.siguienteNivel()
		}
		if(marcador.masQue(10)){
			self.ganar()
		}
	}
	method ganar()
	{
		ganador.image("winner" + direccion.toString() + ".png")
		pantalla.ganar()
	}
	method cambiarDireccionV(parametro){}
	method iniciar()
	{
		game.addVisual(self)
		game.addVisual(marcador)
		partes.forEach({x=> game.addVisual(x)})
		self.collides()
		self.teclas()
	}
	method teclas()
	{
		teclaDerecha.onPressDo{self.derecha()} 
		teclaIzquierda.onPressDo{self.izquierda()} 
	}
	method collides()
	{
		partes.forEach({x=> x.colision(direccion)})
	}
	method revisarGol(pelota)
	{
		if(pelota.position().y() == position.y() -direccion)
		{
			pelota.gol(marcador)
			self.gol()
		}
	}
}

class Marcador{
	var property puntos = 0
	const property position
	method text() = puntos.toString()
	method textColor() = "#F8FFB8"
	method aumentar(n)
	{
		puntos += n
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
		pantalla.revisarGol(self)
	}
	method image() = "pelota.png"
	
	method gol(marcador)
	{
		marcador.aumentar(1)
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
	override method gol(marcador)
	{
			marcador.aumentar(3)
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
	method iniciar()
	{
		keyboard.enter().onPressDo{self.comenzar()}
		game.addVisual(self)
	}
}

object pantalla {
	var property pelotas = [new Pelota(nombreOnTick = "moverPelotita1")]
	const jugador1 = new Jugador(teclaDerecha = keyboard.d(),teclaIzquierda = keyboard.a(), position = game.center().down(1), marcador = new Marcador(position = game.center().up(4).left(2)),direccion =1)
	const jugador2 = new Jugador( teclaDerecha = keyboard.right(),teclaIzquierda = keyboard.left(), position = game.center().up(9),marcador = new Marcador(position = game.center().up(2).left(2)),direccion = -1)
	var alguienGano = false
	
	method iniciar(){
		jugador1.iniciar()
		jugador2.iniciar()
		enter.iniciar()
		self.configuracionBasica()
		self.agregarVisuales()

		//pelotas.first().desplazamiento()
		}
		
	
	method configuracionBasica() {
		game.width(15)
		game.height(12)
		game.title("Juego")
	}
	
	method agregarVisuales() {
		game.boardGround("fondo.png")
		pelotas.forEach{pelota=>
		 game.addVisual(pelota)}
	}
		

	
	method revisarGol(pelota)
	{
		jugador1.revisarGol(pelota)
		jugador2.revisarGol(pelota)
	}
	method goldorada(n){
		
	}
	method siguienteNivel()
	{
		pelotas.add(new Pelota(nombreOnTick = "moverPelotita2"))
		pelotas.get(1).desplazamiento()
		game.addVisual(pelotas.get(1))
	}
	method ganar()
	{
		
		if(alguienGano.negate())
		{
		game.allVisuals().forEach{visual => game.removeVisual(visual)}
		game.removeTickEvent("moverPelotita2")
		game.removeTickEvent("moverPelotita1")
		game.addVisual(ganador)
		game.schedule(4000,{game.stop()})
		}
		alguienGano = true
	}
}
