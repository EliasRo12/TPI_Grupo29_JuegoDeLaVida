"VERSION:1.0"!Morph subclass: #VistaJuegoDeLaVida	instanceVariableNames: 'simulador ladoCelda corriendo indicador botonPausa botonPaso botonReiniciar botonMasRapido botonMasLento botonCerrar intervaloMs coordenadasIniciales'	classVariableNames: ''	package: 'TPI-JuegoDeLaVida-UI'!VistaJuegoDeLaVida class	instanceVariableNames: ''!!VistaJuegoDeLaVida commentStamp: '<historical>' prior: '0'!Vista Morphic del tablero. Anima las generaciones del simulador sin implementar reglas propias. Permite iniciar, pausar, avanzar, reiniciar y cambiar velocidad.!Morph subclass: #PanelConfiguracionJuegoDeLaVida	instanceVariableNames: 'filas columnas tipoGrilla modoInicializacion densidad numeroFigura generaciones morphFilas morphColumnas morphTipoGrilla morphModo morphDensidad morphFigura morphGeneraciones botonIniciar botonCerrar'	classVariableNames: ''	package: 'TPI-JuegoDeLaVida'!PanelConfiguracionJuegoDeLaVida class	instanceVariableNames: ''!Object subclass: #Celda	instanceVariableNames: 'estadoActual estadoSiguiente vecinas'	classVariableNames: ''	package: 'TPI-JuegoDeLaVida'!Celda class	instanceVariableNames: ''!!Celda commentStamp: '<historical>' prior: '0'!Representa una celda con estado binario. Consulta sus vecinas y prepara su siguiente estado sin alterar el actual. Regla base: consigna de UTN FRRe, tema 9, pagina 16.!Object subclass: #SimuladorJuegoDeLaVida	instanceVariableNames: 'grilla generacionActual generacionesObjetivo'	classVariableNames: ''	package: 'TPI-JuegoDeLaVida'!SimuladorJuegoDeLaVida class	instanceVariableNames: ''!!SimuladorJuegoDeLaVida commentStamp: '<historical>' prior: '0'!Orquesta la cantidad de generaciones y permite consultar poblacion y estado de ejecucion. No hace presentacion.!Object subclass: #Grilla	instanceVariableNames: 'filas columnas celdas'	classVariableNames: ''	package: 'TPI-JuegoDeLaVida'!Grilla class	instanceVariableNames: ''!!Grilla commentStamp: '<historical>' prior: '0'!Administra las celdas, acceso por coordenadas, vinculacion de vecinas y actualizacion en dos fases. Subclases especializan la topologia.!Grilla subclass: #GrillaPlana	instanceVariableNames: ''	classVariableNames: ''	package: 'TPI-JuegoDeLaVida'!GrillaPlana class	instanceVariableNames: ''!!GrillaPlana commentStamp: '<historical>' prior: '0'!Vecindad limitada: solo incluye posiciones validas dentro del tablero.!Grilla subclass: #GrillaToroidal	instanceVariableNames: ''	classVariableNames: ''	package: 'TPI-JuegoDeLaVida'!GrillaToroidal class	instanceVariableNames: ''!!GrillaToroidal commentStamp: '<historical>' prior: '0'!Variante original: conecta bordes opuestos para obtener 8 vecinas distintas en grillas de al menos 3 por 3.!!Celda methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.691739-03:00' prior: 0!cantidadVecinasVivas
    ^ vecinas count: [ :unaCelda | unaCelda estaViva ]
! !!Celda methodsFor: 'evolution' stamp: '2026-11-23T11:22:44.691894-03:00' prior: 0!confirmarEvolucion
    "Fase 2: ejecutar solo despues de preparar todas las celdas."
    estadoActual := estadoSiguiente.
    ^ self
! !!Celda methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.692097-03:00' prior: 0!estaViva
    ^ estadoActual
! !!Celda methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.692166-03:00' prior: 0!estadoInicialVivo: unBooleano
    "Solo para la configuracion antes de iniciar la simulacion."
    ((unBooleano == true) or: [ unBooleano == false ])
        ifFalse: [ self error: 'El estado inicial debe ser booleano' ].
    estadoActual := unBooleano.
    estadoSiguiente := unBooleano.
    ^ self
! !!Celda methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.692199-03:00' prior: 0!initialize
    super initialize.
    estadoActual := false.
    estadoSiguiente := false.
    vecinas := #().
! !!Celda methodsFor: 'evolution' stamp: '2026-11-23T11:22:44.69224-03:00' prior: 0!prepararSiguienteEstado
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
! !!Celda methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.692293-03:00' prior: 0!vecinas: unaColeccion
    "La grilla asigna las vecinas una vez al construir el tablero."
    vecinas := unaColeccion asArray.
    ^ self
