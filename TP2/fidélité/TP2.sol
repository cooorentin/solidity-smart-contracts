pragma solidity ^0.4.6;

contract Fidelity {

  //Client
  struct Client {
    string name;
    uint equity;
    string [] rewards;
    bool IsClient;
  }
  struct Reward {
    string reward;
    uint points;
    uint price;
  }

  //Commerçant
  address shop;
  mapping(address => Client)  public clients;
  Reward [] listReward;

  //Restriction
  modifier clientOwnly(){
      if (clients[msg.sender].IsClient) throw;
      _;
  }
  modifier shopOnly(){
    if (msg.sender != shop) throw;
    _;
  }

  //Constructeur
  function Fidelity(){
    shop = msg.sender;
    //SetClient(); //just in testRpc to test it
    //SetRewardList(); //just in testRpc to test it
  }

  function ConsultEquity(address asdresse) clientOwnly() constant returns (uint){
    return clients[asdresse].equity;
  }

  function CheckMyReward (address adresse, uint index) constant returns (string){
    return clients[adresse].rewards[index];
  }

  function CheckAllReward (address adresse, uint index) constant returns (string){
    return listReward[index].reward;
  }

  function ApplyReward (address adresse, uint pointSent) constant returns (bool){
    uint equity = clients[adresse].equity;
    uint rewardId = clients[adresse].rewards.length + 1;
    bool done = false;

    //check Balance
    if(pointSent < equity){
      for(uint i = 0; i < listReward.length; i++){
        if(pointSent == listReward[i].points){
          //add reward
          clients[adresse].rewards[rewardId] = listReward[i].reward;
          //delete point
          clients[adresse].equity -= pointSent;
          //set true
          done = true;
        }
      }
    }

    return done;
  }

  function Buy (uint price, address adresse) shopOnly() constant returns(string){
    string reward_proposition; //A déduire si le client le souhaite via Apply Reward

    for(uint i = 0; i < listReward.length; i++){
      if(listReward[i].price == price){
        clients[adresse].equity += listReward[i].points ; //Attribution des points en fonction du prix de l'achat
        reward_proposition = listReward[i].reward;
      }
    }
    return reward_proposition;
  }

}
