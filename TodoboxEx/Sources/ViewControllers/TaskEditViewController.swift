//
//  TaskEditViewController.swift
//  Todobox
//
//  Created by admin on 2017. 2. 15..
//  Copyright © 2017년 admin. All rights reserved.
//

import UIKit
import Alamofire


class TaskEditViewController: UIViewController,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate {

    //MARK ::
    fileprivate let taskListIndex = 0
    fileprivate var didAddTask: ((Task) -> Void)?
    fileprivate var taskEditMode = false
    //fileprivate var imageUrl:NSURL!
    fileprivate var localPath:URL!
    var taskList: [TaskList] = []
    
    //MARK :: UI
    @IBOutlet var titleInput:UITextField!
    @IBOutlet var detailInput:UITextView!
    @IBOutlet var mediaFileNameLabel: UILabel!
    fileprivate var picker:UIImagePickerController?=UIImagePickerController()

    //MARK :: 파일 선택
    @IBAction func mediaFileSelect(_ sender: Any) {
        
        //Gallary
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
        
        /*
        //Camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        */
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let imageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName         = imageUrl.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        localPath         = photoURL.appendingPathComponent(imageName!)
        let image             = info[UIImagePickerControllerOriginalImage]as! UIImage
        let data              = UIImagePNGRepresentation(image)
        
        do
        {
            try data?.write(to: localPath!, options: Data.WritingOptions.atomic)
        }
        catch
        {
            // Catch exception here and act accordingly
        }
        
        self.mediaFileNameLabel.text = imageUrl.lastPathComponent
        self.dismiss(animated: true, completion: nil);
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate=self
        
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
        var parameters: [String: Any] = [:]
       
        if taskEditMode == true {
            let task = self.taskList[taskListIndex]

            urlString = urlString + "/edit"
            parameters = [
                "_id" : task.id,
                "message" : detailInput
                //"mediaFile" : localPath
            ]
        } else {
            urlString = urlString + "/write"
            parameters = [
                "fromUser" : "1@1.com",
                "nickName" : titleInput,
                "phoneNo" : "01000001112",
                "message" : detailInput
                //"mediaFile" : localPath
            ]
        }
        
        /*
        var parametersFile: [String: Any] = [:]
        if self.localPath != nil {
            parametersFile = [
                "mediaFile" : localPath
            ]
        }
        */
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if self.localPath != nil {
                multipartFormData.append(self.localPath, withName: "mediaFile")
            }
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: urlString, method:.post, encodingCompletion: { (result) in
            switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("Task 등록 완료 \(response)")
                        self.titleInput.resignFirstResponder() //키보드 숨기기
                        let newTask = Task(title: titleInput, detail: detailInput, isDone: false)
                        self.didAddTask?(newTask)
                        NotificationCenter.default.post(name: .taskDidAdd, object: self, userInfo: ["task": newTask])
                        self.dismiss(animated: true, completion: nil)
                }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
   
        
        /*
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.imageUrl as URL, withName: "mediaFile")
                //for (key, value) in parameters {
                    //multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                //}
            },
            to: urlString,
            method:.post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        */
        
        /*
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(self.imageUrl as URL, withName: "mediaFile")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to:"http://sample.com/upload_img.php")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                
                upload.responseJSON { response in
                    //print response.result
                }
                
            case .failure():
                //print encodingError.description
            }
        }
        */
        
        /*
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
        */
        
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


