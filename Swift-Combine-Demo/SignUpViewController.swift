//
//  SignUpViewController.swift
//  Combine Demo
//
//  Created by Yvan Feng on 2021/6/20.
//


//API验证username没有重复
//两次密码一样
//密码大于8位
//以上3个条件都成立，创建按钮可以点击，否则不可点击


import UIKit
import Combine

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordAgain: String = ""
    
    private var signupButtonStream: AnyCancellable?

    //验证用户名
    var validateUsername: AnyPublisher<String?, Never> {
        return $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { username in
                //Future是一个Publisher
                return Future { [self] promise in
                    usernameAvailable(username) { available in
                        promise(.success(available ? username : "nil"))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    //验证密码
    private var validatedPassowrd: AnyPublisher<String?, Never> {
      return Publishers.CombineLatest($password, $passwordAgain)
        .map { password, passwordAgain in
            print(password)
            guard password == passwordAgain && password.count > 8 else { return nil }
            return password
        }
        .eraseToAnyPublisher()
    }
   
    //最终验证
    var validatedCredentials: AnyPublisher<(String, String)?,Never> {
          // 合并检验密码和检验用户名发布者，均有合理值时发送
        return Publishers.CombineLatest(validateUsername, validatedPassowrd)
            .map { username, password in
            print("validatedEMail: \(username ?? "not set"), validatedPassword: \(password ?? "not set")")
            //guard 如何拦截?
            guard username != nil, let a = username, let b = password else {
                return nil
            }
            return (a, b)
        }
        .eraseToAnyPublisher()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 检查是否有合理的值
        signupButtonStream = validatedCredentials
                                .map({ (result) -> Bool in
                                    print("结果：\(String(describing: result))") //Optional(("nil", "123123123"))
                                    return result != nil
                                })
                                .receive(on: RunLoop.main)
                                .assign(to: \.isEnabled, on: signupButton)
    }
    
    
    // 提交给服务器判断用户名是否合法
    func usernameAvailable(_ username:String, completion:((Bool) -> ())) {
        let isValidEMailAddress: Bool = NSPredicate(format:"SELF MATCHES %@", "^[A-Za-z0-9.~!#$%-_+=&]+@([A-Za-z0-9_-]+\\.)+[A-Za-z]{2,18}$").evaluate(with: username)
        print("是否有效 \(isValidEMailAddress)")
        completion(isValidEMailAddress)
    }
    
    //用户名
    @IBAction func usernameChanged(_ sender: UITextField) {
        username = sender.text ?? ""
    }
    //输入密码
    @IBAction func passwordChanged(_ sender: UITextField) {
        password = sender.text ?? ""
        print("密码是：\(password)")
    }
    //再次输入密码
    @IBAction func passwordAgainChanged(_ sender: UITextField) {
        passwordAgain = sender.text ?? ""
        print("密码是：\(passwordAgain)")
    }

}

/**
 
 func test() {
     let _ = Just(1).map { (i) -> String in
         return "操作者转变-\(i*10)"
     }.sink { (rec) in
         print("最终接收到到的值：\(rec)")
     }
     
     _ = PassthroughSubject<String, Never>()
         .flatMap { name in
             return Future<String, Error> { promise in
                 promise(.success(""))
             }.catch { _ in
                 Just("No user found")
             }.map { result in
                 return "\(result) foo"
             }
         }
 }
 
 */