! !!Grilla class methodsFor: 'instance creation' stamp: '2026-11-23T11:22:44.692328-03:00' prior: 0!conFilas: cantidadFilas columnas: cantidadColumnas vivasEn: coordenadas
    "Constructor heredable, llamado sobre GrillaPlana o GrillaToroidal."
    self == Grilla ifTrue: [ self error: 'Elegir GrillaPlana o GrillaToroidal' ].
    ^ self new
        inicializarConFilas: cantidadFilas
        columnas: cantidadColumnas
        vivasEn: coordenadas
! !!Grilla methodsFor: 'evolution' stamp: '2026-11-23T11:22:44.692359-03:00' prior: 0!avanzarGeneracion
    "La fase 1 completa no cambia estadoActual de ninguna celda."
    celdas do: [ :unaCelda | unaCelda prepararSiguienteEstado ].
    celdas do: [ :unaCelda | unaCelda confirmarEvolucion ].
! !!Grilla methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.692391-03:00' prior: 0!celdaEnFila: unaFila columna: unaColumna
    ^ celdas at: (self indiceParaFila: unaFila columna: unaColumna)
! !!Grilla methodsFor: 'topology' stamp: '2026-11-23T11:22:44.692423-03:00' prior: 0!celdasVecinasDeFila: unaFila columna: unaColumna
    "Cada modalidad implementa la topologia concreta."
    self subclassResponsibility
! !!Grilla methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.692455-03:00' prior: 0!columnas
    ^ columnas
! !!Grilla methodsFor: 'topology' stamp: '2026-11-23T11:22:44.692486-03:00' prior: 0!conectarVecinas
    1 to: filas do: [ :fila |
        1 to: columnas do: [ :columna |
            (self celdaEnFila: fila columna: columna)
                vecinas: (self celdasVecinasDeFila: fila columna: columna) ] ].
! !!Grilla methodsFor: 'validation' stamp: '2026-11-23T11:22:44.692522-03:00' prior: 0!coordenadasValidasFila: unaFila columna: unaColumna
    ^ ((unaFila isInteger) and: [ unaColumna isInteger ])
        and: [ (unaFila between: 1 and: filas)
        and: [ unaColumna between: 1 and: columnas ] ]
! !!Grilla methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.692551-03:00' prior: 0!filas
    ^ filas
! !!Grilla methodsFor: 'private' stamp: '2026-11-23T11:22:44.69258-03:00' prior: 0!indiceParaFila: unaFila columna: unaColumna
    (self coordenadasValidasFila: unaFila columna: unaColumna)
        ifFalse: [ self error: 'Coordenada fuera del tablero' ].
    ^ ((unaFila - 1) * columnas) + unaColumna
! !!Grilla methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.692634-03:00' prior: 0!inicializarConFilas: cantidadFilas columnas: cantidadColumnas vivasEn: coordenadas
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
! !!Grilla methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.692674-03:00' prior: 0!initialize
    super initialize.
    filas := 0.
    columnas := 0.
    celdas := #().
! !!Grilla methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.692702-03:00' prior: 0!poblacionViva
    ^ celdas count: [ :unaCelda | unaCelda estaViva ]
! !!Grilla methodsFor: 'validation' stamp: '2026-11-23T11:22:44.692733-03:00' prior: 0!validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas
    ((cantidadFilas isInteger) and: [ cantidadColumnas isInteger ])
        ifFalse: [ self error: 'Las dimensiones deben ser enteros' ].
    ((cantidadFilas > 0) and: [ cantidadColumnas > 0 ])
        ifFalse: [ self error: 'Las dimensiones deben ser mayores a cero' ].
