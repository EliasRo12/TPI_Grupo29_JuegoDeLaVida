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
