//SPDX-License-Identifier:MIT
pragma solidity ^0.8.1;

contract UisngStruct {
    uint256 year;
    address Own;

    struct Book {
        string names;
        uint256 year;
        address Own;
    }
    Book public book;
    Book[] public books;
    mapping(address => Book[]) public ownBook;

    function initialize() public {
        Book memory Agbak = Book("opor", 1222, msg.sender);
        Book memory Kaka = Book({names: "Opg", year: 2234, Own: msg.sender});
        Book memory daba;
        daba.names = "opp";
        daba.year = 1123;
        daba.Own = msg.sender;
        books.push(Agbak);
        books.push(Kaka);
        books.push(daba);
        books.push(Book("Kpk", 1223, msg.sender));
    }
}
