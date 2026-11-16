Object subclass: #Celda
	instanceVariableNames: 'estadoActual estadoSiguiente vecinas'
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida'!

Celda comment: 'Representa una celda con estado binario. Consulta sus vecinas y prepara su siguiente estado sin alterar el actual. Regla base: consigna de UTN FRRe, tema 9, pagina 16.'!

Object subclass: #Grilla
	instanceVariableNames: 'filas columnas celdas'
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida'!

Grilla comment: 'Administra las celdas, acceso por coordenadas, vinculacion de vecinas y actualizacion en dos fases. Subclases especializan la topologia.'!

Grilla subclass: #GrillaPlana
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida'!

GrillaPlana comment: 'Vecindad limitada: solo incluye posiciones validas dentro del tablero.'!

Grilla subclass: #GrillaToroidal
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida'!

GrillaToroidal comment: 'Variante original: conecta bordes opuestos para obtener 8 vecinas distintas en grillas de al menos 3 por 3.'!

Object subclass: #SimuladorJuegoDeLaVida
	instanceVariableNames: 'grilla generacionActual generacionesObjetivo'
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida'!

SimuladorJuegoDeLaVida comment: 'Orquesta la cantidad de generaciones y permite consultar poblacion y estado de ejecucion. No hace presentacion.'!

!Celda methodsFor: 'initialization'!
initialize
    super initialize.
    estadoActual := false.
    estadoSiguiente := false.
    vecinas := #().
! !

!Celda methodsFor: 'initialization'!
estadoInicialVivo: unBooleano
    "Solo para la configuracion antes de iniciar la simulacion."
    ((unBooleano == true) or: [ unBooleano == false ])
        ifFalse: [ self error: 'El estado inicial debe ser booleano' ].
    estadoActual := unBooleano.
    estadoSiguiente := unBooleano.
    ^ self
! !

!Celda methodsFor: 'initialization'!
vecinas: unaColeccion
    "La grilla asigna las vecinas una vez al construir el tablero."
    vecinas := unaColeccion asArray.
    ^ self
! !

!Celda methodsFor: 'accessing'!
estaViva
    ^ estadoActual
! !

!Celda methodsFor: 'accessing'!
cantidadVecinasVivas
    ^ vecinas count: [ :unaCelda | unaCelda estaViva ]
! !

!Celda methodsFor: 'evolution'!
prepararSiguienteEstado
    | cantidad |
    "Reglas de la catedra: 2 vecinas conservan estado; una celda muerta
    nace con 3; una viva muere con menos de 2 o mas de 3.
    Una celda viva con 2 o 3 vecinas sobrevive: aclaracion del profesor
    Rubén Bernal (11/11/2026). Para los casos de celda muerta sin
    nacimiento, se conserva el estado por interpretacion del equipo."
    cantidad := self cantidadVecinasVivas.
    estadoSiguiente := estadoActual.
    ((estadoActual not) and: [ cantidad = 3 ])
        ifTrue: [ estadoSiguiente := true ].
    (estadoActual and: [ (cantidad < 2) or: [ cantidad > 3 ] ])
        ifTrue: [ estadoSiguiente := false ].
    ^ self
! !

!Celda methodsFor: 'evolution'!
confirmarEvolucion
    "Fase 2: ejecutar solo despues de preparar todas las celdas."
    estadoActual := estadoSiguiente.
    ^ self
! !

!Grilla methodsFor: 'initialization'!
initialize
    super initialize.
    filas := 0.
    columnas := 0.
    celdas := #().
! !

!Grilla class methodsFor: 'instance creation'!
conFilas: cantidadFilas columnas: cantidadColumnas vivasEn: coordenadas
    "Constructor heredable, llamado sobre GrillaPlana o GrillaToroidal."
    self == Grilla ifTrue: [ self error: 'Elegir GrillaPlana o GrillaToroidal' ].
    ^ self new
        inicializarConFilas: cantidadFilas
        columnas: cantidadColumnas
        vivasEn: coordenadas