! !!GrillaPlana methodsFor: 'topology' stamp: '2026-11-23T11:22:44.692782-03:00' prior: 0!celdasVecinasDeFila: unaFila columna: unaColumna
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
! !!GrillaToroidal methodsFor: 'topology' stamp: '2026-11-23T11:22:44.692834-03:00' prior: 0!celdasVecinasDeFila: unaFila columna: unaColumna
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
! !!GrillaToroidal methodsFor: 'validation' stamp: '2026-11-23T11:22:44.693014-03:00' prior: 0!validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas    super validarDimensionesConFilas: cantidadFilas columnas: cantidadColumnas.    ((cantidadFilas >= 10) and: [ cantidadColumnas >= 10 ])        ifFalse: [ self error: 'La grilla toroidal requiere como minimo 10 x 10' ].    ((cantidadFilas <= 55) and: [ cantidadColumnas <= 100 ])        ifFalse: [ self error: 'La grilla toroidal admite como maximo 55 x 100' ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones' stamp: '2026-11-23T11:22:44.693049-03:00' prior: 0!actualizarTextoColumnas    morphColumnas contents: 'Columnas: ', columnas asString.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Densidad' stamp: '2026-11-23T11:22:44.693084-03:00' prior: 0!actualizarTextoDensidad    morphDensidad contents:        (modoInicializacion = 1            ifTrue: [ 'Densidad: ', densidad asString, '%' ]            ifFalse: [ 'Densidad: No aplica' ]).! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Figuras' stamp: '2026-11-23T11:22:44.693125-03:00' prior: 0!actualizarTextoFigura    | nombreFigura |    nombreFigura := #(        'Block (Estable)'        'Blinker'        'Toad'        'Beacon'        'Glider (Planeador)'        'LWSS'        'Pulsar'        'Pentadecathlon'        'Acorn'        'Gosper Glider Gun'    ) at: numeroFigura.    morphFigura contents:        (modoInicializacion = 2            ifTrue: [ 'Figura: ', nombreFigura ]            ifFalse: [ 'Figura: No aplica' ]).! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones' stamp: '2026-11-23T11:22:44.69316-03:00' prior: 0!actualizarTextoFilas    morphFilas contents: 'Filas: ', filas asString.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Generaciones' stamp: '2026-11-23T11:22:44.693202-03:00' prior: 0!actualizarTextoGeneraciones    morphGeneraciones contents:        'Generaciones: ', generaciones asString.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Inicializacion' stamp: '2026-11-23T11:22:44.693235-03:00' prior: 0!actualizarTextoModo    morphModo contents:        (modoInicializacion = 1            ifTrue: [ 'Modo: Aleatorio' ]            ifFalse: [                modoInicializacion = 2                    ifTrue: [ 'Modo: Figura predefinida' ]                    ifFalse: [ 'Modo: Manual' ] ]).! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Grilla' stamp: '2026-11-23T11:22:44.693267-03:00' prior: 0!actualizarTextoTipoGrilla    morphTipoGrilla contents:        (tipoGrilla = 1            ifTrue: [ 'Tipo: Plana' ]            ifFalse: [ 'Tipo: Toroidal' ]).! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones - Acciones' stamp: '2026-11-23T11:22:44.693295-03:00' prior: 0!aumentarColumnas    columnas < 100        ifTrue: [            columnas := columnas + 10.            self actualizarTextoColumnas ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Densidad' stamp: '2026-11-23T11:22:44.693331-03:00' prior: 0!aumentarDensidad    (modoInicializacion = 1 and: [ densidad < 100 ])        ifTrue: [            densidad := (densidad + 5) min: 100.            self actualizarTextoDensidad ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones - Acciones' stamp: '2026-11-23T11:22:44.69336-03:00' prior: 0!aumentarFilas    filas < 100        ifTrue: [            filas := filas + 5.            self actualizarTextoFilas ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Generaciones' stamp: '2026-11-23T11:22:44.693391-03:00' prior: 0!aumentarGeneraciones    generaciones := generaciones + 10.    self actualizarTextoGeneraciones.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Inicializacion' stamp: '2026-11-23T11:22:44.69342-03:00' prior: 0!cambiarModoInicializacion    modoInicializacion := modoInicializacion = 3        ifTrue: [ 1 ]        ifFalse: [ modoInicializacion + 1 ].    self actualizarTextoModo.    self actualizarTextoDensidad.    self actualizarTextoFigura.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Grilla' stamp: '2026-11-23T11:22:44.69345-03:00' prior: 0!cambiarTipoGrilla    tipoGrilla := tipoGrilla = 1        ifTrue: [ 2 ]        ifFalse: [ 1 ].    self actualizarTextoTipoGrilla.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Acciones' stamp: '2026-11-23T11:22:44.693477-03:00' prior: 0!cerrarPanel    self delete.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Construccion' stamp: '2026-11-23T11:22:44.693513-03:00' prior: 0!crearBoton: unaEtiqueta accion: unSelector posicion: unaPosicion    | boton |    boton := SimpleButtonMorph new.    boton label: unaEtiqueta.    boton target: self.    boton actionSelector: unSelector.    boton color: 	Color veryLightGray.    boton extent: 100 @ 30.    boton position: unaPosicion.    self addMorph: boton.    ^ boton! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Acciones' stamp: '2026-11-23T11:22:44.693558-03:00' prior: 0!crearBotonesFinales    botonIniciar := self crearBoton: 'Iniciar simulacion'        accion: #iniciarSimulacion        posicion: 170 @ 665.    botonIniciar color: Color paleGreen.    botonIniciar submorphs first color: Color black.    botonCerrar := self crearBoton: 'Cerrar'        accion: #cerrarPanel        posicion: 300 @ 665.    botonCerrar color: Color lightRed.    botonCerrar submorphs first color: Color black.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Densidad' stamp: '2026-11-23T11:22:44.693599-03:00' prior: 0!crearControlDensidad    self crearTexto: 'DENSIDAD DE POBLACION' posicion: 30 @ 405.    self crearBoton: '- 5%'        accion: #disminuirDensidad        posicion: 40 @ 445.    morphDensidad := StringMorph new.    self actualizarTextoDensidad.    morphDensidad position: 200 @ 455.    morphDensidad color: Color black.    self addMorph: morphDensidad.    self crearBoton: '+ 5%'        accion: #aumentarDensidad        posicion: 350 @ 445.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Figuras' stamp: '2026-11-23T11:22:44.693644-03:00' prior: 0!crearControlFigura    self crearTexto: 'FIGURA PREDEFINIDA' posicion: 30 @ 495.    self crearBoton: 'Anterior'        accion: #figuraAnterior        posicion: 40 @ 535.    morphFigura := StringMorph new.    self actualizarTextoFigura.    morphFigura position: 180 @ 545.    morphFigura color: Color black.    self addMorph: morphFigura.    self crearBoton: 'Siguiente'        accion: #figuraSiguiente        posicion: 350 @ 535.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Generaciones' stamp: '2026-11-23T11:22:44.693686-03:00' prior: 0!crearControlGeneraciones    self crearTexto: 'CANTIDAD DE GENERACIONES' posicion: 30 @ 575.    self crearBoton: '- 10'        accion: #disminuirGeneraciones        posicion: 40 @ 615.    morphGeneraciones := StringMorph new.    self actualizarTextoGeneraciones.    morphGeneraciones position: 200 @ 625.    morphGeneraciones color: Color black.    self addMorph: morphGeneraciones.    self crearBoton: '+ 10'        accion: #aumentarGeneraciones        posicion: 350 @ 615.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Inicializacion' stamp: '2026-11-23T11:22:44.693723-03:00' prior: 0!crearControlInicializacion    self crearTexto: 'INICIALIZACION' posicion: 30 @ 315.    self crearBoton: 'Cambiar modo'        accion: #cambiarModoInicializacion        posicion: 40 @ 355.    morphModo := StringMorph new.    self actualizarTextoModo.    morphModo position: 200 @ 365.    morphModo color: Color black.    self addMorph: morphModo.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Grilla' stamp: '2026-11-23T11:22:44.693759-03:00' prior: 0!crearControlTipoGrilla    self crearTexto: 'TIPO DE GRILLA' posicion: 30 @ 225.    self crearBoton: 'Cambiar tipo'        accion: #cambiarTipoGrilla        posicion: 40 @ 265.    morphTipoGrilla := StringMorph new.    self actualizarTextoTipoGrilla.    morphTipoGrilla position: 200 @ 275.    morphTipoGrilla color: Color black.    self addMorph: morphTipoGrilla.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones' stamp: '2026-11-23T11:22:44.693803-03:00' prior: 0!crearControlesDimensiones    self crearTexto: 'DIMENSIONES DE LA GRILLA' posicion: 30 @ 75.    self crearBoton: '-'        accion: #disminuirFilas        posicion: 40 @ 115.    morphFilas := StringMorph new.    self actualizarTextoFilas.    morphFilas position: 165 @ 125.    morphFilas color: Color black.    self addMorph: morphFilas.    self crearBoton: '+'        accion: #aumentarFilas        posicion: 250 @ 115.    self crearBoton: '-'        accion: #disminuirColumnas        posicion: 40 @ 165.    morphColumnas := StringMorph new.    self actualizarTextoColumnas.    morphColumnas position: 165 @ 175.    morphColumnas color: Color black.    self addMorph: morphColumnas.    self crearBoton: '+'        accion: #aumentarColumnas        posicion: 250 @ 165.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Construccion' stamp: '2026-11-23T11:22:44.69384-03:00' prior: 0!crearTexto: unTexto posicion: unaPosicion    | texto |    texto := StringMorph new.    texto contents: unTexto.    texto color: Color black.    texto position: unaPosicion.    self addMorph: texto.    ^ texto! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Construccion' stamp: '2026-11-23T11:22:44.693871-03:00' prior: 0!crearTitulo    | titulo |    titulo := StringMorph new.    titulo contents: 'JUEGO DE LA VIDA'.    titulo color: Color black.    titulo emphasis: 1.    titulo position: 30 @ 25.    self addMorph: titulo.    ^ titulo! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones - Acciones' stamp: '2026-11-23T11:22:44.693902-03:00' prior: 0!disminuirColumnas    columnas > 1        ifTrue: [            columnas := columnas - 10.            self actualizarTextoColumnas ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Densidad' stamp: '2026-11-23T11:22:44.693936-03:00' prior: 0!disminuirDensidad    (modoInicializacion = 1 and: [ densidad > 0 ])        ifTrue: [            densidad := (densidad - 5) max: 0.            self actualizarTextoDensidad ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Dimensiones - Acciones' stamp: '2026-11-23T11:22:44.693964-03:00' prior: 0!disminuirFilas    filas > 1        ifTrue: [            filas := filas - 5.            self actualizarTextoFilas ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Generaciones' stamp: '2026-11-23T11:22:44.693995-03:00' prior: 0!disminuirGeneraciones    generaciones > 10        ifTrue: [            generaciones := generaciones - 10.            self actualizarTextoGeneraciones ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Figuras' stamp: '2026-11-23T11:22:44.694026-03:00' prior: 0!figuraAnterior    modoInicializacion = 2        ifTrue: [            numeroFigura := numeroFigura = 1                ifTrue: [ 10 ]                ifFalse: [ numeroFigura - 1 ].            self actualizarTextoFigura ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Figuras' stamp: '2026-11-23T11:22:44.694058-03:00' prior: 0!figuraSiguiente    modoInicializacion = 2        ifTrue: [            numeroFigura := numeroFigura = 10                ifTrue: [ 1 ]                ifFalse: [ numeroFigura + 1 ].            self actualizarTextoFigura ].! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'UI - Acciones' stamp: '2026-11-23T11:22:44.6941-03:00' prior: 0!iniciarSimulacion    | grilla simulador vista |    self validarConfiguracion.    grilla := (tipoGrilla = 1        ifTrue: [ GrillaPlana ]        ifFalse: [ GrillaToroidal ])        conFilas: filas        columnas: columnas        vivasEn: #().    simulador := SimuladorJuegoDeLaVida        conGrilla: grilla        generaciones: generaciones.    modoInicializacion = 1        ifTrue: [            simulador generarAleatoriamenteConDensidad: densidad        ].    modoInicializacion = 2        ifTrue: [            simulador cargarFigura: numeroFigura        ].    vista := VistaJuegoDeLaVida        conSimulador: simulador.    vista abrir.    self delete.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694144-03:00' prior: 0!initialize    super initialize.    filas := 20.    columnas := 20.    tipoGrilla := 1.    modoInicializacion := 1.    densidad := 30.    numeroFigura := 5.    generaciones := 100.    self color: 	Color lightGray.    self extent: 600 @ 700.    self crearTitulo.    self crearControlesDimensiones.    self crearControlTipoGrilla.    self crearControlInicializacion.    self crearControlDensidad.    self crearControlFigura.    self crearControlGeneraciones.    self crearBotonesFinales.! !!PanelConfiguracionJuegoDeLaVida methodsFor: 'validacion' stamp: '2026-11-23T11:22:44.6942-03:00' prior: 0!validarConfiguracion    (filas isInteger and: [ columnas isInteger ])        ifFalse: [ self error: 'Las dimensiones deben ser enteras' ].    (filas >= 10 and: [ columnas >= 10 ])        ifFalse: [ self error: 'Las dimensiones deben ser minimo 10 x 10' ].    (filas <= 55 and: [ columnas <= 100 ])        ifFalse: [ self error: 'La grilla plana admite hasta 55 x 100' ].    (tipoGrilla = 2)        ifTrue: [            (filas >= 10 and: [ columnas >= 10 ])                ifFalse: [ self error: 'La grilla toroidal requiere como minimo 10 x 10' ].            (filas <= 55 and: [ columnas <= 100 ])                ifFalse: [ self error: 'La grilla toroidal admite como maximo 55 x 100' ] ].    (generaciones isInteger and: [ generaciones > 0 ])        ifFalse: [ self error: 'Las generaciones deben ser mayores a cero' ].    (densidad >= 0 and: [ densidad <= 100 ])        ifFalse: [ self error: 'La densidad debe estar entre 0 y 100' ].    ^ true.! !!SimuladorJuegoDeLaVida class methodsFor: 'instance creation' stamp: '2026-11-23T11:22:44.694245-03:00' prior: 0!conGrilla: unaGrilla generaciones: unaCantidad
    ^ self new inicializarConGrilla: unaGrilla generaciones: unaCantidad
! !!SimuladorJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694373-03:00' prior: 0!cargarFigura: numeroFigura    | coordenadas altoFigura anchoFigura filaInicial columnaInicial fila columna celda |    "Validar seleccion"    ((numeroFigura isInteger) and: [        (numeroFigura >= 1) and: [ numeroFigura <= 10 ] ])        ifFalse: [ self error: 'Seleccione una figura entre 1 y 10' ].    "Validar que no haya comenzado la simulacion"    generacionActual >= 1        ifTrue: [ self error: 'No se puede cargar una figura durante la simulacion' ].    "Catalogo de figuras"    numeroFigura = 1 ifTrue: [        "Block: figura estable"        coordenadas := #(            (1 1) (1 2)            (2 1) (2 2)        )    ].    numeroFigura = 2 ifTrue: [        "Blinker: oscilador de periodo 2"        coordenadas := #(            (1 1) (1 2) (1 3)        )    ].    numeroFigura = 3 ifTrue: [        "Toad: oscilador de periodo 2"        coordenadas := #(            (1 2) (1 3) (1 4)            (2 1) (2 2) (2 3)        )    ].    numeroFigura = 4 ifTrue: [        "Beacon: oscilador de periodo 2"        coordenadas := #(            (1 1) (1 2)            (2 1) (2 2)            (3 3) (3 4)            (4 3) (4 4)        )    ].    numeroFigura = 5 ifTrue: [        "Glider: planeador"        coordenadas := #(            (1 2)            (2 3)            (3 1) (3 2) (3 3)        )    ].    numeroFigura = 6 ifTrue: [        "LWSS: Lightweight Spaceship"        coordenadas := #(            (1 1) (1 3)            (2 5)            (3 1) (3 4)            (4 2) (4 3) (4 4) (4 5)        )    ].    numeroFigura = 7 ifTrue: [        "Pulsar: oscilador de periodo 3"        coordenadas := #(            (2 4) (2 5) (2 6)            (2 8) (2 9) (2 10)            (4 2) (4 7) (4 12)            (5 2) (5 7) (5 12)            (6 2) (6 7) (6 12)            (7 4) (7 5) (7 6)            (7 8) (7 9) (7 10)            (8 4) (8 5) (8 6)            (8 8) (8 9) (8 10)            (10 2) (10 7) (10 12)            (11 2) (11 7) (11 12)            (12 2) (12 7) (12 12)            (13 4) (13 5) (13 6)            (13 8) (13 9) (13 10)        )    ].    numeroFigura = 8 ifTrue: [        "Pentadecathlon: oscilador de periodo 15"        coordenadas := #(            (1 1) (1 2) (1 3) (1 4) (1 5)            (1 6) (1 7) (1 8) (1 9) (1 10)        )    ].    numeroFigura = 9 ifTrue: [        "Acorn: evolucion prolongada"        coordenadas := #(            (1 2)            (2 4)            (3 1) (3 2)            (3 5) (3 6) (3 7)        )    ].    numeroFigura = 10 ifTrue: [        "Gosper Glider Gun: generador de planeadores"        coordenadas := #(            (1 25)            (2 23) (2 25)            (3 13) (3 14) (3 21) (3 22) (3 34) (3 35)            (4 12) (4 16) (4 21) (4 22) (4 34) (4 35)            (5 1) (5 2) (5 11) (5 17) (5 21) (5 22)            (6 1) (6 2) (6 11) (6 15) (6 17) (6 18)            (6 23) (6 25)            (7 11) (7 17)            (8 12) (8 16)            (9 13) (9 14)        )    ].    "Calcular dimensiones de la figura"    altoFigura := (coordenadas collect: [ :p | p first ]) max.    anchoFigura := (coordenadas collect: [ :p | p second ]) max.    "Verificar que la figura entre en la grilla"    (altoFigura > grilla filas or: [ anchoFigura > grilla columnas ])        ifTrue: [ self error: 'La figura es demasiado grande para la grilla' ].    "Calcular posicion inicial centrada"    filaInicial := ((grilla filas - altoFigura) // 2) + 1.    columnaInicial := ((grilla columnas - anchoFigura) // 2) + 1.    "Limpiar grilla"    1 to: grilla filas do: [ :unaFila |        1 to: grilla columnas do: [ :unaColumna |            celda := grilla celdaEnFila: unaFila columna: unaColumna.            celda estadoInicialVivo: false ] ].    "Ubicar figura seleccionada"    coordenadas do: [ :coordenada |        fila := filaInicial + coordenada first - 1.        columna := columnaInicial + coordenada second - 1.        celda := grilla celdaEnFila: fila columna: columna.        celda estadoInicialVivo: true ].    generacionActual := 0.    ^ self! !!SimuladorJuegoDeLaVida methodsFor: 'evolution' stamp: '2026-11-23T11:22:44.694452-03:00' prior: 0!ejecutar
    [ self finalizo ] whileFalse: [ self paso ].
    ^ self
! !!SimuladorJuegoDeLaVida methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.69448-03:00' prior: 0!finalizo
    ^ generacionActual >= generacionesObjetivo
! !!SimuladorJuegoDeLaVida methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.694506-03:00' prior: 0!generacionActual
    ^ generacionActual
! !!SimuladorJuegoDeLaVida methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.694531-03:00' prior: 0!generacionesObjetivo
    ^ generacionesObjetivo
! !!SimuladorJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694567-03:00' prior: 0!generarAleatoriamenteConDensidad: porcentaje    | aleatorio celda |    ((porcentaje isNumber) and: [ (porcentaje >= 0) and: [ porcentaje <= 100 ] ])        ifFalse: [ self error: 'La densidad debe estar entre 0 y 100' ].    aleatorio := Random new.    1 to: grilla filas do: [ :fila |        1 to: grilla columnas do: [ :columna |            celda := grilla celdaEnFila: fila columna: columna.            celda estadoInicialVivo:                (aleatorio next < (porcentaje / 100.0)) ] ].    generacionActual := 0.    ^ self! !!SimuladorJuegoDeLaVida methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.694597-03:00' prior: 0!grilla
    ^ grilla
! !!SimuladorJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694631-03:00' prior: 0!inicializarConGrilla: unaGrilla generaciones: unaCantidad
    (unaGrilla isKindOf: Grilla)
        ifFalse: [ self error: 'La simulacion requiere una grilla valida' ].
    ((unaCantidad isInteger) and: [ unaCantidad >= 0 ])
        ifFalse: [ self error: 'Las generaciones deben ser un entero no negativo' ].
    grilla := unaGrilla.
    generacionActual := 0.
    generacionesObjetivo := unaCantidad.
    ^ self
! !!SimuladorJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694662-03:00' prior: 0!initialize
    super initialize.
    grilla := nil.
    generacionActual := 0.
    generacionesObjetivo := 0.
! !!SimuladorJuegoDeLaVida methodsFor: 'evolution' stamp: '2026-11-23T11:22:44.69469-03:00' prior: 0!paso
    "Devuelve false si ya se completo la simulacion."
    self finalizo ifTrue: [ ^ false ].
    grilla avanzarGeneracion.
    generacionActual := generacionActual + 1.
    ^ true
! !!SimuladorJuegoDeLaVida methodsFor: 'accessing' stamp: '2026-11-23T11:22:44.694718-03:00' prior: 0!poblacionActual
    ^ grilla poblacionViva
! !!VistaJuegoDeLaVida class methodsFor: 'instance creation' stamp: '2026-11-23T11:22:44.694743-03:00' prior: 0!conSimulador: unSimulador
    ^ self new configurarCon: unSimulador
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.694771-03:00' prior: 0!abrir    corriendo := false.    self actualizarIndicador.    self openInWindowLabeled: 'Juego de la Vida'.    ^ self! !!VistaJuegoDeLaVida methodsFor: 'display' stamp: '2026-11-23T11:22:44.694815-03:00' prior: 0!actualizarIndicador
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
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.694854-03:00' prior: 0!alternarPausa
    simulador finalizo ifTrue: [ ^ self ].
    corriendo := corriendo not.
    self actualizarIndicador.
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.694883-03:00' prior: 0!avanzarUnPaso
    corriendo := false.
    simulador finalizo ifFalse: [ simulador paso ].
    self actualizarIndicador.
    self changed.
! !!VistaJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694948-03:00' prior: 0!configurarCon: unSimulador    | ancho alto anchoVentana anchoFila inicioX |    (unSimulador isKindOf: SimuladorJuegoDeLaVida)        ifFalse: [ self error: 'Se requiere un SimuladorJuegoDeLaVida' ].    simulador := unSimulador.    coordenadasIniciales := OrderedCollection new.    1 to: simulador grilla filas do: [ :fila |        1 to: simulador grilla columnas do: [ :columna |            (simulador grilla celdaEnFila: fila columna: columna) estaViva                ifTrue: [ coordenadasIniciales add: (Array with: fila with: columna) ] ] ].    ancho := simulador grilla columnas * ladoCelda.    alto := simulador grilla filas * ladoCelda.    anchoVentana := ancho max: 540.    self extent: anchoVentana @ (alto + 150).	    indicador position: self topLeft + (12 @ (alto + 12)).	anchoFila := botonPausa width + botonPaso width + botonReiniciar width + 40.	inicioX := (self width - anchoFila) / 2.	botonPausa position: self topLeft + (inicioX @ (alto + 45)).	botonPaso position: botonPausa topRight + (20 @ 0).	botonReiniciar position: botonPaso topRight + (20 @ 0).	anchoFila := botonMasLento width + botonMasRapido width + botonCerrar width + 40.	inicioX := (self width - anchoFila) / 2.	botonMasLento position: self topLeft + (inicioX @ (alto + 95)).	botonMasRapido position: botonMasLento topRight + (20 @ 0).	botonCerrar position: botonMasRapido topRight + (20 @ 0).	Transcript cr; show: 'Iniciar: ', botonPausa extent printString.Transcript cr; show: 'Siguiente: ', botonPaso extent printString.Transcript cr; show: 'Reiniciar: ', botonReiniciar extent printString.    self actualizarIndicador.    ^ self! !!VistaJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.694999-03:00' prior: 0!crearBoton: unaEtiqueta accion: unSelector    | boton |    boton := SimpleButtonMorph new.    boton label: unaEtiqueta.    boton target: self.    boton actionSelector: unSelector.    boton color: Color lightGray.    boton extent: 150 @ 40.    boton borderWidth: 1.    self addMorph: boton.    ^ boton! !!VistaJuegoDeLaVida methodsFor: 'drawing' stamp: '2026-11-23T11:22:44.695041-03:00' prior: 0!drawOn: unCanvas    | origen rectangulo estaViva |    super drawOn: unCanvas.    simulador ifNil: [ ^ self ].    origen := self origenGrilla.    1 to: simulador grilla filas do: [ :fila |        1 to: simulador grilla columnas do: [ :columna |            estaViva := (simulador grilla celdaEnFila: fila columna: columna) estaViva.            rectangulo :=                (origen + (((columna - 1) * ladoCelda) @ ((fila - 1) * ladoCelda)))                    extent: (ladoCelda - 1) @ (ladoCelda - 1).            unCanvas                fillRectangle: rectangulo                color: (estaViva ifTrue: [ Color blue ] ifFalse: [ Color white ]) ] ].! !!VistaJuegoDeLaVida methodsFor: 'event handling' stamp: '2026-11-23T11:22:44.695076-03:00' prior: 0!handlesMouseDown: unEvento
    ^ true
! !!VistaJuegoDeLaVida methodsFor: 'initialization' stamp: '2026-11-23T11:22:44.695118-03:00' prior: 0!initialize
    super initialize.
    simulador := nil.
    ladoCelda := 10.
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
    botonMasRapido := self crearBoton: 'Mas rapido' accion: #masRapido.	botonCerrar := self crearBoton: 'Salir' accion: #salir.
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.695157-03:00' prior: 0!masLento
    intervaloMs := (intervaloMs + 50) min: 1000.
    self reiniciarTemporizador.
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.695185-03:00' prior: 0!masRapido
    intervaloMs := (intervaloMs - 50) max: 50.
    self reiniciarTemporizador.
! !!VistaJuegoDeLaVida methodsFor: 'event handling' stamp: '2026-11-23T11:22:44.695228-03:00' prior: 0!mouseDown: unEvento    | posicion origen fila columna celda |    simulador ifNil: [ ^ self ].    coordenadasIniciales isEmpty ifFalse: [ ^ self ].    simulador generacionActual > 1 ifTrue: [ ^ self ].    corriendo ifTrue: [ ^ self ].    posicion := unEvento position.    origen := self origenGrilla.    columna := ((posicion x - origen x) // ladoCelda) + 1.    fila := ((posicion y - origen y) // ladoCelda) + 1.    ((fila >= 1) and: [ fila <= simulador grilla filas ])        ifFalse: [ ^ self ].    ((columna >= 1) and: [ columna <= simulador grilla columnas ])        ifFalse: [ ^ self ].    celda := simulador grilla celdaEnFila: fila columna: columna.    celda estadoInicialVivo: celda estaViva not.    self changed.    ^ self! !!VistaJuegoDeLaVida methodsFor: 'drawing' stamp: '2026-11-23T11:22:44.695267-03:00' prior: 0!origenGrilla    | anchoGrilla altoGrilla origenX origenY |    anchoGrilla := simulador grilla columnas * ladoCelda.    altoGrilla := simulador grilla filas * ladoCelda.    origenX := (self width - anchoGrilla) / 2.    origenY := ((self height - 120 - altoGrilla) / 2).    ^ self topLeft + (origenX @ origenY).! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.695302-03:00' prior: 0!reiniciar
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
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.695335-03:00' prior: 0!reiniciarTemporizador
    self stopStepping.
    self startStepping.
    self actualizarIndicador.
! !!VistaJuegoDeLaVida methodsFor: 'controls' stamp: '2026-11-23T11:22:44.695364-03:00' prior: 0!salir    | ventana |    self stopStepping.    corriendo := false.    ventana := self owner.    ventana ifNotNil: [        ventana delete ].    PanelConfiguracionJuegoDeLaVida new openInWorld.! !!VistaJuegoDeLaVida methodsFor: 'stepping' stamp: '2026-11-23T11:22:44.695397-03:00' prior: 0!step
    corriendo ifFalse: [ ^ self ].
    simulador finalizo ifTrue: [
        corriendo := false.
        self actualizarIndicador.
        ^ self ].
    simulador paso.
    simulador finalizo ifTrue: [ corriendo := false ].
    self actualizarIndicador.
    self changed.
! !!VistaJuegoDeLaVida methodsFor: 'stepping' stamp: '2026-11-23T11:22:44.695427-03:00' prior: 0!stepTime
    ^ intervaloMs
! !VistaJuegoDeLaVida initialize!PanelConfiguracionJuegoDeLaVida initialize!Celda initialize!SimuladorJuegoDeLaVida initialize!Grilla initialize!