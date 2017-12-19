pragma solidity ^0.4.11;

contract Message {
    // The keyword "public" makes those variables
    // readable from outside.
    address public minter;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, string message);

    // This is the constructor whose code is
    // run only when the contract is created.
    function Message() {
        minter = msg.sender;
    }

    function send(address receiver, string message) {
        Sent(msg.sender, receiver, message);
    }
}


//字串的處理在這邊有些問題：

//你只能先預設出長度，再取代其值（因為找不到字串串接的方式）

//string a = "hello";         長度為5
//bytes(a).length = 15;       改成長度10
        //for(uint i = 0; i < bytes(a).length; i++){       把所以的值都改成b
            //bytes(a)[i] = "b";
        //}


//總結：要做字串處理全部都要先轉成bytes才行


//如果要串接就要寫函式：

//function substring(string x, string y) public returns (string){
    //string z;
    //bytes(z).length = bytes(x).length + bytes(y).length
    
    //for(uint i = 0; i < bytes(x).length; i++){
        //bytes(z)[i] = bytes(x)[i];
    //}

    //for(uint i = bytes(x).length; i < bytes(y).length + bytes(x).length ;i++){
        //bytes(z)[i] = bytes(y)[i - bytes(x).length];
    //}

    //return z;

//}