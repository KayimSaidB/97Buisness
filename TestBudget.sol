pragma solidity ^0.4.11;

/// tokens parts sociales
import "./datetime.sol";
/// we import datatime in order to convert te timestamp provided by solidity
/// to more commoun unity like day and hours
contract budget is DateTime {
    
/// the aim of the  contract is to deal with budget management

uint nb_income; // corresponds to the number of income currently 
 uint nb_outcomes; /// outcome
 uint value_outcomes; // value of all outcomes
 uint value_income; // value of all income
 uint nb_assets; // number of assets
 uint nb_liabilities;/// liabilities
 uint value_assets; 
 uint value_liabilities;
 ///registers connecting the name of each incomes/outcomes/assets/liabilities to their value
 /// we also add index registers in order to list them as it's currently not possible to iterate on mapping with solidity
 mapping (string => uint) register_assets; 
 mapping(uint => string) assets_index;
 mapping (string =>uint )register_liabilities;
 mapping(uint => string) liabilities_index;
 mapping(string => uint) registre_income;
 mapping (uint => string) index_incomes;
  mapping(string => uint) registre_outcomes;
 mapping (uint => string) index_outcomes;
 uint money_available; /// corresponds to the money available by the company 
 function init_money_available() payable { /// how we initiate the variable with ether
     money_available=msg.value;
 }
 function register_a_new_assets(uint valeur, string nom){ 
     register_assets[nom]=valeur; /// update registers
    assets_index[nb_assets]=nom;
    nb_assets++; /// increment the number
     value_assets+=valeur; /// update the value
     
 }
  function register_a_new_liabilities(uint valeur, string nom){
     register_liabilities[nom]=valeur;
     liabilities_index[nb_liabilities]=nom;
     nb_liabilities++;
     value_liabilities+=valeur;
 }

 /// verify if the value of assets is equal to the value of liabilities
 function is_count_right() returns (bool){
     return (value_liabilities==value_assets);
 }

event show(string assive,uint valeur);
function show_assets() {
    uint i=0;
    for (i=0;i<nb_assets;i++){
        show(assets_index[i],register_assets[assets_index[i]]);
    }

    
}
function show_liabilities() {
    uint i=0;
    for (i=0;i<nb_liabilities;i++){
        show(liabilities_index[i],register_liabilities[liabilities_index[i]]);
    }
    
    }
event show_date_and_hour(uint16[6]);

function bilan_financier(){
   /// corresponds to the block timestamp of the transaction
    show_liabilities();
    show_assets();
    show_date_and_hour([getDay(now),getMonth(now),getYear(now),getHour(now),getMinute(now),getSecond(now)]);
}

mapping(address => uint) register_of_social_part; /// register of social part, connect the address of owners of social part to the number of parts    
uint totalnumberpart; 
function register_a_social_part(address newowner,uint numberpart)  { /// add a new address to the register with the number of part
    register_of_social_part[newowner]=numberpart;
    totalnumberpart+=numberpart;
    
}   

function register_a_new_income(uint valeur, string nom){
     registre_income[nom]=valeur;
     index_incomes[nb_income]=nom;
     nb_income++;
     value_income+=valeur;
 }
 function register_a_new_outcome(uint valeur, string nom){
     registre_outcomes[nom]=valeur;
     index_outcomes[nb_income]=nom;
     nb_income++;
     value_outcomes+=valeur;
 }
 /// when we want to divide benefits to investors we start a divide (one per year)
 struct a_divide { 
     bool has_started; /// indicate if the dividing of parts has started
    mapping(address => bool) has_get_parts; /// indicate if an investor has already get its part
    uint benefit_to_share; /// indicate the part of benefit we can share
 } 
mapping (uint16 => a_divide) register_divide; /// the register of divide connect a year to the strut we define previously
uint report_benefices;
 function start_divide_benefit(uint benefit_to_share) returns (bool){
     
     uint benefices=value_income-value_outcomes; /// first we evaluate the benefit of the company 
     if (benefices>benefit_to_share){ /// if the benefit we want to share is lower than the all we can start the divide otherwise no
         register_divide[getYear(now)].has_started=true;
         register_divide[getYear(now)].benefit_to_share=benefit_to_share;
         report_benefices=benefices-benefit_to_share;
         return true;
     }
     else 
     return false;
 }
 function reverse_benefit_to_available(){
     money_available+=report_benefices; /// enable to transfer the benefit non divided to the money available
 }
  
function give_the_part(address investor) {  /// transfer the money related to his parts to an investor
    if (register_divide[getYear(now)].has_started==true && register_divide[getYear(now)].has_get_parts[investor]==false){
    investor.transfer((register_divide[getYear(now)].benefit_to_share*register_of_social_part[investor])/totalnumberpart);     
    register_divide[getYear(now)].has_get_parts[investor]=true;
    show_date_and_hour([getDay(now),getMonth(now),getYear(now),getHour(now),getMinute(now),getSecond(now)]);

    }
    
    
}

function allocate(address some) payable returns (bool) { /// transfer money available to an address
    if  (money_available>msg.value){
    some.transfer(msg.value);
    money_available-=msg.value;
    return true;
    }
    else
    return false;
}

function check_balance() returns (uint){
    show_date_and_hour([getDay(now),getMonth(now),getYear(now),getHour(now),getMinute(now),getSecond(now)]);
    return msg.sender.balance/10e18;
    
}

    
}