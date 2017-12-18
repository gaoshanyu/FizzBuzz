//
//  ViewController.swift
//  FizzBuzz
//
//  Created by raniys on 12/8/17.
//  Copyright © 2017 raniys. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var game: Game?
    
    var gameScore: Int? {
        didSet {
            numberButton.setTitle("\(gameScore ?? 0)", for: .normal)
        }
    }
    
    @IBOutlet weak var numberButton: UIButton!
    @IBOutlet weak var fizzButton: UIButton!
    @IBOutlet weak var buzzButton: UIButton!
    @IBOutlet weak var fizzBuzzButton: UIButton!
    
    
    @IBAction func onButtonTapped(_ sender: UIButton) {
        
        switch sender {
        case numberButton:
            play(move: .number)
        case fizzButton:
            play(move: .fizz)
        case buzzButton:
            play(move: .buzz)
        case fizzBuzzButton:
            play(move: .fizzBuzz)
        default:
            print("Invalid selection")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        numberButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        game = Game()
        gameScore = game!.score

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func play(move: Move) {
        
        guard let unwarappedGame = game else {
            print("Game is nil")
            return
        }
        
        let response = unwarappedGame.play(move: move)
        gameScore = response.score
        
        
    }
}

