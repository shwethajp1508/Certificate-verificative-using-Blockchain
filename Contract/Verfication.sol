// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Verification {
    constructor() { owner = msg.sender; }
    uint16 public count_institutes =0;
    uint16 public count_hashes=0;
    address public owner;

    struct  Record  {
        uint blockNumber; 
        uint minetime; 
        string info;
        string ipfs_hash;
         }
    struct institute_Record{
        uint blockNumber;
        string info;
         }
     mapping (bytes32  => Record) private docHashes;
     mapping (address => institute_Record) private institutes;
     
//---------------------------------------------------------------------------------------------------------//
    modifier onlyOwner() {
            if (msg.sender != owner) {
            revert("Caller is not the owner"); }_; }

    modifier validAddress(address _addr) {
            assert(_addr != address(0)); _; }

   
    modifier authorised_institute(bytes32  _doc){

         if (keccak256(abi.encodePacked((institutes[msg.sender].info )))!= keccak256(abi.encodePacked((docHashes[_doc].info))))
      
        revert("Caller is not  authorised to edit this document"); 
         _; }

    modifier canAddHash(){
        require(institutes[msg.sender].blockNumber!=0,"Caller not authorised to add documents");   _; }

//---------------------------------------------------------------------------------------------------------//

    function add_institute(address _add,string calldata _info) external
    onlyOwner(){ 
        assert(institutes[_add].blockNumber==0);
         
          institutes[_add].blockNumber = block.number;
          institutes[_add].info = _info;
          ++count_institutes;
        
        }

    function delete_institute(address _add) external  
    onlyOwner
    {
        assert(institutes[_add].blockNumber!=0);
        
        institutes[_add].blockNumber=0;
        institutes[_add].info="";
        --count_institutes;
        }
        
    function alter_institute(address _add,string calldata    _newInfo) public
    onlyOwner()
     { 
          assert(institutes[_add].blockNumber!=0);
             institutes[_add].info=_newInfo; }

    function changeOwner(address _newOwner) public 
        onlyOwner  validAddress(_newOwner)   {  owner = _newOwner; }

        event addHash(address indexed _institute,string _ipfsHash);
    function addDocHash (bytes32  hash,string calldata _ipfs) public 
      canAddHash
      {
            assert(docHashes[hash].blockNumber==0 && docHashes[hash].minetime==0);
            Record memory  newRecord = 
            Record(block.number,block.timestamp,institutes[msg.sender].info,_ipfs);
            docHashes[hash] = newRecord; 
            ++count_hashes;
            emit addHash(msg.sender,_ipfs);
      }
      

    function findDocHash (bytes32 _hash) 
    external  view  returns (uint,uint,string memory,string memory) {
       
        return (docHashes[_hash].blockNumber,docHashes[_hash].minetime,
        docHashes[_hash].info,docHashes[_hash].ipfs_hash );
        }

    function deleteHash (bytes32 _hash) public
    authorised_institute(_hash)
    canAddHash
    {
    assert(docHashes[_hash].minetime!=0);
    docHashes[_hash].blockNumber=0;
    docHashes[_hash].minetime=0;
    
    --count_hashes;
    
    }
    
    function  getinstituteInfo(address _add) external view returns(string memory){

        return (institutes[_add].info);
    }
}