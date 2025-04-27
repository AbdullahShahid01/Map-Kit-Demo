//
//  AddGeoFencePopup.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 27/04/2025.
//

import UIKit
import HGCircularSlider
import Anchorage

final class AddGeoFencePopup: UIViewController {
    private let mainStackView = UIStackView()
    private let circularSlider = CircularSlider()
    private let sliderValueLabel = UILabel()
    
    private let viewModel = AddGeoFencePopupViewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        configureBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input(.viewDidLoad)
    }
    
    private func configureBindings() {
        viewModel.output = { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .configureUI:
                strongSelf.configureUI()
            }
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        let mainView = UIView()
        mainView.backgroundColor = .systemBackground
        mainView.layer.cornerRadius = 16
        view.addSubview(mainView)
        mainView.horizontalAnchors == view.safeAreaLayoutGuide.horizontalAnchors + 16
        mainView.centerYAnchor == view.safeAreaLayoutGuide.centerYAnchor
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        
        mainView.addSubview(mainStackView)
        mainStackView.edgeAnchors == mainView.edgeAnchors + 32
        
        configureNameLabel()
        configureLongitudeLabel()
        configureLatitudeLabel()
        configureCircularSlider()
        configureNoteTextField()
        configureButtonsStack()
    }
    
    private func configureNameLabel() {
        let nameLabel = UILabel()
        nameLabel.textColor = .label
        nameLabel.font = .systemFont(ofSize: 17, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.text = viewModel.nameLabelValue
        mainStackView.addArrangedSubview(nameLabel)
    }
    
    private func configureLongitudeLabel() {
        let longitudeLabel = UILabel()
        longitudeLabel.textColor = .label
        longitudeLabel.font = .systemFont(ofSize: 17, weight: .medium)
        longitudeLabel.textAlignment = .center
        longitudeLabel.text = viewModel.longitudeLabelValue
        mainStackView.addArrangedSubview(longitudeLabel)
    }
    
    private func configureLatitudeLabel() {
        let latitudeLabel = UILabel()
        latitudeLabel.textColor = .label
        latitudeLabel.font = .systemFont(ofSize: 17, weight: .medium)
        latitudeLabel.textAlignment = .center
        latitudeLabel.text = viewModel.latitudeLabelValue
        mainStackView.addArrangedSubview(latitudeLabel)
    }
    
    private func configureCircularSlider() {
        circularSlider.minimumValue = 100
        circularSlider.maximumValue = 1000
        circularSlider.numberOfRounds = 1
        circularSlider.diskColor = .clear
        circularSlider.trackFillColor = .darkGray
        circularSlider.trackColor = .lightGray
        circularSlider.endThumbTintColor = .systemBlue
        circularSlider.endThumbStrokeColor = .clear
        circularSlider.endThumbStrokeHighlightedColor = .clear
        circularSlider.stopThumbAtMinMax = true
        circularSlider.thumbRadius = 10
        circularSlider.backgroundColor = .clear
        circularSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        circularSlider.sizeAnchors == CGSize(width: 150, height: 150)
        
        configureSliderValueLabel()
        
        mainStackView.addArrangedSubview(circularSlider)
    }
    
    private func configureSliderValueLabel() {
        let valuesStack = UIStackView()
        valuesStack.axis = .vertical
        valuesStack.alignment = .center
        valuesStack.spacing = 4
        circularSlider.addSubview(valuesStack)
        valuesStack.edgeAnchors >= circularSlider.edgeAnchors + 8
        valuesStack.centerAnchors == circularSlider.centerAnchors
        
        
        sliderValueLabel.textColor = .label
        sliderValueLabel.font = .systemFont(ofSize: 17, weight: .medium)
        sliderValueLabel.textAlignment = .center
        sliderValueLabel.text = "\(Int(circularSlider.endPointValue))"
        valuesStack.addArrangedSubview(sliderValueLabel)
        
        let sliderRangeLabel = UILabel()
        sliderRangeLabel.textColor = .secondaryLabel
        sliderRangeLabel.font = .systemFont(ofSize: 15, weight: .medium)
        sliderRangeLabel.textAlignment = .center
        sliderRangeLabel.text = "100-1000"
        valuesStack.addArrangedSubview(sliderRangeLabel)
    }
    
    private func configureNoteTextField() {
        let noteTextField = UITextField()
        noteTextField.placeholder = "Enter Note..."
        noteTextField.font = .systemFont(ofSize: 17)
        noteTextField.returnKeyType = .done
        noteTextField.delegate = self
        let textFieldView = UIView()
        textFieldView.layer.borderColor = UIColor.gray.cgColor
        textFieldView.layer.borderWidth = 1
        textFieldView.layer.cornerRadius = 4
        
        textFieldView.addSubview(noteTextField)
        noteTextField.horizontalAnchors == textFieldView.horizontalAnchors + 16
        noteTextField.verticalAnchors == textFieldView.verticalAnchors + 8
        
        mainStackView.addArrangedSubview(textFieldView)
        mainStackView.setCustomSpacing(16, after: textFieldView)
    }
    
    private func configureButtonsStack() {
        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.alignment = .center
        buttonsStack.spacing = 24
        buttonsStack.heightAnchor == 36
        
        mainStackView.addArrangedSubview(buttonsStack)
        
        
        buttonsStack.addArrangedSubview(UIView())
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        buttonsStack.addArrangedSubview(cancelButton)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 4
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        buttonsStack.addArrangedSubview(saveButton)
        
        
        
        buttonsStack.addArrangedSubview(UIView())
    }
    
    @objc
    private func sliderValueChanged() {
        sliderValueLabel.text = "\(Int(circularSlider.endPointValue))"
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func saveButtonTapped() {
        dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddGeoFencePopup: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
