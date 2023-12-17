/// Realizado por Alejandro Gavira García
/// Practica_Swift

//MARK: - Creacion de estructuras

struct Client:Equatable{
    let nombre:String
    let edad: Int
    let altura:Float
}

struct Reservation{
    let ID:Int
    let nombreHotel:String
    let listaClientes: [Client]
    let duracion: Int
    let precio: Float
    let siDesayuno: Bool
    
    init(numID: Int,nombreHotel: String, listaClientes: [Client], duracion: Int, precio: Float, siDesayuno: Bool) {
        self.ID = numID
        self.nombreHotel = nombreHotel
        self.listaClientes = listaClientes
        self.duracion = duracion
        self.precio = precio
        self.siDesayuno = siDesayuno
    }
    
}

//MARK: - Enum Errores

enum ReservationError:Error{
    case ocupadoID
    case ocupadoReserva
    case noEncontradoReserva
    case datosIncorrectos
}

//MARK: - Creación de clase

class HotelReservationManager{
    
    private var id = 0
    var listaReservas: [Reservation] = []
    
    //MARK: - Funciones
    
    func añadirReserva(listaClientes: [Client],duracion: Int,siDesayuno: Bool) throws ->Reservation {
        
        if !listaReservas.filter({$0.ID == id}).isEmpty{
            throw ReservationError.ocupadoID
        }else if !listaReservas.filter({$0.listaClientes == listaClientes}).isEmpty{
            throw ReservationError.ocupadoReserva
        }else if duracion <= 0 || listaClientes.isEmpty {
            throw ReservationError.datosIncorrectos
        }
        
        var precioReserva:Float = 0.0
        
        if siDesayuno{
            precioReserva = Float(listaClientes.count * 20 * duracion) * 1.25
        }else{
            precioReserva = Float(listaClientes.count * 20 * duracion)
        }
        
        let reserva = Reservation(numID: id,nombreHotel: "Hoteles Sol", listaClientes: listaClientes, duracion: duracion, precio: precioReserva, siDesayuno: siDesayuno)
        
        listaReservas.append(reserva)
        self.id = listaReservas.count
        return reserva
    }
    
    func cancelarReserva(idCancel:Int) throws {
        guard id > listaReservas.count || id < 0 else {
            throw ReservationError.noEncontradoReserva
        }
        listaReservas.remove(at: idCancel)
        self.id = idCancel
    }
    
    func descripcionReservas(){
        
        for element in listaReservas{
            print(element.ID)
            print(element.nombreHotel)
            print(element.listaClientes)
            print(element.duracion)
            print(element.precio)
            print(element.siDesayuno)
            print("")
        }
    }
    var idPublico: Int{
        return self.id
    }
}

//MARK: - Seccion de Pruebas

