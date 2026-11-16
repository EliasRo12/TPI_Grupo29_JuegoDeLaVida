"TPI Grupo 29 - instalacion completa y apertura automatica de la interfaz.
 Contiene las cinco clases originales, las 27 pruebas SUnit y la vista animada.
 Importar UNA SOLA VEZ con fileIn desde Pharo 14.
 La GUI no ha podido probarse en Pharo dentro de este entorno."!

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

TestCase subclass: #CeldaTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida-Tests'!

CeldaTest comment: 'Pruebas SUnit del TPI Juego de la Vida - Grupo 29.'!

TestCase subclass: #GrillaTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida-Tests'!

GrillaTest comment: 'Pruebas SUnit del TPI Juego de la Vida - Grupo 29.'!

TestCase subclass: #SimuladorJuegoDeLaVidaTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'TPI-JuegoDeLaVida-Tests'!

SimuladorJuegoDeLaVidaTest comment: 'Pruebas SUnit del TPI Juego de la Vida - Grupo 29.'!

!CeldaTest methodsFor: 'tests'!
testEstadoInicialMuerto
    | celda |
    celda := Celda new.
    self deny: celda estaViva.
    self assert: celda cantidadVecinasVivas equals: 0
! !

!CeldaTest methodsFor: 'tests'!
testUnaCeldaAisladaMuere
    | celda |
    celda := Celda new estadoInicialVivo: true.
    celda prepararSiguienteEstado.
    self assert: celda estaViva.
    celda confirmarEvolucion.
    self deny: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testNaceConTresVecinas
    | celda vecinas |
    celda := Celda new.
    vecinas := (1 to: 3) collect: [ :i | Celda new estadoInicialVivo: true ].
    celda vecinas: vecinas.
    celda prepararSiguienteEstado.
    celda confirmarEvolucion.
    self assert: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testMuertaConDosVecinasSigueMuerta
    | celda |
    celda := Celda new.
    celda vecinas: ((1 to: 2) collect: [ :i | Celda new estadoInicialVivo: true ]).
    celda prepararSiguienteEstado.
    celda confirmarEvolucion.
    self deny: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testVivaConDosVecinasSobrevive
    | celda |
    celda := Celda new estadoInicialVivo: true.
    celda vecinas: ((1 to: 2) collect: [ :i | Celda new estadoInicialVivo: true ]).
    celda prepararSiguienteEstado.
    celda confirmarEvolucion.
    self assert: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testVivaConTresVecinasSobreviveConfirmadoDocente
    | celda |
    celda := Celda new estadoInicialVivo: true.
    celda vecinas: ((1 to: 3) collect: [ :i | Celda new estadoInicialVivo: true ]).
    celda prepararSiguienteEstado.
    celda confirmarEvolucion.
    self assert: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testVivaConCuatroVecinasMuere
    | celda |
    celda := Celda new estadoInicialVivo: true.
    celda vecinas: ((1 to: 4) collect: [ :i | Celda new estadoInicialVivo: true ]).
    celda prepararSiguienteEstado.
    celda confirmarEvolucion.
    self deny: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testSinReglaAplicableConservaEstado
    | celda |
    celda := Celda new.
    celda prepararSiguienteEstado.
    celda confirmarEvolucion.
    self deny: celda estaViva
! !

!CeldaTest methodsFor: 'tests'!
testPreparacionNoCambiaEstadoActual
    | celda |
    celda := Celda new estadoInicialVivo: true.
    celda prepararSiguienteEstado.
    self assert: celda estaViva
! !

!GrillaTest methodsFor: 'tests'!
testConstruccionArrayYPoblacion
    | grilla |
    grilla := GrillaPlana conFilas: 4 columnas: 5 vivasEn: #((1 1) (4 5)).
    self assert: grilla filas equals: 4.
    self assert: grilla columnas equals: 5.
    self assert: grilla poblacionViva equals: 2.
    self assert: (grilla celdaEnFila: 4 columna: 5) estaViva
