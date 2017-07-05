//
//  TaskEditViewController.swift
//  Todobox
//
//  Created by admin on 2017. 2. 15..
//  Copyright © 2017년 admin. All rights reserved.
//

import UIKit
import Alamofire


class TaskEditViewController: UIViewController {

    let taskListIndex = 0
    var didAddTask: ((Task) -> Void)?
    var taskList: [TaskList] = []
    var taskEditMode = false
    
    @IBOutlet var titleInput:UITextField!
    @IBOutlet var detailInput:UITextView!
    @IBOutlet var mediaFile: UILabel!
    

    //파일 선택
    @IBAction func mediaFileSelect(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailInput.layer.cornerRadius = 5
        self.detailInput.layer.borderColor = UIColor.lightGray.cgColor
        self.detailInput.layer.borderWidth = 1 / UIScreen.main.scale
        
        if self.taskList.count != 0 {
            taskEditMode = true
            let task = self.taskList[taskListIndex]
            self.titleInput.text = "to. " + task.nickName + " (" + task.id + ")"
            self.titleInput.isUserInteractionEnabled = false
            self.detailInput.text = task.message
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleInput.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask" {
            print("editTask")
        }
    }

    @IBAction func doneButtonDidTap(){
        //if let & guard let
        //if let => 영역 안에서만 사용 가능
        //guard let => 선언 아래부터 사용 가능
        guard let titleInput = self.titleInput.text, !titleInput.isEmpty else {
            self.shakeTitleInput()
            return
        }
        
        guard let detailInput = self.detailInput.text, !detailInput.isEmpty else {
            self.shakeDetailInput()
            return;
        }
        
        var urlString = "http://127.0.0.1:3000"
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            ]
        var parameters: [String: Any] = [:]
       
        if taskEditMode == true {
            let task = self.taskList[taskListIndex]

            urlString = urlString + "/edit"
            parameters = [
                "_id": task.id,
                "message": detailInput,
                //TODO : mediaFile 처리 필요
            ]
        } else {
            urlString = urlString + "/write"
            parameters = [
                "fromUser": "1@1.com",
                "nickName": titleInput,
                "phoneNo": "01000001112",
                "message": detailInput,
                //TODO : mediaFile 처리 필요
            ]
        }
        
        Alamofire.request(urlString, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value) :
                print("요청 완료 \(value)")
                
                self.titleInput.resignFirstResponder() //키보드 숨기기
                let newTask = Task(title: titleInput, detail: detailInput, isDone: false)
                self.didAddTask?(newTask)
                NotificationCenter.default.post(name: .taskDidAdd, object: self, userInfo: ["task": newTask])
                self.dismiss(animated: true, completion: nil)
            case .failure(let error) :
                print("요청 실패 \(error)")
            }
        }
        
        
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


