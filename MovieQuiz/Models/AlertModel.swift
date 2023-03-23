//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Антон Кашников on 23.03.2023.
//

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
