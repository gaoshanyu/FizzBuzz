//
//  GameTests.swift
//  FizzBuzzTests
//
//  Created by raniys on 12/13/17.
//  Copyright © 2017 raniys. All rights reserved.
//

import XCTest
@testable import FizzBuzz

class GameTests: XCTestCase {
    
    let game = Game()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGameStartsAtZero() {
        XCTAssertTrue(game.score == 0)
    }
    
    func testOnPlayScoreIncremented() {
        let _ = game.play(move: .number)
        XCTAssertTrue(game.score == 1)
    }
    
    func testOnPlayTwiceScoreIncremented() {
        game.score = 1
        let _ = game.play(move: .number)
        XCTAssertTrue(game.score == 2)
    }
    
    func testIfFizzMoveIsRight() {
        game.score = 2
        let result = game.play(move: .fizz)
        XCTAssertEqual(result.right, true)
    }
    
    func testIfFizzMoveIsWrong() {
        game.score = 1
        let result = game.play(move: .fizz)
        XCTAssertEqual(result.right, false)
    }
    
    func testIfBuzzMoveRight() {
        game.score = 4
        let result = game.play(move: .buzz)
        XCTAssertEqual(result.right, true)
    }
    
    func testIfBuzzMoveWrong() {
        game.score = 1
        let result = game.play(move: .buzz)
        XCTAssertEqual(result.right, false)
    }
    
    func testIfFizzBuzzMoveRight() {
        game.score = 14
        let result = game.play(move: .fizzBuzz)
        XCTAssertEqual(result.right, true)
    }
    
    func testIfFizzBuzzMoveWrong() {
        game.score = 1
        let result = game.play(move: .fizzBuzz)
        XCTAssertEqual(result.right, false)
    }
    
    func testIfNumberMoveRight() {
        game.score = 1
        let result = game.play(move: .number)
        XCTAssertEqual(result.right, true)
    }
    
    func testIfNumberMoveWrong() {
        game.score = 2
        let result = game.play(move: .number)
        XCTAssertEqual(result.right, false)
    }
    
    func testIfMoveWrongScoreNotIncremented() {
        game.score = 1
        let _ = game.play(move: .fizz)
        XCTAssertEqual(game.score, 1)
    }
    
    func testPlayShouldReturnIfMoveRight() {
        let response = game.play(move: .number)
        XCTAssertNotNil(response.right)
    }
    
    func testPlayShouldReturnNewScore() {
        let response = game.play(move: .number)
        XCTAssertNotNil(response.score)
    }
}


