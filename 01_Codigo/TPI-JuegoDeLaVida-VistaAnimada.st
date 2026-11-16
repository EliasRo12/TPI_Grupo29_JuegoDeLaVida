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
