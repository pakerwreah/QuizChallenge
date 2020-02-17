//
//  QuizViewController.swift
//  QuizChallenge
//
//  Created by Carlos on 11/02/20.
//  Copyright © 2020 ArcTouch. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hitsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!

    private let loading = Loading()

    private var words: [String] = []
    private var hits: [String] = []

    private var timer: Timer? = nil
    private var remaining: TimeInterval = 0

    private var running = false {
        didSet {
            titleLabel.isHidden = !running
            textField.isHidden = !running
            tableView.isHidden = !running
            startButton.setTitle(running ? "Reset" : "Start", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell")

        keyboardNotifications()
        
        reset()
    }

    @IBAction func startButtonAction(_ sender: Any) {
        if running {
            reset()
        } else {
            start()
        }
    }

    private func reset() {
        deinitTimer()
        timeLabel.text = timeString(0)
        hitsLabel.text = "00/00"
        view.endEditing(true)
        running = false
    }

    private func start() {
        present(loading, animated: true)

        thread {
            do {
                let quiz = try Http.get(url: "https://codechallenge.arctouch.com/quiz/1", model: QuizModel.self)

                main {
                    self.loading.dismiss(animated: true)
                    self.titleLabel.text = quiz.question
                    self.words = quiz.answer
                    self.hits = []
                    self.tableView.reloadData()
                    self.running = true
                    self.initTimer()
                    self.textField.becomeFirstResponder()
                }
            } catch {
                main {
                    self.loading.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error loading the quiz", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

    private func timeString(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 60 * 60) / 60)
        return String(format: "%.2d:%.2d", minutes, seconds)
    }

    private func initTimer() {
        remaining = 5 * 60
        timeLabel.text = timeString(remaining)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if let self = self {
                self.remaining -= 1

                self.timeLabel.text = self.timeString(self.remaining)

                if self.remaining == 0 {
                    self.timeUp()
                }
            }
        }
    }
    
    private func timeUp() {
        deinitTimer()
        
        view.endEditing(true)

        let alert = UIAlertController(title: "Time finished", message: "Sorry, time is up! You got \(hits.count) out of \(hits.count + words.count) answers.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
            self.reset()
            self.start()
        })

        present(alert, animated: true)
    }

    private func deinitTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        deinitTimer()
    }
}

// MARK: - Keyboard configuration

extension QuizViewController {
    private func keyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        keyboardConstraint.constant = keyboardSize - view.safeAreaInsets.bottom

        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        keyboardConstraint.constant = 0

        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
}

// MARK: - TextField configuration

extension QuizViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let text = textField.text, let range = Range(range, in: text) {
            let guess = text.replacingCharacters(in: range, with: string)

            if let i = words.firstIndex(of: guess) {
                hits.insert(words.remove(at: i), at: 0)
                hitsLabel.text = String(format: "%.2d/%.2d", hits.count, hits.count + words.count)
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                textField.text = ""

                if(words.isEmpty) {
                    self.deinitTimer()
                    
                    self.view.endEditing(true)

                    let alert = UIAlertController(title: "Congratulations", message: "Good job! You found all the answers on time. Keep up with the great work.", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Play Again", style: .default) { _ in
                        self.reset()
                        self.start()
                    })

                    self.present(alert, animated: true)
                }

                return false
            }
        }

        return true
    }

}

// MARK: - TableView configuration

extension QuizViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)

        cell.textLabel?.text = hits[indexPath.row]

        return cell
    }

}