func testAddReservation(clase: HotelReservationManager){
    
    var IDPruebasPublico = clase.idPublico
    
    var pruebaListaClientesFamilia: [Client]  = [
        Client(nombre: "Pedro", edad: 31, altura: 1.85),
        Client(nombre: "Maria", edad: 24, altura: 1.66),
        Client(nombre: "Rodrigo", edad: 10, altura: 1.15)
    ]
    var pruebaListaClientesPrecios: [Client]  = [
        Client(nombre: "Luis", edad: 20, altura: 1.34),
        Client(nombre: "Ash", edad: -12, altura: 1.89),
        Client(nombre: "Naruto", edad: -5, altura: 1.45)
    ]
    var pruebaListaClientesNormal: [Client]  = [
        Client(nombre: "Alfredo", edad: 22, altura: 1.87),
        Client(nombre: "Roberto", edad: 36, altura: 1.66)
    ]
    var pruebaListaClientesFiesta: [Client]  = [
        Client(nombre: "Luisa", edad: 19, altura: 1.75),
        Client(nombre: "Maria", edad: 17, altura: 2.15),
        Client(nombre: "Rigoberta", edad: 21, altura: 1.66),
        Client(nombre: "Lucia", edad: 19, altura: 1.54),
        Client(nombre: "Luisa", edad: 20, altura: 1.72),
        Client(nombre: "Alfonso", edad: 19, altura: 1.82)
    ]
    var pruebaListaClienteFalso: [Client]  = [Client(nombre: "-----", edad: -34, altura: -1.85)]
    
    
    do{
        try clase.añadirReserva(listaClientes: pruebaListaClientesFamilia, duracion: 3, siDesayuno: true)
        try clase.añadirReserva(listaClientes: pruebaListaClientesPrecios, duracion: 3, siDesayuno: true)
        try clase.añadirReserva(listaClientes: pruebaListaClientesNormal, duracion: 15, siDesayuno: false)
        try clase.añadirReserva(listaClientes: pruebaListaClientesFiesta, duracion: 8, siDesayuno: true)
        
        
        
        /// Conjunto vacío
        /// Duracion negativa
        try clase.añadirReserva(listaClientes: [], duracion: 8, siDesayuno: true)
        try clase.añadirReserva(listaClientes: pruebaListaClienteFalso, duracion: -5, siDesayuno: false)
         
        /// Este caso lanza un error de tipo Reserva Ocupada y lo atrapa
        try clase.añadirReserva(listaClientes: pruebaListaClientesFamilia, duracion: 3, siDesayuno: true)
        
        
        /// Este caso lanza un error de tipo ID ocupado y lo atrapa, al hacerlo privado ya es dificilmente provocable
         // hrm.id = 2 Hacer publico id y se podrá modificar, se comprobço y funcionó
        try clase.añadirReserva(listaClientes: pruebaListaClientesFiesta, duracion: 8, siDesayuno: true)
        
    }
    catch ReservationError.ocupadoID{
        print("El ID está siendo utilizado por otra reserva")
    }catch ReservationError.ocupadoReserva{
        print("Ya existe una reserva del mismo tipo")
    }catch ReservationError.datosIncorrectos{
        print("Duracion o lista de clientes incorrecto")
    }catch{
        assertionFailure("Error de otro lado desconocido")
    }
}

func testCancelReservation(clase: HotelReservationManager){
    
    do{
        
        /// Aqui quiero probar si quitando una y añadiendo otra, ocupa el ID que estaba vacio
        try clase.cancelarReserva(idCancel: 1)
        try clase.añadirReserva(listaClientes: [Client(nombre: "Luisa", edad: 33, altura: 1.76)], duracion: 3, siDesayuno: false)
        
        /// Cancelamos alguno mas
        try clase.cancelarReserva(idCancel: 2)
        
        /// Aqui quiero probar si quitando una y añadiendo otra, ocupa el ID que estaba vacio
        try clase.cancelarReserva(idCancel: 3)
        try clase.añadirReserva(listaClientes: [Client(nombre: "Alfredo", edad: 12, altura: 77)], duracion: 6, siDesayuno: true)
        
        /// En este caso, siempre se quedara un hueco vacio que es el 2, pero el programa sigue avanzando sin problema
        try clase.cancelarReserva(idCancel: 1)
        try clase.cancelarReserva(idCancel: 1)
        
        /// En este caso devuelve error
        try clase.cancelarReserva(idCancel: -3)
        try clase.cancelarReserva(idCancel: clase.listaReservas.count + 3)
    }
    catch ReservationError.ocupadoID{
        print("El ID está siendo utilizado por otra reserva")
    }catch ReservationError.noEncontradoReserva{
        print("Ya existe una reserva del mismo tipo")
    }catch ReservationError.datosIncorrectos{
        print("Duracion o lista de clientes incorrecto")
    }catch{
        assertionFailure("Error de otro lado desconocido")
    }
}

func testReservationPrice(clase: HotelReservationManager){
    
    assert(clase.listaReservas[0].precio == clase.listaReservas[1].precio, "Mismas condiciones, distintos precios")
    assert(clase.listaReservas[2].precio > 0, "El precio es negativo")
    assert(clase.listaReservas[clase.listaReservas.count-1].duracion >= 0)
}

//MARK: - INICIO CODIGO


let hrm = HotelReservationManager()

testAddReservation(clase: hrm)
hrm.descripcionReservas()

testCancelReservation(clase: hrm)
hrm.descripcionReservas()

testReservationPrice(clase: hrm)
hrm.descripcionReservas()