! !

!Grilla methodsFor: 'initialization'!
inicializarConFilas: cantidadFilas columnas: cantidadColumnas vivasEn: coordenadas
    "Crea un objeto valido; no inicia ninguna generacion."
    self validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas.
    (coordenadas isCollection) ifFalse: [ self error: 'Las coordenadas deben ser una coleccion' ].
    coordenadas do: [ :par |
        ((par isArray) and: [ par size = 2 ])
            ifFalse: [ self error: 'Cada coordenada debe ser un Array de dos enteros' ].
        (((par first isInteger) and: [ par second isInteger ])
            and: [ (par first between: 1 and: cantidadFilas)
            and: [ par second between: 1 and: cantidadColumnas ] ])
            ifFalse: [ self error: 'Coordenada fuera del tablero' ] ].
    filas := cantidadFilas.
    columnas := cantidadColumnas.
    celdas := Array new: filas * columnas.
    1 to: celdas size do: [ :indice |
        celdas at: indice put: Celda new ].
    coordenadas do: [ :par |
        (self celdaEnFila: par first columna: par second)
            estadoInicialVivo: true ].
    self conectarVecinas.
    ^ self
! !

!Grilla methodsFor: 'validation'!
validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas
    ((cantidadFilas isInteger) and: [ cantidadColumnas isInteger ])
        ifFalse: [ self error: 'Las dimensiones deben ser enteros' ].
    ((cantidadFilas > 0) and: [ cantidadColumnas > 0 ])
        ifFalse: [ self error: 'Las dimensiones deben ser mayores a cero' ].
! !

!Grilla methodsFor: 'validation'!
coordenadasValidasFila: unaFila columna: unaColumna
    ^ ((unaFila isInteger) and: [ unaColumna isInteger ])
        and: [ (unaFila between: 1 and: filas)
        and: [ unaColumna between: 1 and: columnas ] ]
! !

!Grilla methodsFor: 'private'!
indiceParaFila: unaFila columna: unaColumna
    (self coordenadasValidasFila: unaFila columna: unaColumna)
        ifFalse: [ self error: 'Coordenada fuera del tablero' ].
    ^ ((unaFila - 1) * columnas) + unaColumna
! !

!Grilla methodsFor: 'accessing'!
celdaEnFila: unaFila columna: unaColumna
    ^ celdas at: (self indiceParaFila: unaFila columna: unaColumna)
! !

!Grilla methodsFor: 'accessing'!
filas
    ^ filas
! !

!Grilla methodsFor: 'accessing'!
columnas
    ^ columnas
! !

!Grilla methodsFor: 'topology'!
celdasVecinasDeFila: unaFila columna: unaColumna
    "Cada modalidad implementa la topologia concreta."
    self subclassResponsibility
! !

!Grilla methodsFor: 'topology'!
conectarVecinas
    1 to: filas do: [ :fila |
        1 to: columnas do: [ :columna |
            (self celdaEnFila: fila columna: columna)
                vecinas: (self celdasVecinasDeFila: fila columna: columna) ] ].
! !

!Grilla methodsFor: 'evolution'!
avanzarGeneracion
    "La fase 1 completa no cambia estadoActual de ninguna celda."
    celdas do: [ :unaCelda | unaCelda prepararSiguienteEstado ].
    celdas do: [ :unaCelda | unaCelda confirmarEvolucion ].
! !

!Grilla methodsFor: 'accessing'!
poblacionViva
    ^ celdas count: [ :unaCelda | unaCelda estaViva ]
! !

