//
//  CurrencyExchangeViewController.swift
//  CurrenciesConverter
//
//  Created by Анастасия Кутняхова on 30.03.2024.
//

import UIKit

class CurrencyExchangeViewController: UIViewController {
    private enum Currency: String {
        case czk = "CZK"
        case eur = "EUR"
        case usd = "USD"
    }

    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var convertButtonLabel: UIButton!
    @IBOutlet var spinnerLabel: UIActivityIndicatorView!

    private var initialCurrency: Currency = .czk
    private var targetCurrency: Currency = .czk

    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerLabel.isHidden = true
    }

    @IBAction func initialCurrenciesStack(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            initialCurrency = .eur
        case 2:
            initialCurrency = .usd
        default:
            initialCurrency = .czk
        }
    }

    @IBAction func targetCurrenciesStack(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            targetCurrency = .eur
        case 2:
            targetCurrency = .usd
        default:
            targetCurrency = .czk
        }
    }

    @IBAction func convertButtonAction(_ sender: Any) {
        guard initialCurrency != targetCurrency else {
            resultLabel.text = "Please choose diffrient currencies"
            return
        }
        guard let value = valueTextField.text else {
            resultLabel.text = "Please enter the value"
            return
        }
        NetworkManager.shared.exchange(
            request: ExchangeCurrencyRequest(
                initialCurrency: initialCurrency.rawValue,
                targetCurrency: targetCurrency.rawValue,
                value: value
            ),
            completion: { [weak self] state in
                self?.handleNetworkState(from: state)
            }
        )
    }
}

// MARK: - HandleNetworkState
private extension CurrencyExchangeViewController {
    func handleNetworkState(from state: NetworkManager.State) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .success(let currency):
                self?.stopLoading()
                self?.resultLabel.text = [
                    "Result:",
                    String(format: "%.2f", currency)
                ].joined(separator: " ")
            case .loading:
                self?.startLoading()
            case .error(let error):
                self?.stopLoading()
                self?.handleNetworkError(from: error)
            }
        }
    }
    
    func handleNetworkError(from error: NetworkManager.Error) {
        switch error {
        case .invalidData:
            resultLabel.text = "invalidData"
        case .invalidJSONDecode:
            resultLabel.text = "invalidJSONDecode"
        case .invalidResponse:
            resultLabel.text = "invalidResponse"
        case .invalidURL:
            resultLabel.text = "invalidURL"
        }
    }
}

// MARK: - HandleLoadingState
private extension CurrencyExchangeViewController {
    func startLoading() {
        convertButtonLabel.isHidden = true
        spinnerLabel.isHidden = false
        spinnerLabel.startAnimating()
    }

    func stopLoading() {
        spinnerLabel.stopAnimating()
        spinnerLabel.isHidden = true
        convertButtonLabel.isHidden = false
    }
}
