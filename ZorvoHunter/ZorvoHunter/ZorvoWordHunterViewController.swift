//
//  NameSearchingVC.swift
//  ZorvoHunter
//
//  Created by jin fu on 2025/1/1.
//

import UIKit

class ZorvoWordHunterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let words = ["ZAP", "JOT", "FLY", "POT", "RUN", "JET", "HOP", "GIG", "PIT", "TAG", "WIN", "TOP", "ZIP", "JOY", "BIT"]
    
    @IBOutlet weak var characterCollectionView: UICollectionView!
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var searchedView: UIView!
    @IBOutlet weak var timeProgress: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    var time = 15.0
    
    private let animationDuration: TimeInterval = 0.3
    private let moveDistance: CGFloat = 35.0
    
    private let alphabetImages: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                                          "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    private let imageSize: CGFloat = 25 // Adjust this size as needed
    
    // Add this property to track all letter images
    private var letterImageViews: [UIImageView] = []
    
    
    private var currentWordIndex = 0
    private var currentLetterIndex = 0
    private var targetLetters: [String] = []  // Array to track target letters
    private var foundLetters: Set<String> = []  // Track found letters in any order
    
    // Add these properties
    private var timer: Timer?
    private let gameDuration: Double = 50.0 // 10 seconds game duration
    private var score = 0
    private var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")
    
    weak var delegate: ZorvoHighScoreUpdate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.addSubview(searchedView)
        setupTargetLetters()  // Initialize target letters
        createRandomAlphabets()
        
        // Setup collection view
        characterCollectionView.dataSource = self
        characterCollectionView.delegate = self
        
        scoreLabel.text = "SCORE : \(score)"
        
        // Initialize progress view and start timer
        timeProgress.progress = 1.0
        startTimer()
        
        // Update high score label
        updateHighScoreLabel()
    }
    
    private func setupTargetLetters() {
        let currentWord = words[currentWordIndex]
        targetLetters = currentWord.map { String($0) }
        foundLetters.removeAll()  // Reset found letters for new word
    }
    
    private func moveView(direction: CGPoint) {
        let newX = searchedView.center.x + direction.x
        let newY = searchedView.center.y + direction.y
        
        // Calculate bounds
        let halfWidth = searchedView.bounds.width / 2
        let halfHeight = searchedView.bounds.height / 2
        
        // Restrict x movement
        let minX = halfWidth
        let maxX = gameView.bounds.width - halfWidth
        let boundedX = min(maxX, max(minX, newX))
        
        // Restrict y movement
        let minY = halfHeight
        let maxY = gameView.bounds.height - halfHeight
        let boundedY = min(maxY, max(minY, newY))
        
        UIView.animate(withDuration: animationDuration) {
            self.searchedView.center = CGPoint(x: boundedX, y: boundedY)
        } completion: { _ in
            self.checkForLetterCollisions()
        }
    }
    
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func topButtonTapped(_ sender: Any) {
        moveView(direction: CGPoint(x: 0, y: -moveDistance))
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        moveView(direction: CGPoint(x: -moveDistance, y: 0))
    }
    
    @IBAction func downButtonTapped(_ sender: Any) {
        moveView(direction: CGPoint(x: 0, y: moveDistance))
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        moveView(direction: CGPoint(x: moveDistance, y: 0))
    }
    
    private func createRandomAlphabets() {
        var occupiedPositions: [CGRect] = []
        
        for letter in alphabetImages {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
            containerView.backgroundColor = .lightGray // Box background color
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.black.cgColor // Box border
            containerView.layer.cornerRadius = 4
            
            let imageView = UIImageView(frame: containerView.bounds)
            imageView.image = UIImage(named: letter)
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = true
            
            // Set the accessibilityIdentifier to match the letter
            imageView.image?.accessibilityIdentifier = letter

            containerView.addSubview(imageView)
            
            // Keep trying until we find a non-overlapping position
            var validPosition = false
            var attempts = 0
            var randomX: CGFloat = 0
            var randomY: CGFloat = 0
            
            while !validPosition && attempts < 100 {
                randomX = CGFloat.random(in: imageSize/2...gameView.bounds.width - imageSize/2)
                randomY = CGFloat.random(in: imageSize/2...gameView.bounds.height - imageSize/2)
                
                let newRect = CGRect(x: randomX - imageSize/2,
                                   y: randomY - imageSize/2,
                                   width: imageSize,
                                   height: imageSize)
                
                let hasOverlap = occupiedPositions.contains { existingRect in
                    return newRect.intersects(existingRect)
                }
                
                if !hasOverlap {
                    validPosition = true
                    occupiedPositions.append(newRect)
                }
                
                attempts += 1
            }
            
            containerView.center = CGPoint(x: randomX, y: randomY)
            gameView.addSubview(containerView)
            letterImageViews.append(imageView)
        }
    }
    
    private func checkForLetterCollisions() {
        let searchedViewFrame = searchedView.frame
        
        for imageView in letterImageViews {
            if searchedViewFrame.intersects(imageView.superview?.frame ?? CGRect.zero), imageView.isHidden {
                print("Collision detected with letter: \(imageView.image?.accessibilityIdentifier ?? "Unknown")")
                imageView.isHidden = false  // Reveal the letter visually
                checkRevealedLetter(imageView: imageView)  // Check and mark as found
            }
        }
    }
    
    private func checkRevealedLetter(imageView: UIImageView) {
        guard let revealedImage = imageView.image,
              let imageName = revealedImage.accessibilityIdentifier else {
            print("No accessibilityIdentifier found for image.")
            return
        }

        print("Revealed letter: \(imageName)")

        if targetLetters.contains(imageName), !foundLetters.contains(imageName) {
            foundLetters.insert(imageName)
            print("Found character: \(imageName)")
            
            // Add animation for found letter
            let dumbImage = UIImageView(image: UIImage(named: "dumb_image")) // Replace "dumb_image" with your actual image name
            dumbImage.frame = imageView.convert(imageView.bounds, to: view)
            view.addSubview(dumbImage)
            
            // Animate the dumb image
            UIView.animate(withDuration: 0.3, animations: {
                dumbImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                dumbImage.alpha = 0
            }) { _ in
                dumbImage.removeFromSuperview()
            }
            
            // Calculate score based on remaining time
            let timeRemaining = Float(timeProgress.progress) * 10 // Convert progress (0-1) to seconds (0-10)
            let timeBonus = Int(timeRemaining * 10) // More points for finding letters quickly
            score += timeBonus + 10 // Base points (10) plus time bonus
            
            scoreLabel.text = "SCORE : \(score)"
            characterCollectionView.reloadData()
            
            // Check if all letters are found
            print("Target letters: \(targetLetters), Found letters: \(foundLetters)")
            if foundLetters.count == targetLetters.count {
                print("All letters found! Triggering alert for the next word.")
                
                let alert = UIAlertController(
                    title: "Great Job!",
                    message: "You found all letters for \(words[currentWordIndex])!",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Next Word", style: .default) { [weak self] _ in
                    self?.proceedToNextWord()
                
                })
                
                present(alert, animated: true)
            }
        }
    }
    
    
    private func proceedToNextWord() {
        currentWordIndex += 1

        // Check if all words are completed
        if currentWordIndex >= words.count {
            timer?.invalidate()
            checkAndUpdateHighScore()
            let finalAlert = UIAlertController(
                title: "Congratulations!",
                message: "You've completed all words!\nFinal Score: \(score)\nHigh Score: \(highScore)",
                preferredStyle: .alert
            )
            finalAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(finalAlert, animated: true)
            return
        }

        
        setupTargetLetters()
        foundLetters.removeAll()

        for imageView in letterImageViews {
            imageView.superview?.removeFromSuperview()
        }
        letterImageViews.removeAll()
        createRandomAlphabets()
        
        // Restart timer for new word
        startTimer()

        characterCollectionView.reloadData()
    }
    
    
    
    private func showCompletionAlert() {
        let alert = UIAlertController(title: "Congratulations!", 
                                    message: "You've completed all words!", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Collection View Data Source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return targetLetters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharCell", for: indexPath) as! ZorvoCharCell
        
        let letter = targetLetters[indexPath.item]
        cell.charImage.image = UIImage(named: letter)
        
        // Highlight found letters
        cell.contentView.backgroundColor = foundLetters.contains(letter) ? .yellow : .clear
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 10, height: collectionView.frame.height - 10)
    }
    
    // Add these new methods
    private func startTimer() {
        // Reset timer if it exists
        timer?.invalidate()
        
        // Reset progress view
        timeProgress.progress = 1.0
        
        // Create new timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let progress = self.timeProgress.progress - Float(0.1 / self.gameDuration)
            self.timeProgress.progress = max(0, progress)
            
            if self.timeProgress.progress <= 0 {
                self.timer?.invalidate()
                self.handleTimeUp()
            }
        }
    }
    
    private func handleTimeUp() {
        checkAndUpdateHighScore()
        
        let alert = UIAlertController(
            title: "Time's Up!",
            message: "Try again with the next word",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Next", style: .default) { [weak self] _ in
            self?.proceedToNextWord()
        })
        
        present(alert, animated: true)
    }
    
    private func updateHighScoreLabel() {
        //highScoreLabel.text = "HIGH SCORE: \(highScore)"
    }
    
    private func checkAndUpdateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "HighScore")
            updateHighScoreLabel()
            
            // Notify delegate about the new high score
            delegate?.updateHighScore(value: highScore)
            
            let alert = UIAlertController(
                title: "New High Score!",
                message: "Congratulations! You've set a new high score of \(highScore)!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    }
}
