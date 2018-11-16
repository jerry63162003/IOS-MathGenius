//
//  GameViewController.swift
//  MathsMaster
//
//  Created by roy on 2018/7/21.
//  Copyright © 2018年 roy. All rights reserved.
//

import UIKit
import LDProgressView

class GameViewController: UIViewController {
    
    //userChooseBtn
    @IBOutlet var buttonList: [UIButton]!
    //blackBoardNum
    @IBOutlet var labelList: [UILabel]!
    //sign
    @IBOutlet weak var operationLabel: UIImageView!
    //questionCount
    @IBOutlet weak var numberCountLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wrongImageView: UIImageView!
    @IBOutlet weak var timeView: UIView!
    
    var progressView = LDProgressView()
    let sound = SoundManager()
    
    var timer: Timer?
    var rightAnswerList: [Int] = []
    var operation: GameOperations?
    var rightNumbers: (Int, Int, Int)?
    var time = 60 {
        didSet {
            timeLabel.text = "\(time)"
            progressView.progress = CGFloat(Float(time) / 60.0)
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    var questionNumber = 0 {
        didSet {
            numberCountLabel.text = "第 \(questionNumber) 题"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        getFormula()
        if GameConfig.shared.isGameMusic {
            sound.playBackGroundSound()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func commonInit() {
        progressView = LDProgressView()
        progressView.color = UIColor.yellow
        progressView.progress = 1.00
        progressView.animate = true
        progressView.showText = false
        progressView.type = LDProgressGradient
        progressView.background = UIColor.gray
        timeView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(timeView)
        }
        
        questionNumber = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            self?.time -= 1
            if self?.time == 0 {
                self?.timer?.invalidate()
                self?.gameOver()
            }
        }
    }
    
    func getFormula() {
        rightAnswerList.removeAll()
        
        operation = GameFuction.getOperations()
        operationLabel.image = UIImage(named: operation!.rawValue)
        
        rightNumbers = GameFuction.getNumbersForOperation(gameOperation: operation!)
        let randomNumber = GameFuction.getRandomNumber()
        
        var numberList: Array = [randomNumber, rightNumbers!.0, rightNumbers!.1, rightNumbers!.2]
        
        for i in 0..<labelList.count {
            let label = labelList[i]
            label.adjustsFontSizeToFitWidth = true
            label.text = "\(numberList[i+1])"
        }
        
        numberList = numberList.shuffle()
        
        for i in 0..<buttonList.count {
            let button = buttonList[i]
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitle("\(numberList[i])", for: .normal)
        }
        
        print(rightNumbers!)
    }
    
    func checkIsRightAnswer() {
        for button in buttonList {
            
            if button.isSelected == true {
                if String(describing:rightNumbers!.2) == button.titleLabel?.text {
                    score += 1
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.wrongImageView.alpha = 1.0
                    }) { (complete) in
                        if complete {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.wrongImageView.alpha = 0.0
                            })
                        }
                    }
                }
            }
            button.isSelected = false
        }
        
        questionNumber += 1
        getFormula()
    }
    
    func gameOver() {
        if score > GameConfig.shared.highScore {
            GameConfig.shared.highScore = score
        }
        if GameConfig.shared.isGameSound {
            sound.stopBackGroundSound()
        }
        sound.playOverSound()
        performSegue(withIdentifier: "toGameOver", sender: score)
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        
        guard rightAnswerList.count != 3 else {
            return
        }
        
        guard sender.isSelected == false else {
            return
        }
        
        sender.isSelected = true
        checkIsRightAnswer()
    }
    
    @IBAction func backClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameOver" {
            let vc = segue.destination as! GameOverViewController
            vc.score = score
        }
    }
    
}
