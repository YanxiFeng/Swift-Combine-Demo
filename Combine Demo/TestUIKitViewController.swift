//
//  TestUIKitViewController.swift
//  Combine Demo
//
//  Created by Yvan Feng on 2021/6/20.
//

import UIKit
import Combine

extension String {
    //是否为空
    var isBlank: Bool {
        return allSatisfy { element in
            return element.isWhitespace
        }
    }
}

class TestUIKitViewController: UIViewController {

    @IBOutlet private weak var acceptTermsSwitch: UISwitch!
    @IBOutlet weak var acceptPrivateSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    
    @Published private var acceptedTerms: Bool = false
    @Published private var acceptedPrivacy: Bool = false
    @Published private var name: String = ""

    private var stream: AnyCancellable?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        stream = validToSubmit
              .receive(on: RunLoop.main)
              .assign(to: \.isEnabled, on: submitButton)
    }

    @IBAction func didSwitch(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }

    @IBAction func privateDidSwitch(_ sender: UISwitch) {
        acceptedPrivacy = sender.isOn
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        name = sender.text ?? ""
    }
    
    @IBAction func submitTap(_ sender: UIButton) {
        print("Submit... \(name)")
    }
    
    private var validToSubmit: AnyPublisher<Bool, Never> {
      return Publishers.CombineLatest3($acceptedTerms, $acceptedPrivacy, $name)
        .map { terms, privacy, name in
          terms && privacy && !name.isBlank
        }
        .eraseToAnyPublisher()
    }
}
