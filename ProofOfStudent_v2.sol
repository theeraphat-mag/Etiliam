// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract ProofOfStudent {  

  mapping (bytes32 => bool) private listStudent;

  //---events---
  event NameAdded(
    address from,   
    string text,
    bytes32 hash
  );
  
  event RegistrationError(
    address from,
    string text,
    string reason
  );

  // store the proof for a student in the contract state
  function recordProof(bytes32 proof) private {
    listStudent[proof] = true;
  }
  
  // record a student name
  function registration(string memory name) public payable {
    address payable owner;
    owner = payable(msg.sender);

    //---check if string was previously stored---
    if (listStudent[hashing(name)]) {
        //---fire the event---
        emit RegistrationError(msg.sender, name, 
            "This Student was added previously");

        //---refund back to the sender---
        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send Ether");
        //---exit the function---
        return;
    }
    
    //---check if msg.value != 0.002 ether---
    if (msg.value != 0.002 ether) {
        //---fire the event---
        emit RegistrationError(msg.sender, name, 
            "Incorrect amount of Ether. 0.002 ether for registration");
        
        //---refund back to the sender---
        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send Ether");
        //---exit the function---
        return;
    }
 
    recordProof(hashing(name));

    //---fire the event---
    emit NameAdded(msg.sender, name, 
        hashing(name));
  }
  
  // SHA256 for Integrity
  function hashing(string memory name) private 
  pure returns (bytes32) {
    return sha256(bytes(name));
  }
  
  // check name of student in this class
  function checkName(string memory name) public 
  view returns (bool) {
    return listStudent[hashing(name)];
  }
}