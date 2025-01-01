//
//  StartGameVC.swift
//  ZorvoHunter
//
//  Created by jin fu on 2025/1/1.
//


import UIKit

class ZorvoStartGameViewController: UIViewController, ZorvoHighScoreUpdate{
    
    @IBOutlet weak var highScoreLabel: UILabel!
  
    @IBOutlet weak var dashImage: UIImageView!
    
    private var highScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        updatdHighScore()
        
        // Start repeating animation
        startRepeatingAnimation()
    }
    
    private func updatdHighScore(){
        highScoreLabel.text = "HIGH SCORE : \(highScore)"
    }
    
    private func startRepeatingAnimation() {
        let dumbView = UIView(frame: dashImage.bounds)
        //dumbView.backgroundColor = .green  // Or any color you want
        dashImage.addSubview(dumbView)
        
        // Create repeating animation
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Reset view properties
            dumbView.alpha = 1
            dumbView.transform = .identity
            
            // Vibrating animation sequence
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                // Shake left
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                    dumbView.transform = CGAffineTransform(translationX: -10, y: 0)
                }
                // Shake right
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                    dumbView.transform = CGAffineTransform(translationX: 10, y: 0)
                }
                // Shake left again
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                    dumbView.transform = CGAffineTransform(translationX: -10, y: 0)
                }
                // Return to center and fade
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                    dumbView.transform = .identity
                    dumbView.alpha = 0
                }
            })
        }
    }
    
    func updateHighScore(value: Int) {
        highScore = value
        updatdHighScore()
    }
    
    
    @IBAction func btnPlayTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NameSearchingVC") as! ZorvoWordHunterViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    

    

}