!GrillaPlana methodsFor: 'topology'!
celdasVecinasDeFila: unaFila columna: unaColumna
    | resultado otraFila otraColumna |
    (self coordenadasValidasFila: unaFila columna: unaColumna)
        ifFalse: [ self error: 'Coordenada fuera del tablero' ].
    resultado := OrderedCollection new.
    -1 to: 1 do: [ :deltaFila |
        -1 to: 1 do: [ :deltaColumna |
            ((deltaFila = 0) and: [ deltaColumna = 0 ]) ifFalse: [
                otraFila := unaFila + deltaFila.
                otraColumna := unaColumna + deltaColumna.
                (self coordenadasValidasFila: otraFila columna: otraColumna)
                    ifTrue: [ resultado add: (self celdaEnFila: otraFila columna: otraColumna) ] ] ] ].
    ^ resultado asArray
! !

!GrillaToroidal methodsFor: 'validation'!
validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas
    super validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas.
    ((cantidadFilas >= 3) and: [ cantidadColumnas >= 3 ])
        ifFalse: [ self error: 'La grilla toroidal requiere como minimo 3 x 3' ].
! !

!GrillaToroidal methodsFor: 'topology'!
celdasVecinasDeFila: unaFila columna: unaColumna
    | resultado otraFila otraColumna |
    (self coordenadasValidasFila: unaFila columna: unaColumna)
        ifFalse: [ self error: 'Coordenada fuera del tablero' ].
    resultado := OrderedCollection new.
    -1 to: 1 do: [ :deltaFila |
        -1 to: 1 do: [ :deltaColumna |
            ((deltaFila = 0) and: [ deltaColumna = 0 ]) ifFalse: [
                otraFila := ((unaFila + deltaFila - 1) \\ filas) + 1.
                otraColumna := ((unaColumna + deltaColumna - 1) \\ columnas) + 1.
                resultado add: (self celdaEnFila: otraFila columna: otraColumna) ] ] ].
    ^ resultado asArray
! !

!SimuladorJuegoDeLaVida methodsFor: 'initialization'!
initialize
    super initialize.
    grilla := nil.
    generacionActual := 0.
    generacionesObjetivo := 0.
! !

!SimuladorJuegoDeLaVida class methodsFor: 'instance creation'!
conGrilla: unaGrilla generaciones: unaCantidad
    ^ self new inicializarConGrilla: unaGrilla generaciones: unaCantidad
! !

!SimuladorJuegoDeLaVida methodsFor: 'initialization'!
inicializarConGrilla: unaGrilla generaciones: unaCantidad
    (unaGrilla isKindOf: Grilla)
        ifFalse: [ self error: 'La simulacion requiere una grilla valida' ].
    ((unaCantidad isInteger) and: [ unaCantidad >= 0 ])
        ifFalse: [ self error: 'Las generaciones deben ser un entero no negativo' ].
    grilla := unaGrilla.
    generacionActual := 0.
    generacionesObjetivo := unaCantidad.
    ^ self
! !

!SimuladorJuegoDeLaVida methodsFor: 'evolution'!
paso
    "Devuelve false si ya se completo la simulacion."
    self finalizo ifTrue: [ ^ false ].
    grilla avanzarGeneracion.
    generacionActual := generacionActual + 1.
    ^ true
! !

!SimuladorJuegoDeLaVida methodsFor: 'evolution'!
ejecutar
    [ self finalizo ] whileFalse: [ self paso ].
    ^ self
! !

!SimuladorJuegoDeLaVida methodsFor: 'accessing'!
finalizo
    ^ generacionActual >= generacionesObjetivo
! !

!SimuladorJuegoDeLaVida methodsFor: 'accessing'!
poblacionActual
    ^ grilla poblacionViva
! !

!SimuladorJuegoDeLaVida methodsFor: 'accessing'!
grilla
    ^ grilla
! !

!SimuladorJuegoDeLaVida methodsFor: 'accessing'!
generacionActual
    ^ generacionActual
! !

!SimuladorJuegoDeLaVida methodsFor: 'accessing'!
generacionesObjetivo
    ^ generacionesObjetivo
! !
