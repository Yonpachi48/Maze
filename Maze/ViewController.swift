//
//  ViewController.swift
//  Maze
//
//  Created by Yudai Takahashi on 2021/05/09.
//

import UIKit
import CoreMotion       //CMMOtionManager(加速度センサー)を使うための設定

class ViewController: UIViewController {
    
    var playerView: UIView!     //プレイヤーを表す
    var playerMotionManager: CMMotionManager!   //iPhoneの動きを感知するCMMotionmanager
    var speedX: Double = 0.0        //プレイヤーが動く速さ
    var speedY: Double = 0.0        //プレイヤーが動く速さ

    //画面のサイズの取得
    let screenSize = UIScreen.main.bounds.size
    
    //迷路のマップのを表した配列
    let maze = [
        [1, 4, 4, 4, 1, 0],
        [1, 0, 1, 0, 1, 0],
        [3, 0, 1, 0, 1, 5],
        [1, 1, 1, 0, 0, 5],
        [1, 0, 0, 1, 1, 5],
        [0, 0, 1, 0, 0, 5],
        [0, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 1, 1],
        [0, 1, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 2],
    ]
    //スタートとゴールを表すUIView
    var startView: UIView!
    var goalView: UIView!
    
    //wallViewのフレーム情報を入れておく配列
    var wallRectArray = [CGRect]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cellWidth = screenSize.width / CGFloat(maze[0].count)   //セルの幅(横画面サイズを横マスの数=6で割る)
        let cellHeight = screenSize.height / CGFloat(maze.count)    //セルの高さ(縦画面サイズを縦マスの数=10で割る)
    
        
        let cellOffsetX = cellWidth / 2         //マスの左上と中心のx座標の差
        let cellOffsetY = cellHeight / 2        //マスの左上と中心のy座標の差
        
        //画面のマスの設定
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count {
                switch maze[y][x] {
                case 1: //当たるとゲームオーバーになるマス
                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2: //スタートマス
                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.green
                    view.addSubview(startView)
                case 3: //ゴールマス
                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                case 4: //当たるとゲームオーバーになるマス(高さ1/2)
                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight * 3 / 4, offsetX: cellOffsetX, offsetY: cellOffsetY - (cellOffsetY / 4))
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 5: //当たるとゲームオーバーになるマス(幅1/2)
                    let wallView = createView(x: x + (x / 2), y: y, width: cellWidth * 3 / 4, height: cellHeight, offsetX: cellOffsetX + (cellOffsetX / 2), offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                default:
                    break
                }
            }
        }
        
        //playrViewを生成
        //playerの幅と高さはマップ1マスの1/6
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth / 6, height: cellHeight / 6))
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.gray
        view.addSubview(playerView)
        
        //MotionManagerを生成
        playerMotionManager = CMMotionManager()
        //playerMotionManagerの加速度の値を0.02秒ごとに取得する
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAccelerometer()
    }

    func createView(x: Int,y: Int, width: CGFloat, height: CGFloat, offsetX:CGFloat, offsetY: CGFloat) -> UIView{
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center  = center
        
        return view
    }
    
    func startAccelerometer() {
        //加速度を取得する
        let handler: CMAccelerometerHandler = {(CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            self.speedY += CMAccelerometerData!.acceleration.y
            
            //プレイヤーの中心位置を設定
            var posX = self.playerView.center.x + (CGFloat(self.speedX / 3))
            var posY = self.playerView.center.y - (CGFloat(self.speedY / 3))
            
            //画面上からプレイヤーがはみ出しそうだったら、posX/posYを修正
            if posX <= self.playerView.frame.width / 2 {
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2 {
                self.speedY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width / 2) {
                self.speedX = 0
                posX = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height / 2) {
                self.speedY = 0
                posY = self.screenSize.height - (self.playerView.frame.height / 2)
            }
            
            for wallRect in self.wallRectArray {
                if wallRect.intersects(self.playerView.frame) {
                    self.gameCheck(resrut: "gameover", message: "壁に当たりました")
                    return
                }
            }
            
            if self.goalView.frame.intersects(self.playerView.frame) {
                self.gameCheck(resrut: "clear", message: "クリアしました！")
                return
            }
            
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        //加速度の開始
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    func gameCheck(resrut: String, message: String) {
        //加速度を止める
        if playerMotionManager.isAccelerometerActive {
            playerMotionManager.stopAccelerometerUpdates()
        }
        let  gameCheckAlert: UIAlertController = UIAlertController(title: resrut, message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.retry()
        })
        
        gameCheckAlert.addAction(retryAction)
        
        self.present(gameCheckAlert, animated: true, completion: nil)
    }
    
    func retry() {
        //プレイヤー位置を初期化
        playerView.center = startView.center
        //加速度センサーを始める
        if !playerMotionManager.isAccelerometerActive {
            self.startAccelerometer()
        }
        //スピードを初期化
        speedX = 0.0
        speedY = 0.0
    }
    
    
}

