//
//  ReviewViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// The `ReviewViewController` offers an interface to review the image after it
/// has been cropped and deskewed according to the passed in quadrilateral.
final class ReviewViewController: UIViewController {

    private var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)
    private var enhancedImageIsAvailable = false
    private var isCurrentlyDisplayingEnhancedImage = false

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = results.croppedScan.image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var enhanceButton: UIBarButtonItem = {
        let image = UIImage(
            systemName: "wand.and.rays.inverse",
            named: "enhance",
            in: Bundle(for: ScannerViewController.self),
            compatibleWith: nil
        )
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleEnhancedImage))
        button.tintColor = .white
        return button
    }()
        private lazy var cancelButton: UIButton = {
            let button = UIButton()
            button.frame.size.height = 100 ;
            button.setTitle(NSLocalizedString("wescan.scanning.cancel", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Cancel", comment: "The cancel button"), for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
            button.backgroundColor = UIColor(hexString: "#CF6F64")
            button.layer.cornerRadius = 0.0
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(cancelButtonTapped) ,for: .touchUpInside)

            return button
        }()
    private lazy var rotateButton: UIBarButtonItem = {
        let image = UIImage(systemName: "rotate.right", named: "rotate", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rotateImage))
        button.tintColor = .white
        return button
    }()

    private lazy var doneButton: UIButton = {
        let title = NSLocalizedString("wescan.edit.button.next",
                                      tableName: nil,
                                      bundle: Bundle(for: EditScanViewController.self),
                                      value: "OK",
                                      comment: "A generic next button"
        )
        let button = UIButton()
        button.frame.size.height = 100 ;
        button.setTitle(title, for: .normal) ;
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        button.backgroundColor = UIColor(hexString: "#58589D")
        button.layer.cornerRadius = 0.0
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
       button.addTarget(self, action: #selector(finishScan), for: .touchUpInside)
        return button
    }()
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)

    }
    private let results: ImageScannerResults

    // MARK: - Life Cycle

    init(results: ImageScannerResults) {
        self.results = results
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        enhancedImageIsAvailable = results.enhancedScan != nil

        setupViews()
       // setupToolbar()
        setupConstraints()

        title = NSLocalizedString("wescan.review.title",
                                  tableName: nil,
                                  bundle: Bundle(for: ReviewViewController.self),
                                  value: "Review",
                                  comment: "The review title of the ReviewController"
        )
       // navigationItem.rightBarButtonItem = doneButton
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We only show the toolbar (with the enhance button) if the enhanced image is available.
//        if enhancedImageIsAvailable {
//            navigationController?.setToolbarHidden(false, animated: true)
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: Setups

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        let stackView = UIStackView(arrangedSubviews: [cancelButton,doneButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        // Add the stack view to your view hierarchy
        view.addSubview(stackView)
    
        // Set constraints for the stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            stackView.heightAnchor.constraint(equalToConstant: 80),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),
            doneButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }

    private func setupToolbar() {
        guard enhancedImageIsAvailable else { return }

        navigationController?.toolbar.barStyle = .blackTranslucent

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [fixedSpace, enhanceButton, flexibleSpace, rotateButton, fixedSpace]
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        var imageViewConstraints: [NSLayoutConstraint] = []
        if #available(iOS 11.0, *) {
            imageViewConstraints = [
                view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.topAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.bottomAnchor),
                view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.leadingAnchor)
            ]
        } else {
            imageViewConstraints = [
                view.topAnchor.constraint(equalTo: imageView.topAnchor),
                view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
            ]
        }

        NSLayoutConstraint.activate(imageViewConstraints)
    }

    // MARK: - Actions

    @objc private func reloadImage() {
        if enhancedImageIsAvailable, isCurrentlyDisplayingEnhancedImage {
            imageView.image = results.enhancedScan?.image.rotated(by: rotationAngle) ?? results.enhancedScan?.image
        } else {
            imageView.image = results.croppedScan.image.rotated(by: rotationAngle) ?? results.croppedScan.image
        }
    }

    @objc func toggleEnhancedImage() {
        guard enhancedImageIsAvailable else { return }

        isCurrentlyDisplayingEnhancedImage.toggle()
        reloadImage()

        if isCurrentlyDisplayingEnhancedImage {
            enhanceButton.tintColor = .yellow
        } else {
            enhanceButton.tintColor = .white
        }
    }

    @objc func rotateImage() {
        rotationAngle.value += 90

        if rotationAngle.value == 360 {
            rotationAngle.value = 0
        }

        reloadImage()
    }

    @objc private func finishScan() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }

        var newResults = results
        newResults.croppedScan.rotate(by: rotationAngle)
        newResults.enhancedScan?.rotate(by: rotationAngle)
        newResults.doesUserPreferEnhancedScan = isCurrentlyDisplayingEnhancedImage
        imageScannerController.imageScannerDelegate?
            .imageScannerController(imageScannerController, didFinishScanningWithResults: newResults)
    }

}
