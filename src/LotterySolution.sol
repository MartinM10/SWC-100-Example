// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LotterySystem {
    address public owner;
    uint256 public lotteryCount;
    uint256 public constant LOTTERY_DURATION = 15 minutes; // Duración de la lotería en segundos

    struct Lottery {
        uint256 lotteryId;
        address payable[] players;
        uint256 ticketPrice;
        uint256 lotteryEndTime;
        uint256 prizePool;
        bool isActive;
        mapping(address => bool) hasTicket;
    }

    mapping(uint256 => Lottery) public lotteries;

    event LotteryStarted(uint256 lotteryId, uint256 endTime);
    event TicketPurchased(
        uint256 lotteryId,
        address indexed player,
        uint256 amount
    );
    event WinnerDeclared(uint256 lotteryId, address winner, uint256 prize);
    event LotteryCancelled(uint256 lotteryId);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier lotteryActive(uint256 _lotteryId) {
        require(lotteries[_lotteryId].isActive, "Lottery is not active");
        _;
    }

    modifier onlyOneTicketPerAccount(uint256 _lotteryId) {
        require(
            !lotteries[_lotteryId].hasTicket[msg.sender],
            "Only one ticket per account allowed"
        );
        _;
    }

    /**
     * @dev Inicia una nueva lotería.
     * @param _ticketPrice Precio del ticket.
     */
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

    /**
     * @dev Compra un ticket para una lotería específica.
     * @param _lotteryId El ID de la lotería.
     */
    function buyTicket(
        uint256 _lotteryId
    )
        external
        payable
        lotteryActive(_lotteryId)
        onlyOneTicketPerAccount(_lotteryId)
    {
        require(
            !lotteries[_lotteryId].hasTicket[msg.sender],
            "Only one ticket per account allowed"
        );
        require(
            msg.value == lotteries[_lotteryId].ticketPrice,
            "Incorrect ticket price"
        );
        Lottery storage lottery = lotteries[_lotteryId];
        lottery.players.push(payable(msg.sender));
        lottery.prizePool += msg.value;
        lottery.hasTicket[msg.sender] = true;

        emit TicketPurchased(_lotteryId, msg.sender, msg.value);
    }

    /**
     * @dev Termina una lotería y selecciona un ganador.
     * @param _lotteryId El ID de la lotería.
     */
    function endLottery(
        uint256 _lotteryId
    ) external onlyOwner lotteryActive(_lotteryId) {
        Lottery storage lottery = lotteries[_lotteryId];
        require(
            block.timestamp >= lottery.lotteryEndTime,
            "Lottery is still active"
        );
        require(lottery.players.length > 0, "No players in the lottery");

        lottery.isActive = false;
        lottery.prizePool = 0; // Reset the prize pool

        uint256 winnerIndex = _random(lottery.players.length);
        address payable winner = lottery.players[winnerIndex];

        _sendPrize(winner, lottery.prizePool);

        emit WinnerDeclared(_lotteryId, winner, lottery.prizePool);
    }

    /**
     * @dev Genera un número aleatorio.
     * @param _numPlayers El número de jugadores en la lotería.
     */
    function _random(uint256 _numPlayers) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        _numPlayers
                    )
                )
            ) % _numPlayers;
    }

    /**
     * @dev Envía el premio al ganador.
     * @param _winner Dirección del ganador.
     * @param _prize Monto del premio.
     */
    function _sendPrize(address payable _winner, uint256 _prize) internal {
        _winner.transfer(_prize);
    }

    /**
     * @dev Cancela una lotería si no hay jugadores.
     * @param _lotteryId El ID de la lotería.
     */
    function cancelLottery(
        uint256 _lotteryId
    ) external onlyOwner lotteryActive(_lotteryId) {
        Lottery storage lottery = lotteries[_lotteryId];
        require(
            lottery.players.length == 0,
            "Cannot cancel lottery with players"
        );

        lottery.isActive = false;

        emit LotteryCancelled(_lotteryId);
    }

    /**
     * @dev Obtiene el balance total del contrato.
     * @return El balance total del contrato.
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Obtiene la información de una lotería específica.
     * @param _lotteryId El ID de la lotería.
     * @return ticketPrice, lotteryEndTime, prizePool, isActive
     */
    function getLotteryInfo(
        uint256 _lotteryId
    ) external view returns (uint256, uint256, uint256, bool) {
        Lottery storage lottery = lotteries[_lotteryId];
        return (
            lottery.ticketPrice,
            lottery.lotteryEndTime,
            lottery.prizePool,
            lottery.isActive
        );
    }

    /**
     * @dev Obtiene los jugadores de una lotería específica.
     * @param _lotteryId El ID de la lotería.
     * @return Una lista de direcciones de jugadores.
     */
    function getLotteryPlayers(
        uint256 _lotteryId
    ) external view returns (address payable[] memory) {
        return lotteries[_lotteryId].players;
    }
}
