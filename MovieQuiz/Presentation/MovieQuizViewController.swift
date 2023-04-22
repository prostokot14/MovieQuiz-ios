import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet var noButton: UIButton!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alertModel = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self else {
                return
            }
            self.presenter.restartGame()
        }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else {
                return
            }
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.show(alertModel: model)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