! !

!GrillaTest methodsFor: 'tests'!
testCoordenadasRepetidasNoDuplicanPoblacion
    | grilla |
    grilla := GrillaPlana conFilas: 3 columnas: 3 vivasEn: #((2 2) (2 2)).
    self assert: grilla poblacionViva equals: 1
! !

!GrillaTest methodsFor: 'tests'!
testEsquinaPlanaTresVecinas
    | grilla |
    grilla := GrillaPlana conFilas: 5 columnas: 5 vivasEn: #().
    self assert: (grilla celdasVecinasDeFila: 1 columna: 1) size equals: 3
! !

!GrillaTest methodsFor: 'tests'!
testGrillaPlanaUnoPorUnoCeroVecinas
    | grilla |
    grilla := GrillaPlana conFilas: 1 columnas: 1 vivasEn: #((1 1)).
    self assert: (grilla celdasVecinasDeFila: 1 columna: 1) size equals: 0.
    grilla avanzarGeneracion.
    self assert: grilla poblacionViva equals: 0
! !

!GrillaTest methodsFor: 'tests'!
testEsquinaToroidalOchoVecinasDistintas
    | grilla vecinas |
    grilla := GrillaToroidal conFilas: 3 columnas: 3 vivasEn: #().
    vecinas := grilla celdasVecinasDeFila: 1 columna: 1.
    self assert: vecinas size equals: 8.
    self assert: vecinas asSet size equals: 8
! !

!GrillaTest methodsFor: 'tests'!
testToroidalConectaBordesOpuestos
    | grilla esquina |
    grilla := GrillaToroidal conFilas: 5 columnas: 5 vivasEn: #((5 5)).
    esquina := grilla celdaEnFila: 1 columna: 1.
    self assert: esquina cantidadVecinasVivas equals: 1
! !

!GrillaTest methodsFor: 'tests'!
testBlOqueEstable
    | grilla |
    grilla := GrillaPlana conFilas: 5 columnas: 5 vivasEn: #((2 2) (2 3) (3 2) (3 3)).
    grilla avanzarGeneracion.
    self assert: grilla poblacionViva equals: 4.
    self assert: (grilla celdaEnFila: 2 columna: 2) estaViva.
    self assert: (grilla celdaEnFila: 3 columna: 3) estaViva
! !

!GrillaTest methodsFor: 'tests'!
testParpadeadorOscilaEnDosGeneraciones
    | grilla |
    grilla := GrillaPlana conFilas: 5 columnas: 5 vivasEn: #((2 3) (3 3) (4 3)).
    grilla avanzarGeneracion.
    self assert: grilla poblacionViva equals: 3.
    self assert: (grilla celdaEnFila: 3 columna: 2) estaViva.
    self deny: (grilla celdaEnFila: 2 columna: 3) estaViva.
    grilla avanzarGeneracion.
    self assert: grilla poblacionViva equals: 3.
    self assert: (grilla celdaEnFila: 2 columna: 3) estaViva.
    self deny: (grilla celdaEnFila: 3 columna: 2) estaViva
! !

