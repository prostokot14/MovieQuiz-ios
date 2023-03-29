//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Антон Кашников on 23.03.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    func show(alertModel: AlertModel) {
        let alertController = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }

        alertController.addAction(action)

        viewController?.present(alertController, animated: true)
    }
}
