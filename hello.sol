pragma solidity ^0.4.11; 

contract Hello { 
function sum(uint _a, uint _b) 
	public returns (uint o_sum, string o_author) 
	{ 
		o_sum = _a + _b; 
		o_author = "freewolf"; 
	} 
}