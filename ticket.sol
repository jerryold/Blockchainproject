pragma solidity ^0.4.11;

contract Ticket{

  struct data{   //票的結構
    uint number;  //編號
    string name;
    uint year;
    uint month;
    uint day;
    uint amount;
  }

  address public minter;
  mapping (address => data[]) public balances;  //餘額以data[]呈現
  mapping(uint => string) str;  
  uint[] day_number = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  uint nowyear = 1970;
  uint nowmonth;
  uint nowday;
  uint register;


  event New(uint number, string name, string date, uint amount, string Tdate);
  event Use(address from, uint number, string name, uint amount, string Tdate);
  event Sent(address from, address to, uint number, string name, uint amount, string Tdate);


  function Ticket(){
    minter = msg.sender;
    now_day();
    init_str();
  }
  
  //初始化數字轉字串要的元素
  function init_str(){
    str[0] = "0";str[1] = "1";str[2] = "2";str[3] = "3";str[4] = "4";
    str[5] = "5";str[6] = "6";str[7] = "7";str[8] = "8";str[9] = "9";
  }
  
  //把年月日化成字串的日期格式
  function dateformat(uint year, uint month, uint day) public returns (string){
      string date;
      bytes(date).length = 10;
      
      
    for(uint i = 0; i <= 3 ; i++){
        bytes(date)[3-i] = bytes(str[year % 10])[0];
        year = (year - (year % 10)) / 10;
    }
        
    bytes(date)[4] = "-";
        
    for(uint j = 6; j >= 5; j--){
        bytes(date)[j] = bytes(str[month % 10])[0];
        month = (month - (month % 10)) / 10;
    }
        
    bytes(date)[7] = "-";
        
    for(uint k = 9; k >= 8; k--){
        bytes(date)[k] = bytes(str[day % 10])[0];
        day = (day - (day % 10)) / 10; 
    }
        
    return date;
  }
  
  //把now轉成日期
  function now_day(){
    uint x = now;
    
    //算是西元多少年
    while(x >= 60*60*24*365){
        if(nowyear%4 == 0){
            if(x >= 60*60*24*366){
                x -= 60*60*24*366;
                nowyear+= 1;
            }else{break;}
        }else{
            x -= 60*60*24*365;
            nowyear+= 1;
        }
    }
    
    //算是幾月幾日
    for(uint i = 1; i<=12; i++){
        if(i == 2 && nowyear%4 == 0){day_number[2] = 29;}
        
        if(x > 60*60*24*day_number[i]){
            x-= 60*60*24*day_number[i];
        }else{
            nowmonth = i;
            nowday = 1 + x/(60*60*24);
            break;
        }
    }
  }

   //是否在有效期內（即now<日期）
  function intime(uint year, uint month, uint day) public returns (bool){
      
    //判斷不合理的日期
    if(year <1 || month <1 || month >12 || day <1 || (day > day_number[month] && month != 2) || (year%4 == 0 && month == 2 && day >29) || (year%4 != 0 && month == 2 && day >28)) return false;
    
    //判斷輸入的是否比now還大（不然就是過期票）
    if(year > nowyear){return true;}
    else{ 
        if(year == nowyear){
            if(month > nowmonth){return true;}
            else{
                if(month == nowmonth){
                    if(day >= nowday){return true;}else{return false;}
                }else{return false;}
            }
          }else{return false;}
    }
    
  }
  
  //資料是否存在
  function isexist(address from, uint number) public returns (uint){
      register = 1000;
      for(uint i = 0; i < balances[from].length; i++){
          if(number == balances[from][i].number){register = i; break;}
      }
      
      return register;
  }

  //是否有過期的，可以直接取代（因為它的陣列不會改變長度）
  function isempty(address from) public returns (uint){
      register = 1000;
      for(uint i = 0; i < balances[from].length; i++){
        if(intime(balances[from][i].year , balances[from][i].month , balances[from][i].day) == false){register = i; break;}
      }
      
      return register;
        
  }


  //新增票券（只有最高權限人可以新增，且不能新增已有的票）
  function newticket(uint number, string name, uint year, uint month, uint day, uint amount) {
    //只有minter可以新增
    if(minter == msg.sender) {          
      //不存在且時限在now以後的
      if(isexist(minter, number) == 1000 && intime(year, month, day) && amount > 0){     
          uint empty = isempty(minter);
          if(empty == 1000){  
              balances[minter].push(data(number, name, year, month, day, amount));
          }else{
              balances[minter][empty].number = number;
              balances[minter][empty].name = name;
              balances[minter][empty].year = year;
              balances[minter][empty].month = month;
              balances[minter][empty].day = day;
              balances[minter][empty].amount = amount;
          }

          New(number, name, dateformat(year, month, day), amount, dateformat(nowyear, nowmonth, nowday));
      }
    }
  }
  
  
  //使用者使用票券
  function useticket(uint number, uint amount){
      uint exist = isexist(msg.sender, number);
      if(exist != 1000){
          if(intime(balances[msg.sender][exist].year, balances[msg.sender][exist].month, balances[msg.sender][exist].day) && balances[msg.sender][exist].amount >= amount){
              balances[msg.sender][exist].amount -= amount;
              Use(msg.sender, number, balances[msg.sender][exist].name, amount, dateformat(nowyear, nowmonth, nowday));
          }
      }
  }


  //送給別人票券
  function send(address receiver, uint number, uint amount){
      if(receiver != msg.sender){
        uint exist = isexist(msg.sender, number);
        if(exist != 1000){
            if(intime(balances[msg.sender][exist].year, balances[msg.sender][exist].month,balances[msg.sender][exist].day) && balances[msg.sender][exist].amount >= amount){
                balances[msg.sender][exist].amount -= amount;
                uint exist2 = isexist(receiver, number);
                if(exist2 == 1000){
                    uint empty = isempty(receiver);
                    if(empty == 1000){
                        balances[receiver].push(data(number, balances[msg.sender][exist].name, balances[msg.sender][exist].year, balances[msg.sender][exist].month, balances[msg.sender][exist].day, amount));
                    }else{
                        balances[receiver][empty].number = number;
                        balances[receiver][empty].name = balances[msg.sender][exist].name;
                        balances[receiver][empty].year = balances[msg.sender][exist].year;
                        balances[receiver][empty].month = balances[msg.sender][exist].month;
                        balances[receiver][empty].day = balances[msg.sender][exist].day;
                        balances[receiver][empty].amount = amount;
                    }
                  
                }else{
                    balances[receiver][exist2].amount += amount;
                }
            }
          
            Sent(msg.sender, receiver, number, balances[msg.sender][exist].name, amount, dateformat(nowyear, nowmonth, nowday));
        }
      }
  }
  

  //查餘額
  function balance(address from, uint number) public returns (uint num, string name, string date, uint amount){
      uint exist = isexist(from, number);
      if(exist == 1000){
          num = 0;
          name = "null";
          date = "0000-00-00";
          amount = 0;
      }else{
          num = number;
          name = balances[from][exist].name;
          date = dateformat(balances[from][exist].year, balances[from][exist].month, balances[from][exist].day);
          amount = balances[from][exist].amount;
      }
  }

}