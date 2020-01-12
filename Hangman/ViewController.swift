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

    var hiddenWord: String?

    var amountGuessedIncorrectly = 0 {
        didSet {
            imageView.image = UIImage(named: "Hangman\(amountGuessedIncorrectly)")
        }
    }

    // MARK: - Lifecycle methods

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        setupUserInterface()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGame()
    }

    // MARK: - Defined methods

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonLetter = sender.titleLabel?.text else { return }
        guard let hiddenWord = hiddenWord else { return }

        sender.isEnabled = false

        if hiddenWord.contains(buttonLetter) {
            //FIXME: Replace the ? with the letter in the right spot

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
        // Load new word from a text file

        hiddenWord = "hangman"
        hiddenWordLabel.text = ""
        amountGuessedIncorrectly = 0

        for button in letterButtons {
            button.isEnabled = true
        }

        for _ in hiddenWord! {
            hiddenWordLabel.text?.append("?")
        }
    }

    func endGame(for playerWon: GameStatus) {
        var title = ""
        var message = ""

        if playerWon == GameStatus.victory {
            title = "You won!"
            message = "You managed to guess the word before running out of tries"
        } else {
            title = "Game over!"
            message = "You ran out of tries to guess the word"
        }

        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let endGameAction = UIAlertAction(title: "Play again", style: .default) {
            action in
            self.loadGame()
        }

        ac.addAction(endGameAction)
        present(ac, animated: true)
    }
}

// MARK: - User interface code

extension ViewController {
    func setupUserInterface() {
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
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
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
