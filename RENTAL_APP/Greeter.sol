// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Storage {

    struct Bike {
        uint256 pph;
        uint256 id;
        address payable ownerAddress;
        address tenantAddress;
        string  pic_url;
        bool available;
    }

    struct User{
       
        address  userAddress;
        bool rented_status;
        uint256 rented_veh_id;

        uint rent_start;
    }




    mapping(address => User) userData;
    mapping(uint256 => Bike) bikeData;
    mapping(address => bool) isRegistered;
  
    function addUser() public {
        require( isRegistered[msg.sender] == false);
        isRegistered[msg.sender] = true;
        userData[msg.sender].userAddress =msg.sender ;
        userData[msg.sender].rented_status =false ;
        userData[msg.sender].rent_start = 0;



    }

    

    function returnUserRentedHr() public view returns (uint hr) {
         uint diff =(block.timestamp/60/60 - userData[msg.sender].rent_start ) ;
         return diff; 
    }

    function returnUserReGStatus() public view returns(bool status){
        return isRegistered[msg.sender];
    }
    function returnDue() public view returns(uint due){
         uint diff =(block.timestamp/60/60 - userData[msg.sender].rent_start ) ;
        
        uint amount = bikeData[userData[msg.sender].rented_veh_id].pph * (diff);
        return amount; 
    }
            function addBike(uint pph,uint id,string memory pic_url) public {
        bikeData[id].pph = pph;
        bikeData[id].id = id;
        bikeData[id].ownerAddress = payable(msg.sender);
        bikeData[id].tenantAddress = 0x0000000000000000000000000000000000000000;
        bikeData[id].pic_url = pic_url;
        bikeData[id].available = true;
       

        
    }
    
    function returnUserData() public view  returns(User memory data){
        return userData[msg.sender];
    }
    function returnVehiclesData(uint256  id) public  view  returns(Bike memory data){
        return  bikeData[id];
    }


    function onCheckIn(uint256 id)public payable {
        require(bikeData[id].ownerAddress != msg.sender,"You cannot rent ur own vehicle");
         require( bikeData[id].available == true,"Bike is not available.");
         require(userData[msg.sender].rented_status == false,"Checkin not possible");
        bikeData[id].tenantAddress = msg.sender;
        bikeData[id].available = false;
        userData[msg.sender].rented_status = true;
        userData[msg.sender].rented_veh_id = id;
        userData[msg.sender].rent_start = block.timestamp/60/60;
       
    }

   function onPayingDue() payable public{
       require( userData[msg.sender].rented_veh_id!=0,"Rent a vehicle to start paying dues");
        uint diff =(block.timestamp/60/60 - userData[msg.sender].rent_start ) ;
        
        uint amount = bikeData[userData[msg.sender].rented_veh_id].pph * (diff);
         bikeData[userData[msg.sender].rented_veh_id].ownerAddress.transfer(amount);
        userData[msg.sender].rent_start = block.timestamp/60/60;
  }

    function onCheckout() public  returns(bool completion) {
            uint diff =(block.timestamp/60/60 - userData[msg.sender].rent_start ) ;
        uint amount = bikeData[userData[msg.sender].rented_veh_id].pph * (diff);
        require(amount==0,"Pay due before proceeeding.");
        bikeData[userData[msg.sender].rented_veh_id].available = true;
        userData[msg.sender].rented_veh_id=0;
        userData[msg.sender].rented_status = false;
          
          return true;

       

    }

}