//
//  ViewController.swift
//  Hangman
//
//  Created by Jerry Turcios on 1/12/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

enum GameStatus {
    case victory
    case failure
}

class ViewController: UIViewController {

    // MARK: - Controller properties

    var scoreLabel: UILabel!
    var imageView: UIImageView!
    var descriptionLabel1: UILabel!
    var descriptionLabel2: UILabel!
    var hiddenWordLabel: UILabel!
    var buttonsView: UIView!
    var letterButtons = [UIButton]()

    let alphabetList = [
        ["a", "h", "o", ""],
        ["b", "i", "p", "v"],
        ["c", "j", "q", "w"],
        ["d", "k", "r", "x"],
        ["e", "l", "s", "y"],
        ["f", "m", "t", "z"],
        ["g", "n", "u", ""]
    ]

    var allWordsFromFile = [String]()
    var hiddenWord = ""

    var amountGuessedIncorrectly = 0 {
        didSet {
            imageView.image = UIImage(named: "Hangman\(amountGuessedIncorrectly)")
        }
    }

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    // MARK: - Lifecycle methods

    override func loadView() {
        view = UIView()
        view.backgroundColor = AppColors.background

        setupUserInterface()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let file = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let words = try? String(contentsOf: file) {
                allWordsFromFile = words.components(separatedBy: "\n")
            }
        }

        loadGame()
    }

    // MARK: - Defined methods

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonLetter = sender.titleLabel?.text else { return }
        guard let hiddenWordLabelText = hiddenWordLabel.text else { return }

        sender.isEnabled = false

        if hiddenWord.contains(buttonLetter) {
            var newGuessedWord = ""

            for letter in hiddenWord {
                if String(letter) == buttonLetter {
                    // If the selected letter is in the hidden word, add that letter
                    // to the new guessed word
                    newGuessedWord.append(letter)
                } else if hiddenWordLabelText.contains(letter) {
                    // If the selected letter is already in the new guessed word, re-add
                    // that letter to it
                    newGuessedWord.append(letter)
                } else {
                    newGuessedWord.append("?")
                }
            }

            // The newly built guessed word is assigned to the hidden word text label
            hiddenWordLabel.text = newGuessedWord

            // Checks to see if the player guessed all the letters
            if hiddenWord == hiddenWordLabel.text {
                endGame(for: .victory)
            }
        } else {
            amountGuessedIncorrectly += 1

            if amountGuessedIncorrectly == 7 {
                endGame(for: .failure)
            }
        }
    }

    func loadGame() {
        guard let randomWord = allWordsFromFile.randomElement() else { return }

        hiddenWord = randomWord
        hiddenWordLabel.text = ""
        amountGuessedIncorrectly = 0

        for button in letterButtons {
            button.isEnabled = true
        }

        for _ in hiddenWord {
            hiddenWordLabel.text?.append("?")
        }
    }

    func endGame(for gameStatus: GameStatus) {
        var title = ""
        var message = ""

        if gameStatus == .victory {
            title = "You won!"
            message = "You managed to guess the word \"\(hiddenWord)\""
        } else {
            title = "Game over!"
            message = "You ran out of tries to guess the word \"\(hiddenWord)\""
        }

        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let endGameAction = UIAlertAction(title: "Play again", style: .default) {
            [weak self] _ in

            // Increments or decrements the score based on the game status
            if gameStatus == .victory {
                self?.score += 1
            } else {
                self?.score -= 1
            }

            self?.loadGame()
        }

        ac.addAction(endGameAction)
        present(ac, animated: true)
    }
}

// MARK: - User interface code

extension ViewController {
    func setupUserInterface() {
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: 0"
        scoreLabel.font = .boldSystemFont(ofSize: 20)
        view.addSubview(scoreLabel)

        imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        descriptionLabel1 = UILabel()
        descriptionLabel1.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel1.text = "Hidden word"
        descriptionLabel1.font = .boldSystemFont(ofSize: 24)
        view.addSubview(descriptionLabel1)

        hiddenWordLabel = UILabel()
        hiddenWordLabel.translatesAutoresizingMaskIntoConstraints = false
        hiddenWordLabel.textAlignment = .center
        view.addSubview(hiddenWordLabel)

        descriptionLabel2 = UILabel()
        descriptionLabel2.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel2.text = "Tap the letters to guess the word"
        descriptionLabel2.textColor = .gray
        descriptionLabel2.font = .boldSystemFont(ofSize: 20)
        view.addSubview(descriptionLabel2)

        buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)

        let width = 59
        let height = 59

        for row in 0..<7 {
            for column in 0..<4 {
                let button = UIButton(type: .system)
                button.titleLabel?.font = .boldSystemFont(ofSize: 30)
                button.setTitle(alphabetList[row][column], for: .normal)
                button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)

                let frame = CGRect(x: row * width, y: column * height, width: width, height: height)
                button.frame = frame

                buttonsView.addSubview(button)
                letterButtons.append(button)
            }
        }

        constrainElements()
    }

    func constrainElements() {
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            imageView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            descriptionLabel1.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 80),
            descriptionLabel1.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            hiddenWordLabel.topAnchor.constraint(equalTo: descriptionLabel1.bottomAnchor, constant: 20),
            hiddenWordLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            hiddenWordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descriptionLabel2.topAnchor.constraint(equalTo: hiddenWordLabel.bottomAnchor, constant: 100),
            descriptionLabel2.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonsView.topAnchor.constraint(equalTo: descriptionLabel2.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ])
    }
}
