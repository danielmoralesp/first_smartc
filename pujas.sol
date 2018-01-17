pragma solidity ^0.4.11;

contract SimpleAuction {
  address public beneficiary;
  uint public auctionStart;
  uint public biddingTime;

  address public highestBidder;
  uint public highestBid;

  mapping(address => uint) pendingReturns;

  bool ended;

  event HighestBidIncresed(address bidder, uint amount);
  event AuctionEnded(address winner, uint amount);

  /// Crea una subasta sencilla con un periodo de pujas
  /// de `_biddingTime` segundos. El beneficiario de
  /// las pujas es la dirección `_beneficiary`.
  function SimpleAuction(uint _biddingTime, address _beneficiary){
    beneficiary = _beneficiary;
    auctionStart = now;
    biddingTime = _biddingTime;
  }

  /// Puja en la subasta con el valor enviado
  /// en la misma transacción.
  /// El valor pujado sólo será devuelto
  /// si la puja no es ganadora.
  function bid() payable {
    require(now <= (auctionStart + biddingTime));

    require(msg.value > highestBid);

    if(highestBidder != 0){
      pendingReturns[highestBidder] += highestBid;
    }
    highestBidder = msg.sender;
    highestBid = msg.value;
    HighestBidIncresed(msg.sender, msg.value);
  }

  /// Retira una puja que fue superada.
  function withdraw() returns(bool) {
    var amount = pendingReturns[msg.sender];
    if(amount > 0){
      pendingReturns[msg.sender] = 0;

      if(!msg.sender.send(amount)){
        pendingReturns[msg.sender] = amount;
        return false;
      }
    }
    return true;
  }

  /// Finaliza la subasta y envía la puja más alta al beneficiario.
  function auctionEnd(){
    // 1. Condiciones
    require(now >= (auctionStart + biddingTime));
    require(!ended);

    // 2. Ejecución
    ended = true
    AuctionEnded(highestBidder, highestBid);

    // 3. Interacción
    beneficiary.transfer(highestBid)
  }
}
