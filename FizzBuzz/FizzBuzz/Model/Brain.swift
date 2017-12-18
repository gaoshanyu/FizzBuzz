//
//  Brain.swift
//  FizzBuzz
//
//  Created by raniys on 12/8/17.
//  Copyright © 2017 raniys. All rights reserved.
//

import Foundation

class Brain {
    
    func check(number: Int) -> Move {
        if isDivisibleByFifteen(number: number) {
            return Move.fizzBuzz
        } else if isDivisibleByThree(number: number) {
            return Move.fizz
        } else if isDivisibleByFive(number: number) {
            return Move.buzz
        } else {
            return Move.number
        }
    }
    
    func isDivisibleByThree(number: Int) -> Bool {
        return isDivisibleBy(divisor: 3, number: number)
    }
    
    func isDivisibleByFive(number: Int) -> Bool {
        return isDivisibleBy(divisor: 5, number: number)
    }
    
    func isDivisibleByFifteen(number: Int) -> Bool {
        return isDivisibleBy(divisor: 15, number: number)
    }
    
    func isDivisibleBy(divisor: Int, number: Int) -> Bool {
        return number % divisor == 0
    }
    
}