!GrillaTest methodsFor: 'tests'!
testRechazarDimensionesInvalidas
    self should: [ GrillaPlana conFilas: 0 columnas: 5 vivasEn: #() ] raise: Error.
    self should: [ GrillaToroidal conFilas: 2 columnas: 3 vivasEn: #() ] raise: Error
! !

!GrillaTest methodsFor: 'tests'!
testRechazarCoordenadaFueraDeRango
    self should: [ GrillaPlana conFilas: 3 columnas: 3 vivasEn: #((4 1)) ] raise: Error.
    self should: [ GrillaPlana conFilas: 3 columnas: 3 vivasEn: #((1 0)) ] raise: Error
! !

!GrillaTest methodsFor: 'tests'!
testRechazarCoordenadasMalFormadas
    self should: [ GrillaPlana conFilas: 3 columnas: 3 vivasEn: #((1)) ] raise: Error
! !

!SimuladorJuegoDeLaVidaTest methodsFor: 'tests'!
testCeroGeneracionesNoEvoluciona
    | grilla simulador |
    grilla := GrillaPlana conFilas: 3 columnas: 3 vivasEn: #((2 2)).
    simulador := SimuladorJuegoDeLaVida conGrilla: grilla generaciones: 0.
    self assert: simulador finalizo.
    self deny: simulador paso.
    self assert: simulador poblacionActual equals: 1
! !

!SimuladorJuegoDeLaVidaTest methodsFor: 'tests'!
testDiezGeneracionesExactas
    | grilla simulador |
    grilla := GrillaPlana conFilas: 5 columnas: 5 vivasEn: #((2 3) (3 3) (4 3)).
    simulador := SimuladorJuegoDeLaVida conGrilla: grilla generaciones: 10.
    simulador ejecutar.
    self assert: simulador generacionActual equals: 10.
    self assert: simulador finalizo.
    self deny: simulador paso.
    self assert: simulador poblacionActual equals: 3
! !

!SimuladorJuegoDeLaVidaTest methodsFor: 'tests'!
testRechazarGeneracionesNegativas
    | grilla |
    grilla := GrillaPlana conFilas: 3 columnas: 3 vivasEn: #().
    self should: [ SimuladorJuegoDeLaVida conGrilla: grilla generaciones: -1 ] raise: Error
! !

!SimuladorJuegoDeLaVidaTest methodsFor: 'tests'!
testPasoIncrementaYActualizaPoblacion
    | grilla simulador |
    grilla := GrillaPlana conFilas: 3 columnas: 3 vivasEn: #((2 2)).
    simulador := SimuladorJuegoDeLaVida conGrilla: grilla generaciones: 2.
    self assert: simulador paso.
    self assert: simulador generacionActual equals: 1.
    self assert: simulador poblacionActual equals: 0
! !

!GrillaTest methodsFor: 'tests'!
testNaceEnEsquinaToroidalCruzandoBordes
    | grilla |
    "Las tres celulas activadas rodean (1,1) atravesando los bordes."
    grilla := GrillaToroidal
        conFilas: 5 columnas: 5 vivasEn: #((5 5) (5 1) (1 5)).
    self assert: (grilla celdaEnFila: 1 columna: 1) cantidadVecinasVivas equals: 3.
    grilla avanzarGeneracion.
    self assert: (grilla celdaEnFila: 1 columna: 1) estaViva
! !

!GrillaTest methodsFor: 'tests'!
testMismoPatronNoNaceEnEsquinaPlana
    | grilla |
    "El mismo patron se comporta distinto sin bordes conectados."
    grilla := GrillaPlana
        conFilas: 5 columnas: 5 vivasEn: #((5 5) (5 1) (1 5)).
    self assert: (grilla celdaEnFila: 1 columna: 1) cantidadVecinasVivas equals: 0.
    grilla avanzarGeneracion.
    self deny: (grilla celdaEnFila: 1 columna: 1) estaViva
! !

!GrillaTest methodsFor: 'tests'!
testPlaneadorCruzaBordesEnGrillaToroidalTreintaPorTreinta
    | grilla posicionesEsperadas |
    "Planeador diagonal: cuatro generaciones implican un desplazamiento (+1,+1)."
    grilla := GrillaToroidal
        conFilas: 30 columnas: 30
        vivasEn: #((28 29) (29 30) (30 28) (30 29) (30 30)).
    4 timesRepeat: [ grilla avanzarGeneracion ].
    posicionesEsperadas := #((1 1) (1 29) (1 30) (29 30) (30 1)).
    self assert: grilla poblacionViva equals: 5.
    posicionesEsperadas do: [ :par |
        self assert: (grilla celdaEnFila: par first columna: par second) estaViva ]
! !

"Interfaz grafica animada del TPI Juego de la Vida, Grupo 29.
 Presentacion Morphic. No cambia las reglas de la catedra ni las clases del dominio.
 Pharo 14: pendiente de validacion de la interfaz en la imagen del equipo."

Morph subclass: #VistaJuegoDeLaVida
    instanceVariableNames: 'simulador ladoCelda corriendo indicador botonPausa botonPaso botonReiniciar botonMasRapido botonMasLento intervaloMs coordenadasIniciales'
    classVariableNames: ''
    package: 'TPI-JuegoDeLaVida-UI'!

VistaJuegoDeLaVida comment: 'Vista Morphic del tablero. Anima las generaciones del simulador sin implementar reglas propias. Permite iniciar, pausar, avanzar, reiniciar y cambiar velocidad.'!

!VistaJuegoDeLaVida class methodsFor: 'instance creation'!
conSimulador: unSimulador
    ^ self new configurarCon: unSimulador
! !

!VistaJuegoDeLaVida methodsFor: 'initialization'!
initialize
    super initialize.
    simulador := nil.
    ladoCelda := 18.
    intervaloMs := 250.
    corriendo := false.
    coordenadasIniciales := #().
    self color: Color veryLightGray.
    self extent: 540 @ 620.
    indicador := StringMorph new.
    indicador color: Color black.
    self addMorph: indicador.
    botonPausa := self crearBoton: 'Iniciar' accion: #alternarPausa.
    botonPaso := self crearBoton: 'Siguiente' accion: #avanzarUnPaso.
    botonReiniciar := self crearBoton: 'Reiniciar' accion: #reiniciar.
    botonMasLento := self crearBoton: 'Mas lento' accion: #masLento.
    botonMasRapido := self crearBoton: 'Mas rapido' accion: #masRapido.
! !

!VistaJuegoDeLaVida methodsFor: 'initialization'!
crearBoton: unaEtiqueta accion: unSelector
    | boton |
    boton := SimpleButtonMorph new.
    boton label: unaEtiqueta.
    boton target: self.
    boton actionSelector: unSelector.
    boton color: Color lightGray.
    boton extent: 98 @ 26.
    self addMorph: boton.
    ^ boton
! !

!VistaJuegoDeLaVida methodsFor: 'initialization'!
configurarCon: unSimulador
    | ancho alto |
    (unSimulador isKindOf: SimuladorJuegoDeLaVida)
        ifFalse: [ self error: 'Se requiere un SimuladorJuegoDeLaVida' ].
    simulador := unSimulador.
    coordenadasIniciales := OrderedCollection new.
    1 to: simulador grilla filas do: [ :fila |
        1 to: simulador grilla columnas do: [ :columna |
            (simulador grilla celdaEnFila: fila columna: columna) estaViva
                ifTrue: [ coordenadasIniciales add: (Array with: fila with: columna) ] ] ].
    ancho := simulador grilla columnas * ladoCelda.
    alto := simulador grilla filas * ladoCelda.
    self extent: (ancho max: 540) @ (alto + 72).
    indicador position: self topLeft + (8 @ (alto + 7)).
    botonPausa position: self topLeft + (8 @ (alto + 36)).
    botonPaso position: self topLeft + (114 @ (alto + 36)).
    botonReiniciar position: self topLeft + (220 @ (alto + 36)).
    botonMasLento position: self topLeft + (326 @ (alto + 36)).
    botonMasRapido position: self topLeft + (432 @ (alto + 36)).
    self actualizarIndicador.
    ^ self
! !

!VistaJuegoDeLaVida methodsFor: 'drawing'!
drawOn: unCanvas
    | origen rectangulo estaViva |
    super drawOn: unCanvas.
    simulador ifNil: [ ^ self ].
    origen := self topLeft.
    1 to: simulador grilla filas do: [ :fila |
        1 to: simulador grilla columnas do: [ :columna |
            estaViva := (simulador grilla celdaEnFila: fila columna: columna) estaViva.
            rectangulo :=
                (origen + (((columna - 1) * ladoCelda) @ ((fila - 1) * ladoCelda)))
                    extent: (ladoCelda - 1) @ (ladoCelda - 1).
            unCanvas
                fillRectangle: rectangulo
                color: (estaViva ifTrue: [ Color blue ] ifFalse: [ Color white ]) ] ].
! !

!VistaJuegoDeLaVida methodsFor: 'display'!
actualizarIndicador
    simulador ifNil: [ ^ self ].
    indicador contents:
        ('Generacion: ', simulador generacionActual asString,
         '    Poblacion: ', simulador poblacionActual asString,
         '    Intervalo: ', intervaloMs asString, ' ms',
         '    ', (simulador finalizo
                ifTrue: [ 'Finalizado' ]
                ifFalse: [ corriendo ifTrue: [ 'En marcha' ] ifFalse: [ 'En pausa' ] ])).
    botonPausa label: (simulador finalizo
        ifTrue: [ 'Finalizado' ]
        ifFalse: [ corriendo ifTrue: [ 'Pausar' ] ifFalse: [ 'Iniciar' ] ]).
! !

!VistaJuegoDeLaVida methodsFor: 'stepping'!
stepTime
    ^ intervaloMs
! !

!VistaJuegoDeLaVida methodsFor: 'stepping'!
step
    corriendo ifFalse: [ ^ self ].
    simulador finalizo ifTrue: [
        corriendo := false.
        self actualizarIndicador.
        ^ self ].
    simulador paso.
    simulador finalizo ifTrue: [ corriendo := false ].
    self actualizarIndicador.
    self changed.
! !

!VistaJuegoDeLaVida methodsFor: 'events'!
handlesMouseDown: unEvento
    ^ true
! !

!VistaJuegoDeLaVida methodsFor: 'events'!
mouseDown: unEvento
    self alternarPausa
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
alternarPausa
    simulador finalizo ifTrue: [ ^ self ].
    corriendo := corriendo not.
    self actualizarIndicador.
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
avanzarUnPaso
    corriendo := false.
    simulador finalizo ifFalse: [ simulador paso ].
    self actualizarIndicador.
    self changed.
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
reiniciar
    | nuevaGrilla |
    nuevaGrilla := simulador grilla class
        conFilas: simulador grilla filas
        columnas: simulador grilla columnas
        vivasEn: coordenadasIniciales.
    simulador := SimuladorJuegoDeLaVida
        conGrilla: nuevaGrilla
        generaciones: simulador generacionesObjetivo.
    corriendo := false.
    self actualizarIndicador.
    self changed.
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
masRapido
    intervaloMs := (intervaloMs - 50) max: 50.
    self reiniciarTemporizador.
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
masLento
    intervaloMs := (intervaloMs + 50) min: 1000.
    self reiniciarTemporizador.
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
reiniciarTemporizador
    self stopStepping.
    self startStepping.
    self actualizarIndicador.
! !

!VistaJuegoDeLaVida methodsFor: 'controls'!
abrir
    self openInWorld.
    corriendo := true.
    self actualizarIndicador.
    self startStepping.
    ^ self
! !

"Demostracion principal: planeador de 5 celulas cerca del borde inferior derecho.
 Modalidad toroidal, 30 x 30, 200 generaciones."
| grilla simulador vista |
grilla := GrillaToroidal
    conFilas: 30
    columnas: 30
    vivasEn: #((28 29) (29 30) (30 28) (30 29) (30 30)).
simulador := SimuladorJuegoDeLaVida
    conGrilla: grilla
    generaciones: 200.
vista := VistaJuegoDeLaVida conSimulador: simulador.
vista abrir.!
