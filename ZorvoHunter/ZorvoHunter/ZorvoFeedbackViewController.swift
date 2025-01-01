//
//  FeedbackViewController.swift
//  ZorvoHunter
//
//  Created by jin fu on 2025/1/1.
//


import UIKit
import IQKeyboardManagerSwift

class ZorvoFeedbackViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!           // Feedback title
    @IBOutlet weak var ratingStackView: UIStackView!  // Star rating
    @IBOutlet weak var feedbackTextView: UITextView!  // Text view for additional feedback
    @IBOutlet weak var submitButton: UIButton!        // Submit button
    @IBOutlet weak var backButton: UIButton!          // Back button (optional)

    
    var selectedRating: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStarRating()
    }

    // MARK: - Setup UI
    private func setupUI() {
        
        IQKeyboardManager.shared.isEnabled = true
        
        titleLabel.text = "We Value Your Feedback"

        feedbackTextView.layer.borderColor = UIColor.lightGray.cgColor
        feedbackTextView.layer.borderWidth = 1
        feedbackTextView.layer.cornerRadius = 8
        feedbackTextView.text = "Enter your feedback here..."
        feedbackTextView.textColor = .lightGray
        feedbackTextView.delegate = self

        // Submit button
        submitButton.layer.cornerRadius = 8
        submitButton.setTitle("Submit Feedback", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
    }

    // MARK: - Actions
    @IBAction func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarRating()
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard selectedRating > 0 else {
            showAlert(message: "Please select a rating.")
            return
        }

        guard let feedback = feedbackTextView.text, !feedback.isEmpty, feedback != "Enter your feedback here..." else {
            showAlert(message: "Please enter your feedback.")
            return
        }

        // Handle feedback submission
        print("Rating: \(selectedRating), Feedback: \(feedback)")
        showAlert(message: "Thank you for your feedback!")
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper Methods
    private func updateStarRating() {
        for (index, star) in ratingStackView.arrangedSubviews.enumerated() {
            if let button = star as? UIButton {
                let imageName = index < selectedRating ? "star.fill" : "star"
                button.setImage(UIImage(systemName: imageName), for: .normal)
                button.tintColor = index < selectedRating ? .systemYellow : .systemBlue
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextView Delegate
extension ZorvoFeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter your feedback here..." {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your feedback here..."
            textView.textColor = .lightGray
        }
    }
}
