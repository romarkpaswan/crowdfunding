// SPDX-License-Identifier:GPL-3.0

pragma solidity 0.8.7;

contract Crowdfunding {
    mapping(address => uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public target;
    uint public deadline;
    uint public raisedAmount;
    uint public noOfcontributors;

    // describing reason for funding

    struct Request {
        string description ;
        address payable recipient;
        uint value;
        bool complete;
        uint noOfvoters;

        mapping(address => bool) voters; // voters voting check

    } 
     mapping(uint => Request) public requests; // no of request for
     uint public numRequests;

    // setting target and deadline by manager

    constructor(uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        manager = msg.sender;
    }
    // contribution by contributors

    function sendETH() public payable {
        require(block.timestamp < deadline,"Deadline is passed.");
        require(msg.value >= minimumContribution,"Criteria is not been satisfied.");

        if (contributors[msg.sender] == 0) {
            noOfcontributors++ ; 
        }
        contributors[msg.sender] += msg.value;
        raisedAmount+= msg.value;
    }
    function getContractbalance() public view returns(uint) {
        return address(this).balance;
    }

    // money refund

    function refund() public {
        require(block.timestamp > deadline && raisedAmount < target,"you are not eligible.");
        require(contributors[msg.sender] > 0); //contri check
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]); // setting owner to payable
        contributors[msg.sender] = 0; // after refund ,money = 0
    }
      
    // creating request to be accesed by manager
    modifier onlymanager {
        require(msg.sender == manager,"Manager cn call this");
        _;
             // the request description
    }
    function createRequestS(string memory _description, address payable _recipient,uint _value) public onlymanager {
       Request storage newRequest = requests[numRequests]; 
       numRequests++;
       newRequest.description = _description;
       newRequest.recipient =_recipient;
       newRequest.value = _value;
       newRequest.complete = false;
       newRequest.noOfvoters = 0;
    }
    // voting from contributors
    
    function voteRequest(uint _requestNo) public  {
        require(contributors[msg.sender]>0,"You must be contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]== false,"you have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfvoters++;
    }
    function makePayment(uint _requestNo) public onlymanager {
        require(raisedAmount >= target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.complete == false,"the request has been completed");
        require(thisRequest.noOfvoters > noOfcontributors/2,"majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.complete = true;
    }

}