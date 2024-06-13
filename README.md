# Sistema de Lotería Smart Contract 🎲

## Tabla de Contenidos

- [Introducción a la Seguridad en Web3 🛡️](#introducción-a-la-seguridad-en-web3-️)
- [Requisitos 🛠️](#requisitos-️)
  - [IDE](#ide)
  - [Foundry](#foundry)
  - [Primeros Pasos](#primeros-pasos)
- [Descripción del Smart Contract 📜](#descripción-del-smart-contract-)
  - [Estructura del Smart Contract 🏗️](#estructura-del-smart-contract-️)
  - [Explicación Detallada de las Funciones 🔍](#explicación-detallada-de-las-funciones-)
  - [Diagrama del Smart Contract 📎](#diagrama-del-smart-contract-)
- [Pruebas y Seguridad 🧪](#pruebas-y-seguridad-)
  - [Casos de Prueba 📑](#casos-de-prueba-)
- [Vulnerabilidad Intencional 🚨](#vulnerabilidad-intencional-)
- [Posible Solución ✍️](#posible-solución-️)
  - [Proof Of Concept 🥷](#proof-of-concept-)
- [Conclusión 💭](#conclusión-)
- [Agradecimientos 🧾](#agradecimientos-)

## Introducción a la Seguridad en Web3 🛡️

¡Bienvenido al mundo de Web3! Los contratos inteligentes son la columna vertebral de las aplicaciones descentralizadas, pero _"un gran poder conlleva una gran responsabilidad"_ 🦸. La seguridad en Web3 es fundamental, ya que las vulnerabilidades pueden llevar a pérdidas financieras significativas. Este repositorio muestra un simple contrato inteligente de sistema de lotería, destacando tanto su funcionalidad como una vulnerabilidad intencional. El objetivo es demostrar la importancia de las prácticas de codificación segura y proporcionar una experiencia práctica en la identificación y mitigación de riesgos de seguridad.

## Requisitos 🛠️

### IDE

Vamos a necesitar un entorno de desarrollo integrado, podemos utilizar cualquier IDE que nos guste, por ejemplo:

- [Visual Studio Code](https://code.visualstudio.com/)

### Foundry

Lo siguiente que necesitamos es instalar un framework de desarrollo para Solidity.

> [!NOTE]
> Puedes utilizar [Remix](https://remix.ethereum.org/), un IDE online para Solidity, pero los tests los tendrías que ejecutar de forma manual. En esta ocasión utilizaremos [Foundry](https://book.getfoundry.sh/) para automatizar los tests.

Foundry está compuesto por cuatro componentes:

> - [**Forge**](https://github.com/foundry-rs/foundry/blob/master/crates/forge): Ethereum Testing Framework
> - [**Cast**](https://github.com/foundry-rs/foundry/blob/master/crates/cast): Una herramienta de línea de comandos para realizar llamadas RPC a Ethereum. Permitiendo interactuar con contratos inteligentes, enviar transacciones o recuperar cualquier tipo de datos de la Blockchain mediante la consola.
> - [**Anvil**](https://github.com/foundry-rs/foundry/blob/master/crates/anvil): Un nodo local de Ethereum, similar a Ganache, el cual es desplegado por defecto durante la ejecución de los tests.
> - [**Chisel**](https://github.com/foundry-rs/foundry/blob/master/crates/chisel): Un REPL de solidity, muy rápido y útil durante el desarrollo de contratos o testing.

**¿Por qué Foundry?**

> - Es el framework más rápido
> - Permite escribir test y scripts en Solidity, minimizando los cambios de contexto
> - Cuenta con muchísimos cheatcodes para testing y debugging

La forma recomendada de instalarlo es mediante la herramienta **foundryup**. A continuación vamos a realizar la instalación paso a paso, pero si quieres realizar una instalación libre de dependencias, puedes seguir las instrucciones de instalación de [este repositorio](https://github.com/hardenerdev/smart-contract-auditor).

#### Instalación

> [!NOTE]
> Si usas Windows, necesitarás instalar y usar [Git BASH](https://gitforwindows.org/) o [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) como terminal, ya que Foundryup no soporta Powershell o Cmd.

En la terminal ejecuta:

```Powershell
curl -L https://foundry.paradigm.xyz | bash
```

Como resultado obtendrás algo parecido a esto:

```shell
consoleDetected your preferred shell is bashrc and added Foundry to Path run:source /home/user/.bashrcStart a new terminal session to use Foundry
```

Ahora simplemente escribe `foundryup` en la terminal y pulsa `Enter`. Esto instalará los cuatro componentes de Foundry: _forge_, _cast_, _anvil_ y _chisel_.

Para confimar la correcta instalación escribe `forge --version`. Deberías de obtener la versión instalada de forge:

```shell
Forge version x.x.x
```

Si no has obtenido la versión, es posible que necesites añadir Foundry a tu PATH. Para ello, puedes ejecutar lo siguiente:

```shell
cd ~echo 'source /home/user/.bashrc' >> ~/.bash_profile
```

Si aún así sigues teniendo problemas con la instalación, puedes seguir las instrucciones de instalación de Foundry en su [repositorio](https://book.getfoundry.sh/getting-started/installation).

Aún así, si no puedes instalar Foundry, no te preocupes, puedes seguir el taller utilizando [Remix](https://remix.ethereum.org/), un IDE online para Solidity.

### Primeros Pasos

Lo primero que vamos a hacer es clonar el repositorio del taller. Para ello, abre una terminal y ejecuta:

```shell
# Clonamos el repo:
https://github.com/MartinM10/VulnerableLottery.git

# Abrimos la carpeta creada
cd VulnerableLottery
```

A continuación instalaremos las dependencias y compilaremos el proyecto para comprobar que todo está correcto.

```shell
# Instalamos las dependencias
forge install foundry-rs/forge-std --no-commit

# Compilamos el proyecto
forge build
```

Con esto ya tendríamos todo lo necesario para ejecutar los tests y probar nuestro smart contract 👍.

## Descripción del Smart Contract 📜

El contrato inteligente [`Lottery.sol`](src/Lottery.sol) permite que múltiples loterías se ejecuten simultáneamente. Cada lotería tiene las siguientes características:

- Los participantes pueden comprar boletos por un precio especificado.
- Solo se permite un boleto por participante por lotería.
- Al final de la lotería, se elige un ganador al azar y se le otorga el bote acumulado. Con lo cual, siempre hay un ganador en cada lotería.

### Estructura del Smart Contract 🏗️

A continuación se muestra una visión general del contrato [`Lottery.sol`](src/Lottery.sol):

1. **Variables y Estructuras**:

   - `owner`: Dirección del propietario del contrato.
   - `lotteryCount`: Contador del número de loterías.
   - `LOTTERY_DURATION`: Duración de cada lotería.
   - `Lottery` struct: Contiene los detalles de cada lotería (ID, jugadores, precio del boleto, tiempo de finalización, bote acumulado, estado activo, y `hasTicket`).
   - `lotteries` mapping: Diccionario que contiene todas las loterías. Devuelve la `Lottery` (struct) que se le indica en la clave (uint256).

2. **Funciones**:
   - `startLottery(uint256 _ticketPrice)`: Inicia una nueva lotería.
   - `buyTicket(uint256 _lotteryId)`: Permite a un participante comprar un boleto para una lotería específica.
   - `endLottery(uint256 _lotteryId)`: Finaliza una lotería y selecciona un ganador.
   - `_random(uint256 _numPlayers)`: Genera un número aleatorio basado en la marca de tiempo del bloque y la dificultad.
   - `_sendPrize(address payable _winner, uint256 _prize)`: Envía el premio al ganador (contiene una vulnerabilidad).
   - `cancelLottery(uint256 _lotteryId)`: Cancela una lotería si no hay jugadores.
   - `getContractBalance()`: Devuelve el balance total del contrato.
   - `getLotteryInfo(uint256 _lotteryId)`: Devuelve información sobre una lotería específica.
   - `getLotteryPlayers(uint256 _lotteryId)`: Devuelve la lista de jugadores en una lotería específica.

### Explicación Detallada de las Funciones 🔍

A continuación se detallan algunas de las funciones más destacables del contrato

#### startLottery

```solidity
function startLottery(uint256 _ticketPrice) external onlyOwner {
    lotteryCount++;
    Lottery storage newLottery = lotteries[lotteryCount];
    newLottery.lotteryId = lotteryCount;
    newLottery.ticketPrice = _ticketPrice;
    newLottery.lotteryEndTime = block.timestamp + LOTTERY_DURATION;
    newLottery.prizePool = 0;
    newLottery.isActive = true;

    emit LotteryStarted(lotteryCount, newLottery.lotteryEndTime);
}
```

- Propósito: Inicializa y comienza una nueva lotería con un precio de boleto especificado. ✅
- Modificadores: onlyOwner asegura que solo el propietario del contrato puede iniciar una lotería. ✅

#### buyTicket

```solidity
function buyTicket(uint256 _lotteryId) external payable lotteryActive(_lotteryId) onlyOneTicketPerAccount(_lotteryId) {
    require(msg.value == lotteries[_lotteryId].ticketPrice, "Incorrect ticket price");
    Lottery storage lottery = lotteries[_lotteryId];
    lottery.players.push(payable(msg.sender));
    lottery.prizePool += msg.value;
    lottery.hasTicket[msg.sender] = true;

    emit TicketPurchased(_lotteryId, msg.sender, msg.value);
}
```

- Propósito: Permite a los usuarios comprar un boleto para una lotería específica. ✅
- Modificadores:
  - lotteryActive: Asegura que la lotería está activa. ✅
  - onlyOneTicketPerAccount: Asegura que cada usuario solo puede comprar un boleto por lotería. ✅

#### endLottery

```solidity
function endLottery(uint256 _lotteryId) external onlyOwner lotteryActive(_lotteryId) {
    Lottery storage lottery = lotteries[_lotteryId];
    require(block.timestamp >= lottery.lotteryEndTime, "Lottery duration has not elapsed");
    require(lottery.players.length > 0, "No players in the lottery");

    lottery.isActive = false;
    lottery.prizePool = 0; // Reset the prize pool

    uint256 winnerIndex = _random(lottery.players.length);
    address payable winner = lottery.players[winnerIndex];

    _sendPrize(winner, lottery.prizePool);

    emit WinnerDeclared(_lotteryId, winner, lottery.prizePool);
}
```

- Propósito: Finaliza una lotería y selecciona un ganador. ✅
- Modificadores:
  - onlyOwner: Asegura que solo el propietario del contrato puede finalizar una lotería. ✅
  - lotteryActive: Asegura que la lotería está activa. ✅

### Diagrama del Smart Contract 📎

A continuación se muestra un diagrama que muestra el funcionamiento más destacable del smart contract de manera visual. Generado con [draw.io](https://app.diagrams.net/)

![Diagrama_01](/resources/LotteryDiagram.png)

## Pruebas y Seguridad 🧪

### Casos de Prueba 📑

> [!NOTE]
> Para la ejecución de los test automatizados debes haber realizado previamente los [Primeros Pasos](#primeros-pasos). Una vez hayamos instalado foundry y compilado el proyecto se pueden ejecutar los tests con el siguiente comando

```shell
forge test --match-contract Lottery
```

Tras ejecutar el comando deberías ver que todos los tests se han pasado correctamente
![TestPassed_01](/resources/TestPassed.png)

> [!WARNING]
> Los tests no son infalibles, y en la mayoría de los casos son escritos por el mismo desarrollador que diseñó el contrato, lo que significa que pueden estar sesgados.

> [!CAUTION]
> Aunque el código pase los tests correctamente y éstos no den ningún tipo de error, ¿Significa que el código es seguro? **NO**

En el contrato [`Lottery.t.sol`](test/Lottery.t.sol) tienes algunos casos de prueba importantes para asegurarte de que el contrato funciona correctamente:

1. **testMultiUserTicketPurchase**: Inicia una lotería, realiza 1 compra de tickets desde 3 cuentas diferentes (1 ticket por cuenta), y comprueba que el balance del contrato es correcto.
2. **testMultiUserLotteryEnd**: Simula una lotería desde el inicio hasta el final, realizando la compra de 1 ticket desde 3 cuentas diferentes.
3. **testMultiUserOneTicketPerAccount**: Verifica que una lotería solo permita 1 ticket por cuenta.

```solidity
function testMultiUserTicketPurchase() public {
    lottery.startLottery(1 ether);

    // User1 buys a ticket
    vm.startPrank(user1);
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();

    // User2 buys a ticket
    vm.startPrank(user2);
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();

    // User3 buys a ticket
    vm.startPrank(user3);
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();

    (, , uint256 prizePool, ) = lottery.getLotteryInfo(1);
    assertEq(
        prizePool,
        3 ether,
        "Prize pool should be 3 ether after three tickets purchased"
    );
    console.log(
        "Multi-user ticket purchase simulated successfully, prize pool:",
        prizePool
    );

    // Check contract balance
    uint256 contractBalance = lottery.getContractBalance();
    assertEq(
        contractBalance,
        3 ether,
        "Contract balance should be 3 ether after ticket purchases"
    );
    console.log("Contract balance is correct:", contractBalance);
  }

  function testMultiUserLotteryEnd() public {
    lottery.startLottery(1 ether);

    // Users buy tickets
    vm.startPrank(user1);
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();

    vm.startPrank(user2);
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();

    vm.startPrank(user3);
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();

    // Skip forward in time to simulate end of lottery
    vm.warp(block.timestamp + 15 minutes);

    // End the lottery
    lottery.endLottery(1);

    (, , uint256 prizePool, bool isActive) = lottery.getLotteryInfo(1);

    assertFalse(isActive, "Lottery should be inactive after ending");
    assertEq(prizePool, 0, "Prize pool should be reset to 0 after ending");
    console.log("Multi-user lottery end simulated successfully");
  }

  function testMultiUserOneTicketPerAccount() public {
    lottery.startLottery(1 ether);

    // User1 buys a ticket
    vm.startPrank(user1);
    lottery.buyTicket{value: 1 ether}(1);

    vm.expectRevert("Only one ticket per account allowed");
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();
    console.log(
        "Verified only one ticket per account restriction for user1"
    );

    // User2 buys a ticket
    vm.startPrank(user2);
    lottery.buyTicket{value: 1 ether}(1);

    vm.expectRevert("Only one ticket per account allowed");
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();
    console.log(
        "Verified only one ticket per account restriction for user2"
    );

    // User3 buys a ticket
    vm.startPrank(user3);
    lottery.buyTicket{value: 1 ether}(1);

    vm.expectRevert("Only one ticket per account allowed");
    lottery.buyTicket{value: 1 ether}(1);
    vm.stopPrank();
    console.log(
        "Verified only one ticket per account restriction for user3"
    );
}
```

## Vulnerabilidad Intencional 🚨

> [!WARNING]
> SPOILER: La vulnerabilidad se encuentra en la función `_sendPrize`, Antes de seguir leyendo te invito a que la encuentres y razones. ¿Qué consecuencias puede tener esta posible vulnerabilidad?

> [!NOTE]
> La función `_sendPrize` tiene una vulnerabilidad de visibilidad. Aunque los tests pasan correctamente, esta función se declara como `public`, lo que permite a cualquiera llamar a esta función y transferir los fondos del contrato, saltándose el mecanismo de cerrar/finalizar una lotería, lo cual, está claro que no es seguro. Se incluyó esta vulnerabilidad para demostrar la importancia de revisar y asegurar cada aspecto del código y para destacar que a diferencia de web2 un error de este tipo, en web3 puede provocar la pérdida de fondos inmediata.

```solidity
function _sendPrize(address payable _winner, uint256 _prize) public {
    _winner.transfer(_prize);
}
```

### Proof of Concept 🥷

Para este repositorio se ha desarrollado un Smart Contract como prueba de concepto para explotar la vulnerabilidad mencionada anteriormente. La idea es simular a través de un test similar a los vistos en [los casos de prueba](#casos-de-prueba-), que un atacante se aprovecha de este posible fallo de seguridad y consigue drenar los fondos de contrato.

El contrato [ProofOfConcept.t.sol](/test/ProofOfConcept.t.sol) tiene todo lo necesario para llevar ejecutar el exploit.

> Para ejecutar el exploit debes usar el siguiente comando

```shell
forge test --match-contract ProofOfConcept -vvv
```

> El argumento `--match-contract` nos permite indicar que solo queremos ejecutar el contrato `ProofOfConcept` y el argumento `-vvv` nos activa el modo `verbose` en la ejecución de `forge test`, de esta manera nos dará las trazas con más información para saber por dónde va la ejecución y qué está ocurriendo con más detalle.

Tras la ejecución del comando deberías ver algo como esto:

![ExploitImage](/resources/ExploitLottery.png)

> Donde se puede observar que:
>
> - Inicialmente:
>   - Se hacen 5 compras de tickets por 1 ether desde 5 cuentas diferentes. Por lo tanto el contrato tiene en su balance 5 ethers.
>   - El atacante tiene 1 ether.
> - Tras ejecutar el exploit:
>   - El atacante tiene un balance de 6 ether y el contrato se ha quedado con un balance de 0, es decir, el atacante ha logrado robar todos los fondos del contrato. 👤💰

## Posible solución ✍️

Si analizamos el código detenidamente podemos observar que esta función se llama desde otra función endLottery. Además hay una pequeña pista que se ha introducido en el código que es el nombre de la función `_sendPrize`, nombre que comienza por `_`. Esto nos debería indicar que se trata de una función `internal`. Esta sería una posible solución a esa posible explotación, indicar que la función debe ser `internal`. Esto implicaría que esta función solo puede ser llamada desde dentro del contrato por otra función, e impidiendo que sea llamada y se ejecute desde fuera del contrato.  
En este repositorio se proporciona el código del smart contract con la posible solución mencionada [LotterySolution.sol](src/LotterySolution.sol)

> [!TIP]
> Además, sería recomendable crear un mecanismo de control de acceso para esta función si es necesario, como permitir que solo el propietario del contrato la llame.

## Conclusión 💭

El objetivo principal de este repositorio ha sido mostrar una posible vulnerabilidad en Smart Contracts, concreamente generar un ejemplo para la vulnerabilidad [SWC-100](https://swcregistry.io/docs/SWC-100/) con fines educativos. Es importante este tipo de actividades para atraer desarolladores del mundo web2 y remarcarles que deben tener precaución a la hora de desarrollar smart contracts, ya que un simple despiste puede provocar una gran pérdida de fondos o totalidad de los mismos.

En resumen:

- Hemos estudiado el contrato inteligente.
- Lo hemos analizado en busca de vulnerabilidades, y hemos encontrado una.
- Hemos realizado un ataque para comprobar que la vulnerabilidad es real.

Este es el proceso que sigue un auditor de contratos inteligentes. Interpreta y analiza el contrato en busca de vulnerabilidades, y si encuentra alguna, realiza una prueba de concepto para comprobar que es real.

Espero que hayas disfrutado del taller, y que hayas aprendido algo nuevo. Si tienes cualquier duda o sugerencia, no dudes en abrir un issue en el repositorio. Si quieres ver otras vulnerabilidades, te dejo otros repositorios desarrollados con el mismo fin y siguiendo la misma metodología.

Repositorio de [@MartinM10](https://github.com/MartinM10) 🧑‍💻

- [VulnerableRenewableEnergy](https://github.com/MartinM10/VulnerableRenewableEnergy)

Repositorios de [@ManuelBD145](https://github.com/ManuelBD145) 🧑‍💻

- [VulnerableDailyLimitWallet](https://github.com/ManuelBD145/Fondos)
- [VulnerableBank](https://github.com/ManuelBD145/Bank)

> [!WARNING]
> Existe otra vulnerabilidad en el contrato que no te he mencionado, a ver si eres capaz de localizarla 🕵️. Te dejo dos enlaces como pistas
> [pista1](https://swcregistry.io/docs/SWC-120/) 👁️
> [pista2](https://chain.link/vrf) 👁️

## Agradecimientos 🧾

Quiero agradecer a por los conocimientos que me proporcionaron y por la plantilla de guía que me brindaron en el repositorio [HackerWeekX-Web3-workshop](https://github.com/Marcolopeez/HackerWeekX-Web3-workshop.git)

- 🦸 [@Marcolopeez](https://github.com/Marcolopeez)
- 🦸 [@jcsec-security](https://github.com/jcsec-security)
