//Édition du temps de vote
//Ajout des membres
//Ajout des propositions
//Ouvrir des propositions
//Supprimer des propositions
//Executer une proposition
//Voter une proposition
pragma solidity ^0.4.6;

contract Democracy {

    uint public votingTimeInMinutes ;

    // Propriétaire du contrat
    address public owner;

    // Les membres (tableau adresse / appartenance aux votants)
    mapping (address => bool) public members;

    // Definition de l'objet proposal
    struct Proposal {
        string description;
        mapping (address => bool) voted;
        bool[] votes;
        uint end;
        bool adopted;
        bool equality;
        bool executed;
    }

    // Liste des propositions
    Proposal[] public proposals;

    // Auth propriétaire uniquement
    modifier ownerOnly(){
        if (msg.sender != owner) throw;
        _;
    }

   // Auth membre uniquement
   modifier memberOnly(){
        if (!members[msg.sender]) throw;
        _;
    }

   // Si la proposition correspondant à cet index n'est pas ouverte au vote, la fonction n'est pas exécutée
    modifier isOpen(uint index) {
        if(now > proposals[index].end) throw;
        _;
    }

    // Si la proposition correspondant à cet index est fermée au vote, la fonction est exécutée
    modifier isClosed(uint index) {
        if(now < proposals[index].end) throw;
        _;
    }

    // Si le compte (msg.sender) a déjà vôté pour cette proposition, la fonction n'est pas exécutée
    modifier didNotVoteYet(uint index) {
        if(proposals[index].voted[msg.sender]) throw;
        _;
    }

    // Constructeur
    function Democracy() {
        owner = msg.sender;
        setVotingTime(votingTimeInMinutes);
    }

     // Fonction de modification du temps
    function setVotingTime(uint newVotingTime) ownerOnly() {
        votingTimeInMinutes = newVotingTime;
    }


    // Ajout des membres
    function addMember(address newMember) ownerOnly() {
        members[newMember] = true;
    }

    // Ajouter une proposition
    function addProposal(string description) memberOnly() {
        uint proposalID = proposals.length++;

        Proposal p = proposals[proposalID];

        // Donner la description
        p.description = description;

        // Initialisation de fin de vote à fermée
        p.end = 0;
    }

    function removeProposal(uint index) {
        if(proposals.length -1 != index){
          for (uint i = index; i < proposals.length - 1; i++){
              proposals[i] = proposals[i+1];
          }
        }
        //delete proposals[proposals.length - 1];
        proposals.length--;
    }

    function openProposal(uint index){
      Proposal p = proposals[index];
      // Donner le moment de fin de vote
      p.end = now + votingTimeInMinutes * 1 minutes;
    }

    //Nombre de propositions TEST
    function nbProposals() constant  returns (uint){
      if(proposals.length > 0){
        return proposals.length;
      }
      return 0;
    }

    //Affiche les résultats
    function getProposals2(uint index) public constant returns(string, uint, bool, bool, uint) {
        uint[] memory score;
        score = Score(index);
        return (proposals[index].description, proposals[index].end, proposals[index].executed, proposals[index].adopted, score[0]);
    }

    //Contenu des propositions
    function getProposals(uint index) public constant returns(string, uint, bool, bool, bool) {
        return (proposals[index].description, proposals[index].end, proposals[index].executed, proposals[index].adopted, proposals[index].equality);
    }

    // Voter pour une proposition
    function vote(uint index, bool vote) memberOnly() isOpen(index) didNotVoteYet(index) {
        proposals[index].votes.push(vote);
        proposals[index].voted[msg.sender] = true;
    }

    /*function ableToVote(uint index) public returns(bool) {
      bool voted = proposals[index].voted[msg.sender];
      return voted;
    }*/

    function Score(uint index) public constant returns (uint []){
      uint yes = 0;
      uint no = 0;

      uint[] memory score;
      bool[] votes = proposals[index].votes;

      for (uint i = 0; i < votes.length; i++) {
        if (votes[i]){
          yes++;
        }
        else {
          no++;
        }
     }
     score[0] = yes;
     score[1] = no;

     return score;
  }

    // Obtenir le résultat d'un vote
    function executeProposal(uint index) isClosed(index) {
        uint yes;
        uint no;
        bool[] votes = proposals[index].votes;

        // On compte les pour et les contre
        for(uint counter = 0; counter < votes.length; counter++) {
            if(votes[counter]) {
                yes++;
            } else {
                no++;
            }
        }
        if(yes > no) {
           proposals[index].adopted = true;
        }
        else if( yes == no){
          proposals[index].equality = true;
        }
        //A été éxécuter
        proposals[index].executed = true;
    }

}
