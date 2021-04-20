pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;
contract SimpleStorage {
    
    // ##########
    // More comments soon.
    // ##########
    
    // Word Struct
    struct Word {
        string word;
        string username;
        uint256 price;
        string message;
        address payable owner;
    }
    
    // Address that receives the XDCs at the first purchase. Avoid burning XDC.
    address payable bank = 0xc1489b00Ba538DdA23c8398F1a114b4EDab62Cd1;
    
    // Public array of words stored in blockchain
    Word[] public words;
    
    // Function to return specific word
    function getWord(string memory _word) public view returns (string memory, string memory, uint256 price, string memory, address owner) {
        uint arrayLength = words.length;
        for (uint i=0; i < arrayLength; i++) {
            if(keccak256(abi.encodePacked(words[i].word)) == keccak256(abi.encodePacked(_word))) {
                return (words[i].word, words[i].username, words[i].price, words[i].message, words[i].owner);
            }
        }
    }
    
    // Function return all words
    function getWords() public view returns (Word[] memory) {
       return words;
    }
    
    // Buy specific word
    function buyWord(string memory _word, string memory _username, string memory _message) payable public returns (string memory){
        
        uint256 amount = msg.value;
        Word memory localWord = Word(_word, _username, amount, _message, msg.sender);   
        
        uint arrayLength = words.length;
        bool canBuy = true;
        bool wordAlreadyTaken = false;
        string memory cbMessage = "";
        uint256 wordIndex = 0;
        address payable creditorAddresses;
        uint256 prevAmout = 0;
        
        for (uint i=0; i < arrayLength; i++) {
            if( keccak256(abi.encodePacked(words[i].word)) == keccak256(abi.encodePacked(_word)) ) {
                prevAmout = words[i].price;
                if(prevAmout < amount) {
                    wordAlreadyTaken = true;
                    cbMessage = "Achat réussi !";
                    wordIndex = i;
                    creditorAddresses = words[i].owner;
                } else {
                    canBuy = false;
                    cbMessage = "Prix trop bas pour acheter ce mot.";
                }
            }
        }
        
        if(canBuy == true && wordAlreadyTaken == true) {

            if( amount < (prevAmout + 1000000000000000000)) {
                return "You must bid at least 1 XDC more.";
            } else {
                // Send XDC to the previous Owner
                creditorAddresses.transfer(amount);
                
                // Update Blockchain
                words[wordIndex] = localWord;
                return "Buy Done.";
            }
        }
        if(canBuy == true && wordAlreadyTaken == false) {
            if(amount < 1000000000000000000) {
                return "Price 1 XDC min.";
            } else {
                words.push(localWord);
                bank.transfer(amount);
                return "Buy done.";
            }
        }
    }
    
    
}
