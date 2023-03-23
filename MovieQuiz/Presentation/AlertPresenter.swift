//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Антон Кашников on 23.03.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var vc: MovieQuizViewController?
    
    init(vc: MovieQuizViewController) {
        self.vc = vc
    }
    
    func show(alertModel: AlertModel) {
        // создаём объекты всплывающего окна
        let alertController = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
//            guard let self else {
//                return
//            }
//
//            delegate.currentQuestionIndex = 0
//            delegate.correctAnswers = 0
//
//            delegate.questionFactory?.requestNextQuestion()
        }

        // добавляем в алерт кнопки
        alertController.addAction(action)

        // показываем всплывающее окно
        vc?.present(alertController, animated: true, completion: nil)
    }
}
