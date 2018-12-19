//
//  OnboardingPageViewController.swift
//  Pwned
//
//  Created by Kevin on 10/27/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OnboardingPageViewController: UIPageViewController, ViewModelBased {
    typealias ViewModelType = OnboardingViewModel
    var viewModel: OnboardingViewModel!

    var vcs: [UIViewController] = []
    private var skipButton = UIButton(type: UIButton.ButtonType.system)
    private var nextButton = UIButton(type: UIButton.ButtonType.system)
    private let disposeBag = DisposeBag()

    private func setupSkipButton() {
        let title = NSLocalizedString("Skip", comment: "Title for skip button.")
        skipButton.setTitle(title, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        skipButton.setTitleColor(.flatSkyBlueDark, for: .normal)
        skipButton.sizeToFit()
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipButton)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            skipButton.rightAnchor.constraint(equalTo: margins.rightAnchor,
                                              constant: -20),
            skipButton.topAnchor.constraint(equalTo: margins.topAnchor,
                                            constant: 20)
            ])
    }

    private func setupNextButton() {
        let title = NSLocalizedString("Continue", comment: "Title for continue button.")
        nextButton.setTitle(title, for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 5
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        nextButton.backgroundColor = UIColor.flatSkyBlueDark
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor,
                                            constant: -50),
            nextButton.widthAnchor.constraint(lessThanOrEqualTo: margins.widthAnchor,
                                              constant: -40),
            nextButton.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
            nextButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 240)
            ])
    }

    private func bindViewModel() {
        // Outputs
        skipButton.rx
            .tap
            .throttle(1.0, scheduler: MainScheduler.instance)
            .bind(to: viewModel.skipTrigger)
            .disposed(by: disposeBag)

        nextButton.rx
            .tap
            .throttle(1.0, scheduler: MainScheduler.instance)
            .map { [weak self] _ in self?.nextIndex }
            .bind(to: viewModel.nextTrigger)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        dataSource = self
        view.backgroundColor = UIColor(displayP3Red: 66/255,
                                       green: 66/255,
                                       blue: 66/255,
                                       alpha: 1)
        setupSkipButton()
        setupNextButton()
        bindViewModel()
    }

    private var currentIndex: Int {
        guard let controller = (viewControllers ?? []).first,
            let index = vcs.firstIndex(of: controller) else { return 0 }
        return index
    }

    private var nextIndex: Int? {
        let next = currentIndex + 1
        guard next < vcs.count else { return nil }
        return next
    }

    func move(to page: Int) {
        guard 0 ..< vcs.count ~= page else { return }
        setViewControllers([vcs[page]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = vcs.firstIndex(of: viewController),
            index > 0 else { return nil }
        return vcs[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = vcs.firstIndex(of: viewController),
            index < vcs.count - 1 else { return nil }
        return vcs[index + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return vcs.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}
