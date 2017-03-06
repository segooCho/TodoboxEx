//
//  TaskEditViewController.swift
//  Todobox
//
//  Created by admin on 2017. 2. 15..
//  Copyright © 2017년 admin. All rights reserved.
//

import UIKit

//Notification : 데이터 공유 서버의 개념으로 업데이트 시 해당 정보를 모고 있는 화면에 업데이트 된다.
extension Notification.Name{
    static var taskDidAdd: Notification.Name {return .init("taskDidadd")}
}

class TaskEditViewController: UIViewController{

    @IBOutlet var titleInput:UITextField!
    @IBOutlet var detailInput:UITextView!

    var didAddTask: ((Task) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailInput.layer.cornerRadius = 5
        self.detailInput.layer.borderColor = UIColor.lightGray.cgColor
        self.detailInput.layer.borderWidth = 1 / UIScreen.main.scale
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleInput.becomeFirstResponder()
    }
    
    @IBAction func doneButtonDidTap(){
        
        //if let & guard let
        //if let => 영역 안에서만 사용 가능
        //guard let => 선언 아래부터 사용 가능
        guard let lTitle = self.titleInput.text, !lTitle.isEmpty else {
            self.shakeTitleInput()
            return
        }
        
        guard let lDetail = self.detailInput.text, !lDetail.isEmpty else {
            self.shakeDetailInput()
            return;
        }
            
        self.titleInput.resignFirstResponder() //키보드 숨기기

        let newTask = Task(title: lTitle, detail: lDetail, isDone: false)
        //self.didAddTask?(newTask)
        NotificationCenter.default.post(name: .taskDidAdd, object: self, userInfo: ["task": newTask])
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonDidTap() {
        self.titleInput.resignFirstResponder() //키보드 숨기기

        if (self.titleInput.text?.isEmpty)!{
            self.dismiss(animated: true, completion: nil)
        }
        
        
        let alertController = UIAlertController(
            title: NSLocalizedString("Confirm", comment: "확인")
            ,message: "입력된 할 일 내용이 있습니다.\n그래도 취소하시겠습니까?"
            ,preferredStyle: .alert)
        
        
        let alertYes = UIAlertAction(
            title: "Yes"
            ,style: .default)
            {(ACTION) in
                self.dismiss(animated: true, completion: nil)
            }
        
        alertController.addAction(alertYes)
        
        let alertCancel = UIAlertAction(
            title: "Cancel"
            ,style: .cancel)
            {(ACTION) in
                self.titleInput.becomeFirstResponder() //키보드 보이기
            }

        alertController.addAction(alertCancel)

        /*
        //handler nil 로 작업 없음
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.cancel, handler: nil))
        */
        self.present(alertController, animated: true, completion: nil)
    }
    
    func shakeTitleInput() {
        UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x -= 5 }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x += 10 }, completion: { _ in
                UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x -= 10 }, completion: { _ in
                    UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x += 10 }, completion: { _ in
                        UIView.animate(withDuration: 0.05, animations: { self.titleInput.frame.origin.x -= 5 })
                    })
                })
            })
        })
    }
    
    func shakeDetailInput() {
        UIView.animate(withDuration: 0.05, animations: { self.detailInput.frame.origin.x -= 5 }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: { self.detailInput.frame.origin.x += 10 }, completion: { _ in
                UIView.animate(withDuration: 0.05, animations: { self.detailInput.frame.origin.x -= 10 }, completion: { _ in
                    UIView.animate(withDuration: 0.05, animations: { self.detailInput.frame.origin.x += 10 }, completion: { _ in
                        UIView.animate(withDuration: 0.05, animations: { self.detailInput.frame.origin.x -= 5 })
                    })
                })
            })
        })
    }
    
}

