//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Антон Кашников on 22.04.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.viewController?.hideLoadingIndicator()
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз")
            
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        guard let bestGame = statisticService.bestGame else {
            return ""
        }
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [totalPlaysCountLine, currentGameResultLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        viewController?.yesButton.isEnabled = false
        viewController?.noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else {
                return
            }
            self.proceedToNextQuestionOrResults()
        }
        
        viewController?.yesButton.isEnabled = true
        viewController?.noButton.isEnabled = true
    }
}
