pragma solidity ^0.4.0;

contract localCurrency{

  // Propriétaire du contrat
  address public _owner;
  //Total monnaie en circulation
  uint _totalValue;

  struct Person {
     string name;
     uint amount;
     bool isMember;
  }

  mapping(address => Person) public persons;

  //Constructeur
  function localCurrency(uint totalValue) {
    _totalValue = totalValue;
    _owner = msg.sender;
  }

  //Modifier controle propriétaire
  modifier ownerOnly(){
    if (msg.sender != _owner) throw;
    _;
  }

  //Modifier controle du solde du dépenseur
  modifier canSpendTheAmount(address _owner, uint value)
  {
    if(balanceOf(_owner) < value) throw;
    _;
  }

  //Modifier controle utilisateur seulement
  modifier memberOnly(){
        if (!persons[msg.sender].isMember) throw;
        _;
    }

  //Modifier controle de la non existence de l'adresse en paramètre
  modifier alreadyMember(){
      if (persons[msg.sender].isMember) throw;
        _;
  }

  //Fonction controle de l'existence de l'adresse en paramètre
  function checkAddress(address addr) constant returns(bool){
    bool result = false;
    if(persons[addr].isMember){
      result = true;
    }
    return result;
  }

  //Fonction d'ajout d'un utilisateur par le propriétaire
  function addPerson(address newAddress, string newName, uint newAmount) ownerOnly() alreadyMember(){
    //Création
    Person p = persons[newAddress];
    p.name = newName;
    p.amount = newAmount;
    p.isMember = true;
  }

  //Fonction pour optenir la balance d'un utilisateur
  function balanceOf(address _owner) memberOnly() constant returns(uint) {
    return persons[_owner].amount;
  }

  //Fonction création/transfert de monnaie à une adresse/utilisateur
  function transfer(address _to, uint _value) ownerOnly() constant returns(bool) {
    bool result = false;
    if(checkAddress(_to)){
      persons[_to].amount += _value;
      result = true;
    }
    return result;
  }

  //Fonction transfert de monnaie d'un utilisateur à un autre
  function transferFrom(address from, address to, uint value) canSpendTheAmount(from, value) returns (bool) {
    bool result = false;
    if(checkAddress(from) && checkAddress(to))
    {
      persons[from].amount -= value;
      persons[to].amount += value;
      result = true;
    }
    return result;
  }
}
