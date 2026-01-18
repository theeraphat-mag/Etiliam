// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract RovMarket {

    struct Purchase {
        address owner;
        string characterName; // ชื่อไฟล์รูป เช่น "Yorn.jpeg"
        uint256 timestamp;
        uint256 price;
    }

    // เก็บประวัติการซื้อขายทั้งหมด
    Purchase[] public purchaseHistory;
    
    // Mapping เช็คเจ้าของ (ถ้าเป็น address(0) คือยังว่าง)
    mapping(string => address) public characterToOwner;
    
    // Mapping ราคาพิเศษ (ถ้าเป็น 0 จะใช้ราคา Default)
    mapping(string => uint256) public specialPrices;

    // Events เพื่อให้ Frontend ดักจับได้แบบ Real-time
    event BuyCharacter(address indexed from, string characterName, uint256 price, uint256 timestamp);
    event PriceUpdated(string characterName, uint256 newPrice);

    address public owner;
    uint256 public constant DEFAULT_PRICE = 0.001 ether;

    // Modifier เพื่อล็อคให้แค่เจ้าของ Contract เรียกใช้ฟังก์ชันสำคัญได้
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        
        // --- ตั้งราคาเริ่มต้น (หน่วย Ether) ---
        // Rare / Legendary (0.01 ETH)
        setPrice("Hayate.jpeg", 0.01 ether);
        setPrice("Yorn.jpeg", 0.01 ether);
        setPrice("Wukong.jpeg", 0.01 ether);

        // Uncommon (0.005 ETH)
        setPrice("Murad.jpeg", 0.005 ether);
        setPrice("Nakroth.jpeg", 0.005 ether);
        setPrice("Florentino.jpeg", 0.005 ether);
    }

    // 1. ฟังก์ชันเช็คราคา (Frontend เรียกใช้ก่อนซื้อ)
    function getPrice(string memory name) public view returns (uint256) {
        if (specialPrices[name] > 0) {
            return specialPrices[name];
        }
        return DEFAULT_PRICE;
    }

    // 2. ฟังก์ชันเช็คสถานะว่าขายไปหรือยัง (Frontend เรียกใช้เพื่อปิดปุ่ม)
    function isCharacterSold(string memory name) public view returns (bool) {
        return characterToOwner[name] != address(0);
    }

    // 3. ฟังก์ชันซื้อสินค้า
    function buyCharacter(string memory name) public payable {
        // Double Lock ชั้นที่ 1: เช็คว่ามีเจ้าของหรือยัง
        require(characterToOwner[name] == address(0), "Error: This character is already sold!");

        // เช็คราคาล่าสุด
        uint256 price = getPrice(name);
        
        // Double Lock ชั้นที่ 2: เงินต้องตรงเป๊ะ
        require(msg.value == price, "Error: Incorrect Ether value sent.");

        // บันทึกความเป็นเจ้าของ
        characterToOwner[name] = msg.sender;
        purchaseHistory.push(Purchase(msg.sender, name, block.timestamp, price));

        emit BuyCharacter(msg.sender, name, price, block.timestamp);
    }

    // --- ส่วนของ Admin ---

    // ตั้งราคาใหม่ (เผื่อจัดโปรโมชั่น)
    function setPrice(string memory name, uint256 price) public onlyOwner {
        specialPrices[name] = price;
        emit PriceUpdated(name, price);
    }

    // ถอนเงินเข้ากระเป๋าเจ้าของ (สำคัญมาก!)
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
    }

    // ดึงประวัติทั้งหมด
    function getPurchaseHistory() public view returns (Purchase[] memory) {
        return purchaseHistory;
    }
}