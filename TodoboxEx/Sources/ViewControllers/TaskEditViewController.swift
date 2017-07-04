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

    var didAddTask: ((Task) -> Void)?
    var taskList: [TaskList] = []

    @IBOutlet var titleInput:UITextField!
    @IBOutlet var detailInput:UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailInput.layer.cornerRadius = 5
        self.detailInput.layer.borderColor = UIColor.lightGray.cgColor
        self.detailInput.layer.borderWidth = 1 / UIScreen.main.scale
        
        
        //TODO :: 서버에서 목록 가져오기
        let urlString = "http://127.0.0.1:3000/edit"
        let parameters: [String: Any] = [
            "_id": "595636c04dc67018c878bdaa"
            ]
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            ]


        Alamofire.request(urlString, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value) :
                guard let json = value as? [[String: Any]] else {break}
                let tempTaskList = [TaskList](JSONArray: json) ?? [] //?? : 앞에 있는 연산자가 오류이면 []를 실행하라
                self.taskList.append(contentsOf: tempTaskList)
                let task = self.taskList[0]
                
                self.titleInput.text = "to. " + task.nickName + " (" + task.phoneNo + ")"
                self.detailInput.text = task.message
            case .failure(let error) :
                print("요청 실패 \(error)")
                
            }
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleInput.becomeFirstResponder()
        

    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("#######")
        if segue.identifier == "taskCell" {
            print("taksCell")
        }
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

