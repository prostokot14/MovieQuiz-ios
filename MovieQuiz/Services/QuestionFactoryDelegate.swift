//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Антон Кашников on 23.03.2023.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
